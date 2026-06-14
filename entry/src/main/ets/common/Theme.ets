/**
 * 适老化设计统一规范（详见 docs/产品计划.md 第 6 节）。
 * 所有页面只引用这里的常量，保证大字、高对比、大按钮一致。
 */
export class Sizes {
  // 字号（fp = 跟随系统字体缩放，适老化必须用 fp）
  static readonly title: number = 30;        // 页面大标题
  static readonly hint: number = 24;          // 提示语
  static readonly button: number = 28;        // 按钮文字
  static readonly result: number = 40;        // 翻译结果（超大）
  static readonly resultBig: number = 52;     // 一键放大后的结果
  static readonly small: number = 20;         // 参考用小字（如英文原文转写）

  // 间距 / 控件尺寸（vp）
  static readonly gap: number = 16;
  static readonly pagePadding: number = 20;
  static readonly bigButtonHeight: number = 200;   // 首页大卡片
  static readonly actionButtonHeight: number = 84; // 主操作按钮
  static readonly micButton: number = 160;         // 中央录音圆钮
  static readonly radius: number = 24;
}

export class Colors {
  static readonly bg: string = '#FFFFFF';
  static readonly textMain: string = '#1A1A1A';
  static readonly textSub: string = '#5A5A5A';
  static readonly listen: string = '#1B8A3A';   // 听 绿
  static readonly speak: string = '#1361C2';    // 说 蓝
  static readonly photo: string = '#D5670B';    // 拍 橙
  static readonly emergency: string = '#C0271A'; // 应急 红
  static readonly onColor: string = '#FFFFFF';
  static readonly card: string = '#F4F6F8';
}
