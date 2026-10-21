import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "../foundation" as Foundation

Button {
    id: root
    checkable: true
    property LiquidBackdrop backdrop: LiquidStyle.backdropForItem(root, root.Window.window)
    property string iconName: ""
    property color iconColor: Foundation.AppTheme.accent
    property real cornerRadius: height / 2
    property color selectionColor: Foundation.AppTheme.accent
    property color hoverColor: Foundation.AppTheme.withAlpha(Foundation.AppTheme.text, 0.07)
    property color focusRingColor: Foundation.AppTheme.focusRing
    property bool keyboardFocusOnly: false
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
            scale: root.down ? 1.10 : 1
            Behavior on scale {
                NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast; easing.type: Easing.OutBack }
            }
            radius: root.cornerRadius
            backdrop: root.backdrop
            convexLens: true
            edgeShadeStrength: .08
            blurStrength: 0
            readability: 0
            edgeWidth: Math.min(10, height * .28)
            refractionStrength: root.hovered ? 4.5 : 3
            magnification: root.hovered ? 1.045 : 1.025
            reflectionStrength: root.hovered ? .72 : .50
            tintColor: root.down ? "#ffffff" : root.checked ? root.selectionColor : (Foundation.AppTheme.dark ? "#20252f" : "#ffffff")
            tintStrength: root.down ? .06 : root.checked ? .80 : .30
            Behavior on refractionStrength { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
            Behavior on magnification { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
            Behavior on reflectionStrength { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
            Behavior on tintStrength { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        }

        Rectangle {
            anchors.fill: parent
            radius: root.cornerRadius
            color: "transparent"
            border.width: 2
            border.color: root.focusRingColor
            visible: false
        }
    }
    opacity: enabled ? 1 : 0.38
}
