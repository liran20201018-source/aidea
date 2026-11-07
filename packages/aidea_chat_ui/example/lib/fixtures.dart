import 'package:aidea_chat_ui/aidea_chat_ui.dart';

AideaModel fixtureModel(
  String id,
  String name,
  String category, {
  int input = 0,
  int output = 0,
  bool vision = false,
  bool reasoning = false,
  bool search = false,
  String? description,
}) {
  return AideaModel(
    id,
    name,
    'fixture',
    category: category,
    description: description ?? '内存假数据，不是厂商目录，价格也不是真实标价。',
    supportVision: vision,
    supportReasoning: reasoning,
    supportSearch: search,
    priceInfo: AideaModelPrice(input: input, output: output, request: 0, note: '').toJson(),
  );
}

/// 模型名和浅色表里能看清的价格按验收截图抄进内存。
/// 深色表后半被裁切，那些价格只是占位，原仓库没有这份目录。
List<AideaModel> fixtureModels() => [
      fixtureModel('deepseek', 'DeepSeek', '最佳', input: 4, output: 15, reasoning: true, search: true),
      fixtureModel('gpt-4o', 'GPT-4o', '最佳', input: 4, output: 15, vision: true, search: true),
      fixtureModel('claude-3.7', 'Claude 3.7 Sonnet', '最佳', input: 4, output: 20, vision: true, reasoning: true, search: true),
      fixtureModel('gemini-2', 'Gemini 2.0 Flash', 'Google', input: 4, output: 15, vision: true, reasoning: true, search: true),
      fixtureModel('deepseek-2', 'DeepSeek', 'DeepSeek', input: 4, output: 15, reasoning: true, search: true),
      fixtureModel('deepseek-free', 'DeepSeek 免费版', 'DeepSeek', vision: true, search: true),
      fixtureModel('gpt-3.5', 'GPT-3.5 Turbo', 'OpenAI', input: 1, output: 2),
      fixtureModel('gpt-4', 'GPT-4', 'OpenAI', input: 25, output: 50),
      fixtureModel('mistral-large', 'Mistral Large', 'Mistral', input: 10, output: 30, vision: true),
      fixtureModel('mistral-medium', 'Mistral Medium', 'Mistral', input: 4, output: 12),
      fixtureModel('mistral-small', 'Mistral Small', 'Mistral', input: 1, output: 3),
      fixtureModel('sensechat-5', 'SenseChat 5', '最近上新', input: 10, output: 20),
      fixtureModel('sensechat-turbo', 'SenseChat Turbo', '最近上新', input: 2, output: 4),
      fixtureModel('doubao-lite', '豆包 Lite', '字节跳动', input: 1, output: 2),
      fixtureModel('doubao-pro', '豆包 Pro', '字节跳动', input: 4, output: 8),
    ];

AideaSearchHit _hit(String index, String title) => AideaSearchHit(
      title: title,
      source: 'https://example.invalid/fixture/$index',
      content: '假摘要，没有访问网页。',
      media: '假来源',
      index: index,
    );

List<AideaChatMessage> lightFixtureMessages() => [
      const AideaChatMessage(
        id: 'u-light',
        role: AideaChatRole.user,
        text: '今天有什么新鲜事儿',
      ),
      AideaChatMessage(
        id: 'a-light',
        role: AideaChatRole.assistant,
        turnState: AideaTurnState.thinkingDone,
        thinkingSeconds: 39.9,
        reasoning: '【演示】这里不是模型的思考过程，只是为了展示折叠条。',
        searchResults: [
          for (var i = 1; i <= 7; i++) _hit('$i', '假网页 $i'),
        ],
        text: '''
今天是2025年2月25日，根据提供的搜索结果（大部分为历史信息），以下是一些可能与今日相关的“新鲜事儿”类型或近期热点整理，供参考：

1. 文化活动和亲子活动
- 环保手工活动：类似北京又见书社举办的亲子活动，通过手工创作提升环保意识，促进亲子互动 [citation:1]。
- 地域庙会：年节期间的文创展、传统小吃、民俗表演。若今年同期举办，可能延续类似主题 [citation:4]。

2. 社会安全和民生提醒
- 防盗提示：公共场所保管好随身物品 [citation:3]。
- 交通提示：晚高峰注意行车秩序，安全驾驶仍是重点 [citation:2]。

以上文字是内存假数据，用来对照界面，不是搜索结果，也不是模型回复。
''',
      ),
    ];

List<AideaChatMessage> darkFixtureMessages() => [
      const AideaChatMessage(
        id: 'u-dark',
        role: AideaChatRole.user,
        text: '漫威有哪些英雄人物？',
      ),
      AideaChatMessage(
        id: 'a-dark',
        role: AideaChatRole.assistant,
        turnState: AideaTurnState.thinkingDone,
        thinkingSeconds: 7.3,
        reasoning: '【演示】没有调用 Claude，也没有搜索漫威资料。',
        searchResults: [
          for (var i = 1; i <= 5; i++) _hit('$i', '假漫威条目 $i'),
        ],
        text: '''
漫威英雄人物大全

漫威漫画创造了众多广受欢迎的超级英雄角色。以下是内存假数据，用来对照深色界面，不是模型回复。

领袖级英雄

1. 美国队长：史蒂夫·罗杰斯，美国精神的象征，初次登场于1941年3月的《美国队长》第1期 [citation:1]。
2. 钢铁侠：托尼·斯塔克，斯塔克工业董事长，科技天才 [citation:2]。
3. 惊奇队长：宇宙中的强者 [citation:3]。

经典英雄

1. 蜘蛛侠：由斯坦·李和史蒂夫·迪特科创造 [citation:4]。
2. 绿巨人浩克：布鲁斯·班纳 [citation:5]。
''',
      ),
    ];
