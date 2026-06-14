/**
 * 全局配置。
 * 所有云端能力统一走【自建后端网关】，API 密钥保存在服务端，绝不放客户端（见 PRD 7.4）。
 */
export class AppConfig {
  // TODO(部署): 替换为真实网关地址
  static readonly gatewayBase: string = 'https://gateway.eldertranslate.example.com';
  static readonly httpTimeoutMs: number = 8000;
}
