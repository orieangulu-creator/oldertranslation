import { router } from '@kit.ArkUI';
import { call } from '@kit.TelephonyKit';
import { Colors, Sizes } from '../common/Theme';
import { ServiceProvider } from '../services/ServiceProvider';
import { Lang } from '../services/Types';
import { EmergencyContact, EmergencyPhrase, getEmergencyPhrases } from '../data/EmergencyPhrases';

/**
 * 应急求助页（离线可用）。
 * - 顶部：家人联系卡，一键拨打 + 一键给老外看"请帮我打这个电话"。
 * - 下方：预置中→英应急用语，点一条即放大英文给对方看，并离线朗读。
 * 所有译文本地预置，无需网络。
 */
@Entry
@Component
struct EmergencyPage {
  @State phrases: EmergencyPhrase[] = getEmergencyPhrases();
  @State selected: EmergencyPhrase | null = null;

  // 一键拨打家人电话
  callFamily(): void {
    call.makeCall(EmergencyContact.phone, (err: Error): void => {
      // 失败也无妨：长辈可把"请帮我打这个电话"的卡片给路人看
    });
  }

  // 选中一条：放大英文 + 离线朗读
  pick(p: EmergencyPhrase): void {
    this.selected = p;
    ServiceProvider.tts().speak(p.en, Lang.EN);
  }

  @Builder
  Detail() {
    Column({ space: Sizes.gap }) {
      Text(this.selected!.zh).fontSize(Sizes.hint).fontColor(Colors.textSub)
      Scroll() {
        Text(this.selected!.en).fontSize(Sizes.resultBig).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
      }.layoutWeight(1).width('100%')
      Row({ space: Sizes.gap }) {
        Button('🔊 再读一遍').layoutWeight(1).height(Sizes.actionButtonHeight)
          .fontSize(Sizes.button).backgroundColor(Colors.emergency).fontColor(Colors.onColor)
          .onClick(() => ServiceProvider.tts().speak(this.selected!.en, Lang.EN))
        Button('收起').layoutWeight(1).height(Sizes.actionButtonHeight)
          .fontSize(Sizes.button).backgroundColor(Colors.card).fontColor(Colors.textMain)
          .onClick(() => { this.selected = null; })
      }
    }
    .width('100%').height('100%').padding(Sizes.pagePadding).backgroundColor('#000000')
    .justifyContent(FlexAlign.Center)
  }

  build() {
    Stack() {
      Column({ space: Sizes.gap }) {
        Button('⬅ 返回首页')
          .fontSize(Sizes.button).fontColor(Colors.onColor).backgroundColor(Colors.emergency)
          .height(Sizes.actionButtonHeight).width('100%')
          .onClick(() => router.back())

        // 家人联系卡
        Column({ space: 8 }) {
          Text(`联系${EmergencyContact.name}`).fontSize(Sizes.title).fontWeight(FontWeight.Bold).fontColor(Colors.onColor)
          Text(EmergencyContact.phone).fontSize(Sizes.hint).fontColor(Colors.onColor)
          Button('📞 一键拨打').width('100%').height(Sizes.actionButtonHeight)
            .fontSize(Sizes.button).backgroundColor('#FFFFFF').fontColor(Colors.emergency)
            .onClick(() => this.callFamily())
        }
        .width('100%').padding(Sizes.gap).backgroundColor(Colors.emergency).borderRadius(Sizes.radius)

        Text('点一句话，给身边的人看（可离线朗读）')
          .fontSize(Sizes.hint).fontColor(Colors.textSub)

        List({ space: Sizes.gap }) {
          ForEach(this.phrases, (p: EmergencyPhrase) => {
            ListItem() {
              Text(p.zh).fontSize(Sizes.button).fontColor(Colors.textMain)
                .width('100%').padding(Sizes.gap)
                .backgroundColor(Colors.card).borderRadius(Sizes.radius)
                .onClick(() => this.pick(p))
            }
          }, (p: EmergencyPhrase) => p.id)
        }.layoutWeight(1).width('100%')
      }
      .width('100%').height('100%').padding(Sizes.pagePadding).backgroundColor(Colors.bg)

      if (this.selected) {
        this.Detail()
      }
    }
  }
}
