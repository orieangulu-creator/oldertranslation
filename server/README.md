# 长辈翻译 · 后端网关

客户端（网页/鸿蒙）只连这个网关，**API 密钥保存在服务端，绝不进客户端**（见 PRD 7.4）。
零第三方依赖（Node 原生），带 **Mock 模式**，没有密钥也能跑通整条链路。

## 启动

```bash
cd server
node gateway.js          # 默认 :3000，未配密钥则为 Mock 模式
PORT=3000 node gateway.js
```

## 接口
| 方法 | 路径 | 入参 | 返回 |
|---|---|---|---|
| GET | `/health` | — | `{ status, mode:{translate, ocr} }` |
| POST | `/translate` | `{ text, from, to }` | `{ targetText }` |
| POST | `/ocr` | `{ imageBase64 }` | `{ fullText, lines:[{text}] }` |

## 配真实云端（Azure）
```bash
export AZURE_TRANSLATOR_KEY=xxx
export AZURE_TRANSLATOR_REGION=eastus
# 可选: export AZURE_TRANSLATOR_ENDPOINT=https://api.cognitive.microsofttranslator.com
export AZURE_VISION_KEY=yyy
export AZURE_VISION_ENDPOINT=https://<your-resource>.cognitiveservices.azure.com
node gateway.js          # 自动切换为 azure 模式
```
未设置对应密钥的能力会自动回退到 Mock。

## 配合网页版
```bash
# 终端1：网关
cd server && node gateway.js
# 终端2：网页
cd web && python3 -m http.server 8080
# 浏览器打开（用 query 指定网关，无需改代码）：
#   http://localhost:8080/?gateway=http://localhost:3000
```
`?gateway=` 会被记住（localStorage），之后直接开 `http://localhost:8080` 即生效。

## 快速自测
```bash
curl -s localhost:3000/health
curl -s -X POST localhost:3000/translate -H 'Content-Type: application/json' -d '{"text":"洗手间在哪里","from":"zh","to":"en"}'
curl -s -X POST localhost:3000/ocr -H 'Content-Type: application/json' -d '{"imageBase64":""}'
```
