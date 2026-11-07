# AIdea 聊天界面包（第一阶段）

这个目录是从本仓库 Flutter 客户端里抽出的聊天界面，外加一个不连后端的演示程序。它只复用原界面的布局、颜色和组件结构，用来看界面、点交互。它不是官方 AIdea 服务，不能登录，也不会接原服务器。

宿主技术栈如果不是 Flutter，这个包不能直接嵌进 React Native、原生或网页工程。第二阶段才考虑按这个界面改写到别的框架。

原仓库许可证是 MIT，版权声明见本目录 `LICENSE`（Copyright (c) 2023 管宜尧）。抽取出的代码仍沿用该许可证。

## 目录

- 界面包：`packages/aidea_chat_ui`
- 演示程序：`packages/aidea_chat_ui/example`
- 原聊天页：`lib/page/chat/home_chat.dart`

## 单独运行

在仓库根目录执行。需要本机已安装 Flutter。

```bash
cd packages/aidea_chat_ui
flutter pub get
flutter analyze
flutter test

cd example
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

演示入口有三个按钮：浅色聊天、深色聊天、浅色模型表。聊天页左上角返回是路由自带的，点一下回到说明页。点标题打开模型表。点绿色的「深度思考」「联网搜索」只改本地开关。输入文字后右侧麦克风会变成发送。加号展开「拍照 / 附加照片 / 附加文档」，麦克风同理，都只弹出说明，不会打开相机、相册、录音，也不会上传。

带查询参数可以直接进入某一屏，方便截图：

```bash
cd packages/aidea_chat_ui/example
flutter run -d web-server --web-port 8877 --web-hostname 127.0.0.1
```

浏览器打开：

- `http://127.0.0.1:8877/?chat=1` 浅色聊天
- `http://127.0.0.1:8877/?chat=1&preset=dark` 深色聊天
- `http://127.0.0.1:8877/?chat=1&preset=sheet` 浅色模型表
- `http://127.0.0.1:8877/?chat=1&preset=dark-sheet` 深色模型表

网页构建：

```bash
cd packages/aidea_chat_ui/example
flutter build web --no-web-resources-cdn
```

Android 安装包（本机有 Android SDK 时）：

```bash
cd packages/aidea_chat_ui/example
flutter build apk --release
```

产物一般在 `example/build/app/outputs/flutter-apk/app-release.apk`。

## 宿主怎么接

下面是最小接法。主题、消息、模型列表都由宿主传入。包内不读登录态、数据库或接口。

```dart
import 'package:aidea_chat_ui/aidea_chat_ui.dart';
import 'package:flutter/material.dart';

class HostChat extends StatelessWidget {
  const HostChat({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AideaThemes.light(),
      darkTheme: AideaThemes.dark(),
      home: AideaChatView(
        title: 'DeepSeek',
        messages: const [
          AideaChatMessage(id: '1', role: AideaChatRole.user, text: '你好'),
        ],
        models: [
          AideaModel(
            'deepseek',
            'DeepSeek',
            'local',
            category: '最佳',
            supportReasoning: true,
            supportSearch: true,
          ),
        ],
        selectedModelId: 'deepseek',
        enableMedia: true,
        onSend: (request) {
          // request.text / request.thinking / request.search
        },
        onModelSelected: (model) {},
        onThinkingChanged: (on) {},
        onSearchChanged: (on) {},
        onMediaAction: (action) {},
        onVoice: () {},
        onStop: () {},
        onLinkTap: (url) {},
        onSearchHitTap: (hit) {},
      ),
    );
  }
}
```

手机圆角输入栏在 Android / iOS 上会自动使用。桌面和 Web 默认走原程序的桌面样式。演示和截图传入 `formFactor: AideaFormFactor.mobile`，用来看验收图里的手机栏。

字体是包内的阿里巴巴普惠体。`AideaThemes` 已经用包名引用，宿主不必再拷一份字体。

## 回调

| 回调 | 何时触发 |
| --- | --- |
| `onSend` | 点发送或回车。参数是 `AideaChatSendRequest`：正文、深度思考开关、联网搜索开关 |
| `onModelSelected` | 模型表里点了可选模型 |
| `onThinkingChanged` | 点「深度思考」 |
| `onSearchChanged` | 点「联网搜索」 |
| `onMediaAction` | 加号展开后点拍照、附加照片、附加文档。值为 `AideaMediaAction.camera` / `gallery` / `file` |
| `onVoice` | 输入框为空时点麦克风 |
| `onStop` | 点「停止输出」，或输入禁用时点右侧加载图标并确认 |
| `onLinkTap` | 点 Markdown 链接或引用角标 |
| `onSearchHitTap` | 点「已搜索到 N 个网页」后的条目 |

包不会因为这些回调去请求网络。引用角标的语法仍是原文的 `[citation:1]` 或 `【citation:1】`，数字对应 `searchResults` 的顺序。

消息上的搜索、思考状态用公开字段，不再写原程序 `Message.extra` 里的 JSON：

- `searchResults` 对应原来的 `search-results`
- `reasoning`、`thinkingSeconds` 对应 `reasoning`、`thinking_time_consumed`
- `turnState` 对应 `states` 的最后一项：`searching`、`thinking`、`thinkingDone`

## 和原文件的对应

| 本包 | 原文件与符号 | 处理 |
| --- | --- | --- |
| `CustomColors` | `lib/page/component/theme/custom_theme.dart` | 原样拷贝颜色 |
| `CustomSize` | `lib/page/component/theme/custom_size.dart` | 原样拷贝 |
| `AideaThemes` | `lib/main.dart` 的 `createLightThemeData` / `createDarkThemeData` | 保留 Material 3、透明顶栏、绿色文字按钮。`DialogTheme` 改成当前 Flutter 的 `DialogThemeData` |
| `ChatStrings` | `lib/lang/lang.dart` 中文表 | 只留下聊天用到的中文，不初始化 `flutter_localization` |
| `AideaModel` / `AideaModelPrice` | `lib/repo/model/model.dart` 的 `Model`、`ModelPrice` | 字段、`uid`、`copyWith`、价格 JSON 一致，类名改了 |
| `AideaModelSheet` | `lib/page/component/model_item.dart` 的 `ModelItem.searchModels`、`buildItem`、`buildTag` | 搜索和标签规则保持一致 |
| `GroupListWidget` | `lib/page/component/group_list_widget.dart` | 分组和圆角底色保持一致。当前 Flutter 要求 `ListTile` 放在 `Material` 上，所以底色改由 `Material` 绘制 |
| `openAideaBottomSheet` | `lib/page/component/dialog.dart` 的 `openModalBottomSheet`、`buildBottomSheetTopBar`，以及 `bottom_sheet_box.dart` | 去掉底部导航显隐事件 |
| `AideaMarkdown` / `CitationSyntax` | `lib/page/component/chat/markdown.dart`、`markdown/citation.dart` | 引用角标和正文样式保留 |
| `CodeElementBuilder` | `lib/page/component/chat/markdown/code.dart` | 高亮保留；复制改用系统剪贴板 |
| `AideaThinkingCard` | `lib/page/component/chat/thinking_card.dart` | 保留折叠和「用时」 |
| `AideaSearchResult` | `lib/page/component/chat/search_result.dart` | 保留「已搜索到 N 个网页」和条目排版 |
| `AideaChatInput` / 按钮 | `lib/page/component/chat/chat_input.dart`、`chat_input_button.dart` | 保留输入栏、加号、麦克风/发送、绿色芯片 |
| `AideaMessageList` | `lib/page/component/chat/chat_preview.dart` 的 `_buildMessageBox` | 保留左右气泡、Markdown、搜索条、思考条 |
| `AideaStopButton` | `lib/page/chat/component/stop_button.dart` | 原样结构 |
| `AideaChatView` | `lib/page/chat/home_chat.dart` 的 `build`、`buildAppBar`、`buildChatComponents`；模型表入口同 `model_switcher.dart` 与 `openSelectModelDialog` | 去掉 Bloc、房间、上传和接口 |

当前 `main` 提交是 `cea454f`（Merge pull request #146）。对照的是这一版源码，不是更早的安装包。

## 和验收截图不一致的地方

截图是手机上的浅色 DeepSeek、深色 Claude，以及可搜索的模型底表。下面这些差异来自当前源码，没有为了贴图去改样式。

- 顶栏标题在 `HomeChatPage.buildAppBar` 里只有文字，没有下拉箭头。截图标题旁边有小箭头。本包同样只有可点击的文字。返回键是路由提供的，源码没有手写返回图标。
- 状态栏时间是系统画的，Flutter 页面里没有。
- 免费筛选在语言包里是「限免」（`AppLocale.free`），截图写成「免费」。本包用「限免」。
- 思考条用的是 `Icons.keyboard_arrow_up`，收起时箭头朝上。搜索条才是向右的 `keyboard_arrow_right`。
- 助手气泡背景是透明的，用户气泡是浅灰或深灰，颜色值来自 `CustomColors.light` / `dark`。
- 模型分组标题来自数据的 `category`，源码不写死「最佳」「Mistral」。截图深色表里的分组，字形更接近语言包里的「上新」，演示数据写成「最近上新」。
- 截图里的厂牌头像是原程序用网络地址加载的 `RemoteAvatar`。仓库里没有这些图标。没有地址时，模型切换按钮用首字母色块（`Initicon`），模型行用 `RandomAvatar`。演示不访问网络，统一用首字母色块，所以不会出现截图里的厂牌标志。
- 加号在源码里要同时满足模型支持视觉、`Ability.supportImageUploader` 和 `Ability.supportWebSocket`。截图里的 DeepSeek 标签没有「视觉」，但输入栏仍有加号。演示把 `enableMedia` 设为 true，好让这个按钮可以被点到；这是宿主开关，不是源码的默认条件。
- 绿色芯片在源码里是 `linkColor`（`#09B955`）加半透明底，文字和图标变绿。截图看起来更实。本包保持源码算法。
- 演示里的两段对话、七条和五条假网页、39.9 秒和 7.3 秒，是按截图填的内存数据。浅色表里能看清的价格按图填写。深色表下半截被裁切，Mistral 之后的价格是占位。原仓库没有这份模型目录，这些数字不是厂商标价。

## 故意没抽进来的依赖

账号、路由、数据库、支付、上传、服务端都不进入本包。具体包括：

`go_router`、`flutter_bloc`、`provider`、`sqflite`、`dio`、`http`、`dart_openai`、`APIServer`、`SettingRepository`、`ImageUploader`、`qiniu_flutter_sdk`、`sign_in_with_apple`、`fluwx`、`tobias`、`flutter_stripe`、`in_app_purchase`、`camera`、`camerawesome`、`file_picker`、`record`、`bot_toast`、`quickalert`、`flutter_localization`、`cached_network_image`、`flutter_cache_manager`、`flutter_math_fork`、`url_launcher`。

因此没有公式排版、没有网络图片预览、没有长按分享菜单、没有翻译、没有语音播放、没有空状态 Lottie。代码块高亮还在，复制只进本机剪贴板。

原 `SearchResult` 在 `build` 里创建并不释放的 `AnimationController`。搜索中的转圈改成了会在销毁时停掉的动画，外观仍是 `Icons.sync`。

## 演示数据和真实能力的边界

`example/lib/fixtures.dart` 和发送后的回复都在内存里，类名和界面文案都标明是假数据。

不会发生这些事：

- 账号注册或官方 AIdea 登录
- 读写原应用数据库
- 调用聊天、搜索、模型列表接口
- 使用任何 API 密钥
- 打开相机、麦克风或文件选择器
- 把图片、语音或文档传到外部

点媒体、麦克风、链接时，演示只弹出「没有打开……」的说明。

## 许可证和第三方资源

- 抽出的 Dart 代码：MIT，保留 `LICENSE` 中的 Copyright (c) 2023 管宜尧。原 README 另写 Copyright (c) 2025, mylxsw，以仓库根目录 `LICENSE` 为准。
- 字体：`assets/fonts/AlibabaPuHuiTi-3-55-Regular.ttf` 与 `AlibabaPuHuiTi-3-85-Bold.ttf` 从本仓库 `assets/fonts` 复制。仓库内没有单独的字体许可证。该字体是阿里巴巴普惠体，不是 MIT 代码的一部分。使用前请自行核对阿里巴巴公布的字体授权。
- 界面依赖：`flutter_markdown` 0.7.6+2、`markdown` 7.3.0、`flutter_highlight` 0.7.0、`loading_animation_widget` 1.3.0、`auto_size_text` 3.0.0，版本与上游 `pubspec.lock` 一致。它们各自的许可证在 pub 缓存里。
- 没有拷贝微信、支付宝、Stripe 等支付图标，也没有把厂牌标志打进包里。演示不声称自己是这些服务的官方客户端。

## 还没在真机上核对的部分

没有 Android 模拟器或真机时，系统键盘是否挡住输入栏、刘海和底部安全区、相机/麦克风权限弹窗都没有在原生界面上点过。这些控件在桌面测试里只验证了回调。网页构建可以看布局，但不能代替原生键盘和安全区。
