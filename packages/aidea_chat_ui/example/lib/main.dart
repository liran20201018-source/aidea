import 'dart:async';

import 'package:aidea_chat_ui/aidea_chat_ui.dart';
import 'package:flutter/material.dart';

import 'fixtures.dart';

enum DemoPreset { lightChat, darkChat, lightSheet, darkSheet }

void main() {
  final query = Uri.base.queryParameters;
  final preset = switch (query['preset']) {
    'dark' => DemoPreset.darkChat,
    'sheet' => DemoPreset.lightSheet,
    'dark-sheet' => DemoPreset.darkSheet,
    _ => DemoPreset.lightChat,
  };
  runApp(DemoApp(
    initialPreset: preset,
    autoOpen: query['chat'] == '1',
  ));
}

class DemoApp extends StatefulWidget {
  final DemoPreset initialPreset;
  final bool autoOpen;

  const DemoApp({super.key, this.initialPreset = DemoPreset.lightChat, this.autoOpen = false});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  late DemoPreset _preset = widget.initialPreset;

  ThemeMode get _mode =>
      _preset == DemoPreset.darkChat || _preset == DemoPreset.darkSheet ? ThemeMode.dark : ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AIdea 聊天界面演示',
      theme: AideaThemes.light(),
      darkTheme: AideaThemes.dark(),
      themeMode: _mode,
      home: _Entry(autoOpen: widget.autoOpen, preset: _preset, onOpen: (preset) => setState(() => _preset = preset)),
    );
  }
}

class _Entry extends StatefulWidget {
  final bool autoOpen;
  final DemoPreset preset;
  final ValueChanged<DemoPreset> onOpen;

  const _Entry({required this.autoOpen, required this.preset, required this.onOpen});

  @override
  State<_Entry> createState() => _EntryState();
}

class _EntryState extends State<_Entry> {
  @override
  void initState() {
    super.initState();
    if (widget.autoOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _push(widget.preset));
    }
  }

  void _push(DemoPreset preset) {
    widget.onOpen(preset);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => DemoChatPage(preset: preset)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('界面演示入口')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '这是从 AIdea 客户端抽出的聊天界面。对话、模型价格、搜索和思考都是内存假数据。'
            '没有账号、没有数据库、没有网络接口，也不会录音、拍照或上传文件。',
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: () => _push(DemoPreset.lightChat), child: const Text('打开浅色聊天')),
          const SizedBox(height: 8),
          FilledButton(onPressed: () => _push(DemoPreset.darkChat), child: const Text('打开深色聊天')),
          const SizedBox(height: 8),
          FilledButton(onPressed: () => _push(DemoPreset.lightSheet), child: const Text('打开浅色模型表')),
        ],
      ),
    );
  }
}

class DemoChatPage extends StatefulWidget {
  final DemoPreset preset;

  const DemoChatPage({super.key, required this.preset});

  @override
  State<DemoChatPage> createState() => _DemoChatPageState();
}

class _DemoChatPageState extends State<DemoChatPage> {
  late List<AideaChatMessage> _messages;
  late String _selectedId;
  bool _thinking = true;
  bool _search = true;
  bool _inputEnabled = true;
  int _seq = 0;
  int _run = 0;

  @override
  void initState() {
    super.initState();
    final dark = widget.preset == DemoPreset.darkChat || widget.preset == DemoPreset.darkSheet;
    _messages = dark ? darkFixtureMessages() : lightFixtureMessages();
    _selectedId = switch (widget.preset) {
      DemoPreset.darkChat || DemoPreset.darkSheet => 'claude-3.7',
      DemoPreset.lightSheet => 'gemini-2',
      DemoPreset.lightChat => 'deepseek',
    };
  }

  AideaModel? get _selected {
    for (final model in fixtureModels()) {
      if (model.id == _selectedId) return model;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AideaChatView(
      formFactor: AideaFormFactor.mobile,
      messages: _messages,
      models: fixtureModels(),
      selectedModelId: _selectedId,
      title: _selected?.name,
      thinkingEnabled: _thinking,
      searchEnabled: _search,
      inputEnabled: _inputEnabled,
      enableMedia: true,
      openModelSheet: widget.preset == DemoPreset.lightSheet || widget.preset == DemoPreset.darkSheet,
      onThinkingChanged: (value) => setState(() => _thinking = value),
      onSearchChanged: (value) => setState(() => _search = value),
      onModelSelected: (model) => setState(() => _selectedId = model.id),
      onStop: () {
        _run++;
        setState(() => _inputEnabled = true);
      },
      onVoice: () => _note('演示反馈：没有录音，也不会把语音发给任何服务。'),
      onMediaAction: (action) => _note('演示反馈：没有打开${_mediaLabel(action)}，也没有选择或上传文件。'),
      onLinkTap: (url) => _note('演示反馈：没有打开链接 $url'),
      onSearchHitTap: (hit) => _note('演示反馈：没有打开「${hit.title}」。'),
      onSend: _onSend,
    );
  }

  String _mediaLabel(AideaMediaAction action) {
    return switch (action) {
      AideaMediaAction.camera => '相机',
      AideaMediaAction.gallery => '相册',
      AideaMediaAction.file => '文件选择器',
    };
  }

  void _note(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _onSend(AideaChatSendRequest request) async {
    final id = ++_seq;
    final run = ++_run;
    setState(() {
      _inputEnabled = false;
      _messages = [
        ..._messages,
        AideaChatMessage(id: 'u-$id', role: AideaChatRole.user, text: request.text),
        AideaChatMessage(
          id: 'a-$id',
          role: AideaChatRole.assistant,
          text: '',
          turnState: AideaTurnState.searching,
          ready: false,
        ),
      ];
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || run != _run || _messages.last.id != 'a-$id') return;
    setState(() {
      _messages = [
        ..._messages.sublist(0, _messages.length - 1),
        AideaChatMessage(
          id: 'a-$id',
          role: AideaChatRole.assistant,
          text: '',
          turnState: AideaTurnState.thinking,
          ready: false,
        ),
      ];
    });
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || run != _run || _messages.last.id != 'a-$id') return;
    final flags = [
      if (request.thinking) '深度思考',
      if (request.search) '联网搜索',
    ].join('、');
    setState(() {
      _inputEnabled = true;
      _messages = [
        ..._messages.sublist(0, _messages.length - 1),
        AideaChatMessage(
          id: 'a-$id',
          role: AideaChatRole.assistant,
          turnState: request.thinking ? AideaTurnState.thinkingDone : AideaTurnState.idle,
          thinkingSeconds: request.thinking ? 0.4 : 0,
          reasoning: request.thinking ? '【演示】本地延时，不是推理服务。' : '',
          searchResults: request.search
              ? [
                  AideaSearchHit(
                    title: '假搜索结果',
                    source: 'https://example.invalid/mock',
                    content: '没有请求搜索接口。',
                    media: '本地',
                    index: '1',
                  ),
                ]
              : const [],
          text: '【演示假回复，不是模型输出，也没有联网】\n\n你发送了：${request.text}'
              '${flags.isEmpty ? '' : '\n\n当时打开的开关：$flags。'}',
        ),
      ];
    });
  }
}
