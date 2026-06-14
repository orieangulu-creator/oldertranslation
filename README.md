# 长辈翻译（oldertranslation）

给 **60 岁以上、戴老花镜、完全不懂英文的长辈**，在夏威夷旅游时使用的傻瓜级中英翻译 App。
首页只有 3 个超大按钮 —— **听 / 说 / 拍**，外加一个红色**应急求助**（离线可用）。

| 功能 | 说明 |
|---|---|
| 🟢 听 | 听别人说英文 → 大字中文 + 自动朗读 |
| 🔵 说 | 我说中文 → 英文（朗读 + 可全屏给老外看）|
| 🟠 拍 | 拍英文照片 → 识别 → 整段大字中文 |
| 🔴 应急 | 离线预置应急用语 + 一键拨打家人电话 |

## 平台与技术

- **HarmonyOS（鸿蒙）**，ArkTS + ArkUI（Stage 模型），兼容设计便于移植 Android。
- 翻译/语音/OCR 走**纯云端 API**（统一经自建后端网关，密钥不入客户端）。
- **应急用语包离线可用**：中→英译文本地预置 + 系统离线 TTS 朗读，断网也能救急。

## 工程结构

```
AppScope/                         应用级配置（app.json5、应用名）
entry/src/main/
├── module.json5                  模块/权限声明（网络、麦克风、相机、拨号）
├── ets/
│   ├── entryability/             应用入口 UIAbility
│   ├── pages/                    Index(首页)/Listen/Speak/Photo/Emergency
│   ├── common/                   Theme(适老化规范)、Config(网关地址)
│   ├── data/EmergencyPhrases.ets 离线应急用语 + 家人联系人
│   └── services/                 能力服务层（接口 + 云端/系统实现 + 工厂）
└── resources/                    字符串/颜色/页面表/媒体
docs/产品计划.md                   完整 PRD
.claude/agents/                   两个测试子 Agent 定义
tests/                            测试用例、翻译语料、校对报告
```

## 运行前需要做的事

1. 用 **DevEco Studio**（API 11/12，HarmonyOS 5.0）打开本工程。
2. 补齐图标资源：见 `entry/src/main/resources/base/media/README.md`。
3. 部署后端网关并把地址填到 `entry/src/main/ets/common/Config.ets` 的 `gatewayBase`
   （网关内部对接 Azure Translator / Speech / Vision OCR 等，详见 PRD 第 7 节）。
4. 子女填写家人紧急联系人：`entry/src/main/ets/data/EmergencyPhrases.ets` 中的
   `EmergencyContact.name` 与 `EmergencyContact.phone`。

> 说明：当前为**可在 DevEco 打开、结构完整的工程骨架**。云端 ASR/OCR 的音频采集与图片读取
> 以 `TODO` 标注（已留好接入位置）；应急用语与朗读已可离线工作。

## 相关文档
- 产品计划（PRD）：`docs/产品计划.md`
- 测试与校对报告：`tests/`
