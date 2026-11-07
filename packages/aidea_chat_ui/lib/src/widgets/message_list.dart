// 视觉结构摘自 lib/page/component/chat/chat_preview.dart 的 _buildMessageBox 与 ListView。
// 原符号：ChatPreview.build、_buildMessageBox、_chatBoxMaxWidth。
// 未接入：BlocBuilder、长按 BotToast 菜单、分享、翻译、文件/图片预览、语音播放、选择模式、aidea-app 路由。
import 'package:aidea_chat_ui/src/l10n/chat_strings.dart';
import 'package:aidea_chat_ui/src/model/chat_message.dart';
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:aidea_chat_ui/src/widgets/letter_avatar.dart';
import 'package:aidea_chat_ui/src/widgets/markdown.dart';
import 'package:aidea_chat_ui/src/widgets/search_result.dart';
import 'package:aidea_chat_ui/src/widgets/thinking_card.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AideaMessageList extends StatefulWidget {
  final List<AideaChatMessage> messages;
  final ScrollController scrollController;
  final ValueChanged<String>? onLinkTap;
  final ValueChanged<AideaSearchHit>? onSearchHitTap;
  final EdgeInsetsGeometry? padding;

  const AideaMessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    this.onLinkTap,
    this.onSearchHitTap,
    this.padding,
  });

  @override
  State<AideaMessageList> createState() => _AideaMessageListState();
}

class _AideaMessageListState extends State<AideaMessageList> {
  final Map<String, bool> _displayThinkingProcess = {};

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final messages = widget.messages.reversed.toList();

    return ListView.builder(
      controller: widget.scrollController,
      itemCount: messages.length,
      shrinkWrap: true,
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      cacheExtent: MediaQuery.of(context).size.height * 10,
      itemBuilder: (context, index) {
        final message = messages[index];
        if (message.role == AideaChatRole.system) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Text(
              message.text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(5),
          child: _box(context, customColors, message, index),
        );
      },
    );
  }

  double _chatBoxMaxWidth(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= CustomSize.maxWindowSize) {
      return CustomSize.maxWindowSize;
    }
    return screenWidth;
  }

  Widget _box(BuildContext context, CustomColors customColors, AideaChatMessage message, int index) {
    final user = message.role == AideaChatRole.user;
    final stateWidgets = <Widget>[];
    if (index == 0 && message.turnState == AideaTurnState.searching) {
      stateWidgets.add(AideaSearchResult(searchResults: const [], isSearching: true));
    } else if (message.turnState == AideaTurnState.thinking && index == 0) {
      if (message.reasoning != '') {
        stateWidgets.add(AideaThinkingCard(
          content: message.reasoning,
          title: ChatStrings.thinkingProcess,
          isExpanded: true,
          onTap: (_) {},
          onUrlTap: widget.onLinkTap,
        ));
      } else {
        stateWidgets.add(Row(
          children: [
            Text(
              ChatStrings.robotIsThinking,
              style: TextStyle(fontSize: 14, color: customColors.weakTextColorLess),
            ),
            const SizedBox(width: 10),
            LoadingAnimationWidget.waveDots(
              color: customColors.weakTextColorLess!,
              size: 16,
            ),
          ],
        ));
      }
    } else if (message.turnState == AideaTurnState.thinkingDone && message.reasoning != '') {
      stateWidgets.add(AideaThinkingCard(
        content: message.reasoning,
        title: ChatStrings.thinkingProcess,
        timeConsumed: message.thinkingSeconds,
        isExpanded: _displayThinkingProcess[message.id] ?? false,
        onUrlTap: widget.onLinkTap,
        onTap: (display) {
          setState(() => _displayThinkingProcess[message.id] = display);
        },
      ));
    }

    var text = message.text;
    if (!message.ready && text != '') {
      text += ' ▌';
    }

    return Align(
      alignment: user ? Alignment.topRight : Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _chatBoxMaxWidth(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!user && message.senderName != null)
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 10, 7),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        AideaLetterAvatar(label: message.senderName!, size: 30),
                        const SizedBox(width: 8),
                        Text(
                          message.senderName!,
                          style: TextStyle(color: customColors.weakTextColor, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _chatBoxMaxWidth(context) - 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.end,
                        children: [
                          if (user && message.failed)
                            const Padding(
                              padding: EdgeInsets.only(right: 5, bottom: 10),
                              child: Icon(Icons.error, color: Colors.red, size: 20),
                            ),
                          if (message.searchResults.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 10, top: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: AideaSearchResult(
                                searchResults: message.searchResults,
                                onTapHit: widget.onSearchHitTap,
                              ),
                            ),
                          if (stateWidgets.isNotEmpty)
                            Container(
                              margin: EdgeInsets.only(left: 10, top: message.searchResults.isEmpty ? 10 : 0),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: stateWidgets,
                              ),
                            ),
                          GestureDetector(
                            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
                            child: Container(
                              margin: user
                                  ? const EdgeInsets.fromLTRB(0, 0, 10, 7)
                                  : const EdgeInsets.fromLTRB(10, 0, 0, 7),
                              decoration: BoxDecoration(
                                borderRadius: CustomSize.borderRadius,
                                color: user
                                    ? customColors.chatRoomSenderBackground
                                    : customColors.chatRoomReplyBackground,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: message.markdown
                                  ? AideaMarkdown(
                                      data: text.trim(),
                                      onUrlTap: widget.onLinkTap,
                                      citations: message.searchResults.map((e) => e.source).toList(),
                                    )
                                  : SelectableText(
                                      text,
                                      style: TextStyle(color: customColors.chatRoomSenderText),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
