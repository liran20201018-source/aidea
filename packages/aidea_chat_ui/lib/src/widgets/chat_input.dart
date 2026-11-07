// 摘自 lib/page/component/chat/chat_input.dart
// 原符号：ChatInput、buildUploadButtons、_buildSendOrVoiceButton、扩展栏里的拍照/相册/文档按钮。
// 适配：不调用相机、FilePicker、VoiceRecord、SettingRepository、go_router、Ability。
// 加号仍展开原按钮；麦克风和媒体按钮只向外回调。
import 'package:aidea_chat_ui/src/l10n/chat_strings.dart';
import 'package:aidea_chat_ui/src/model/chat_message.dart';
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:aidea_chat_ui/src/widgets/chat_input_button.dart';
import 'package:aidea_chat_ui/src/widgets/form_factor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AideaChatInput extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  final bool inputEnabled;
  final bool enableMedia;
  final ValueChanged<AideaMediaAction>? onMediaAction;
  final VoidCallback? onVoice;
  final VoidCallback? onStopGenerate;
  final String hintText;
  final List<Widget> tools;
  final ValueChanged<bool>? onFocusChange;

  const AideaChatInput({
    super.key,
    required this.onSubmit,
    required this.inputEnabled,
    this.enableMedia = false,
    this.onMediaAction,
    this.onVoice,
    this.onStopGenerate,
    this.hintText = ChatStrings.askMeAnyQuestion,
    this.tools = const [],
    this.onFocusChange,
  });

  @override
  State<AideaChatInput> createState() => _AideaChatInputState();
}

class _AideaChatInputState extends State<AideaChatInput> {
  final TextEditingController _textController = TextEditingController();
  late final FocusNode _focusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (!HardwareKeyboard.instance.isShiftPressed && event.logicalKey.keyLabel == 'Enter') {
        if (event is KeyDownEvent && widget.inputEnabled) {
          _handleSubmitted(_textController.text.trim());
        }
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
  );

  var showExtensionButtons = false;
  var inputFocused = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final desktop = AideaFormFactorScope.of(context) == AideaFormFactor.desktop;
    final mobile = !desktop;

    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: SafeArea(
        bottom: false,
        child: Container(
          margin: desktop ? const EdgeInsets.all(8) : null,
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          decoration: BoxDecoration(
            color: customColors.chatInputAreaBackground,
            borderRadius: desktop
                ? BorderRadius.circular(CustomSize.radiusValue)
                : const BorderRadius.only(
                    topLeft: Radius.circular(CustomSize.radiusValue * 2),
                    topRight: Radius.circular(CustomSize.radiusValue * 2),
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(-1, -1),
                blurRadius: CustomSize.radiusValue,
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Focus(
                      onFocusChange: (hasFocus) {
                        setState(() => inputFocused = hasFocus);
                        widget.onFocusChange?.call(hasFocus);
                      },
                      child: TextFormField(
                        key: const Key('aidea_chat_input'),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        maxLines: inputFocused ? 10 : 3,
                        minLines: 1,
                        maxLength: 150000,
                        focusNode: _focusNode,
                        controller: _textController,
                        enabled: widget.inputEnabled,
                        style: const TextStyle(fontSize: CustomSize.defaultHintTextSize),
                        decoration: InputDecoration(
                          hintText: widget.hintText,
                          hintStyle: TextStyle(
                            fontSize: CustomSize.defaultHintTextSize,
                            color: customColors.textfieldHintColor,
                          ),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (widget.inputEnabled && widget.enableMedia) _plusButton(customColors),
                                ...widget.tools,
                              ],
                            ),
                          ),
                        ),
                        _sendOrVoice(customColors),
                      ],
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: showExtensionButtons && widget.inputEnabled ? 80 : 0,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (widget.enableMedia)
                              AideaChatInputSquareButton(
                                icon: Icons.camera_alt,
                                text: ChatStrings.takePhoto,
                                onPressed: () => widget.onMediaAction?.call(AideaMediaAction.camera),
                              ),
                            if (widget.enableMedia)
                              AideaChatInputSquareButton(
                                icon: Icons.photo_library,
                                text: ChatStrings.photoLibrary,
                                onPressed: () => widget.onMediaAction?.call(AideaMediaAction.gallery),
                              ),
                            if (widget.enableMedia)
                              AideaChatInputSquareButton(
                                icon: Icons.upload_file_sharp,
                                text: ChatStrings.fileLibrary,
                                onPressed: () => widget.onMediaAction?.call(AideaMediaAction.file),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: mobile && inputFocused ? 8 : 6),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _plusButton(CustomColors customColors) {
    return InkWell(
      key: const Key('aidea_chat_plus'),
      onTap: () => setState(() => showExtensionButtons = !showExtensionButtons),
      child: Container(
        decoration: BoxDecoration(
          color: customColors.tagsBackground,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(4),
        child: AnimatedRotation(
          turns: showExtensionButtons ? 0.125 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.add,
            color: customColors.chatInputPanelText,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _sendOrVoice(CustomColors customColors) {
    if (!widget.inputEnabled) {
      return InkWell(
        key: const Key('aidea_chat_stop_icon'),
        onTap: () {
          if (widget.onStopGenerate == null) return;
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text(ChatStrings.confirmStopOutput),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text(ChatStrings.cancel)),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onStopGenerate!();
                  },
                  child: const Text(ChatStrings.ok),
                ),
              ],
            ),
          );
        },
        child: LoadingAnimationWidget.beat(
          color: customColors.linkColor ?? Colors.green,
          size: 20,
        ),
      );
    }

    if (_textController.text == '') {
      return IconButton(
        key: const Key('aidea_chat_mic'),
        onPressed: widget.onVoice,
        icon: Icon(Icons.mic_none_outlined, color: customColors.chatInputPanelText),
        splashRadius: 20,
        color: customColors.chatInputPanelText,
      );
    }

    return IconButton(
      key: const Key('aidea_chat_send'),
      onPressed: () => _handleSubmitted(_textController.text.trim()),
      icon: Icon(Icons.send, color: customColors.chatInputPanelText),
      splashRadius: 20,
      color: customColors.chatInputPanelText,
    );
  }

  void _handleSubmitted(String text) {
    if (text == '') return;
    widget.onSubmit(text);
    _textController.clear();
  }
}
