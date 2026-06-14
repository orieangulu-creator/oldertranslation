import { IAsrService, IOcrService, ITranslateService, ITtsService } from './Types';
import { CloudTranslateService } from './impl/CloudTranslateService';
import { CloudOcrService } from './impl/CloudOcrService';
import { SystemAsrService } from './impl/SystemAsrService';
import { SystemTtsService } from './impl/SystemTtsService';

/**
 * 能力服务工厂：页面只依赖这里拿实现，方便整体替换厂商/做 Mock 测试。
 */
export class ServiceProvider {
  private static translateInst: ITranslateService = new CloudTranslateService();
  private static ttsInst: ITtsService = new SystemTtsService();
  private static ocrInst: IOcrService = new CloudOcrService();

  static translate(): ITranslateService {
    return ServiceProvider.translateInst;
  }

  static tts(): ITtsService {
    return ServiceProvider.ttsInst;
  }

  static ocr(): IOcrService {
    return ServiceProvider.ocrInst;
  }

  /** ASR 每次新建会话，避免状态残留。 */
  static newAsr(): IAsrService {
    return new SystemAsrService();
  }
}
