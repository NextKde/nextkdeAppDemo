import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
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
        color: Ui.AppTheme.text; wrapMode: Text.WordWrap
        font.pixelSize: 20; font.weight: Font.Bold
        topPadding: 16; bottomPadding: 16
    }
    Label {
        Layout.fillWidth: true
        Layout.leftMargin: root.contentIndent
        Layout.rightMargin: root.contentIndent
        text: root.tr("03.1 · Toolbar actions", "03.1 · 工具栏操作")
        color: Ui.AppTheme.text
        font.pixelSize: 17; font.weight: Font.DemiBold
        topPadding: 8; bottomPadding: 8
    }
    Label {
        Layout.fillWidth: true
        Layout.leftMargin: root.contentIndent
        Layout.rightMargin: root.contentIndent
        text: root.tr("Scroll the content: the toolbar is glass; its input and action use plain fills.", "滚动下方内容：工具栏共用一层玻璃，内部搜索和按钮采用普通填充。")
        color: Ui.AppTheme.mutedText; wrapMode: Text.WordWrap
    }
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: tokens.sceneHeight
        Layout.leftMargin: root.contentIndent
        Layout.rightMargin: root.contentIndent
        clip: true
        // Capture only the sibling content. Neither toolbar nor controls enter it.
        Item {
            id: contentScene
            anchors.fill: parent
            Rectangle { anchors.fill: parent; color: tokens.regularColor }
            Flickable {
                anchors.fill: parent
                contentWidth: width; contentHeight: rows.implicitHeight
                boundsBehavior: Flickable.StopAtBounds; clip: true
                Column {
                    id: rows
                    width: parent.width; spacing: tokens.gap
                    Item { width: 1; height: tokens.toolbarHeight + 2 * tokens.gap }
                    Image {
                        width: parent.width; height: 128
                        source: "../../assets/contrast-flow.jpg"
                        fillMode: Image.PreserveAspectCrop; asynchronous: true
                    }
                    Repeater {
                        model: 12
                        Label {
                            required property int index
                            width: rows.width
                            leftPadding: tokens.gap; rightPadding: tokens.gap
                            topPadding: tokens.gap; bottomPadding: tokens.gap
                            text: root.tr("Scrolling content", "滚动内容") + " " + (index + 1) + " · Aa 0123456789"
                            font.pixelSize: tokens.bodySize; color: tokens.labelPrimary
                        }
                    }
                }
            }
        }
        Controls.LiquidBackdrop {
            id: sceneBackdrop
            sourceItem: contentScene; registerAsDefault: false
            blur: tokens.backdropBlur
        }
        Item {
            id: toolbar
            x: tokens.gap; y: tokens.gap
            width: parent.width - 2 * tokens.gap; height: tokens.toolbarHeight
            Rectangle {
                id: shadowShape
                anchors.fill: parent; radius: tokens.toolbarRadius
                color: tokens.regularColor; visible: false
            }
            DropShadow {
                anchors.fill: shadowShape; source: shadowShape
                verticalOffset: tokens.shadowMainOffset
                radius: tokens.shadowMainBlur; samples: 65
                color: Qt.rgba(0, 0, 0, tokens.shadowMainAlpha)
                visible: toolbar.enabled
            }
            DropShadow {
                anchors.fill: shadowShape; source: shadowShape
                verticalOffset: tokens.shadowContactOffset
                radius: tokens.shadowContactBlur; samples: 13
                color: Qt.rgba(0, 0, 0, tokens.shadowContactAlpha)
                visible: toolbar.enabled
            }
            Controls.LiquidSurface {
                anchors.fill: parent
                radius: tokens.toolbarRadius
                backdrop: Ui.AppTheme.reduceTransparency ? null : sceneBackdrop
                tintColor: tokens.regularColor
                tintStrength: Ui.AppTheme.reduceTransparency ? 1 : tokens.regularAlpha
                readability: 0; blurStrength: 0
                refractionStrength: tokens.refraction; magnification: tokens.magnification
                reflectionStrength: toolbar.enabled && !Ui.AppTheme.reduceTransparency ? tokens.reflection : 0
            }
            RowLayout {
                anchors.fill: parent; anchors.margins: tokens.gap; spacing: tokens.gap
                TextField {
                    id: query
                    Layout.fillWidth: true; Layout.minimumWidth: 28
                    Layout.preferredHeight: tokens.controlHeight
                    placeholderText: root.tr("Search", "搜索"); Accessible.name: placeholderText
                    font.pixelSize: tokens.bodySize
                    color: tokens.labelPrimary; placeholderTextColor: tokens.labelSecondary
                    leftPadding: tokens.gap; rightPadding: tokens.gap; selectByMouse: true
                    opacity: enabled ? 1 : tokens.disabledOpacity
                    background: Rectangle {
                        radius: tokens.controlRadius; color: tokens.inputFill
                        Rectangle {
                            anchors.fill: parent; anchors.margins: -tokens.focusOffset
                            radius: tokens.controlRadius + tokens.focusOffset; color: "transparent"
                            border.width: tokens.focusWidth; border.color: Ui.AppTheme.accent
                            visible: query.activeFocus
                        }
                    }
                }
                Button {
                    id: action
                    Layout.preferredHeight: tokens.controlHeight
                    implicitWidth: contentItem.implicitWidth + 2 * tokens.gap
                    text: root.tr("Clear", "清空"); hoverEnabled: true
                    opacity: enabled ? 1 : tokens.disabledOpacity
                    scale: down && !Ui.AppTheme.reduceMotion ? tokens.pressScale : 1
                    Behavior on scale {
                        NumberAnimation {
                            duration: Ui.AppTheme.reduceMotion ? 0 : tokens.instant
                            easing.type: Easing.BezierSpline
                            easing.bezierCurve: [.2, 0, 0, 1, 1, 1]
                        }
                    }
                    onClicked: query.clear()
                    contentItem: Label {
                        text: action.text; color: tokens.labelPrimary; font.pixelSize: tokens.bodySize
                        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    }
                    background: Rectangle {
                        radius: tokens.controlRadius
                        color: action.down ? tokens.pressFill : action.hovered ? tokens.hoverFill : tokens.plainFill
                        Behavior on color { ColorAnimation { duration: Ui.AppTheme.reduceMotion ? 0 : tokens.fast } }
                        Rectangle {
                            anchors.fill: parent; anchors.margins: -tokens.focusOffset
                            radius: tokens.controlRadius + tokens.focusOffset; color: "transparent"
                            border.width: tokens.focusWidth; border.color: Ui.AppTheme.accent
                            visible: action.visualFocus
                        }
                    }
                }
            }
        }
    }
}
