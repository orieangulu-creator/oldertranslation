/**
 * 长辈翻译 · 后端网关示例（Node 原生，无第三方依赖）
 *
 * 作用：客户端（网页/鸿蒙）只连这个网关，API 密钥保存在服务端，绝不进客户端（见 PRD 7.4）。
 * 能力：
 *   POST /translate  { text, from, to }      -> { targetText }
 *   POST /ocr        { imageBase64 }         -> { fullText, lines:[{text}] }
 *   GET  /health                              -> { status, mode }
 *
 * 模式：
 *   - 配置了 Azure 环境变量 -> 走真实云端
 *   - 未配置 -> MOCK 模式（返回演示数据），便于本地自测整条链路
 *
 * 环境变量：
 *   PORT (默认 3000)
 *   AZURE_TRANSLATOR_KEY / AZURE_TRANSLATOR_REGION
 *   AZURE_TRANSLATOR_ENDPOINT (默认 https://api.cognitive.microsofttranslator.com)
 *   AZURE_VISION_KEY / AZURE_VISION_ENDPOINT  (如 https://<resource>.cognitiveservices.azure.com)
 */
'use strict';
const http = require('http');
const https = require('https');
const { URL } = require('url');

const PORT = process.env.PORT || 3000;
const TR_KEY = process.env.AZURE_TRANSLATOR_KEY || '';
const TR_REGION = process.env.AZURE_TRANSLATOR_REGION || '';
const TR_ENDPOINT = process.env.AZURE_TRANSLATOR_ENDPOINT || 'https://api.cognitive.microsofttranslator.com';
const VISION_KEY = process.env.AZURE_VISION_KEY || '';
const VISION_ENDPOINT = process.env.AZURE_VISION_ENDPOINT || '';

const translateMode = TR_KEY ? 'azure' : 'mock';
const ocrMode = (VISION_KEY && VISION_ENDPOINT) ? 'azure' : 'mock';

/* ---------- 演示词典（MOCK） ---------- */
const DEMO_ZH2EN = {
  '洗手间在哪里': 'Where is the restroom?',
  '多少钱': 'How much is it?',
  '我要这个': 'I would like this one.',
  '谢谢': 'Thank you.',
  '请帮我叫救护车': 'Please call an ambulance.'
};
const DEMO_EN2ZH = {
  'your table will be ready in ten minutes': '您的桌子十分钟后就好。',
  'how can i help you': '请问需要什么帮助？',
  'that will be twenty five dollars': '一共二十五美元。'
};

/* ---------- HTTP 小工具 ---------- */
function readBody(req) {
  return new Promise((resolve, reject) => {
    let data = '';
    req.on('data', (c) => { data += c; if (data.length > 12 * 1024 * 1024) req.destroy(); });
    req.on('end', () => resolve(data));
    req.on('error', reject);
  });
}
function sendJson(res, code, obj) {
  const body = JSON.stringify(obj);
  res.writeHead(code, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type',
    'Access-Control-Allow-Methods': 'POST, GET, OPTIONS'
  });
  res.end(body);
}
// 向 Azure 发起请求（支持 json 或 二进制 buffer）
function request(urlStr, options, payload) {
  return new Promise((resolve, reject) => {
    const u = new URL(urlStr);
    const opt = {
      method: options.method || 'POST',
      hostname: u.hostname,
      path: u.pathname + u.search,
      headers: options.headers || {}
    };
    const r = https.request(opt, (resp) => {
      let chunks = [];
      resp.on('data', (d) => chunks.push(d));
      resp.on('end', () => resolve({ status: resp.statusCode, body: Buffer.concat(chunks).toString('utf8') }));
    });
    r.on('error', reject);
    if (payload) r.write(payload);
    r.end();
  });
}

/* ---------- 翻译 ---------- */
function norm(s) { return String(s).replace(/[，。！？,.!?\s]/g, '').toLowerCase(); }
function buildNorm(d) { const o = {}; for (const k of Object.keys(d)) o[norm(k)] = d[k]; return o; }
const DEMO_ZH2EN_N = buildNorm(DEMO_ZH2EN);
const DEMO_EN2ZH_N = buildNorm(DEMO_EN2ZH);
function mockTranslate(text, from, to) {
  const key = norm(text);
  const dict = from === 'zh' ? DEMO_ZH2EN_N : DEMO_EN2ZH_N;
  if (dict[key]) return dict[key];
  return to === 'en'
    ? `[mock] "${text}" (set AZURE_TRANSLATOR_KEY for real translation)`
    : `[mock] "${text}" 的中文译文（配置 AZURE_TRANSLATOR_KEY 后为真实译文）`;
}
async function azureTranslate(text, from, to) {
  const url = `${TR_ENDPOINT}/translate?api-version=3.0&from=${encodeURIComponent(from)}&to=${encodeURIComponent(to)}`;
  const payload = JSON.stringify([{ Text: text }]);
  const headers = {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(payload),
    'Ocp-Apim-Subscription-Key': TR_KEY
  };
  if (TR_REGION) headers['Ocp-Apim-Subscription-Region'] = TR_REGION;
  const resp = await request(url, { method: 'POST', headers }, payload);
  if (resp.status !== 200) throw new Error(`azure translate ${resp.status}: ${resp.body}`);
  const arr = JSON.parse(resp.body);
  return arr[0].translations[0].text;
}

/* ---------- OCR ---------- */
function mockOcr() {
  const lines = ['Grilled Salmon  $24.50', 'Caesar Salad  $12.00', 'Gate 31  Boarding 10:45'];
  return { fullText: lines.join('\n'), lines: lines.map((t) => ({ text: t })) };
}
async function azureOcr(imageBase64) {
  const url = `${VISION_ENDPOINT.replace(/\/$/, '')}/vision/v3.2/ocr?language=en&detectOrientation=true`;
  const buf = Buffer.from(imageBase64, 'base64');
  const headers = {
    'Content-Type': 'application/octet-stream',
    'Content-Length': buf.length,
    'Ocp-Apim-Subscription-Key': VISION_KEY
  };
  const resp = await request(url, { method: 'POST', headers }, buf);
  if (resp.status !== 200) throw new Error(`azure ocr ${resp.status}: ${resp.body}`);
  const data = JSON.parse(resp.body);
  const lines = [];
  for (const region of (data.regions || [])) {
    for (const line of (region.lines || [])) {
      lines.push({ text: (line.words || []).map((w) => w.text).join(' ') });
    }
  }
  return { fullText: lines.map((l) => l.text).join('\n'), lines };
}

/* ---------- 路由 ---------- */
const server = http.createServer(async (req, res) => {
  if (req.method === 'OPTIONS') return sendJson(res, 204, {});

  if (req.method === 'GET' && req.url === '/health') {
    return sendJson(res, 200, { status: 'ok', mode: { translate: translateMode, ocr: ocrMode } });
  }

  if (req.method === 'POST' && req.url === '/translate') {
    try {
      const { text, from, to } = JSON.parse(await readBody(req) || '{}');
      if (!text) return sendJson(res, 400, { error: 'text required' });
      const targetText = translateMode === 'azure'
        ? await azureTranslate(text, from || 'auto', to || 'zh')
        : mockTranslate(text, from || 'zh', to || 'en');
      return sendJson(res, 200, { targetText });
    } catch (e) {
      return sendJson(res, 502, { error: String(e.message || e) });
    }
  }

  if (req.method === 'POST' && req.url === '/ocr') {
    try {
      const { imageBase64 } = JSON.parse(await readBody(req) || '{}');
      const result = ocrMode === 'azure' ? await azureOcr(imageBase64 || '') : mockOcr();
      return sendJson(res, 200, result);
    } catch (e) {
      return sendJson(res, 502, { error: String(e.message || e) });
    }
  }

  sendJson(res, 404, { error: 'not found' });
});

server.listen(PORT, () => {
  console.log(`gateway listening on :${PORT}  (translate=${translateMode}, ocr=${ocrMode})`);
});
