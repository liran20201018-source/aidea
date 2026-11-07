// 摘自 lib/page/component/chat/markdown.dart 的 Markdown（当前启用的 flutter_markdown 分支）。
// 原符号：Markdown.build。
// 未接入：文件后半被注释的 MarkdownPlus、LatexBlockSyntax / LatexInlineSyntax / LatexElementBuilder、
// NetworkImagePreviewer 与 DefaultCacheManager。公式和网络图片会去拉 flutter_math_fork 与图片预览页。
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:aidea_chat_ui/src/widgets/citation.dart';
import 'package:aidea_chat_ui/src/widgets/code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:markdown/markdown.dart' as mm;

class AideaMarkdown extends StatelessWidget {
  final String data;
  final Function(String value)? onUrlTap;
  final TextStyle? textStyle;
  final bool thinkingMode;
  final List<String> citations;

  const AideaMarkdown({
    super.key,
    required this.data,
    this.onUrlTap,
    this.textStyle,
    this.citations = const [],
    this.thinkingMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    final style = thinkingMode
        ? md.MarkdownStyleSheet(
            p: TextStyle(fontSize: 14, color: customColors.weakTextColorLess, height: 1.5),
            listBullet: TextStyle(fontSize: 14, color: customColors.weakTextColorLess, height: 1.5),
            code: TextStyle(
              fontSize: 14,
              color: customColors.weakTextColorLess,
              backgroundColor: Colors.transparent,
            ),
            codeblockPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            codeblockDecoration: const BoxDecoration(borderRadius: CustomSize.borderRadiusAll),
            tableBorder: TableBorder.all(color: customColors.weakTextColorLess!.withOpacity(0.5), width: 1),
            tableColumnWidth: const FlexColumnWidth(),
            blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            blockquoteDecoration: BoxDecoration(
              border: Border(left: BorderSide(color: customColors.weakTextColorLess!.withOpacity(0.4), width: 4)),
            ),
            a: TextStyle(color: customColors.weakTextColorLess, decoration: TextDecoration.none),
            h1: TextStyle(color: customColors.weakTextColorLess, height: 1.5),
            h2: TextStyle(color: customColors.weakTextColorLess, height: 1.5),
            h3: TextStyle(color: customColors.weakTextColorLess, height: 1.5),
            h4: TextStyle(color: customColors.weakTextColorLess, height: 1.5),
            h5: TextStyle(color: customColors.weakTextColorLess, height: 1.5),
            h6: TextStyle(color: customColors.weakTextColorLess, height: 1.5),
          )
        : md.MarkdownStyleSheet(
            p: textStyle ?? TextStyle(fontSize: CustomSize.markdownTextSize, height: 1.5),
            listBullet: textStyle ?? TextStyle(fontSize: CustomSize.markdownTextSize, height: 1.5),
            code: TextStyle(
              fontSize: CustomSize.markdownCodeSize,
              color: customColors.markdownCodeColor,
              backgroundColor: Colors.transparent,
            ),
            codeblockPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            codeblockDecoration: const BoxDecoration(borderRadius: CustomSize.borderRadiusAll),
            tableBorder: TableBorder.all(color: customColors.weakTextColor!.withOpacity(0.5), width: 1),
            tableColumnWidth: const FlexColumnWidth(),
            blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            blockquoteDecoration: BoxDecoration(
              border: Border(left: BorderSide(color: customColors.weakTextColor!.withOpacity(0.4), width: 4)),
            ),
            a: TextStyle(color: customColors.weakLinkColor, decoration: TextDecoration.none),
          );

    return md.MarkdownBody(
      shrinkWrap: true,
      selectable: false,
      softLineBreak: true,
      styleSheetTheme: md.MarkdownStyleSheetBaseTheme.material,
      styleSheet: style,
      onTapLink: (text, href, title) {
        if (onUrlTap != null && href != null) onUrlTap!(href);
      },
      imageBuilder: (uri, title, alt) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            alt ?? title ?? uri.toString(),
            style: TextStyle(fontSize: 12, color: customColors.weakTextColorLess),
          ),
        );
      },
      extensionSet: mm.ExtensionSet(
        [
          ...mm.ExtensionSet.gitHubFlavored.blockSyntaxes,
        ],
        <mm.InlineSyntax>[
          CitationSyntax(citations: citations),
          mm.EmojiSyntax(),
          ...mm.ExtensionSet.gitHubFlavored.inlineSyntaxes,
        ],
      ),
      data: data,
      builders: {
        'code': CodeElementBuilder(customColors),
        'citation': CitationBuilder(onTap: onUrlTap),
      },
    );
  }
}
