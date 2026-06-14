import { router } from '@kit.ArkUI';
import { Colors, Sizes } from '../common/Theme';

/**
 * 首页：只有 3 个超大功能按钮（听/说/拍）+ 1 个红色应急入口。
 * 进入时语音播报一次引导（见 PRD 4.2）。
 */
@Entry
@Component
struct Index {
  aboutToAppear(): void {
    // TODO: 用 ServiceProvider.tts().speak('请选择，听、说、还是拍。', Lang.ZH) 做进入引导
  }

  @Builder
  FeatureCard(title: string, subtitle: string, icon: Resource, color: string, url: string) {
    Column({ space: 8 }) {
      Image(icon).width(72).height(72).fillColor(Colors.onColor)
      Text(title).fontSize(Sizes.title).fontWeight(FontWeight.Bold).fontColor(Colors.onColor)
      Text(subtitle).fontSize(Sizes.hint).fontColor(Colors.onColor)
    }
    .width('100%')
    .height(Sizes.bigButtonHeight)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(color)
    .borderRadius(Sizes.radius)
    .onClick(() => router.pushUrl({ url: url }))
  }

  build() {
    Column({ space: Sizes.gap }) {
      Text('请选择')
        .fontSize(Sizes.title)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.textMain)
        .margin({ top: 8, bottom: 4 })

      this.FeatureCard('听', '听别人说英文', $r('app.media.ic_listen'), Colors.listen, 'pages/ListenPage')
      this.FeatureCard('说', '我说中文给老外看', $r('app.media.ic_speak'), Colors.speak, 'pages/SpeakPage')
      this.FeatureCard('拍', '拍英文给我看懂', $r('app.media.ic_photo'), Colors.photo, 'pages/PhotoPage')

      // 应急（红色、离线可用）
      Button() {
        Row({ space: 12 }) {
          Image($r('app.media.ic_sos')).width(48).height(48).fillColor(Colors.onColor)
          Text('应急求助').fontSize(Sizes.button).fontWeight(FontWeight.Bold).fontColor(Colors.onColor)
        }
      }
      .width('100%')
      .height(Sizes.actionButtonHeight)
      .backgroundColor(Colors.emergency)
      .borderRadius(Sizes.radius)
      .onClick(() => router.pushUrl({ url: 'pages/EmergencyPage' }))
    }
    .width('100%')
    .height('100%')
    .padding(Sizes.pagePadding)
    .backgroundColor(Colors.bg)
  }
}
