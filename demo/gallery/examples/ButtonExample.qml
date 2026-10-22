import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property string language: "en"
    property bool sceneOnly: false
    function tr(en, zh) { return language === "zh" ? zh : en }
    spacing: 24

    // Section furniture is plain: examples retain the shared material unchanged.
    component ExampleGroup: ColumnLayout {
        property string heading
        property string note
        default property alias examples: buttons.data
        Layout.fillWidth: true
        spacing: 8
        Label {
            Layout.fillWidth: true
            text: parent.heading
            color: Ui.AppTheme.text
            font.pixelSize: 17; font.weight: Font.DemiBold
            wrapMode: Text.WordWrap
        }
        Label {
            Layout.fillWidth: true
            text: parent.note
            color: Ui.AppTheme.mutedText
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }
        Flow {
            id: buttons
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 12
        }
    }

    ExampleGroup {
        heading: example.sceneOnly ? example.tr("02.1 · Buttons over a background", "02.1 · 背景上的按钮") : example.tr("01.1 · Action styles", "01.1 · 操作样式")
        note: example.sceneOnly
            ? example.tr("The same controls over the selected background. Compare visibility and refraction.", "相同按钮放到所选背景上，观察文字清晰度、高光和折射。")
            : example.tr("Choose by purpose: a normal action, a primary action, a lightweight action or a destructive action.", "按用途区分：普通操作、主操作、轻量操作和危险操作。")
        Controls.LiquidActionButton { text: example.tr("Default", "普通操作") }
        Controls.LiquidActionButton { text: example.tr("Primary", "主操作"); highlighted: true }
        Controls.LiquidActionButton { text: example.tr("Plain", "轻量操作"); flat: true }
        Controls.LiquidActionButton { text: example.tr("Delete", "删除"); destructive: true }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Ui.AppTheme.border; visible: !example.sceneOnly }
    ExampleGroup {
        visible: !example.sceneOnly
        heading: example.tr("01.2 · Liquid intensity", "01.2 · 液态强度")
        note: example.tr("Only optical strength changes. Size and fill are the same.", "只比较液态强弱，尺寸和填充保持一致。")
        Controls.LiquidActionButton { text: example.tr("Light", "轻档"); liquidIntensity: "light" }
        Controls.LiquidActionButton { text: example.tr("Medium", "中档"); liquidIntensity: "medium" }
        Controls.LiquidActionButton { text: example.tr("Strong", "强档"); liquidIntensity: "strong" }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Ui.AppTheme.border; visible: !example.sceneOnly }
    ExampleGroup {
        visible: !example.sceneOnly
        heading: example.tr("01.3 · Sizes", "01.3 · 尺寸")
        note: example.tr("28 / 34 / 44 logical pixels. Same action, different control sizes.", "28 / 34 / 44 逻辑像素。同一种操作，只比较尺寸。")
        Controls.LiquidActionButton { text: example.tr("Small · 28", "小 · 28"); implicitHeight: 28; font.pixelSize: 13 }
        Controls.LiquidActionButton { text: example.tr("Medium · 34", "中 · 34"); implicitHeight: 34; font.pixelSize: 14 }
        Controls.LiquidActionButton { text: example.tr("Large · 44", "大 · 44"); implicitHeight: 44; font.pixelSize: 15 }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Ui.AppTheme.border; visible: !example.sceneOnly }
    ExampleGroup {
        visible: !example.sceneOnly
        heading: example.tr("01.4 · Icon actions", "01.4 · 图标操作")
        note: example.tr("Previous, play/pause and next. Click the middle button to switch its icon.", "上一首、播放/暂停、下一首。点击中间按钮可切换图标。")
        Controls.LiquidActionButton {
            iconOnly: true; iconName: "mediaPrevious"; iconFilled: true
            Accessible.name: example.tr("Previous", "上一首")
            ToolTip.visible: hovered; ToolTip.text: Accessible.name
        }
        Controls.LiquidActionButton {
            iconOnly: true; iconName: checked ? "mediaPause" : "mediaPlay"; iconFilled: true; checkable: true
            Accessible.name: checked ? example.tr("Pause", "暂停") : example.tr("Play", "播放")
            ToolTip.visible: hovered; ToolTip.text: Accessible.name
        }
        Controls.LiquidActionButton {
            iconOnly: true; iconName: "mediaNext"; iconFilled: true
            Accessible.name: example.tr("Next", "下一首")
            ToolTip.visible: hovered; ToolTip.text: Accessible.name
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Ui.AppTheme.border; visible: !example.sceneOnly }
    ExampleGroup {
        visible: !example.sceneOnly
        heading: example.tr("01.5 · States", "01.5 · 状态")
        note: example.tr("Try selection, disabled state and keyboard focus with Tab.", "比较可切换、已选中、禁用状态；按 Tab 查看键盘焦点。")
        Controls.LiquidActionButton { text: example.tr("Toggle", "点击切换"); checkable: true }
        Controls.LiquidActionButton { text: example.tr("Selected", "已选中"); checkable: true; checked: true }
        Controls.LiquidActionButton { text: example.tr("Disabled", "已禁用"); enabled: false }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Ui.AppTheme.border; visible: !example.sceneOnly }
    ExampleGroup {
        visible: !example.sceneOnly
        heading: example.tr("01.6 · Solid content actions", "01.6 · 实色内容按钮")
        note: example.tr("For ordinary content. These buttons do not sample or refract the background.", "用于普通内容区域，不采样背景，也不产生折射。")
        Controls.LiquidActionButton { text: example.tr("Content action", "普通操作"); materialForm: true }
        Controls.LiquidActionButton { text: example.tr("Primary action", "主操作"); materialForm: true; highlighted: true }
        Controls.LiquidActionButton { text: example.tr("Disabled", "已禁用"); materialForm: true; enabled: false }
    }
}
