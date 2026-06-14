import { router } from '@kit.ArkUI';
import { Colors, Sizes } from '../common/Theme';
import { ServiceProvider } from '../services/ServiceProvider';
import { Lang } from '../services/Types';

/** 拍：拍英文照片 → OCR → 整段大字中文（可朗读）。 */
@Entry
@Component
struct PhotoPage {
  @State zhResult: string = '';
  @State busy: boolean = false;
  @State enlarged: boolean = false;
  @State hint: string = '对准英文，点下面大钮拍照';

  // 拍照 -> OCR -> 翻译
  async capture(): Promise<void> {
    this.busy = true;
    this.hint = '正在识别…';
    try {
      // TODO: 用 @kit.CameraKit 拍照得到本地图片 uri（或相册选择）
      const imageUri: string = await this.takePhoto();
      const ocr = await ServiceProvider.ocr().recognize(imageUri);
      if (!ocr.fullText) {
        this.hint = '没找到英文，请对准文字重拍';
        this.busy = false;
        return;
      }
      const res = await ServiceProvider.translate().translate(ocr.fullText, Lang.EN, Lang.ZH);
      this.zhResult = res.targetText;
      this.hint = '';
    } catch (e) {
      this.hint = '拍照失败，请重试';
    }
    this.busy = false;
  }

  private async takePhoto(): Promise<string> {
    // 占位：实际调用相机拍照并返回图片 uri
    return '';
  }

  build() {
    Column({ space: Sizes.gap }) {
      Button('⬅ 返回首页')
        .fontSize(Sizes.button).fontColor(Colors.onColor).backgroundColor(Colors.photo)
        .height(Sizes.actionButtonHeight).width('100%')
        .onClick(() => router.back())

      if (this.hint) {
        Text(this.hint).fontSize(Sizes.hint).fontColor(Colors.textSub).textAlign(TextAlign.Center)
      }

      if (this.zhResult) {
        Scroll() {
          Text(this.zhResult)
            .fontSize(this.enlarged ? Sizes.resultBig : Sizes.result)
            .fontWeight(FontWeight.Bold).fontColor(Colors.textMain)
        }.layoutWeight(1).width('100%')
      } else {
        // 相机取景占位
        Column().layoutWeight(1).width('100%').backgroundColor(Colors.card).borderRadius(Sizes.radius)
      }

      Button(this.busy ? '正在识别…' : '📷 拍照')
        .width('100%').height(Sizes.micButton).borderRadius(Sizes.radius)
        .fontSize(Sizes.title).fontColor(Colors.onColor).backgroundColor(Colors.photo)
        .enabled(!this.busy)
        .onClick(() => this.capture())

      Row({ space: Sizes.gap }) {
        Button('🔆 放大看').layoutWeight(1).height(Sizes.actionButtonHeight)
          .fontSize(Sizes.button).backgroundColor(Colors.card).fontColor(Colors.textMain)
          .onClick(() => { this.enlarged = !this.enlarged; })
        Button('🔊 朗读').layoutWeight(1).height(Sizes.actionButtonHeight)
          .fontSize(Sizes.button).backgroundColor(Colors.photo).fontColor(Colors.onColor)
          .onClick(() => { if (this.zhResult) { ServiceProvider.tts().speak(this.zhResult, Lang.ZH); } })
      }
    }
    .width('100%').height('100%').padding(Sizes.pagePadding).backgroundColor(Colors.bg)
  }
}
