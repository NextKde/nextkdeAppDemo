# 设置分组与设置项规范

[English](Settings.md)

设置表单统一使用 `shared/qml/foundation` 中的 **SettingsGroup** 和
**SettingsItem**。分组底板、标题和条目布局由组件管理，各页面填写名称、说明、
控件及业务绑定。本规范优先于设置场景中旧的通用灰色卡片写法。
“主题 → 界面形态”是参考组合，示例只操作自身状态。

## 层级与尺寸

| 元素 | 默认规格 |
| --- | --- |
| Group 标题 | 15px，Bold（700），主文字色，放在分组底板外 |
| Item 名称 | 12px，Normal（400），只保留一个设置名称，不加额外标题或图标 |
| 可选说明 | 10px，Normal；浅色 `#8E8E93`，深色 `#98989D`；允许换行 |
| Group 底板 | 普通材质；浅色 `#f7f7f7`、深色 `#242426`；12px 圆角；无描边、无投影 |
| 标题到底板 | 6px |
| Group 之间 | 宿主纵向布局统一使用 12px spacing |
| Group 上下内边距 | 4px |
| Item 之间 | 额外间距为 0px |
| Item 高度 | 最小 36px；有说明、长名称或较高控件时自然增高 |
| Item 内边距 | 水平 16px，垂直 5px |
| 名称到说明 | 2px |
| 名称区域到控件 | 横向 12px；上下排列时 6px |
| 示例紧凑控件高度 | 切换器、开关、滑块的布局区高 24px；开关外观为 44×20px、居中对齐，滑块把手 26×14px、轨道 4px |
| 分隔线 | 1px，左右缩进 16px；仅显示在可见设置项之间 |

SettingsItem 的 `title` 就是“材质风格”“模糊强度”等单一设置名称，
不再重复一层小标题，也不放前置图标。`description` 是可选辅助说明，
字号更小、颜色更浅，不使用 Group 标题样式。

Group 和 Item 都是普通材质。宿主按控件用途显式选择既有组件的液态或实色形态。
保留键盘及无障碍交互；液态控件聚焦、选中时不加蓝色或强调色外框。
形态预览属于普通选项，可以显示真实的选中状态。减少透明效果时，控件使用其不透明形态。

## 选择类控件

**三个及以上选项**的设置统一使用这套下拉组件，仅两个选项可保留分段切换器。
下拉选项文字（包括选中项）使用普通字重 Normal（400），设置 `popupFontWeight: Font.Normal`。统一采用 `LiquidSelect`，设置
`indicatorStyle: "upDown"` 和 `plainTrigger: true`：收起时只显示当前值及成对的
上下箭头。仅箭头区启用 `indicatorBackground: true`，包一块普通灰色圆角底板；
当前值文字不画按钮底板、胶囊、描边、投影或悬停底色，聚焦、按下及打开
菜单时也保持如此。保持设置场景
24px 高度及 SettingsItem 的右侧缩进，参考示例也遵循此规则。
设置下拉菜单使用 `popupMaterialForm: true` 和不透明的 `sheetColor: "#f0f0f1"`，
8px 圆角、3px 内边距、24px 选项行。启用 `compactPopup: true`，按最长选项文字
加勾选区及内边距计算菜单宽度，不保留通用的 160px 最小宽度；超长菜单受窗口
宽度约束。设置菜单在打开和关闭过程中也保持不透明。
设置 `popupBorderWidth: 0` 和 `popupShadowEnabled: true`：不加描边，只用一层
四周均匀扩散的轻阴影（X/Y 偏移均为 0，不透明度 0.14，柔化 7px，扩散范围 18px）。
阴影由 QML 绘制，不采样桌面、不请求 KWin 效果。启用 `neutralOptionHighlight: true`，
选中状态只用前置深色勾表示，不加蓝色 active 底或蓝字；悬停和键盘导航使用
中性灰提示，内部选项均为普通材质。
这是设置下拉对通用悬浮液态面板规则的明确例外。通过 `activated(int)` 由宿主
确认状态；打开菜单或聚焦本身不能触发保存。

## 组件接口与接入

**SettingsGroup**：`title` 为分组标题，默认子内容为预览或设置项。组件拥有一块
普通底板和一个零间距内容列。`background` 暴露底板 Item，可以作为独立
`LiquidBackdrop` 的同窗口采样源；该子树不包含前景文字和控件。
`contentItem` 暴露内容布局。默认宽度 420px，宿主通过 `width` 或
`Layout.fillWidth` 控制实际宽度；高度由内容决定。
可覆盖 `backgroundColor`、`titleColor`、`cornerRadius`、`titleSpacing`、
`verticalPadding`、`titleFont`，统一设置页应直接使用默认值。

**SettingsItem**：`title` 为名称，`description` 为可选说明，默认子内容为末端控件。
所有条目的控件都右对齐。放不下“名称最小 120px＋间隔 12px＋控件首选宽度”时，
控件自动移动到名称和说明下方，仍保持右侧内边距，并限制在可用宽度内。长文字换行并撑高条目，
不得通过固定行高截断说明。`stacked` 表示实际是否上下排列。
`separator: false` 可隐藏中间分隔线，最后一个可见 Item 自动不画底线。
标准 `enabled` 传递给内部控件；每个控件还应填写自己的无障碍名称并绑定宿主持有的值。

其他可配置输入：`minimumRowHeight`、`horizontalPadding`、`verticalPadding`、
`controlSpacing`、`minimumLabelWidth`、`titleColor`、`descriptionColor`、
`separatorColor`、`titleFont`、`descriptionFont`。宿主负责外层滚动，
两个组件都不自行创建嵌套滚动区。

```qml
import QtQuick
import QtQuick.Layouts
import Kos.Ui

SettingsGroup {
    id: section
    width: 600
    title: "界面形态"
    property real blurStrength: 0.42

    SettingsItem {
        title: "模糊强度"
        description: "柔化液态组件背后的内容。"
        LiquidSlider {
            Layout.preferredWidth: 170
            Layout.preferredHeight: 24
            materialForm: true
            value: section.blurStrength
            Accessible.name: "模糊强度"
            onPreviewChanged: value => section.blurStrength = value
        }
    }
}
```

应用适配层区分预览值与已保存值，在 `commitRequested` 时保存，在 `canceled`
或保存失败时恢复已确认状态；分组组件不改变控件原有的状态契约。

## 示范与检查

在已获授权的图形验证环境打开：`qs -p demo/settings-demo.qml`。
`GALLERY_LANGUAGE=zh` 为中文，`GALLERY_THEME=dark` 为深色。
Gallery 的“设置分组与条目”使用同一个 `SettingsExample.qml`，没有第二套视觉实现。
首个 Group 是“界面形态”，包含形态预览、材质风格、模糊强度、液态强度；
第二个 Group 演示长说明、条件禁用，以及分组间的 12px 间距。
示例页面和形态预览都使用普通纯色背景，不在 Group 底下或预览内部添加渐变背景。

检查真实切换、滑块预览/提交/取消、键盘聚焦、禁用控件、深浅色、长说明和窄窗口。
液态控件只采样真实同窗口背景并使用 QML 效果，不依赖 KWin 液态插件。

专项 Qt Quick 检查位于 `tests/tst_settings.qml`。在已获授权的验证环境使用 Qt 6
`qmltestrunner -input tests -platform offscreen`，检查真实鼠标/键盘、预览/提交/取消、
条件可用状态与换行/上下布局。QML 示例无需编译或重新烘焙着色器。

界面形态选项共用规范组件 `SettingsAppearancePreview`：以相同的侧栏、开关、
滑块设置场景对比。macOS 使用中性色、交通灯和小巧通透工具栏胶囊；Material
使用浅主题色顶栏、导航轨及更大的圆角底板。下方仅保留 macOS 和 Material Design
名称，不加描述性口号。
组件接受 `form`（`macos` / `material`）、`darkAppearance`、`windowTitle` 和
`settingTitle`，为自动缩放的静态图形，不加渐变、没有内部交互，也不代表实时截图。
外层单选按钮继续管理选中状态、键盘和无障碍交互。
