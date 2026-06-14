import { http } from '@kit.NetworkKit';
import { AppConfig } from '../../common/Config';
import { IOcrService, OcrLine, OcrResult } from '../Types';

interface OcrReq {
  imageBase64: string;
}

interface OcrRespLine {
  text: string;
}

interface OcrResp {
  fullText: string;
  lines: OcrRespLine[];
}

/**
 * 云端 OCR 实现：POST {gateway}/ocr（网关内部对接 Azure Vision OCR 等）。
 * 入参 imageUri 已是可读的本地缓存文件；此处省略读文件转 base64 的细节（见 TODO）。
 */
export class CloudOcrService implements IOcrService {
  async recognize(imageUri: string): Promise<OcrResult> {
    const req: http.HttpRequest = http.createHttp();
    try {
      // TODO: 读取 imageUri 文件 -> base64（fileIo + util.Base64Helper），并按需压缩
      const imageBase64: string = await this.readAsBase64(imageUri);
      const body: OcrReq = { imageBase64: imageBase64 };
      const resp: http.HttpResponse = await req.request(
        `${AppConfig.gatewayBase}/ocr`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(body),
          connectTimeout: AppConfig.httpTimeoutMs,
          readTimeout: AppConfig.httpTimeoutMs
        }
      );
      if (resp.responseCode !== 200) {
        throw new Error(`ocr http ${resp.responseCode}`);
      }
      const parsed: OcrResp = JSON.parse(resp.result as string) as OcrResp;
      const lines: OcrLine[] = parsed.lines.map((l: OcrRespLine): OcrLine => ({ text: l.text }));
      return { fullText: parsed.fullText, lines: lines };
    } finally {
      req.destroy();
    }
  }

  private async readAsBase64(imageUri: string): Promise<string> {
    // 占位：实际用 @kit.CoreFileKit 读取并 base64 编码
    return '';
  }
}
