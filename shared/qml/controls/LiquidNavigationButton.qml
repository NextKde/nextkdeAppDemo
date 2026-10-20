import QtQuick
import QtQuick.Controls
import "../foundation" as Foundation

Button {
    id: root
    checkable: true
    implicitHeight: 38
    leftPadding: 12
    rightPadding: 12
    hoverEnabled: true
    font.weight: checked ? Font.DemiBold : Font.Normal
    contentItem: Text {
        text: root.text
        color: Foundation.AppTheme.text
        font: root.font
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Item {
        LiquidSurface {
            anchors.fill: parent
            radius: 10
            tintColor: Foundation.AppTheme.accent
            tintStrength: root.checked ? 0.20 : 0.05
            visible: root.checked
        }
        Rectangle {
            anchors.fill: parent
            radius: 10
            color: Foundation.AppTheme.withAlpha(Foundation.AppTheme.text, 0.07)
            visible: !root.checked && root.hovered
        }
        Rectangle {
            anchors.fill: parent
            radius: 10
            color: "transparent"
            border.width: 2
            border.color: Foundation.AppTheme.focusRing
            visible: root.activeFocus
        }
    }
    opacity: enabled ? 1 : 0.38
}
