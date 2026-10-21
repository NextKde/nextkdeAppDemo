import QtQuick
import QtQuick.Controls
import "../foundation" as Foundation

Button {
    id: root
    checkable: true
    property string iconName: ""
    property color iconColor: Foundation.AppTheme.accent
    property real cornerRadius: 10
    implicitHeight: 38
    leftPadding: 12
    rightPadding: 12
    hoverEnabled: true
    font.weight: checked ? Font.DemiBold : Font.Normal
    contentItem: Item {
        implicitWidth: caption.implicitWidth + (root.iconName.length ? 26 : 0)
        implicitHeight: Math.max(caption.implicitHeight, 16)
        VectorIcon {
            anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
            visible: root.iconName.length > 0
            name: root.iconName; size: 16; color: root.iconColor
        }
        Text {
            id: caption
            anchors.fill: parent; anchors.leftMargin: root.iconName.length ? 26 : 0
            text: root.text; color: Foundation.AppTheme.text; font: root.font
            verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight
        }
    }
    background: Item {
        LiquidSurface {
            anchors.fill: parent
            radius: root.cornerRadius
            tintColor: Foundation.AppTheme.accent
            tintStrength: root.checked ? 0.20 : 0.05
            visible: root.checked
        }
        Rectangle {
            anchors.fill: parent
            radius: root.cornerRadius
            color: Foundation.AppTheme.withAlpha(Foundation.AppTheme.text, 0.07)
            visible: !root.checked && root.hovered
        }
        Rectangle {
            anchors.fill: parent
            radius: root.cornerRadius
            color: "transparent"
            border.width: 2
            border.color: Foundation.AppTheme.focusRing
            visible: root.activeFocus
        }
    }
    opacity: enabled ? 1 : 0.38
}
