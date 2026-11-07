// 原 ModelItem.buildAvatar 在有 http 地址时用 RemoteAvatar（cached_network_image），
// 否则用 RandomAvatar。ModelSwitcher 在没有头像地址时用 Initicon 首字母色块。
// 本包不访问网络，也不带厂商图标。有地址时仍只画首字母，避免把远程头像说成已内置。
import 'package:flutter/material.dart';

class AideaLetterAvatar extends StatelessWidget {
  final String label;
  final double size;

  const AideaLetterAvatar({super.key, required this.label, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final text = label.trim().isEmpty ? '?' : label.trim();
    final initial = String.fromCharCode(text.runes.first);
    final color = Colors.primaries[text.hashCode.abs() % Colors.primaries.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withAlpha(180),
        borderRadius: BorderRadius.circular(size),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
