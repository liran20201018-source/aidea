// 页面骨架摘自 lib/page/chat/home_chat.dart
// 原符号：HomeChatPage.build、buildAppBar、buildChatComponents、ChatInput.toolsBuilder。
// 模型表摘自 lib/page/chat/character_create.dart 的 openSelectModelDialog（高度 0.9）
// 和 lib/page/chat/component/model_switcher.dart 的 ModelSwitcher.openActionDialog。
// 数据、发送、模型切换都由宿主回调接管，不再读 RoomBloc、ChatMessageBloc、APIServer、SettingRepository。
import 'package:aidea_chat_ui/src/l10n/chat_strings.dart';
import 'package:aidea_chat_ui/src/model/aidea_model.dart';
import 'package:aidea_chat_ui/src/model/chat_message.dart';
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:aidea_chat_ui/src/widgets/bottom_sheet.dart';
import 'package:aidea_chat_ui/src/widgets/chat_input.dart';
import 'package:aidea_chat_ui/src/widgets/chat_input_button.dart';
import 'package:aidea_chat_ui/src/widgets/form_factor.dart';
import 'package:aidea_chat_ui/src/widgets/message_list.dart';
import 'package:aidea_chat_ui/src/widgets/model_item.dart';
import 'package:aidea_chat_ui/src/widgets/stop_button.dart';
import 'package:flutter/material.dart';

class AideaChatView extends StatefulWidget {
  final List<AideaChatMessage> messages;
  final List<AideaModel> models;
  final ValueChanged<AideaChatSendRequest> onSend;
  final ValueChanged<AideaModel>? onModelSelected;
  final String? title;
  final String? selectedModelId;
  final bool thinkingEnabled;
  final bool searchEnabled;
  final ValueChanged<bool>? onThinkingChanged;
  final ValueChanged<bool>? onSearchChanged;
  final bool inputEnabled;
  final VoidCallback? onStop;
  final bool enableMedia;
  final ValueChanged<AideaMediaAction>? onMediaAction;
  final VoidCallback? onVoice;
  final ValueChanged<String>? onLinkTap;
  final ValueChanged<AideaSearchHit>? onSearchHitTap;
  final AideaFormFactor? formFactor;
  final List<Widget>? appBarActions;
  final bool openModelSheet;

  const AideaChatView({
    super.key,
    required this.messages,
    required this.models,
    required this.onSend,
    this.onModelSelected,
    this.title,
    this.selectedModelId,
    this.thinkingEnabled = false,
    this.searchEnabled = false,
    this.onThinkingChanged,
    this.onSearchChanged,
    this.inputEnabled = true,
    this.onStop,
    this.enableMedia = false,
    this.onMediaAction,
    this.onVoice,
    this.onLinkTap,
    this.onSearchHitTap,
    this.formFactor,
    this.appBarActions,
    this.openModelSheet = false,
  });

  @override
  State<AideaChatView> createState() => _AideaChatViewState();
}

class _AideaChatViewState extends State<AideaChatView> {
  final ScrollController _scrollController = ScrollController();

  AideaModel? get _selected {
    for (final model in widget.models) {
      if (model.id == widget.selectedModelId) return model;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.openModelSheet) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openModels();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final body = Scaffold(
      backgroundColor: customColors.backgroundContainerColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        toolbarHeight: CustomSize.toolbarHeight,
        actions: widget.appBarActions,
        title: GestureDetector(
          key: const Key('aidea_chat_title'),
          onTap: _openModels,
          child: Text(
            widget.title ?? _selected?.name ?? '',
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: const TextStyle(fontSize: CustomSize.appBarTitleSize),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                AideaMessageList(
                  messages: widget.messages,
                  scrollController: _scrollController,
                  onLinkTap: widget.onLinkTap,
                  onSearchHitTap: widget.onSearchHitTap,
                  padding: widget.inputEnabled ? null : const EdgeInsets.only(bottom: 35),
                ),
                if (!widget.inputEnabled)
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: AideaStopButton(
                        key: const Key('aidea_chat_stop'),
                        label: ChatStrings.stopOutput,
                        onPressed: widget.onStop,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: CustomSize.radius, topRight: CustomSize.radius),
              color: customColors.chatInputPanelBackground,
            ),
            child: AideaChatInput(
              inputEnabled: widget.inputEnabled,
              enableMedia: widget.enableMedia,
              onMediaAction: widget.onMediaAction,
              onVoice: widget.onVoice,
              onStopGenerate: widget.onStop,
              tools: [
                if (_selected?.supportReasoning ?? false)
                  AideaChatInputButton(
                    buttonKey: const Key('aidea_chat_thinking'),
                    text: ChatStrings.reasoning,
                    icon: Icons.tips_and_updates_outlined,
                    isActive: widget.thinkingEnabled,
                    onPressed: () => widget.onThinkingChanged?.call(!widget.thinkingEnabled),
                  ),
                if (_selected?.supportSearch ?? false)
                  AideaChatInputButton(
                    buttonKey: const Key('aidea_chat_search'),
                    text: ChatStrings.onlineSearch,
                    icon: Icons.language_outlined,
                    isActive: widget.searchEnabled,
                    onPressed: () => widget.onSearchChanged?.call(!widget.searchEnabled),
                  ),
              ],
              onSubmit: (value) {
                widget.onSend(AideaChatSendRequest(
                  text: value,
                  thinking: widget.thinkingEnabled,
                  search: widget.searchEnabled,
                ));
                FocusManager.instance.primaryFocus?.unfocus();
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );

    final framed = RepaintBoundary(key: const Key('aidea_chat_boundary'), child: body);
    if (widget.formFactor == null) return framed;
    return AideaFormFactorScope(formFactor: widget.formFactor!, child: framed);
  }

  void _openModels() {
    openAideaBottomSheet(
      context,
      (context) {
        return AideaModelSheet(
          models: widget.models.where((e) => !e.disabled).toList(),
          initValue: widget.selectedModelId,
          onSelected: (selected) {
            if (selected != null) widget.onModelSelected?.call(selected);
            Navigator.pop(context);
          },
        );
      },
      heightFactor: 0.9,
    );
  }
}
