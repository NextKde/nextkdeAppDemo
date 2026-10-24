import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: root
    property string language: "en"
    property int contentIndent: 16
    function tr(en, zh) { return language === "zh" ? zh : en }
    spacing: tokens.gap
    MaterialSpecTokens { id: tokens; dark: Ui.AppTheme.dark }
    Label {
        Layout.fillWidth: true
        text: root.tr("03 · Composition example", "03 · 组合示例")
        color: Ui.AppTheme.text
        font.pixelSize: tokens.sectionTitleSize; font.weight: Font.DemiBold
        topPadding: tokens.sectionPadding; bottomPadding: tokens.sectionPadding
    }
    Label {
        Layout.fillWidth: true
        Layout.leftMargin: root.contentIndent; Layout.rightMargin: root.contentIndent
        text: root.tr("The floating toolbar uses light glass over scrolling content; its search and action stay ordinary.",
            "悬浮工具栏以轻玻璃覆盖滚动内容，内部搜索和按钮保持普通材质。")
        color: Ui.AppTheme.mutedText; wrapMode: Text.WordWrap
    }
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: tokens.sceneHeight
        Layout.leftMargin: root.contentIndent; Layout.rightMargin: root.contentIndent
        clip: true
        Item {
            id: scrollScene
            anchors.fill: parent
            Rectangle { anchors.fill: parent; color: tokens.contentFill }
            Flickable {
                anchors.fill: parent
                contentWidth: width; contentHeight: rows.implicitHeight
                boundsBehavior: Flickable.StopAtBounds; clip: true
                Column {
                    id: rows
                    width: parent.width
                    Item { width: 1; height: tokens.gap + tokens.toolbarHeight + tokens.sectionGap }
                    Repeater {
                        model: 12
                        Rectangle {
                            required property int index
                            width: rows.width; height: tokens.listHeight
                            color: index % 2 ? tokens.secondaryFill : tokens.contentFill
                            Label {
                                anchors.fill: parent; leftPadding: tokens.gap
                                verticalAlignment: Text.AlignVCenter
                                text: root.tr("Scrolling content", "滚动内容") + " " + (index + 1)
                                font.pixelSize: tokens.bodySize; color: tokens.labelPrimary
                            }
                        }
                    }
                }
            }
        }
        Controls.LiquidBackdrop {
            id: toolbarBackdrop
            sourceItem: scrollScene; registerAsDefault: false
            active: !Ui.AppTheme.reduceTransparency; blur: tokens.toolbarBlur
        }
        Controls.LiquidSurface {
            id: toolbarBase
            x: tokens.gap; y: tokens.gap
            width: parent.width - 2 * tokens.gap; height: tokens.toolbarHeight
            adaptiveGlass: true; backdrop: toolbarBackdrop
            convexLens: true; fullHighlight: true
            radius: tokens.toolbarRadius; blurStrength: 0
            refractionStrength: tokens.toolbarOptics.refraction
            magnification: tokens.toolbarOptics.magnification
            reflectionStrength: tokens.toolbarOptics.reflection
        }
        RowLayout {
            anchors.fill: toolbarBase; anchors.margins: tokens.gap; spacing: tokens.gap
            Controls.LiquidTextField {
                id: query
                Layout.fillWidth: true; Layout.minimumWidth: tokens.controlHeight
                Layout.preferredHeight: tokens.searchHeight
                specificationForm: true
                cornerRadius: tokens.controlRadius
                focusedOutlineColor: tokens.focusAccent
                placeholderText: root.tr("Search", "搜索")
                Accessible.name: placeholderText
            }
            Controls.LiquidActionButton {
                Layout.preferredHeight: tokens.controlHeight
                text: root.tr("Clear", "清空")
                materialForm: true
                cornerRadius: tokens.controlRadius; focusRingColor: tokens.focusAccent
                onClicked: query.clear()
            }
        }
    }
}
