/**
 * 能力服务层 —— 接口与数据类型（与具体云厂商解耦，便于替换/移植 Android）。
 */

export enum Lang {
  ZH = 'zh',
  EN = 'en'
}

export interface TranslateResult {
  sourceText: string;
  targetText: string;
}

export interface AsrResult {
  text: string;
}

export interface OcrLine {
  text: string;
}

export interface OcrResult {
  fullText: string;   // 整段译前英文原文
  lines: OcrLine[];   // 逐行（供"对照模式"）
}

/** 文本翻译（中⇄英）。 */
export interface ITranslateService {
  translate(text: string, from: Lang, to: Lang): Promise<TranslateResult>;
}

/** 语音识别（流式：边说边出字 onPartial，停顿后 onFinal）。 */
export interface IAsrService {
  start(lang: Lang,
        onPartial: (text: string) => void,
        onFinal: (text: string) => void,
        onError: (msg: string) => void): Promise<void>;
  stop(): Promise<void>;
}

/** 语音合成（朗读结果）。优先用系统引擎，可离线朗读。 */
export interface ITtsService {
  speak(text: string, lang: Lang): Promise<void>;
  stop(): Promise<void>;
}

/** 图片文字识别（英文）。 */
export interface IOcrService {
  recognize(imageUri: string): Promise<OcrResult>;
}
