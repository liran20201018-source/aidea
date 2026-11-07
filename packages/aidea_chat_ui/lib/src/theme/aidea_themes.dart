// 摘自 lib/main.dart 的 createLightThemeData / createDarkThemeData。
// 原符号：createLightThemeData、createDarkThemeData。
// 适配：DialogTheme 在当前 Flutter 里是 DialogThemeData；字体通过包名加载，宿主不用再声明字体文件。
// 原文件用 PlatformTool.isMacOS() 关掉图标水波纹，这里不按桌面系统分支，避免把手机演示画成桌面特例。
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:flutter/material.dart';

const aideaFontFamily = 'AlibabaPuHuiTi';
const aideaFontPackage = 'aidea_chat_ui';

class AideaThemes {
  static ThemeData light() => _base(ThemeData.light(useMaterial3: true)).copyWith(
        extensions: const [CustomColors.light],
        textTheme: ThemeData(fontFamily: aideaFontFamily).textTheme.apply(
              fontFamily: aideaFontFamily,
              package: aideaFontPackage,
            ),
        dialogBackgroundColor: Colors.white,
      );

  static ThemeData dark() => _base(ThemeData.dark(useMaterial3: true)).copyWith(
        extensions: const [CustomColors.dark],
        textTheme: ThemeData(fontFamily: aideaFontFamily).primaryTextTheme.apply(
              fontFamily: aideaFontFamily,
              package: aideaFontPackage,
            ),
        dialogBackgroundColor: const Color.fromARGB(255, 48, 48, 48),
      );

  static ThemeData _base(ThemeData theme) {
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      dividerColor: Colors.transparent,
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: CustomSize.borderRadius,
        ),
        elevation: 0,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 9, 185, 85),
        ),
      ),
    );
  }
}
