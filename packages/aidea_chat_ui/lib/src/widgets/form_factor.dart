// 原逻辑在 lib/helper/platform.dart 的 PlatformTool.isDesktopAndWeb / isMobile。
// 桌面和 Web 走一套输入栏圆角，Android / iOS 走手机圆角。
// 宿主不一定是 Flutter 设备本身，所以增加显式覆盖；不覆盖时仍按原平台判断。
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

enum AideaFormFactor { mobile, desktop }

class AideaFormFactorScope extends InheritedWidget {
  final AideaFormFactor formFactor;

  const AideaFormFactorScope({
    super.key,
    required this.formFactor,
    required super.child,
  });

  static AideaFormFactor of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AideaFormFactorScope>();
    if (scope != null) {
      return scope.formFactor;
    }
    return detect();
  }

  static AideaFormFactor detect() {
    if (kIsWeb) {
      return AideaFormFactor.desktop;
    }
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        return AideaFormFactor.mobile;
      }
    } catch (_) {
      return AideaFormFactor.desktop;
    }
    return AideaFormFactor.desktop;
  }

  @override
  bool updateShouldNotify(AideaFormFactorScope oldWidget) => formFactor != oldWidget.formFactor;
}
