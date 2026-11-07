// 摘自 lib/page/component/dialog.dart 的 openModalBottomSheet、buildBottomSheetTopBar
// 以及 lib/page/component/bottom_sheet_box.dart 的 BottomSheetBox。
// 去掉 GlobalEvent 对底部导航栏的显隐通知。桌面底边距改由 AideaFormFactor 判断。
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:aidea_chat_ui/src/widgets/form_factor.dart';
import 'package:flutter/material.dart';

Future<T?> openAideaBottomSheet<T>(
  BuildContext context,
  Widget Function(BuildContext context) builder, {
  bool useSafeArea = false,
  bool isScrollControlled = true,
  double heightFactor = 0.5,
  String? title,
}) {
  final customColors = Theme.of(context).extension<CustomColors>()!;

  return showModalBottomSheet<T>(
    context: context,
    useSafeArea: useSafeArea,
    isScrollControlled: isScrollControlled,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: CustomSize.radius),
    ),
    elevation: 0,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return AideaBottomSheetBox(
        child: FractionallySizedBox(
          heightFactor: heightFactor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildAideaBottomSheetTopBar(customColors),
              if (title != null)
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: customColors.weakTextColorPlus,
                  ),
                ),
              if (title != null) const SizedBox(height: 10),
              Expanded(child: builder(context)),
            ],
          ),
        ),
      );
    },
  );
}

class AideaBottomSheetBox extends StatelessWidget {
  final Widget child;

  const AideaBottomSheetBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final desktop = AideaFormFactorScope.of(context) == AideaFormFactor.desktop;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: desktop ? 10 : (MediaQuery.of(context).viewInsets.bottom > 0 ? 10 : 0),
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: CustomSize.radius, bottom: CustomSize.radius),
              color: customColors.backgroundColor,
            ),
            padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
            child: SafeArea(child: child),
          ),
        ),
      ),
    );
  }
}

Center buildAideaBottomSheetTopBar(CustomColors customColors) {
  return Center(
    child: FractionallySizedBox(
      widthFactor: 0.25,
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 10),
        height: 4,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 192, 192, 192),
          borderRadius: CustomSize.borderRadius,
          border: Border.all(
            color: Colors.black12,
            width: 0.5,
          ),
        ),
      ),
    ),
  );
}
