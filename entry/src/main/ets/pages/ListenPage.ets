import { router } from '@kit.ArkUI';
import { Colors, Sizes } from '../common/Theme';
import { ServiceProvider } from '../services/ServiceProvider';
import { IAsrService, Lang } from '../services/Types';

/** 听：英文语音 → 大字中文（自动朗读）。 */
@Entry
@Component
struct ListenPage {
  @State isListening: boolean = false;
  @State enText: string = '';      // 英文转写（参考小字）
  @State zhResult: string = '';    // 中文结果（超大）
  @State enlarged: boolean = false;
  @State hint: string = '请把手机靠近对方，点下面的大圆钮开始听';
  private asr: IAsrService | null = null;

  async startListen(): Promise<void> {
    this.isListening = true;
    this.zhResult = '';
    this.enText = '';
    this.hint = '正在听…';
    this.asr = ServiceProvider.newAsr();
    await this.asr.start(
      Lang.EN,
      (partial: string): void => { this.enText = partial; },
      (final: string): void => { this.onHeard(final); },
      (_msg: string): void => { this.onError(); }
    );
  }

  async onHeard(en: string): Promise<void> {
    this.isListening = false;
    if (this.asr) { await this.asr.stop(); }
    if (!en) { this.onError(); return; }
    this.enText = en;
    try {
      const res = await ServiceProvider.translate().translate(en, Lang.EN, Lang.ZH);
      this.zhResult = res.targetText;
      this.hint = '';
      await ServiceProvider.tts().speak(this.zhResult, Lang.ZH);
    } catch (e) {
      this.onError();
    }
  }

  onError(): void {
    this.isListening = false;
    this.hint = '没听清，请再说一次';
  }

  build() {
    Column({ space: Sizes.gap }) {
      Button('⬅ 返回首页')
        .fontSize(Sizes.button).fontColor(Colors.onColor).backgroundColor(Colors.listen)
        .height(Sizes.actionButtonHeight).width('100%')
        .onClick(() => router.back())

      if (this.hint) {
        Text(this.hint).fontSize(Sizes.hint).fontColor(Colors.textSub).textAlign(TextAlign.Center)
      }

      // 中文结果（超大）
      if (this.zhResult) {
        Scroll() {
          Text(this.zhResult)
            .fontSize(this.enlarged ? Sizes.resultBig : Sizes.result)
            .fontWeight(FontWeight.Bold).fontColor(Colors.textMain)
        }.layoutWeight(1).width('100%')
        if (this.enText) {
          Text(this.enText).fontSize(Sizes.small).fontColor(Colors.textSub)
        }
      } else {
        Blank()
      }

      // 中央录音圆钮
      Button(this.isListening ? '正在听…' : '🎤 开始听')
        .width(Sizes.micButton).height(Sizes.micButton).borderRadius(Sizes.micButton / 2)
        .fontSize(Sizes.button).fontColor(Colors.onColor)
        .backgroundColor(this.isListening ? Colors.emergency : Colors.listen)
        .onClick(() => { if (!this.isListening) { this.startListen(); } })

      Row({ space: Sizes.gap }) {
        Button('🔁 再听一句').layoutWeight(1).height(Sizes.actionButtonHeight)
          .fontSize(Sizes.button).backgroundColor(Colors.listen).fontColor(Colors.onColor)
          .onClick(() => this.startListen())
        Button(this.enlarged ? '缩小' : '放大').layoutWeight(1).height(Sizes.actionButtonHeight)
          .fontSize(Sizes.button).backgroundColor(Colors.card).fontColor(Colors.textMain)
          .onClick(() => { this.enlarged = !this.enlarged; })
      }
    }
    .width('100%').height('100%').padding(Sizes.pagePadding).backgroundColor(Colors.bg)
  }
}
