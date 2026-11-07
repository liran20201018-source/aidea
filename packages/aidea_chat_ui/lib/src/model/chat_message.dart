// 原聊天消息是 lib/repo/model/message.dart 的 Message。
// 搜索结果、思考正文、耗时写在 extra JSON（search-results、reasoning、states、thinking_time_consumed），
// 由 lib/page/component/chat/chat_preview.dart 的 _buildMessageBox 解析。
// 本包改成公开字段，渲染分支仍按那几段状态来，宿主不用拼内部 JSON，也不用引用仓库里的 Message。

enum AideaChatRole { user, assistant, system }

/// 对应原消息 extra.states 的最后一项，以及 thinking-done。
enum AideaTurnState { idle, searching, thinking, thinkingDone }

enum AideaMediaAction { camera, gallery, file }

class AideaSearchHit {
  final String title;
  final String source;
  final String content;
  final String media;
  final String icon;
  final String index;

  const AideaSearchHit({
    required this.title,
    required this.source,
    required this.content,
    required this.media,
    this.icon = '',
    required this.index,
  });
}

class AideaChatMessage {
  final String id;
  final AideaChatRole role;
  final String text;
  final bool markdown;
  final List<AideaSearchHit> searchResults;
  final String reasoning;
  final double thinkingSeconds;
  final AideaTurnState turnState;
  final bool ready;
  final bool failed;
  final String? senderName;

  const AideaChatMessage({
    required this.id,
    required this.role,
    required this.text,
    this.markdown = true,
    this.searchResults = const [],
    this.reasoning = '',
    this.thinkingSeconds = 0,
    this.turnState = AideaTurnState.idle,
    this.ready = true,
    this.failed = false,
    this.senderName,
  });
}

class AideaChatSendRequest {
  final String text;
  final bool thinking;
  final bool search;

  const AideaChatSendRequest({
    required this.text,
    required this.thinking,
    required this.search,
  });
}
