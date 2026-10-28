# 通用提示气泡

[English](Tooltips.md)

应用帮助提示统一使用 `shared/qml/foundation/KosToolTip.qml`。Gallery 的
“提示气泡”示例直接使用同一个组件，不在应用中重画气泡；需要统一外观时，
不要继续使用 Qt 附加属性 `ToolTip.visible/text`。

## 外观与文案

| 项目 | 默认规格 |
| --- | --- |
| 材质 | 悬浮液态玻璃，`materialOpacity: 0.7`；浅色覆盖色 `#f0f0f1`、深色 `#303034` |
| 文字 | 11px，Normal（400），完全不透明；浅色 `#55555a`、深色 `#d6d6da`；纯文字 |
| 圆角 / 内边距 | 14px / 水平 10px、垂直 5px |
| 描边 / 尖角 / 焦点环 | 不额外添加；使用共享玻璃边缘和轻微 QML 投影 |
| 宽度 | 按文字自适应，最大 280px 且不超出窗口，长文字换行 |
| 位置 | 距触发控件 6px；优先上方，顶部空间不足时放下方 |
| 距窗口边缘 | 至少 8px |
| 延迟 / 显示时长 | 700ms / 5000ms，沿用原生 ToolTip 定时机制 |

圆角不超过短边的一半，短的单行提示呈胶囊形。

Tooltip 也属于悬浮液态材质，复用 `LiquidSurface` 对真实同窗内容做模糊和轻微折射。
`materialOpacity` 只控制背景覆盖强度，不降低整个 Popup 或文字的不透明度。
不使用 KWin 效果。气泡依旧无交互、不抢键盘焦点、不放按钮。
仅在减少透明效果、软件渲染、缺少安全采样源时使用不透明回退。
不额外添加强调色外框或装饰动画。

用动词简短说明动作，不加句末标点，建议最多 60–75 个字符。
不要重复已经完整显示的名称；导航文字被截断时，可以用提示展示全称。

## 接入

```qml
import Kos.Ui as Ui

Ui.KosToolTip {
    target: openSettingsButton
    text: qsTr("打开设置")
}
```

`target` 必填。按钮等 Controls 会自动提供 `hovered`，键盘提示跟随键盘焦点。
普通 Item 可以把自己的 HoverHandler 绑定到 `hovered`：

```qml
Text {
    id: name
    width: 148
    text: fullName
    elide: Text.ElideRight
    activeFocusOnTab: true
    HoverHandler { id: pointer }
    Ui.KosToolTip {
        target: name
        hovered: pointer.hovered
        text: name.text
        onlyWhenTruncated: true
        truncated: name.truncated
    }
}
```

文案和截断判断由宿主维护；`when` 控制是否允许显示，`showOnFocus` 默认启用。
空文案、隐藏或禁用的目标不提示；启用 `onlyWhenTruncated` 后，完整名称不提示。
离开、按下触发控件、Escape 或超时会关闭；原控件照常接收点击，Escape 不改变焦点。

宿主可以在目标的祖先 Item 上公开 `toolTipBackdrop`，用于提示气泡专用采样。
该 `LiquidBackdrop` 捕获真实应用内容，必须与被捕获场景同级；Popup overlay
及气泡自身不得出现在采样源子树中。也可以显式传入 `backdrop`。
查找优先级为 `toolTipBackdrop`、可用的局部 `contentBackdrop`、窗口默认采样源。
不要采集包含 overlay 的整个窗口。

其他输入包括 `materialOpacity`（0.7）、`cornerRadius`（14）、`reduceTransparency`、
`maximumWidth`、`targetGap`、`darkAppearance`、`delay`、`timeout`、只读的 `sampling`
以及继承的字体和 Popup 属性。统一表单保持默认几何；应用封装不要再加强调色外框、
独立投影或玻璃层。

## 虚拟机验证

```sh
/usr/lib/qt6/bin/qmltestrunner -input tests/tst_tooltip.qml -platform offscreen
```

聚焦检查覆盖真实悬停延迟、离开/按下/超时关闭、键盘聚焦与 Escape、截断条件、
空值和可用性、纯文字换行、深浅色、窗口边缘避让、采样材质回退以及 Gallery 示例加载。
模糊／折射的采样检查需在 GPU 后端执行，软件后端用于行为和回退验证。
不安装自动验证调度，也不在维护者工作站执行验证。
