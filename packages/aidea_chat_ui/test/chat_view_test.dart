import 'package:aidea_chat_ui/aidea_chat_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

AideaModel _model(
  String id,
  String name,
  String category, {
  int input = 0,
  int output = 0,
  bool vision = false,
  bool reasoning = false,
  bool search = false,
}) {
  return AideaModel(
    id,
    name,
    'test',
    category: category,
    supportVision: vision,
    supportReasoning: reasoning,
    supportSearch: search,
    priceInfo: AideaModelPrice(input: input, output: output, request: 0, note: '').toJson(),
  );
}

List<AideaModel> _models() => [
      _model('deepseek', 'DeepSeek', '最佳', input: 4, output: 15, reasoning: true, search: true),
      _model('gpt-4o', 'GPT-4o', '最佳', input: 4, output: 15, vision: true, search: true),
      _model('claude', 'Claude 3.7 Sonnet', '最佳', input: 4, output: 20, vision: true),
      _model('gpt-4', 'GPT-4', 'OpenAI', input: 25, output: 50),
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('发送文本会回调，并清空输入框', (tester) async {
    AideaChatSendRequest? sent;
    await tester.pumpWidget(_harness(
      models: _models(),
      selectedId: 'deepseek',
      onSend: (value) => sent = value,
    ));

    await tester.enterText(find.byKey(const Key('aidea_chat_input')), '你好');
    await tester.pump();
    await tester.tap(find.byKey(const Key('aidea_chat_send')));
    await tester.pump();

    expect(sent?.text, '你好');
    expect(sent?.thinking, isFalse);
    expect(sent?.search, isFalse);
    expect(tester.widget<TextFormField>(find.byKey(const Key('aidea_chat_input'))).controller?.text, '');
  });

  testWidgets('模型搜索和点选', (tester) async {
    AideaModel? picked;
    await tester.pumpWidget(_harness(
      models: _models(),
      selectedId: 'deepseek',
      onModelSelected: (model) => picked = model,
    ));

    await tester.tap(find.byKey(const Key('aidea_chat_title')));
    await tester.pumpAndSettle();
    expect(find.text('搜索'), findsOneWidget);
    expect(find.text('DeepSeek'), findsWidgets);

    await tester.enterText(find.byKey(const Key('aidea_model_search')), 'Claude');
    await tester.pumpAndSettle();
    expect(find.text('Claude 3.7 Sonnet'), findsOneWidget);
    expect(find.text('GPT-4o'), findsNothing);
    expect(find.text('GPT-4'), findsNothing);

    await tester.tap(find.byKey(const Key('aidea_model_claude')));
    await tester.pumpAndSettle();
    expect(picked?.id, 'claude');
  });

  testWidgets('视觉标签会过滤模型', (tester) async {
    await tester.pumpWidget(_harness(models: _models(), selectedId: 'deepseek'));
    await tester.tap(find.byKey(const Key('aidea_chat_title')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('#视觉').first);
    await tester.pumpAndSettle();
    expect(find.text('GPT-4o'), findsOneWidget);
    expect(find.text('Claude 3.7 Sonnet'), findsOneWidget);
    expect(find.byKey(const Key('aidea_model_deepseek')), findsNothing);
  });

  testWidgets('深度思考和联网搜索开关', (tester) async {
    await tester.pumpWidget(_toggleHarness());
    expect(_chipColor(tester, '深度思考'), CustomColors.light.chatInputPanelText);
    expect(_chipColor(tester, '联网搜索'), CustomColors.light.chatInputPanelText);

    await tester.tap(find.byKey(const Key('aidea_chat_thinking')));
    await tester.pump();
    expect(_chipColor(tester, '深度思考'), CustomColors.light.linkColor);

    await tester.tap(find.byKey(const Key('aidea_chat_search')));
    await tester.pump();
    expect(_chipColor(tester, '联网搜索'), CustomColors.light.linkColor);

    await tester.enterText(find.byKey(const Key('aidea_chat_input')), '带开关');
    await tester.pump();
    await tester.tap(find.byKey(const Key('aidea_chat_send')));
    await tester.pump();
    expect(toggleSent?.thinking, isTrue);
    expect(toggleSent?.search, isTrue);
  });

  testWidgets('浅色和深色主题背景', (tester) async {
    await tester.pumpWidget(_harness(models: _models(), selectedId: 'deepseek', dark: false));
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      CustomColors.light.backgroundContainerColor,
    );

    await tester.pumpWidget(_harness(models: _models(), selectedId: 'deepseek', dark: true));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      CustomColors.dark.backgroundContainerColor,
    );
  });

  testWidgets('引用角标和思考耗时沿用原组件文案', (tester) async {
    await tester.pumpWidget(_harness(
      models: _models(),
      selectedId: 'deepseek',
      messages: [
        const AideaChatMessage(id: 'u', role: AideaChatRole.user, text: '问'),
        AideaChatMessage(
          id: 'a',
          role: AideaChatRole.assistant,
          text: '答案 [citation:1]',
          turnState: AideaTurnState.thinkingDone,
          thinkingSeconds: 39.9,
          reasoning: '过程',
          searchResults: const [
            AideaSearchHit(title: '页', source: 'https://example.invalid/1', content: '摘', media: '示例', index: '1'),
          ],
        ),
      ],
    ));
    await tester.pumpAndSettle();
    expect(find.text('已搜索到 1 个网页'), findsOneWidget);
    expect(find.textContaining('深度思考'), findsWidgets);
    expect(find.textContaining('39.9s'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
  });
}

AideaChatSendRequest? toggleSent;

Color? _chipColor(WidgetTester tester, String label) {
  final text = tester.widget<Text>(find.text(label));
  return text.style?.color;
}

Widget _harness({
  required List<AideaModel> models,
  required String selectedId,
  List<AideaChatMessage> messages = const [],
  ValueChanged<AideaChatSendRequest>? onSend,
  ValueChanged<AideaModel>? onModelSelected,
  bool dark = false,
}) {
    return MaterialApp(
      theme: AideaThemes.light(),
      darkTheme: AideaThemes.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: AideaChatView(
      formFactor: AideaFormFactor.mobile,
      messages: messages,
      models: models,
      selectedModelId: selectedId,
      title: 'DeepSeek',
      enableMedia: true,
      onSend: onSend ?? (_) {},
      onModelSelected: onModelSelected,
    ),
  );
}

class _ToggleHarness extends StatefulWidget {
  @override
  State<_ToggleHarness> createState() => _ToggleHarnessState();
}

class _ToggleHarnessState extends State<_ToggleHarness> {
  bool thinking = false;
  bool search = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AideaThemes.light(),
      home: AideaChatView(
        formFactor: AideaFormFactor.mobile,
        messages: const [],
        models: _models(),
        selectedModelId: 'deepseek',
        title: 'DeepSeek',
        thinkingEnabled: thinking,
        searchEnabled: search,
        onThinkingChanged: (value) => setState(() => thinking = value),
        onSearchChanged: (value) => setState(() => search = value),
        onSend: (value) => toggleSent = value,
      ),
    );
  }
}

Widget _toggleHarness() {
  toggleSent = null;
  return _ToggleHarness();
}
