# 长辈翻译 · 网页版（可立即验证）

一个自包含的网页版（单个 `index.html`，无需构建），用来**快速验证交互与流程**，也可作为长辈用的 PWA。

## 怎么打开验证

**方式 A：直接双击 `index.html`（最快，但有限制）**
- ✅ 能用：首页、**应急用语 + 朗读**、全屏给对方看、放大字、拨号链接。
- ⚠️ 不能用：麦克风（听/说）、相机（拍）——浏览器要求"安全环境"。

**方式 B：用 localhost 打开（推荐，全功能可试）**
```bash
cd web
python3 -m http.server 8080
# 然后浏览器打开 http://localhost:8080
```
- ✅ 这样麦克风、相机都能用（Chrome / Edge 体验最好）。
- 翻译/OCR 未配后端时走"演示词典/占位"，保证可点可看。

**方式 C：部署到 HTTPS** 即为正式可用版（手机也能用）。

## 为什么"双击打开"时相机/麦克风不行？
不是相机本身不支持网页，而是浏览器规定 `getUserMedia`（相机/麦克风）只在
**安全环境**（HTTPS 或 `localhost`）下可用；`file://` 不算安全环境。
所以**不用去掉相机**——换成 localhost / HTTPS 打开即可。

## 各功能在网页端的支持情况
| 功能 | 网页支持 | 说明 |
|---|---|---|
| 应急用语 + 朗读 | ✅ 完全离线 | 浏览器 TTS（SpeechSynthesis）|
| 拍（相机/选图） | ✅ HTTPS/localhost | `getUserMedia`；OCR 需后端 |
| 听 / 说（语音识别） | ✅ Chrome/Edge ⚠️ iOS Safari 弱 | Web Speech API 各浏览器支持不一 |
| 翻译 / OCR | 需后端网关 | 填 `index.html` 顶部 `GATEWAY_BASE` |

## 配置（可选）
- `GATEWAY_BASE`：后端网关地址（对接 Azure 翻译/OCR），留空走演示兜底。
- `CONTACT`：家人紧急联系人姓名与电话。

> 结论：**网页版可行，相机不是障碍。** 唯一对老人体验有真实影响的是
> iOS Safari 的语音识别较弱——若主打 iPhone，"听/说"建议走原生或云端流式 ASR。
