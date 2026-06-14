import { textToSpeech } from '@kit.CoreSpeechKit';
import { ITtsService, Lang } from '../Types';

/**
 * 系统语音合成实现（@kit.CoreSpeechKit）。
 * 系统引擎支持离线朗读，因此【离线应急用语】也能念给老外听。
 * 语速默认偏慢（老人/嘈杂环境更清楚）。
 */
export class SystemTtsService implements ITtsService {
  private engine: textToSpeech.TextToSpeechEngine | null = null;

  private async ensureEngine(lang: Lang): Promise<textToSpeech.TextToSpeechEngine> {
    const createParams: textToSpeech.CreateEngineParams = {
      language: lang === Lang.ZH ? 'zh-CN' : 'en-US',
      person: 0,
      online: 1 // 1=优先离线引擎可用即用
    };
    this.engine = await textToSpeech.createEngine(createParams);
    return this.engine;
  }

  async speak(text: string, lang: Lang): Promise<void> {
    const engine: textToSpeech.TextToSpeechEngine = await this.ensureEngine(lang);
    const speakParams: textToSpeech.SpeakParams = {
      requestId: `tts_${Date.now()}`,
      extraParams: {
        speed: 0.9,   // 略慢
        volume: 1.0,
        pitch: 1.0
      }
    };
    engine.speak(text, speakParams);
  }

  async stop(): Promise<void> {
    if (this.engine) {
      this.engine.stop();
    }
  }
}
