import { router } from '@kit.ArkUI';
import { Colors, Sizes } from '../common/Theme';
import { ServiceProvider } from '../services/ServiceProvider';
import { IAsrService, Lang } from '../services/Types';

/** 说：中文语音 → 英文（自动朗读 + 可全屏给对方看）。 */
@Entry
@Component
struct SpeakPage {
  @State isRecording: boolean = false;
  @State zhText: string = '';     // 中文原话（小字对照）
  @State enResult: string = '';   // 英文结果（超大，给老外看）
  @State showFullScreen: boolean = false;
  @State hint: string = '点下面的钮，对我说中文';
  private asr: IAsrService | null = null;

  async startSpeak(): Promise<void> {
    this.isRecording = true;
    this.zhText = '';
    this.enResult = '';
    this.hint = '请说…';
    this.asr = ServiceProvider.newAsr();
    await this.asr.start(
      Lang.ZH,
      (partial: string): void => { this.zhText = partial; },
      (final: string): void => { this.onSpoke(final); },
      (_msg: string): void => { this.onError(); }
    );
  }

  async onSpoke(zh: string): Promise<void> {
    this.isRecording = false;
    if (this.asr) { await this.asr.stop(); }
    if (!zh) { this.onError(); return; }
    this.zhText = zh;
    try {
      const res = await ServiceProvider.translate().translate(zh, Lang.ZH, Lang.EN);
      this.enResult = res.targetText;
      this.hint = '';
      await ServiceProvider.tts().speak(this.enResult, Lang.EN);
    } catch (e) {
      this.onError();
    }
  }

  onError(): void {
    this.isRecording = false;
    this.hint = '没听清，请再说一次';
  }

  // 全屏给对方看：黑底白字超大英文
  @Builder
  FullScreen() {
    Column() {
      Text(this.enResult).fontSize(Sizes.resultBig).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .textAlign(TextAlign.Center).layoutWeight(1)
      Button('收起').fontSize(Sizes.button).height(Sizes.actionButtonHeight).width('100%')
        .backgroundColor(Colors.speak).fontColor(Colors.onColor)
        .onClick(() => { this.showFullScreen = false; })
    }
    .width('100%').height('100%').padding(Sizes.pagePadding).backgroundColor('#000000')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      Column({ space: Sizes.gap }) {
        Button('⬅ 返回首页')
          .fontSize(Sizes.button).fontColor(Colors.onColor).backgroundColor(Colors.speak)
          .height(Sizes.actionButtonHeight).width('100%')
          .onClick(() => router.back())

        if (this.hint) {
          Text(this.hint).fontSize(Sizes.hint).fontColor(Colors.textSub).textAlign(TextAlign.Center)
        }

        if (this.enResult) {
          if (this.zhText) {
            Text(this.zhText).fontSize(Sizes.small).fontColor(Colors.textSub)
          }
          Scroll() {
            Text(this.enResult).fontSize(Sizes.result).fontWeight(FontWeight.Bold).fontColor(Colors.textMain)
          }.layoutWeight(1).width('100%')
        } else {
          Blank()
        }

        Button(this.isRecording ? '正在听…' : '🎤 我要说')
          .width(Sizes.micButton).height(Sizes.micButton).borderRadius(Sizes.micButton / 2)
          .fontSize(Sizes.button).fontColor(Colors.onColor)
          .backgroundColor(this.isRecording ? Colors.emergency : Colors.speak)
          .onClick(() => { if (!this.isRecording) { this.startSpeak(); } })

        if (this.enResult) {
          Button('📺 全屏给对方看').width('100%').height(Sizes.actionButtonHeight)
            .fontSize(Sizes.button).backgroundColor(Colors.speak).fontColor(Colors.onColor)
            .onClick(() => { this.showFullScreen = true; })
        }

        Row({ space: Sizes.gap }) {
          Button('🔊 再读一遍').layoutWeight(1).height(Sizes.actionButtonHeight)
            .fontSize(Sizes.button).backgroundColor(Colors.card).fontColor(Colors.textMain)
            .onClick(() => { if (this.enResult) { ServiceProvider.tts().speak(this.enResult, Lang.EN); } })
          Button('🔁 重新说').layoutWeight(1).height(Sizes.actionButtonHeight)
            .fontSize(Sizes.button).backgroundColor(Colors.speak).fontColor(Colors.onColor)
            .onClick(() => this.startSpeak())
        }
      }
      .width('100%').height('100%').padding(Sizes.pagePadding).backgroundColor(Colors.bg)

      if (this.showFullScreen) {
        this.FullScreen()
      }
    }
  }
}
