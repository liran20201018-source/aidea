// 摘自 lib/page/component/chat/search_result.dart
// 原符号：SearchResult、点击后打开的条目排版（原 ItemSearchSelector 里的列）。
// 适配：搜索中的旋转图标改为可释放的动画；点开后的列表保留原条目结构，
// 不再依赖 ItemSearchSelector、CachedNetworkImageEnhanced、launchUrlString。
import 'package:aidea_chat_ui/src/l10n/chat_strings.dart';
import 'package:aidea_chat_ui/src/model/chat_message.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:aidea_chat_ui/src/widgets/bottom_sheet.dart';
import 'package:flutter/material.dart';

class AideaSearchResult extends StatelessWidget {
  final List<AideaSearchHit> searchResults;
  final bool isSearching;
  final ValueChanged<AideaSearchHit>? onTapHit;

  const AideaSearchResult({
    super.key,
    required this.searchResults,
    this.isSearching = false,
    this.onTapHit,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    return SizedBox(
      width: double.infinity,
      child: isSearching
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ChatStrings.robotIsSearching,
                  style: TextStyle(fontSize: 14, color: customColors.weakTextColorLess),
                ),
                const SizedBox(width: 5),
                _SpinIcon(color: customColors.weakTextColorLess),
              ],
            )
          : GestureDetector(
              onTap: () {
                openAideaBottomSheet(
                  context,
                  (context) {
                    return ListView(
                      children: [
                        for (final e in searchResults)
                          InkWell(
                            onTap: () => onTapHit?.call(e),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                              child: _SearchHitTile(hit: e, colors: customColors),
                            ),
                          ),
                      ],
                    );
                  },
                  heightFactor: 0.9,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ChatStrings.searchedPages(searchResults.length),
                    style: TextStyle(fontSize: 14, color: customColors.weakTextColorLess),
                  ),
                  Icon(
                    Icons.keyboard_arrow_right,
                    size: 16,
                    color: customColors.weakTextColorLess,
                  ),
                ],
              ),
            ),
    );
  }
}

class _SearchHitTile extends StatelessWidget {
  final AideaSearchHit hit;
  final CustomColors colors;

  const _SearchHitTile({required this.hit, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      hit.media,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        color: colors.weakTextColorLess,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colors.weakTextColorLess,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(4),
              child: Text(
                hit.index,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          hit.title,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(color: colors.weakTextColor),
        ),
        const SizedBox(height: 4),
        Text(
          hit.content,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(color: colors.weakTextColorLess),
          textScaler: const TextScaler.linear(0.8),
        ),
      ],
    );
  }
}

class _SpinIcon extends StatefulWidget {
  final Color? color;

  const _SpinIcon({this.color});

  @override
  State<_SpinIcon> createState() => _SpinIconState();
}

class _SpinIconState extends State<_SpinIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 3),
    vsync: this,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(Icons.sync, size: 16, color: widget.color),
    );
  }
}
