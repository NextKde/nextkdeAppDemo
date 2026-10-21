import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "../foundation" as Foundation

Button {
    id: root
    property LiquidBackdrop backdrop: LiquidStyle.backdropForItem(root, root.Window.window)
    property bool secondary: false
    property bool destructive: false
    // Compact glyph actions keep their content centered without label insets.
    property bool shadowEnabled: false
    property real shadowOpacity: .06
    property bool convexLens: true
    property bool iconOnly: false
    property string iconName: ""
    property bool iconFilled: false
    property real iconSize: 16
    property color textColor: destructive ? Foundation.AppTheme.destructive : Foundation.AppTheme.text
    property color iconColor: textColor
    property color surfaceColor: Foundation.AppTheme.dark ? "#20252f" : "#ffffff"
    property color accentColor: Foundation.AppTheme.accent
    property color focusRingColor: Foundation.AppTheme.focusRing
    property bool keyboardFocusOnly: false
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
    scale: hovered ? 1.03 : 1
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
            color: root.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: root.iconOnly ? Text.ElideNone : Text.ElideRight
        }
        VectorIcon {
            anchors.centerIn: parent
            visible: root.iconName.length > 0
            filled: root.iconFilled
            name: root.iconName
            size: root.iconSize
            color: root.iconColor
        }
    }
    background: LiquidSurface {
        id: buttonGlass
        convexLens: root.convexLens
        edgeShadeStrength: .10
        // Preserve the actual sampled texture; the bezel supplies depth.
        blurStrength: root.convexLens ? 0 : .45
        readability: 0
        edgeWidth: Math.min(10, height * .28)
        refractionStrength: root.hovered ? 4.5 : 3
        magnification: root.hovered ? 1.045 : 1.025
        Behavior on refractionStrength { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        Behavior on magnification { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        radius: height / 2
        backdrop: root.backdrop
        reflectionStrength: root.hovered ? .72 : .50
        Behavior on reflectionStrength { NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        tintColor: root.highlighted || root.checked ? root.accentColor : root.surfaceColor
        tintStrength: root.highlighted || root.checked ? 0.24
            : root.hovered ? 0.25 : 0.20
        Behavior on tintStrength {
            NumberAnimation { duration: Foundation.AppTheme.reduceMotion ? 0 : Foundation.AppTheme.motionFast }
        }
        opacity: root.flat && !root.hovered && !root.checked && !root.visualFocus ? 0.45 : 1
        LiquidOuterShadow {
            anchors.fill: parent; z: -1; radius: parent.radius
            visible: root.shadowEnabled; shadowOpacity: root.shadowOpacity
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: height / 2
            color: "transparent"
            border.width: 2
            border.color: root.focusRingColor
            visible: root.visualFocus
        }
    }
}
