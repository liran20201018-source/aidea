// 摘自 lib/page/component/chat/chat_input_button.dart
// 原符号：ChatInputButton、ChatInputSquareButton
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class AideaChatInputButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final Key? buttonKey;

  const AideaChatInputButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.buttonKey,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return IconButton(
      key: buttonKey,
      onPressed: onPressed,
      icon: Container(
        decoration: BoxDecoration(
          color: isActive ? customColors.linkColor?.withAlpha(100) : null,
          borderRadius: BorderRadius.circular(CustomSize.radiusValue * 2),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? customColors.linkColor : customColors.chatInputPanelText,
              size: 18,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? customColors.linkColor : customColors.chatInputPanelText,
              ),
            ),
          ],
        ),
      ),
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}

class AideaChatInputSquareButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final String text;

  const AideaChatInputSquareButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: IconButton(
        onPressed: onPressed,
        icon: Container(
          decoration: BoxDecoration(
            color: isActive ? customColors.linkColor?.withAlpha(100) : null,
            borderRadius: BorderRadius.circular(CustomSize.radiusValue * 2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? customColors.linkColor : customColors.chatInputPanelText,
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isActive ? customColors.linkColor : customColors.chatInputPanelText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
