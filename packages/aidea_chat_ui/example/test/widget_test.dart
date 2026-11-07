import 'package:aidea_chat_ui_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder plain(String needle) {
  return find.byWidgetPredicate((widget) {
    if (widget is RichText) {
      return widget.text.toPlainText().contains(needle);
    }
    if (widget is Text) {
      final data = widget.data ?? widget.textSpan?.toPlainText() ?? '';
      return data.contains(needle);
    }
    return false;
  });
}

Future<void> frames(WidgetTester tester, [int count = 8]) async {
  for (var i = 0; i < count; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('演示入口可以打开浅色聊天并得到假回复', (tester) async {
    await tester.pumpWidget(const DemoApp());
    await tester.tap(find.text('打开浅色聊天'));
    await frames(tester);

    expect(find.text('DeepSeek'), findsOneWidget);
    expect(find.text('已搜索到 7 个网页'), findsOneWidget);
    expect(plain('今天是2025年2月25日'), findsWidgets);
    expect(plain('深度思考 (用时 39.9s)'), findsWidgets);

    await tester.enterText(find.byKey(const Key('aidea_chat_input')), '再问一句');
    await tester.pump();
    await tester.tap(find.byKey(const Key('aidea_chat_send')));
    await tester.pump();
    expect(find.text('正在联网搜索'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 900));
    expect(plain('演示假回复，不是模型输出'), findsWidgets);
  });

  testWidgets('深色入口使用深色背景', (tester) async {
    await tester.pumpWidget(const DemoApp());
    await tester.tap(find.text('打开深色聊天'));
    await frames(tester);
    expect(plain('漫威英雄人物大全'), findsWidgets);
    expect(find.text('Claude 3.7 Sonnet'), findsOneWidget);
    expect(find.text('已搜索到 5 个网页'), findsOneWidget);
  });
}
