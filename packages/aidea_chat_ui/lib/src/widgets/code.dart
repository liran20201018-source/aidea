// 摘自 lib/page/component/chat/markdown/code.dart
// 原符号：codeTheme、CodeElementBuilder
// 适配：主题不再读 Ability().themeMode；复制改用系统剪贴板，不再用 clipboard 插件和全局 toast。
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/tomorrow.dart';
import 'package:flutter_highlight/themes/tomorrow-night.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

Map<String, TextStyle> codeTheme(BuildContext context) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  var theme = Map<String, TextStyle>.from(dark ? tomorrowNightTheme : tomorrowTheme);
  theme['root'] = TextStyle(
    backgroundColor: Colors.transparent,
    color: theme['root']?.color,
  );
  return theme;
}

class CodeElementBuilder extends MarkdownElementBuilder {
  final CustomColors customColors;

  CodeElementBuilder(this.customColors);

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    var language = '';

    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }
    if (language.isEmpty) {
      language = 'plaintext';
    }

    final multiLine = element.textContent.trim().split('\n').length > 1;

    final child = RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: HighlightView(
              element.textContent,
              language: language,
              theme: codeTheme(context),
              padding: multiLine
                  ? const EdgeInsets.only(top: 30, bottom: 10, left: 10, right: 10)
                  : const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              textStyle: TextStyle(
                fontSize: multiLine ? CustomSize.markdownCodeSize : CustomSize.markdownTextSize,
                height: 1.5,
                wordSpacing: 3,
              ),
            ),
          )
        ],
      ),
    );

    if (multiLine) {
      return Card(
        elevation: 0,
        color: customColors.markdownPreColor,
        shape: RoundedRectangleBorder(
          borderRadius: CustomSize.borderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: customColors.listTileBackgroundColor,
                borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, topRight: CustomSize.radius),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      fontSize: 12,
                      color: customColors.weakTextColor,
                    ),
                  ),
                  TextButton.icon(
                    icon: Icon(
                      Icons.copy,
                      size: 14,
                      color: customColors.weakTextColorLess,
                    ),
                    label: Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: 12,
                        color: customColors.weakTextColorLess,
                      ),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: element.textContent));
                    },
                    style: ButtonStyle(
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                ],
              ),
            ),
            child,
          ],
        ),
      );
    }

    return child;
  }
}
