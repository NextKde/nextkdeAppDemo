import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls

// 第一章：总览。只讲两件事——液态材质放在哪一层，以及每一部分来自哪一代 macOS。
ScrollView {
    id: page
    property string language: "en"
    property real toolbarScrollInset: 0
    function tr(en, zh) { return language === "zh" ? zh : en }

    contentWidth: availableWidth
    clip: true

    ColumnLayout {
        width: page.availableWidth
        spacing: 18

        Item { visible: page.toolbarScrollInset > 0; Layout.fillWidth: true; Layout.preferredHeight: Math.max(0, page.toolbarScrollInset - 8) }

        Label {
            Layout.fillWidth: true
            text: page.tr("01 · Overview", "01 · 总览")
            color: Ui.AppTheme.text
            font.pixelSize: 24; font.weight: Font.Bold
        }
        Label {
            Layout.fillWidth: true
            text: page.tr("Liquid material from macOS 27, compact sizing from macOS 26. Material follows the layer; size follows the placement.",
                          "液态效果取自 macOS 27，尺寸与密度取自 macOS 26 紧凑规格。材质看层级，尺寸看位置。")
            color: Ui.AppTheme.mutedText
            font.pixelSize: 14
            wrapMode: Text.WordWrap
        }

        // 示意：上面一条液态浮层，下面一行实色按钮
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 176
            radius: 14
            color: Ui.AppTheme.dark ? "#1B1B1F" : "#F5F5F7"
            border.width: 1
            border.color: Ui.AppTheme.border

            Controls.LiquidActionButton { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 16
                text: page.tr("Liquid · floating layer", "液态 · 浮起层"); implicitHeight: 28 }
            Controls.LiquidActionButton { anchors.left: parent.left; anchors.top: parent.top; anchors.margins: 16
                anchors.leftMargin: 170; text: page.tr("Toolbar", "工具栏"); implicitHeight: 22; font.pixelSize: 12 }

            Rectangle {
                anchors.left: parent.left; anchors.right: parent.right
                anchors.top: parent.top; anchors.topMargin: 88
                anchors.leftMargin: 16; anchors.rightMargin: 16
                height: 1; color: Ui.AppTheme.border
            }

            Controls.LiquidActionButton { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 16
                text: page.tr("Solid · content layer", "实色 · 内容层"); materialForm: true; implicitHeight: 28 }
            Controls.LiquidActionButton { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 16
                anchors.leftMargin: 190; text: page.tr("Primary", "主操作"); materialForm: true; highlighted: true; implicitHeight: 28 }
            Controls.LiquidActionButton { anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 16
                anchors.leftMargin: 290; text: page.tr("Delete", "删除"); materialForm: true; destructive: true; implicitHeight: 28 }
        }

        // 材质放哪里
        GridLayout {
            Layout.fillWidth: true
            columns: 3
            columnSpacing: 16
            rowSpacing: 10

            Label { text: page.tr("Layer", "层级"); color: Ui.AppTheme.mutedText; font.pixelSize: 12; font.weight: Font.DemiBold }
            Label { text: page.tr("Material", "材质"); color: Ui.AppTheme.mutedText; font.pixelSize: 12; font.weight: Font.DemiBold }
            Label { text: page.tr("Where it appears", "出现在哪里"); color: Ui.AppTheme.mutedText; font.pixelSize: 12; font.weight: Font.DemiBold }

            Label { Layout.preferredWidth: 210; wrapMode: Text.WordWrap; color: Ui.AppTheme.text; font.pixelSize: 13
                text: page.tr("Floating (function layer)", "浮起（功能层）") }
            Label { Layout.preferredWidth: 190; wrapMode: Text.WordWrap; color: Ui.AppTheme.text; font.pixelSize: 13
                text: page.tr("Liquid glass", "液态玻璃") }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Ui.AppTheme.mutedText; font.pixelSize: 12
                text: page.tr("Toolbar, sidebar container, popovers, player bar", "工具栏、侧栏容器、浮层、播放条") }

            Label { Layout.preferredWidth: 210; wrapMode: Text.WordWrap; color: Ui.AppTheme.text; font.pixelSize: 13
                text: page.tr("Content (inside the window)", "内容（窗口之内）") }
            Label { Layout.preferredWidth: 190; wrapMode: Text.WordWrap; color: Ui.AppTheme.text; font.pixelSize: 13
                text: page.tr("Solid fill", "实色填充") }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Ui.AppTheme.mutedText; font.pixelSize: 12
                text: page.tr("Lists, forms, cards, buttons in the content area, sidebar rows, menu bar items", "列表、表单、卡片、内容区按钮；侧栏条目与菜单条条目") }
        }

        // 三条规则
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            Label { text: page.tr("Three rules", "三条规则"); color: Ui.AppTheme.text; font.pixelSize: 17; font.weight: Font.DemiBold }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Ui.AppTheme.text; font.pixelSize: 13
                text: page.tr("1 · One liquid treatment per panel.", "1 · 一个面板只用一种液态。") }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Ui.AppTheme.mutedText; font.pixelSize: 12
                text: page.tr("A panel is one floating container: a toolbar, a sidebar, a popover, a player bar. Everything inside it shares the same tint, rim and blur; two panels may differ from each other.",
                             "面板 = 一个独立的浮起容器（一条工具栏、一个侧栏、一个浮层、一条播放条）。同一面板内的液态元素共用同一套染色、高光与模糊；不同面板之间可以各自不同。") }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Ui.AppTheme.text; font.pixelSize: 13
                text: page.tr("2 · Never use liquid glass for a large area in the content layer.", "2 · 内容层不要大面积使用液态玻璃。") }
            Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Ui.AppTheme.text; font.pixelSize: 13
                text: page.tr("3 · On a uniform background the glass has nothing to sample; only the rim keeps its outline.", "3 · 均匀纯色背景下玻璃无内容可采，只能靠高光维持轮廓。") }
        }
    }
}
