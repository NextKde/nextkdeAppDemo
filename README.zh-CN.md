# nextkdeAppDemo

[English](README.md)

面向 NextKde 应用开发者和 AI 贡献者的 Qt Quick 液态组件、交互组件 Gallery，
以及完整侧栏布局 Demo。

视觉组件使用 QML 和烘焙着色器，不导入 NextKde Shell 服务，不请求 KWin 模糊，
也不需要 NextKde KWin 插件。预览宿主使用 Quickshell 提供普通窗口和源码预览，
组件库本身是可移植的 Qt Quick 实现。

## 打开 Demo

需要运行验收时，在虚拟机图形会话中，从仓库根目录执行：

```sh
qs -p demo/gallery.qml
qs -p demo/sidebar-demo.qml
qs -p demo/settings-demo.qml
```

任选一条命令，打开对应的普通可缩放窗口。关闭窗口退出该预览进程。
无需安装 NextKde，也无需启动 Shell。

- **Gallery：**可操作控件、可搜索导航、属性和信号说明，以及可复制的 QML 示例。
  默认英文，可切换中文说明。
- **提示气泡：**紧凑悬浮液态提示，背景覆盖强度 0.7，支持截断名称。[规范](docs/Tooltips.zh-CN.md)。
- **设置分组：**使用统一的 `SettingsGroup` / `SettingsItem`，以“主题 → 界面形态”
  做交互示范。见[设置分组与条目规范](docs/Settings.zh-CN.md)。
- **侧栏：**真实导航、文件过滤及选择、不透明内容区，以及默认
  `opacity: 0.95` 的侧栏背景。文字保持完全不透明。桌面模式下窗口底色透明；
  勾选“窗口内背景”可对比 QML 对仓库内图片的模糊及折射效果。

运行依赖为 Quickshell、匹配的 Qt Quick、Qt Quick Controls、
Qt5Compat.GraphicalEffects 及 Qt 的 SVG 图片支持。着色器光学需要支持的
Qt Quick GPU 后端。导出的基础组件使用 Qt 6.8 或更新版本。
`GALLERY_LANGUAGE=zh`、`GALLERY_THEME=light` 可设置 Gallery 初始偏好。

## 使用组件

唯一实现位于 [`shared/qml`](shared/qml)。可选的 CMake 构建导出静态
`Kos.Ui` QML 模块及 `Kos::Ui` / `Kos::UiPlugin` 目标。
`demo/Kos/Ui` 映射到同一份源码，不是另一套实现。

液态与普通实色控件均保留。下例显式选择普通材质；液态输入使用
`specificationForm: false`、`materialForm: false`、`liquidFinish: true`。
两种材质均可采用紧凑尺寸。

```qml
import QtQuick
import Kos.Ui

LiquidTextField {
    width: 280
    specificationForm: true
    implicitHeight: 28
    cornerRadius: height / 2
    placeholderText: "Search"
    textColor: AppTheme.text
    mutedTextColor: AppTheme.mutedText
}
```

采样光学需要宿主提供窗口内的 `LiquidBackdrop`。仅设置 alpha 透明无法取得
桌面或其他应用的背景纹理。桌面模式不模糊真实桌面；普通窗口仍由系统合成器完成合成。

详细说明见[组件及接入](docs/Components.zh-CN.md)、[架构及归属](docs/Architecture.zh-CN.md)
和[迁出来源](NOTICE.md)。

## 可选的组件库构建

需要构建时，在虚拟机或托管 CI 中执行：

```sh
cmake -S . -B build
cmake --build build
```

这里只构建组件模块，不生成原生 Gallery 可执行程序。
预览使用上面的 `qs` 命令及已提交的 QSB 资源，不需要本地构建。

初始版本来自 NextKde 当前 Gallery 开发快照，包含尚未提交的组件修改。
迁出后的仓库尚未构建或启动；本次没有发布版本，也没有添加自动测试工作流。
仅在明确要求时执行构建、测试及图形检查，并且只在虚拟机或托管 CI 中执行。

保留原有 [GPL-3.0 许可证全文](LICENSE)。

Gallery 的布局、材质与紧凑尺寸以 [Gallery 设计语言](docs/GalleryDesign.zh-CN.md) 为准。

浮动对话框统一规格与示例：[`LiquidDialog`](docs/Dialogs.zh-CN.md)，G2 大圆角、0.95 背景不透明度、模糊折射与内部实体按钮。
