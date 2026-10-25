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
    spacing: 16

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
            spacing: 8
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
        heading: example.tr("01.3 · Same size, different material", "01.3 · 同尺寸，不同材质")
        note: example.tr("Both variants stay 28px high. Choose the material explicitly for the context.", "液态与实色按钮均高 28px，按使用位置显式选择材质。")
        Controls.LiquidActionButton { text: example.tr("Liquid · 28", "液态 · 28"); materialForm: false; implicitHeight: 28 }
        Controls.LiquidActionButton { text: example.tr("Solid · 28", "实色 · 28"); materialForm: true; implicitHeight: 28 }
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

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Ui.AppTheme.border; visible: !example.sceneOnly }
    ColumnLayout {
        visible: !example.sceneOnly
        Layout.fillWidth: true
        spacing: 10

        Label {
            Layout.fillWidth: true
            text: example.tr("01.7 · Placement decides size and corner", "01.7 · 位置决定尺寸和圆角")
            color: Ui.AppTheme.text
            font.pixelSize: 17; font.weight: Font.DemiBold
        }
        Label {
            Layout.fillWidth: true
            text: example.tr("Toolbar and content rows use macOS 15 corners (6 / 8) for both materials; dialogs and floating bars are capsules, as Apple draws them.",
                             "工具栏与内容行的液态、实色都用 macOS 15 小圆角（6 / 8）；弹窗与浮层是胶囊，和苹果原图一致。")
            color: Ui.AppTheme.mutedText
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label {
                Layout.preferredWidth: 132
                text: example.tr("Toolbar", "工具栏")
                color: Ui.AppTheme.text
                font.pixelSize: 13; font.weight: Font.DemiBold
            }
            Label {
                Layout.preferredWidth: 140
                text: example.tr("h 22 · r6", "高 22 · 圆角 6")
                color: Ui.AppTheme.mutedText
                font.pixelSize: 12
            }
            Controls.LiquidActionButton {
                text: example.tr("Liquid", "液态"); implicitHeight: 22; font.pixelSize: 12
                cornerRadius: 6
            }
            Controls.LiquidActionButton {
                text: example.tr("Solid", "实色"); materialForm: true
                implicitHeight: 22; cornerRadius: 6; font.pixelSize: 12
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label {
                Layout.preferredWidth: 132
                text: example.tr("Content row", "内容行")
                color: Ui.AppTheme.text
                font.pixelSize: 13; font.weight: Font.DemiBold
            }
            Label {
                Layout.preferredWidth: 140
                text: example.tr("h 28 · r8", "高 28 · 圆角 8")
                color: Ui.AppTheme.mutedText
                font.pixelSize: 12
            }
            Controls.LiquidActionButton {
                text: example.tr("Liquid", "液态"); implicitHeight: 28; font.pixelSize: 13
            }
            Controls.LiquidActionButton {
                text: example.tr("Solid", "实色"); materialForm: true
                implicitHeight: 28; cornerRadius: 8; font.pixelSize: 13
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label {
                Layout.preferredWidth: 132
                text: example.tr("Dialog footer", "弹窗底栏")
                color: Ui.AppTheme.text
                font.pixelSize: 13; font.weight: Font.DemiBold
            }
            Label {
                Layout.preferredWidth: 140
                text: example.tr("h 32 · capsule", "高 32 · 胶囊")
                color: Ui.AppTheme.mutedText
                font.pixelSize: 12
            }
            Controls.LiquidActionButton {
                text: example.tr("Liquid", "液态"); implicitHeight: 32; font.pixelSize: 13
            }
            Controls.LiquidActionButton {
                text: example.tr("Solid", "实色"); materialForm: true
                implicitHeight: 32; cornerRadius: 16; font.pixelSize: 13
            }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Label {
                Layout.preferredWidth: 132
                text: example.tr("Floating bar", "浮层 / 侧栏")
                color: Ui.AppTheme.text
                font.pixelSize: 13; font.weight: Font.DemiBold
            }
            Label {
                Layout.preferredWidth: 140
                text: example.tr("h 28 · capsule", "高 28 · 胶囊")
                color: Ui.AppTheme.mutedText
                font.pixelSize: 12
            }
            Controls.LiquidActionButton {
                text: example.tr("Liquid", "液态"); implicitHeight: 28; font.pixelSize: 13
            }
            Controls.LiquidActionButton {
                text: example.tr("Solid", "实色"); materialForm: true
                implicitHeight: 28; cornerRadius: 14; font.pixelSize: 13
            }
        }
    }

}
