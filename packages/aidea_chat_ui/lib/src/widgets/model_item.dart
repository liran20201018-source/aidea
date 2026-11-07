// 摘自 lib/page/component/model_item.dart
// 原符号：ModelItem、searchModels、buildItem、buildPriceBlock、buildTag、formatTags
// 适配：登录拦截不再走 showErrorMessage；长按说明和价格备注用 AlertDialog，不再用 quickalert。
// 头像见 AideaLetterAvatar。关键字匹配字符串与原 searchModels 相同（含 vision视觉看图 等）。
import 'package:aidea_chat_ui/src/l10n/chat_strings.dart';
import 'package:aidea_chat_ui/src/model/aidea_model.dart';
import 'package:aidea_chat_ui/src/theme/custom_size.dart';
import 'package:aidea_chat_ui/src/theme/custom_theme.dart';
import 'package:aidea_chat_ui/src/widgets/group_list_widget.dart';
import 'package:aidea_chat_ui/src/widgets/letter_avatar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AideaModelSheet extends StatefulWidget {
  final List<AideaModel> models;
  final String? initValue;
  final ValueChanged<AideaModel?> onSelected;

  const AideaModelSheet({
    super.key,
    required this.models,
    required this.onSelected,
    this.initValue,
  });

  @override
  State<AideaModelSheet> createState() => _AideaModelSheetState();
}

class _AideaModelSheetState extends State<AideaModelSheet> {
  String keyword = '';
  String selectedTag = '';

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final tags = _uniqueTags().map((tag) {
      return InkWell(
        onTap: () {
          setState(() {
            selectedTag = selectedTag == tag ? '' : tag;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: buildAideaTag(
            customColors,
            tag,
            tagTextColor: selectedTag == tag ? customColors.linkColor : null,
          ),
        ),
      );
    }).toList();

    if (widget.models.isEmpty) {
      return const Center(
        child: Text(
          'No model available\nPlease login first!',
          textAlign: TextAlign.center,
        ),
      );
    }

    return RepaintBoundary(
      key: const Key('aidea_model_sheet_boundary'),
      child: Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
          decoration: BoxDecoration(
            color: customColors.textfieldBackgroundColor,
            borderRadius: CustomSize.borderRadius,
          ),
          child: TextField(
            key: const Key('aidea_model_search'),
            textAlignVertical: TextAlignVertical.center,
            style: TextStyle(color: customColors.dialogDefaultTextColor),
            decoration: InputDecoration(
              hintText: ChatStrings.search,
              hintStyle: TextStyle(color: customColors.textfieldHintColor),
              prefixIcon: Icon(
                Icons.search,
                color: customColors.weakTextColor?.withAlpha(150),
              ),
              isDense: true,
              border: InputBorder.none,
            ),
            onChanged: (value) => setState(() => keyword = value.toLowerCase()),
          ),
        ),
        if (tags.isNotEmpty)
          Container(
            padding: const EdgeInsets.only(top: 5, left: 5, right: 5, bottom: 5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: tags),
            ),
          ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 15),
            child: GroupListWidget(
              items: _searchModels(),
              showTitle: true,
              groupKey: (item) => item.category,
              itemBuilder: (item) => _buildItem(context, item, customColors),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Set<String> _uniqueTags() {
    var uniqueTags = <String>{};
    for (var model in widget.models) {
      if (model.tag != null) {
        uniqueTags.addAll(model.tag!.split(',').where((e) => e.isNotEmpty));
      }
      if (model.isRecommend) uniqueTags.add(ChatStrings.recommendTag);
      if (model.isNew) uniqueTags.add(ChatStrings.newTag);
      if (model.supportVision) uniqueTags.add(ChatStrings.visionTag);
      if (model.supportReasoning) uniqueTags.add(ChatStrings.reasoning);
      if (model.supportSearch) uniqueTags.add(ChatStrings.search);
      if (model.modelPrice.isFree) uniqueTags.add(ChatStrings.free);
    }
    return uniqueTags;
  }

  List<AideaModel> _searchModels() {
    var models = keyword.isEmpty
        ? widget.models
        : widget.models.where((e) {
            var matchText = e.name + (e.description ?? '') + (e.shortName ?? '') + (e.tag ?? '') + (e.category);
            if (e.supportVision) matchText += 'vision视觉看图';
            if (e.isNew) matchText += 'new新';
            if (e.isRecommend) matchText += 'recommend推荐';
            if (e.supportReasoning) matchText += 'reasoning推理';
            if (e.supportSearch) matchText += 'search搜索';
            if (e.modelPrice.isFree) matchText += 'free免费';
            return matchText.toLowerCase().contains(keyword);
          }).toList();

    if (selectedTag.isNotEmpty) {
      models = models.where((e) => _tagsOf(e).contains(selectedTag)).toList();
    }
    return models;
  }

  List<String> _tagsOf(AideaModel e) {
    var tags = <String>[];
    if (e.tag != null) {
      tags.addAll(e.tag!.split(',').where((e) => e.isNotEmpty));
    }
    if (e.isRecommend) tags.add(ChatStrings.recommendTag);
    if (e.isNew) tags.add(ChatStrings.newTag);
    if (e.supportVision) tags.add(ChatStrings.visionTag);
    if (e.supportReasoning) tags.add(ChatStrings.reasoning);
    if (e.supportSearch) tags.add(ChatStrings.search);
    if (e.modelPrice.isFree) tags.add(ChatStrings.free);
    return tags;
  }

  Widget _buildItem(BuildContext context, AideaModel item, CustomColors customColors) {
    final modelPrice = item.modelPrice;
    final selected = widget.initValue == item.uid();
    var tags = <Widget>[];
    if (modelPrice.isFree) {
      tags.add(buildAideaTag(customColors, ChatStrings.free, tagTextColor: selected ? customColors.linkColor : null));
    }
    if (item.tag != null) {
      for (final tt in item.tag!.split(',').where((e) => e.isNotEmpty)) {
        tags.add(buildAideaTag(customColors, tt, tagTextColor: selected ? customColors.linkColor : null));
      }
    }
    if (item.supportVision) {
      tags.add(buildAideaTag(customColors, ChatStrings.visionTag, tagTextColor: selected ? customColors.linkColor : null));
    }
    if (item.supportReasoning) {
      tags.add(buildAideaTag(customColors, ChatStrings.reasoning, tagTextColor: selected ? customColors.linkColor : null));
    }
    if (item.supportSearch) {
      tags.add(buildAideaTag(customColors, ChatStrings.search, tagTextColor: selected ? customColors.linkColor : null));
    }
    if (item.isNew) {
      tags.add(buildAideaTag(customColors, ChatStrings.newTag, tagTextColor: selected ? customColors.linkColor : null));
    }

    return ListTile(
      key: Key('aidea_model_${item.id}'),
      leading: Stack(
        children: [
          AideaLetterAvatar(label: item.shortName ?? item.name, size: 48),
          if (item.userNoPermission)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: CustomSize.borderRadiusAll,
              ),
              child: const Icon(Icons.lock_outline, color: Colors.white, size: 24),
            ),
        ],
      ),
      contentPadding: EdgeInsets.zero,
      title: AutoSizeText(
        item.name,
        minFontSize: 10,
        maxFontSize: 15,
        maxLines: 1,
        style: TextStyle(
          color: selected ? customColors.linkColor : (item.userNoPermission ? customColors.weakTextColorLess : null),
          fontWeight: selected ? FontWeight.bold : null,
        ),
      ),
      subtitle: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: tags),
            ),
          ),
          _priceBlock(customColors, item, modelPrice, selected),
        ],
      ),
      onTap: () {
        if (item.userNoPermission) {
          showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              content: const Text(ChatStrings.modelNeedSignIn),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text(ChatStrings.gotIt)),
              ],
            ),
          );
          return;
        }
        widget.onSelected(item);
      },
      onLongPress: () {
        if (item.description == null || item.description == '') return;
        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            content: Text(item.description!),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text(ChatStrings.gotIt)),
            ],
          ),
        );
      },
    );
  }

  Widget _priceBlock(CustomColors customColors, AideaModel model, AideaModelPrice item, bool selected) {
    if (item.isFree) return const SizedBox();

    var priceText = '';
    if (item.input > 0 || item.output > 0) {
      priceText += '${ChatStrings.input} ￠${item.input}, ${ChatStrings.output} ￠${item.output}';
    }
    if (item.request > 0) {
      priceText += '${priceText == '' ? '' : ', '}${ChatStrings.perRequest} ￠${item.request}';
    }
    if (item.search > 0) {
      priceText += '${priceText == '' ? '' : ', '}${ChatStrings.perSearch} ￠${item.search}';
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            priceText,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: selected ? customColors.linkColor : customColors.weakTextColor?.withAlpha(150),
            ),
          ),
        ),
        if (item.hasNote) ...[
          const SizedBox(width: 5),
          InkWell(
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(item.note),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text(ChatStrings.gotIt)),
                  ],
                ),
              );
            },
            child: Icon(
              Icons.help_outline,
              size: 12,
              color: customColors.weakLinkColor?.withAlpha(50),
            ),
          ),
        ],
      ],
    );
  }
}

Widget buildAideaTag(
  CustomColors customColors,
  String tag, {
  double? tagFontSize,
  Color? tagTextColor,
}) {
  return Container(
    padding: const EdgeInsets.only(right: 5),
    child: Text(
      '#$tag',
      style: TextStyle(
        fontSize: tagFontSize ?? 11,
        color: tagTextColor ?? customColors.weakTextColor?.withAlpha(150),
      ),
    ),
  );
}
