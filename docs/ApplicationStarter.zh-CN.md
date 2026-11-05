# 原生应用起步模板与 AI 开发入口

[English](ApplicationStarter.md)

新建原生 Qt 应用从 [`examples/native-notes`](../examples/native-notes) 开始。
它直接使用 canonical `Kos.Ui`，不依赖 Quickshell、NextKde 服务、KWin 协议或
另一个应用仓库。默认英文。这是小型应用参考，不是生产级存储框架。

## 修改前先读

依次阅读 [AGENTS.md](../AGENTS.md)、[Architecture](Architecture.zh-CN.md)、
[Components](Components.zh-CN.md)、[GalleryDesign](GalleryDesign.zh-CN.md)、
[WindowControls](WindowControls.zh-CN.md)、[Dialogs](Dialogs.zh-CN.md)、
[Popovers](Popovers.zh-CN.md) 和 [Settings](Settings.zh-CN.md)。当前材质契约优先于
历史光学实验配方。业务逻辑和持久化不得放入 `shared/qml`。

| 可复制或引用的内容 | 用途 |
| --- | --- |
| `examples/native-notes/CMakeLists.txt`、`src/main.cpp`、`data/` | 原生入口、资源模块、应用标识、desktop/icon 安装；新应用须统一改名 |
| `src/NotesAdapter.*` | 类型化边界、校验、原子 JSON 写入及失败恢复；替换为真实业务 adapter |
| `qml/Main.qml` | 列表、筛选、选择、详情、空/加载/失败状态与退出协调 |
| `qml/EditorWindow.qml` | 独立非模态窗口、编辑草稿、保存失败、保存/不保存/取消关闭保护 |
| `qml/Preferences.qml` | canonical 设置分组；草稿/提交/取消；成功落盘后才生效 |
| `shared/qml/foundation/KosAppWindow.qml` | 通过 `KosAppWindow` 使用；不要复制其中的控件实现 |
| Gallery 示例 | 核对材质所在层后复制 API 用法；光学页、示例图、实验滑块和独立玻璃卡片不是应用页面模板 |

对比 NkMail 后，保留窗口 chrome、业务 adapter 和独立编辑生命周期的分层。
没有移入邮件模型、服务、凭据、账户、协议或富文本编辑业务。NkMail 只是只读
应用参考，不是此模板的依赖，也不是 canonical UI 库。

## 推荐外壳

`KosAppWindow` 是新增 API，旧 `KosApplicationWindow` 的行为保持兼容。
新外壳使用不透明、平直贴边的矩形内容，不自绘应用外圆角、边框或阴影。
它提供 36px 标题行、canonical `KosWindowControls`、系统拖动、双击最大化
（动作列表含 maximize 时）及 canonical 缩放手柄。按应用调整继承的 title、
width、height、minimumWidth、minimumHeight、header、footer 和内容。
默认 960×660 只是初始建议；最小尺寸应依据布局，保留用户缩放。若需要保存
窗口尺寸，应由应用 adapter 实现；本模板不持久化窗口几何。编辑窗口采用独立
的 720×540 初始尺寸。

`windowActions` 声明真实且不重复的有序动作，可为
`["maximize", "minimize", "close"]`、`["close"]` 或 `[]`。
`windowControls` 暴露 canonical 控件及真实 `buttonLayout`，不得按固定按钮数
猜坐标。`titleBarHeight` 控制标题行高度。覆盖 `header` 时，应用必须自供
canonical 控件和拖动区域，并移除旧行的 adapter 声明。

`windowControlsAdapter` 默认 null。可选的应用级 adapter 接收窗口及暴露的控件，
只有可观察属性 `available` 和 `takeoverConfirmed` 都为 true 才隐藏客户端绘制；
可选 `hoverGlyphs` 传递共享图标偏好。服务丢失必须立即清空 available。
adapter 负责共享 KOS 窗口外观开关、协议版本和确认协商，布局事件后发送完整实际
几何，每个 surface 仅一个。模板没有实现平台协议，也不声称合成器接入完成。
不得无条件导入可选原生模块，或用轮询/像素推断几何。无 adapter 时客户端控件
正常工作。

AppTheme 由应用统一设置，不由每个窗口写入。内容与嵌入工具栏采用普通材质。
左列是内容列表，不是半透明导航侧栏实验。对话框只采样自己窗口的 scene，排除
浮层和捕获节点；编辑器不得跨窗口采样主界面。降低透明度使用 canonical 不透明回退。

## 在已授权环境构建安装

需要 Qt 6.8+ 开发包（Core、Gui、Qml、Quick、QuickControls2、LinguistTools；根目录另查找
QuickDialogs2）、C++17、CMake 3.21+、Qt Quick Controls 运行时、
Qt5Compat.GraphicalEffects 与 SVG 支持。使用仓库提交的 shader，不在本机烘焙。

构建、翻译工具、测试和图形检查仅在 VM 或托管 CI 执行，不在维护者本机运行，
也不启动或替换维护者 Shell。在 VM 中从仓库根目录执行：

```sh
cmake -S . -B build -DKOS_BUILD_NATIVE_NOTES=ON
cmake --build build --target kos-notes
cmake --install build --prefix "$HOME/.local"
```

也可独立配置示例目录：

```sh
cmake -S examples/native-notes -B build-notes
cmake --build build-notes
cmake --install build-notes --prefix "$HOME/.local"
```

复制示例到新仓库后，传入 `-DKOS_UI_SOURCE_DIR=/path/to/pinned/nextkdeAppDemo`。
用精确提交（通常通过 submodule）固定 UI 依赖，不以移动分支发布。链接
`Kos::Ui` 与 `Kos::UiPlugin`，保留 GPL 与来源说明。仓库默认仍只构建 UI 库。
安装包含 `kos-notes`、`org.nextkde.KosNotes.desktop` 与 scalable 图标；
Qt 运行库部署由应用发行方负责。

## 翻译目录与维护

`examples/native-notes/i18n/kos_notes_{en_US,zh_CN}.ts` 属于应用，覆盖四个应用 QML
上下文以及实际使用的共享 `KosWindowControls`、`SettingsTextField` 上下文。
共享组件源码保持不变。这**不是**全部 `Kos.Ui` 控件、Gallery 或未来消费应用的
完整翻译；应用需要补充自己实际使用的上下文。异步示例使用 `%n` 与英文单复数，
进度数字通过所选 `Qt.locale` 及其百分号格式化，不新增日期业务。

VM 需要匹配的 Qt Linguist 工具与 Qt 翻译包。CMake 要求 Qt 翻译目录中的
`qtbase_zh_CN.qm`、`qtdeclarative_zh_CN.qm`，覆盖其中已有的 Qt 内建文案。
应用、相关共享控件以及 Qt 目录均嵌入两个可执行目标；根构建、独立构建和安装版
均不依赖源码目录或外部翻译路径。Qt 文案覆盖以其上游目录内容为界，无关的平台/
系统界面遵循自身语言设置。随应用再分发 Qt 资源时须保留相应翻译许可证。

修改 `qsTr` 文案后，在 VM 执行（独立构建将 `build` 换为 `build-notes`）：

```sh
cmake --build build --target update_translations
# 用 Qt Linguist 审阅两个 TS，完成新增文案和 numerus 复数形式。
cmake --build build --target release_translations
cmake --build build --target kos-notes
```

`update_translations` 除应用源码外，明确扫描实际使用的两个共享上下文。
审阅 TS diff，保留完整英文单复数及中文翻译，确认不再使用后才删除 obsolete 项。
`release_translations` 调用 `lrelease`；普通可执行程序构建也会生成并嵌入 QM。
提交 TS 源文件，不提交构建目录的 QM。复制模板后，应用自行维护目录和上下文列表
并重新构建；仅改变 `QLocale` 不会翻译 QML 绑定。

## 状态与生命周期

C++ adapter 从 `QStandardPaths::AppDataLocation` 下读取 `notes.json`，Linux
通常为 `~/.local/share/NextKdeExamples/KosNotes`。缺失文件时在内存提供一条
双语示例，首次成功保存才落盘。现有文件无法读取、版本不支持或格式错误会进入
失败状态并禁止写入；修复后 Retry 重读，不会静默用默认数据覆盖。
结构为 `{version: 1, notes: [{id, title, body}], preferences: {theme,
language, reduced}}`。允许空列表，编辑保持稳定 ID。筛选忽略大小写、同时匹配
标题和正文；条目被筛选隐藏时仍保留其选中 ID 和详情，避免自动跳转。

只有 QSaveFile 成功提交才发布新的数据/设置。保存笔记失败保留编辑草稿及原文件。
设置独立维护草稿，失败或取消/Escape 时原确认值继续生效。主题（系统/浅色/深色）、
中英文、降低透明度会持久化。应用使用标准 Qt `qsTr`、TS/QM 翻译目录与应用自有
`TranslationManager`。默认英文（`en_US`），不随宿主 locale 改变；已持久化的
`language: "zh"` 使用简体中文（`zh_CN`）。只有成功提交/重读后发布的设置才替换
translator、设置应用 locale 并调用 `QQmlEngine::retranslate()`。已经打开的编辑器、
设置、任务及错误状态绑定立即更新。取消或保存失败不改变当前语言。笔记标题、
正文及恢复草稿是用户数据，不进行翻译。

只复用一个独立编辑窗口；已打开时请求编辑其他条目只激活现有窗口，不覆盖草稿。
编辑器或主窗口退出时若有更改，则提供保存、不保存、取消；保存成功才能关闭，
取消同时撤销待执行的应用退出。空标题禁止保存。编辑停顿 600 ms 或请求关闭脏窗口时，
通过原子写入更新独立 `draft.json`，不改变 `notes.json`；保存仍是明确确认操作。
启动后有效恢复草稿自动在编辑器打开。保存或不保存关闭会清理恢复文件；保存失败
保留内存编辑和最近成功的恢复副本。所有正常关闭都会清理恢复文件，包括撤销回
原始内容后立即关闭。删除失败时保持窗口打开并提供重试/取消，再次 Close/Quit
也不能绕过保护。若笔记已先提交，保留新 ID 和已保存基线，重试清理不会重复
创建笔记；即使没有编辑，保存按钮也可重试清理。自动保存失败会显示错误，不关闭窗口，但崩溃
仍可能丢失最近一次成功检查点之后的编辑。损坏恢复文件保留并阻止新开编辑器，
可在停止应用后修复，或经确认明确丢弃。这里只保留单份草稿，没有历史版本。
恢复检查点带有随机 `token`；确认保存时在同一 `notes.json` 原子事务中写入
`committedDraftToken`。启动先验证笔记，再检查恢复文件：已确认 token 不会作为
草稿打开，即使检查点内容落后于保存内容、进程在提交后清理前退出，或清理失败。
后续编辑生成新 token，未提交或保存失败的检查点仍可恢复。旧 version 1 文件兼容：
无 token 的草稿在确认保存前原子升级；升级失败保留草稿并拒绝提交。不会根据内容
相同猜测已保存。清理失败仍保留错误及重试保护。该协议针对进程退出，不是跨设备
事务或掉电持久性保证。

`QLockFile` 在 adapter 生命周期持有 `notes.lock`，第二进程无法读写此目录并显示
锁定/权限错误及重试。Qt 可回收已退出进程的锁，不会只凭时间覆盖活跃锁。
这是协作式单写保护，不能防止其他程序直接编辑文件。没有网络、迁移或
冲突合并；不要把这个小型 adapter 当作生产数据库契约。

## 删除、撤销与异步示例任务

“删除笔记”打开 canonical 确认对话框。任何打开的编辑器（包括尚未 checkpoint
的草稿）、有效恢复草稿或恢复文件错误都会阻止删除；请先保存或丢弃编辑并关闭
编辑器，或解决恢复问题。adapter 也检查这些保护条件。只有原子提交成功才移除
笔记；失败保留笔记、选择和上次撤销记录，修复存储后可以重试。删除所选笔记后
清空选择，不自动跳到其他行。撤销恢复原 ID、内容与列表位置，并选中该 ID，
即使筛选暂时隐藏它。撤销失败保留记录供重试。只有一个内存撤销槽，下次成功
删除会替换它，重新加载或退出应用会清空它；它不是回收站或持久历史。

可见的“任务演示”入口打开独立的“示例数据任务”对话框。“加载示例数据”通过
绑定 adapter 生命周期的 C++ `QTimer` 回调异步调度五个小批次，显示加载百分比，
支持取消、可控模拟失败与重试。重试不再注入故障；关闭对话框会取消进行中的任务。
每次启动或取消都改变请求代次，旧回调无法发布进度、错误或结果。销毁 adapter
会移除待执行回调。三个虚构结果仅保留在独立临时属性中，不联网，不修改真实
笔记或恢复文件。这演示事件循环调度，不能作为阻塞 CPU/I/O 工作的工作线程。

## 验收清单

仅在 VM/托管 CI 执行。将实际命令、Qt/平台/backend 版本、截图、日志及
结果放在受跟踪文档之外。未执行项明确记为**未验证**；源码审阅不是运行验收。

1. 分别构建根目录开关与独立目录入口；安装后离开源码目录启动 desktop 项。
   检查资源导入、图标、QML 日志，以及无 Quickshell/NextKde/KWin 服务时运行。
2. 用临时 `XDG_DATA_HOME` 启动 `kos-notes`，检查加载、示例选择、匹配/无匹配筛选、
   清空筛选、Tab/方向键和长文本选择。准备多条笔记，点击选中一条、用筛选隐藏它、
   再清空筛选：选中 ID 与详情应保持，条目高亮应恢复。键盘选择后，以及保存编辑
   导致条目是否匹配筛选发生变化后，重复检查；模型替换不得选中其他笔记。
   停止应用后把临时文件 notes 改为 `[]`，
   重启检查空状态和新建。
3. 新建标题与多行正文，保存重启确认持久化；编辑同一条检查 ID/选择稳定。
   编辑窗口打开时请求另一条，确认原草稿不变且被激活。
4. 分别通过编辑窗口关闭和主窗口退出，覆盖取消、不保存、保存、空标题、键盘
   Close/Quit 与标题栏关闭。保存失败不得关闭编辑窗口或退出应用。独立编辑窗口
   活跃时再次触发 Quit 快捷键：保存成功落盘后才关闭两个窗口，不保存应丢弃草稿
   并退出，取消应保留两个窗口和草稿。注入保存失败后，从活跃编辑器再次触发 Quit：
   保存失败必须保留草稿和两个窗口，取消必须撤销退出。
5. 带 `KOS_NOTES_FAIL_SAVE=1` 运行，检查笔记和设置都保存失败且原 JSON 不变；
   移除此环境变量重启后重试成功。另测真实不可写路径。
6. 停止应用，破坏临时 JSON 或版本；重启检查加载失败和禁止写入，修复后 Retry。
7. 保存每种主题/语言/降低透明度，重启检查；取消设置草稿并注入失败，原设置应
   保持。检查深色菜单、应用文案、请求范围内的缩放、最小尺寸、长标题和长正文。
8. 检查两个窗口的移动/缩放/最大化/恢复/最小化，以及主窗口最小化后编辑窗口独立
   可用。检查贴边矩形、无应用外框/阴影/圆角、命中区域、双击和键盘焦点；在临时
   VM harness 中覆盖三/一/零按钮及动作重排。
9. GPU 下检查对话框同窗口模糊/折射、32px G2 轮廓、普通内部按钮、液态层无额外
   强调色焦点环。复测降低透明度与软件渲染；不得把 offscreen/software 当 GPU 验收。
10. 若新增可选平台 adapter，独立检查开关、拒绝、延迟确认、服务丢失、控件移动/
    缩放、多窗口与旧命中区域清除。本模板未实现此 adapter。


`commitCrash` 回归启动真实子进程，在 `saveNote` 后直接 `std::_Exit(73)`，不调用
`clearDraft`、正常窗口关闭或析构。覆盖新建与编辑的落后检查点、未提交编辑、
保存失败、再次编辑、旧格式升级及升级失败、内容相同但未提交的检查点；重启检查
还注入清理失败。全量测试只在已授权 VM 运行；这是进程恢复检查，不是图形或
掉电验收。

## 可选回归测试与实际验收范围

任一构建入口增加 `-DKOS_NOTES_BUILD_TESTS=ON`（根入口同时启用
`-DKOS_BUILD_NATIVE_NOTES=ON`），构建后执行
`ctest --test-dir build --output-on-failure`。测试使用临时数据目录及离屏软件渲染；
默认 OFF，不新增 CI。`KOS_NOTES_FAIL_DRAFT=1` 独立注入恢复副本写入失败，
`KOS_NOTES_FAIL_CLEAR_DRAFT=1` 注入恢复文件删除失败。

可见输入检查只在已授权 VM 图形会话运行。先创建截图目录，隔离
`XDG_DATA_HOME`、`XDG_CONFIG_HOME` 与 `XDG_CACHE_HOME`，然后执行：

```sh
QT_QPA_PLATFORM=wayland QSG_RHI_BACKEND=opengl QT_SCALE_FACTOR=1 \
KOS_NOTES_DESKTOP_ACCEPTANCE=1 KOS_NOTES_CAPTURE_DIR=/tmp/notes-captures \
./build-notes/kos-notes-tests desktopInput
```

可选用例为 `desktopInput`（编辑、选择、关闭保护及设置）、`desktopDeleteTask`
（删除/撤销与任务生命周期）、`desktopI18n`（语言切换、错误绑定、复数与重启）。
将对应函数名作为最后一个参数；普通 `ctest` 跳过这些用例。它们向可见窗口发送
Qt 鼠标/键盘事件，截图不能代替交互断言。XCB 下 `desktopInput` 还使用
`xdotool` 激活自身窗口并做有界原生几何检查。使用并记录 VM 的实际平台/backend，
不更改全局显示设置。仅在明确要求的范围内执行缩放矩阵。模板没有窗口几何持久化。

### 历史范围与边界

2026-11-05 的历史证据覆盖两个构建入口、安装资源、恢复与持久化回归及可见桌面输入。
较早的 Qt 6.12.0 本机/XCB 运行记录了 Intel Arc/OpenGL 的 DPR 1/2 对话框对比及
软件/减少透明度回退；这是历史事实，不是现在允许本机验证的指令。
后续 Qt 6.10.2 VM/Wayland 运行覆盖全量回归、`commitCrash`、`translationBindings`，
以及 DPR 1 下的 `desktopDeleteTask`/`desktopI18n` 聚焦交互（VMware SVGA3D/OpenGL）。
国际化运行还覆盖安装资源及翻译构建目标。
这些属于独立范围，不代表当前全平台或全库验收。可选合成器 adapter 仍未验证，
Qt 注入的窗口移动本身不代表合成器 seat 行为通过。
命令、源码哈希、截图和详细结果保存在受跟踪文档之外。

补充手动检查：编辑后等待超过 600 ms，仅终止隔离示例进程，重启检查恢复内容；
带 `KOS_NOTES_FAIL_DRAFT=1` 重复。两个实例使用同一临时数据目录，关闭首实例后
在第二实例重试。不要使用个人笔记数据做验收。
