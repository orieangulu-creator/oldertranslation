import { speechRecognizer } from '@kit.CoreSpeechKit';
import { IAsrService, Lang } from '../Types';

/**
 * 语音识别实现（@kit.CoreSpeechKit speechRecognizer）。
 * 支持流式：边说边回 onPartial，停顿/静音断句后回 onFinal。
 * 注：麦克风音频采集（AudioCapturer -> writeAudio）此处以 TODO 标注，
 *     接入时把采集到的 PCM 帧持续写入引擎即可。
 */
export class SystemAsrService implements IAsrService {
  private engine: speechRecognizer.SpeechRecognitionEngine | null = null;
  private readonly sessionId: string = 'asr_session';

  async start(lang: Lang,
              onPartial: (text: string) => void,
              onFinal: (text: string) => void,
              onError: (msg: string) => void): Promise<void> {
    const createParams: speechRecognizer.CreateEngineParams = {
      language: lang === Lang.ZH ? 'zh-CN' : 'en-US',
      online: 1
    };
    this.engine = await speechRecognizer.createEngine(createParams);

    const listener: speechRecognizer.RecognitionListener = {
      onStart: (_sessionId: string, _eventMessage: string): void => {},
      onEvent: (_sessionId: string, _eventCode: number, _eventMessage: string): void => {},
      onResult: (_sessionId: string, result: speechRecognizer.SpeechRecognitionResult): void => {
        if (result.isFinal) {
          onFinal(result.result);
        } else {
          onPartial(result.result);
        }
      },
      onComplete: (_sessionId: string, _eventMessage: string): void => {},
      onError: (_sessionId: string, errorCode: number, errorMessage: string): void => {
        onError(`asr ${errorCode}: ${errorMessage}`);
      }
    };
    this.engine.setListener(listener);

    const recognizerParams: speechRecognizer.StartParams = {
      sessionId: this.sessionId,
      audioInfo: { audioType: 'pcm', sampleRate: 16000, soundChannel: 1, sampleBit: 16 },
      extraParams: {
        // 静音断句：停顿约 1.5s 视为说完（适老化，无需手动精确停止）
        'vadEnd': 1500
      }
    };
    this.engine.startListening(recognizerParams);
    // TODO: 启动 AudioCapturer，将 PCM 帧通过 engine.writeAudio(sessionId, buffer) 持续写入
  }

  async stop(): Promise<void> {
    if (this.engine) {
      this.engine.finish(this.sessionId);
      this.engine.shutdown();
      this.engine = null;
    }
  }
}
