import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "../foundation" as Foundation

Button {
    id: root
    property LiquidBackdrop backdrop: LiquidStyle.backdropFor(root.Window.window)
    property bool secondary: false
    property bool destructive: false
    // Compact glyph actions keep their content centered without label insets.
    property bool iconOnly: false
    property string iconName: ""
    property real iconSize: 16
    readonly property bool sampling: buttonGlass.sampling
    readonly property real opticalExpansion: buttonGlass.scale
    readonly property real opticalRefraction: buttonGlass.refractionStrength
    readonly property real opticalMagnification: buttonGlass.magnification
    readonly property real opticalReflection: buttonGlass.reflectionStrength
    hoverEnabled: true
    implicitHeight: 36
    implicitWidth: iconOnly ? 36 : Math.max(76, contentItem.implicitWidth + 28)
    leftPadding: iconOnly ? 0 : 14
    rightPadding: iconOnly ? 0 : 14
    scale: down ? 0.96 : hovered ? 1.02 : 1
    Behavior on scale { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast; easing.type: Easing.OutCubic } }
    opacity: enabled ? 1 : 0.38
    contentItem: Item {
        implicitWidth: root.iconName.length ? root.iconSize : caption.implicitWidth
        implicitHeight: Math.max(caption.implicitHeight, root.iconName.length ? root.iconSize : 0)
        Label {
            id: caption
            anchors.fill: parent
            visible: !root.iconName.length
            text: root.text
            font: root.font
            color: root.destructive ? Foundation.AppTheme.destructive : Foundation.AppTheme.text
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: root.iconOnly ? Text.ElideNone : Text.ElideRight
        }
        VectorIcon {
            anchors.centerIn: parent
            visible: root.iconName.length > 0
            name: root.iconName
            size: root.iconSize
            color: root.destructive ? Foundation.AppTheme.destructive : Foundation.AppTheme.text
        }
    }
    background: LiquidSurface {
        id: buttonGlass
        scale: root.down ? 1.065 : root.hovered ? 1.018 : 1
        Behavior on scale { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast; easing.type: Easing.OutCubic } }
        refractionStrength: root.down ? 7 : root.hovered ? 4.5 : 3
        magnification: root.down ? 1.07 : root.hovered ? 1.045 : 1.025
        Behavior on refractionStrength { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        Behavior on magnification { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        radius: height / 2
        backdrop: root.backdrop
        reflectionStrength: root.down ? .90 : root.hovered ? .72 : .50
        Behavior on reflectionStrength { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        tintColor: root.highlighted || root.checked ? Foundation.AppTheme.accent
            : Foundation.AppTheme.dark ? "#17223b" : "#ffffff"
        tintStrength: root.highlighted || root.checked ? 0.24 : root.down ? 0.18
            : root.hovered ? 0.12 : root.secondary ? 0.03 : 0.05
        opacity: root.flat && !root.hovered && !root.checked && !root.activeFocus ? 0.45 : 1
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: height / 2
            color: "transparent"
            border.width: 2
            border.color: Foundation.AppTheme.focusRing
            visible: root.activeFocus
        }
    }
}
