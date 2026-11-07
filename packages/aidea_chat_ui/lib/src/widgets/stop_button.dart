// 摘自 lib/page/chat/component/stop_button.dart
// 原符号：StopButton
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class AideaStopButton extends StatelessWidget {
  final Function()? onPressed;
  final String label;

  const AideaStopButton({super.key, this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return TextButton.icon(
      style: ButtonStyle(
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        iconColor: const WidgetStatePropertyAll(Colors.red),
        backgroundColor: WidgetStatePropertyAll(customColors.backgroundContainerColor),
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: customColors.textfieldLabelColor,
        ),
      ),
      icon: const Icon(
        Icons.stop_circle_outlined,
        size: 13,
      ),
      onPressed: onPressed,
    );
  }
}
