import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "../foundation" as Foundation

Button {
    id: root
    checkable: true
    property LiquidBackdrop backdrop: LiquidStyle.backdropForItem(root, root.Window.window)
    property string iconName: ""
    property url iconSource: ""
    property color iconColor: Foundation.AppTheme.accent
    property real cornerRadius: height / 2
    // 选中态用中性灰，不用强调色：苹果官方截图实测 #E7E7E7 叠在 #F2F2F2 上 ≈ 6% 黑
    property color selectionColor: Foundation.AppTheme.dark
        ? Qt.rgba(1, 1, 1, 0.08)
        : Qt.rgba(0, 0, 0, 0.06)
    property color hoverColor: Foundation.AppTheme.withAlpha(Foundation.AppTheme.text, 0.07)
    property color focusRingColor: Foundation.AppTheme.focusRing
    property bool keyboardFocusOnly: false
    property bool showIdleBackground: true
    // Opt-in pilot: plain rows inside a host-owned sidebar material.
    // Existing applications retain their current liquid navigation by default.
    property bool specificationForm: false
    property int specificationFontSize: Foundation.AppTheme.compactDesign ? 13 : 14
    property int specificationSelectedVerticalInset: 0
    readonly property QtObject specification: QtObject {
        readonly property int rowHeight: 30
        readonly property int radius: 8
        readonly property int fontSize: root.specificationFontSize
        readonly property int focusWidth: 2
        readonly property int focusOffset: 2
        readonly property int pressDuration: 100
        readonly property int hoverDuration: 150
        readonly property real pressScale: .96
        readonly property real selectedAlpha: .13
        readonly property color hoverFill: Foundation.AppTheme.dark
            ? Qt.rgba(1, 1, 1, .08) : Qt.rgba(0, 0, 0, .06)
        readonly property color pressFill: Foundation.AppTheme.dark
            ? Qt.rgba(1, 1, 1, .12) : Qt.rgba(0, 0, 0, .10)
    }
    property color specificationSelectedFillColor: Foundation.AppTheme.withAlpha(selectionColor, specification.selectedAlpha)
    property color specificationHoverFillColor: specification.hoverFill
    property color specificationSelectedTextColor: Foundation.AppTheme.dark
        ? Qt.rgba(1, 1, 1, .92) : Qt.rgba(0, 0, 0, .92)
    implicitHeight: specificationForm || Foundation.AppTheme.compactDesign ? specification.rowHeight : 38
    leftPadding: 12
    rightPadding: 12
    hoverEnabled: true
    font.weight: checked ? Font.DemiBold : Font.Normal
    Binding {
        target: root
        property: "font.pixelSize"
        value: root.specification.fontSize
        when: root.specificationForm || Foundation.AppTheme.compactDesign
        restoreMode: Binding.RestoreBindingOrValue
    }
    scale: specificationForm && down && !Foundation.AppTheme.reduceMotion ? specification.pressScale : 1
    Behavior on scale {
        NumberAnimation {
            duration: Foundation.AppTheme.reduceMotion ? 0 : root.specification.pressDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [.2, 0, 0, 1, 1, 1]
        }
    }
    contentItem: Item {
        implicitWidth: caption.implicitWidth + (root.iconName.length ? 26 : 0)
        implicitHeight: Math.max(caption.implicitHeight, 16)
        VectorIcon {
            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
            visible: root.iconName.length > 0 && !root.iconSource.toString().length
            name: root.iconName; size: 16; color: root.iconColor
        }
        Image {
            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
            width: 16; height: 16
            visible: root.iconSource.toString().length > 0
            source: root.iconSource
            sourceSize: Qt.size(32, 32)
        }
        Text {
            id: caption
            anchors.fill: parent; anchors.leftMargin: root.iconName.length ? 26 : 0
            text: root.text
            color: root.specificationForm
                ? (root.checked ? root.specificationSelectedTextColor
                    : Foundation.AppTheme.dark ? Qt.rgba(1, 1, 1, .92) : Qt.rgba(0, 0, 0, .92))
                : Foundation.AppTheme.text
            font: root.font
            verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
        }
    }
    background: Item {
        Rectangle {
            anchors.fill: parent
            visible: root.specificationForm
            radius: root.specification.radius
            color: "transparent"
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: root.specificationSelectedVerticalInset
                anchors.bottomMargin: root.specificationSelectedVerticalInset
                radius: Math.max(0, parent.radius - root.specificationSelectedVerticalInset)
                visible: root.checked
                color: root.specificationSelectedFillColor
            }
            Rectangle {
                anchors.fill: parent; radius: parent.radius
                color: root.down ? root.specification.pressFill
                    : root.hovered && !root.checked ? root.specificationHoverFillColor : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: Foundation.AppTheme.reduceMotion ? 0 : root.specification.hoverDuration
                        easing.type: Easing.BezierSpline
                        easing.bezierCurve: [.2, 0, 0, 1, 1, 1]
                    }
                }
            }
        }
        // 侧栏条目不用液态玻璃：选中 / 悬停 / 按下都是实色填充。
        Rectangle {
            anchors.fill: parent
            visible: !root.specificationForm && (root.showIdleBackground || root.checked || root.hovered || root.down)
            radius: root.cornerRadius
            color: root.checked ? root.selectionColor
                : root.down ? Foundation.AppTheme.withAlpha(Foundation.AppTheme.text, 0.10)
                : root.hovered ? Foundation.AppTheme.withAlpha(Foundation.AppTheme.text, 0.06)
                : "transparent"
            Behavior on color {
                ColorAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast }
            }
        }

        Rectangle {
            anchors.fill: parent
            anchors.margins: root.specificationForm ? -(root.specification.focusOffset + root.specification.focusWidth) : 0
            radius: root.specificationForm ? root.specification.radius + root.specification.focusOffset : root.cornerRadius
            color: "transparent"
            border.width: 2
            border.color: root.focusRingColor
            visible: root.specificationForm && root.visualFocus
        }
    }
    opacity: enabled ? 1 : 0.38
}
