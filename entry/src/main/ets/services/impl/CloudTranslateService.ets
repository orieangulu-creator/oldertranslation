import { http } from '@kit.NetworkKit';
import { AppConfig } from '../../common/Config';
import { ITranslateService, Lang, TranslateResult } from '../Types';

interface TranslateReq {
  text: string;
  from: string;
  to: string;
}

interface TranslateResp {
  targetText: string;
}

/**
 * 云端翻译实现：POST {gateway}/translate（网关内部对接 Azure Translator 等）。
 */
export class CloudTranslateService implements ITranslateService {
  async translate(text: string, from: Lang, to: Lang): Promise<TranslateResult> {
    const req: http.HttpRequest = http.createHttp();
    try {
      const body: TranslateReq = { text: text, from: from, to: to };
      const resp: http.HttpResponse = await req.request(
        `${AppConfig.gatewayBase}/translate`,
        {
          method: http.RequestMethod.POST,
          header: { 'Content-Type': 'application/json' },
          extraData: JSON.stringify(body),
          connectTimeout: AppConfig.httpTimeoutMs,
          readTimeout: AppConfig.httpTimeoutMs
        }
      );
      if (resp.responseCode !== 200) {
        throw new Error(`translate http ${resp.responseCode}`);
      }
      const parsed: TranslateResp = JSON.parse(resp.result as string) as TranslateResp;
      return { sourceText: text, targetText: parsed.targetText };
    } finally {
      req.destroy();
    }
  }
}
