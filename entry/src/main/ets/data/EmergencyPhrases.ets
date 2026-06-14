/**
 * 离线应急用语包。
 *
 * 设计要点：
 * 1. 全部中→英译文【预置在本地】，断网/无流量也能用——夏威夷网络不稳时的救命兜底。
 * 2. 译文经人工校定（见 tests/翻译校对报告.md 高风险清单），不走实时机翻，确保安全。
 * 3. 家人联系方式由子女在"设置"里填写一次，长辈一键即可给老外看 + 一键拨打。
 */

/** 一条应急用语：中文给长辈确认，英文给老外看/朗读。 */
export interface EmergencyPhrase {
  id: string;
  zh: string;          // 中文（大字给长辈看）
  en: string;          // 英文（预置，给老外看，可离线朗读）
  category: string;    // 分类：身份 / 求助 / 医疗 / 方向 / 日常
}

/** 家人紧急联系人，由子女预先填写。 */
export class EmergencyContact {
  // TODO(子女填写): 把下面两项改成真实的姓名与电话
  static name: string = '我的女儿';
  static phone: string = '+86 138 0000 0000';

  /** 是否已由子女配置好（用于首启提醒）。 */
  static isConfigured(): boolean {
    return EmergencyContact.phone.indexOf('0000 0000') < 0;
  }
}

/**
 * 应急用语清单。第一条"找家人"会动态带入联系人姓名与电话。
 * 顺序即优先级：身份与求助在最前，最常用、最救命。
 */
export function getEmergencyPhrases(): EmergencyPhrase[] {
  const name: string = EmergencyContact.name;
  const phone: string = EmergencyContact.phone;
  return [
    // —— 身份 ——
    {
      id: 'who',
      category: '身份',
      zh: '你好，我来自中国，我不懂英文。',
      en: "Hello, I'm from China and I don't speak English."
    },
    {
      id: 'help_general',
      category: '求助',
      zh: '请帮我个忙，好吗？',
      en: 'Could you please help me?'
    },
    {
      id: 'find_family',
      category: '求助',
      zh: `我需要找到${name}。这是她的电话：${phone}，可以帮我打给她吗？`,
      en: `I need to reach my family. This is the number: ${phone}. Could you please call for me?`
    },
    // —— 医疗（高风险，已人工校定）——
    {
      id: 'ambulance',
      category: '医疗',
      zh: '请帮我叫救护车！',
      en: 'Please call an ambulance!'
    },
    {
      id: 'call_911',
      category: '医疗',
      zh: '请帮我打 911 报警/求救。',
      en: 'Please call 911.'
    },
    {
      id: 'not_well',
      category: '医疗',
      zh: '我身体很不舒服，需要看医生。',
      en: 'I feel very sick. I need to see a doctor.'
    },
    {
      id: 'allergy',
      category: '医疗',
      zh: '我对坚果和海鲜过敏，请不要给我吃。',
      en: "I'm allergic to tree nuts, peanuts and seafood. Please don't give me any."
    },
    // —— 方向 / 求助 ——
    {
      id: 'lost',
      category: '方向',
      zh: '我迷路了，请帮我看看怎么回酒店。',
      en: "I'm lost. Could you help me get back to my hotel?"
    },
    {
      id: 'restroom',
      category: '日常',
      zh: '请问洗手间在哪里？',
      en: 'Where is the restroom, please?'
    },
    {
      id: 'consulate',
      category: '求助',
      zh: '请帮我联系中国驻当地领事馆。',
      en: 'Please help me contact the Chinese consulate.'
    },
    // —— 日常 ——
    {
      id: 'how_much',
      category: '日常',
      zh: '这个多少钱？',
      en: 'How much is this?'
    },
    {
      id: 'thanks',
      category: '日常',
      zh: '谢谢您！',
      en: 'Thank you very much!'
    }
  ];
}
