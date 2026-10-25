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

    // 场景优先：先说“什么时候用哪种”，再谈尺寸与外观。
    ColumnLayout {
        visible: !example.sceneOnly
        Layout.fillWidth: true
        spacing: 8

        Label {
            Layout.fillWidth: true
            text: example.tr("01 · General rules", "01 · 总则")
            color: Ui.AppTheme.text
            font.pixelSize: 17; font.weight: Font.DemiBold
        }
        Label {
            Layout.fillWidth: true
            text: example.tr("Two decisions, in this order: material follows the layer (floating above content → liquid, inside content → solid), colour follows priority (primary → accent, secondary → normal, destructive → red).",
                             "按两步决定：先看层级定材质（浮在内容之上 → 液态，内容之内 → 实色），再看优先级定颜色（主操作 → 强调色，次要 → 普通，危险 → 红）。")
            color: Ui.AppTheme.mutedText
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }

        GridLayout {
            Layout.fillWidth: true
            Layout.topMargin: 6
            columns: 3
            columnSpacing: 16
            rowSpacing: 10

            Label { text: example.tr("Situation", "场景"); color: Ui.AppTheme.mutedText; font.pixelSize: 12; font.weight: Font.DemiBold }
            Label { text: example.tr("Use", "用哪种"); color: Ui.AppTheme.mutedText; font.pixelSize: 12; font.weight: Font.DemiBold }
            Label { text: example.tr("Do not", "不要这样用"); color: Ui.AppTheme.mutedText; font.pixelSize: 12; font.weight: Font.DemiBold }

            Label { Layout.preferredWidth: 300; wrapMode: Text.WordWrap
                text: example.tr("A control strip that floats above content: toolbar, sidebar, player bar, popover", "浮在内容之上的操作条：工具栏、侧栏、播放条、浮层")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.preferredWidth: 190; wrapMode: Text.WordWrap
                text: example.tr("Liquid button", "液态按钮")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap
                text: example.tr("Do not use liquid for rows of actions inside the content layer", "不要用液态做内容区里成排的操作")
                color: Ui.AppTheme.mutedText; font.pixelSize: 12 }

            Label { Layout.preferredWidth: 300; wrapMode: Text.WordWrap
                text: example.tr("The single most important action on this screen: Save, Done, Send", "此屏唯一最重要的动作：保存、完成、发送")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.preferredWidth: 190; wrapMode: Text.WordWrap
                text: example.tr("Accent button", "强调色按钮")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap
                text: example.tr("Never two accent buttons on one screen, and never for Cancel", "一屏不要两个强调色，也不要用它做“取消”")
                color: Ui.AppTheme.mutedText; font.pixelSize: 12 }

            Label { Layout.preferredWidth: 300; wrapMode: Text.WordWrap
                text: example.tr("Parallel or secondary actions, Cancel, openings that are not the main goal", "并列动作、取消、非首要入口")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.preferredWidth: 190; wrapMode: Text.WordWrap
                text: example.tr("Normal button", "普通按钮")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap
                text: example.tr("Do not use accent colour for routine or reversible actions", "日常、可撤销的动作不要用强调色")
                color: Ui.AppTheme.mutedText; font.pixelSize: 12 }

            Label { Layout.preferredWidth: 300; wrapMode: Text.WordWrap
                text: example.tr("Deleting, overwriting, anything that cannot be undone", "删除、覆盖、任何不可撤销的动作")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.preferredWidth: 190; wrapMode: Text.WordWrap
                text: example.tr("Destructive button", "危险按钮")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap
                text: example.tr("Red means consequence, not emphasis — do not use it to make a button stand out", "红色表示后果，不表示强调——不要用它让按钮更显眼")
                color: Ui.AppTheme.mutedText; font.pixelSize: 12 }

            Label { Layout.preferredWidth: 300; wrapMode: Text.WordWrap
                text: example.tr("Tight space where a word would not fit: toolbar, list row", "空间不够放文字：工具栏、列表行")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.preferredWidth: 190; wrapMode: Text.WordWrap
                text: example.tr("Icon button", "图标按钮")
                color: Ui.AppTheme.text; font.pixelSize: 13 }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap
                text: example.tr("Never ship an icon button without a tooltip and an accessible name", "没有 tooltip 和可访问名称的图标按钮不要上线")
                color: Ui.AppTheme.mutedText; font.pixelSize: 12 }
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Ui.AppTheme.border; visible: !example.sceneOnly }

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
            text: example.tr("02 · In use", "02 · 实际应用场景")
            color: Ui.AppTheme.text
            font.pixelSize: 19; font.weight: Font.DemiBold
            topPadding: 6
        }
        Label {
            Layout.fillWidth: true
            text: example.tr("The same rules applied where the buttons actually live. Liquid in floating containers, solid inside content, capsules for actions and 6pt corners for toolbar items.",
                             "把总则放回真实位置：浮起容器里用液态，内容里用实色；操作按钮是胶囊，工具栏项是 6 点圆角。")
            color: Ui.AppTheme.mutedText
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 6
            spacing: 12

            // toolbar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 52
                radius: 12
                color: Ui.AppTheme.dark ? "#232327" : "#F6F6F8"
                border.width: 1
                border.color: Ui.AppTheme.border
                Row {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 10
                    spacing: 8
                    Controls.LiquidActionButton { text: example.tr("Back", "返回"); implicitHeight: 22; implicitWidth: 58; font.pixelSize: 12; cornerRadius: 6 }
                    Controls.LiquidActionButton { text: example.tr("Share", "共享"); implicitHeight: 22; implicitWidth: 58; font.pixelSize: 12; cornerRadius: 6; materialForm: true }
                }
                Label {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 12
                    text: "toolbar 52"
                    color: Ui.AppTheme.mutedText; font.pixelSize: 11
                }
            }

            // content row
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 12
                color: Ui.AppTheme.dark ? "#232327" : "#F6F6F8"
                border.width: 1
                border.color: Ui.AppTheme.border
                Row {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 10
                    spacing: 8
                    Controls.LiquidActionButton { text: example.tr("Open", "打开"); materialForm: true; implicitHeight: 28 }
                    Controls.LiquidActionButton { text: example.tr("Done", "完成"); materialForm: true; highlighted: true; implicitHeight: 28 }
                    Controls.LiquidActionButton { text: example.tr("Delete", "删除"); materialForm: true; destructive: true; implicitHeight: 28 }
                }
                Label {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 12
                    text: "content row 44"
                    color: Ui.AppTheme.mutedText; font.pixelSize: 11
                }
            }

            // dialog footer
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 78
                radius: 12
                color: Ui.AppTheme.dark ? "#232327" : "#F6F6F8"
                border.width: 1
                border.color: Ui.AppTheme.border
                Row {
                    anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.rightMargin: 14; anchors.bottomMargin: 12
                    spacing: 8
                    Controls.LiquidActionButton { text: example.tr("Cancel", "取消"); materialForm: true; implicitHeight: 32 }
                    Controls.LiquidActionButton { text: example.tr("Save", "保存"); materialForm: true; highlighted: true; implicitHeight: 32 }
                }
                Label {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 12
                    text: "dialog footer 78"
                    color: Ui.AppTheme.mutedText; font.pixelSize: 11
                }
            }

            // floating bar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 64
                radius: 12
                color: Ui.AppTheme.dark ? "#232327" : "#F6F6F8"
                border.width: 1
                border.color: Ui.AppTheme.border
                Row {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; anchors.leftMargin: 12
                    spacing: 8
                    Controls.LiquidActionButton { iconOnly: true; iconName: "mediaPrevious"; iconFilled: true; implicitHeight: 28; iconSize: 14 }
                    Controls.LiquidActionButton { iconOnly: true; iconName: "mediaPlay"; iconFilled: true; implicitHeight: 28; iconSize: 14 }
                    Controls.LiquidActionButton { iconOnly: true; iconName: "mediaNext"; iconFilled: true; implicitHeight: 28; iconSize: 14 }
                }
                Label {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; anchors.rightMargin: 12
                    text: "floating bar 64"
                    color: Ui.AppTheme.mutedText; font.pixelSize: 11
                }
            }
        }
    }

}
