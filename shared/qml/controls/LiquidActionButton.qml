import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "../foundation" as Foundation

Button {
    id: root
    property string liquidIntensity: LiquidStyle.intensityLevel
    readonly property var _intensity: LiquidStyle.intensityProfile(liquidIntensity)
    property LiquidBackdrop backdrop: LiquidStyle.backdropForItem(root, root.Window.window)
    property bool materialForm: ControlForm.materialForm
    property bool darkAppearance: Foundation.AppTheme.dark
    property bool reduceMotion: Foundation.AppTheme.reduceMotion
    property bool secondary: false
    property bool destructive: false
    // Compact glyph actions keep their content centered without label insets.
    property bool shadowEnabled: false
    property int shadowLevel: LiquidStyle.shadowLevel
    property real shadowOpacity: LiquidStyle.shadowProfile(shadowLevel).opacity
    property bool adaptiveGlass: false
    property bool convexLens: !adaptiveGlass
    property real cornerRadius: materialForm && Foundation.AppTheme.compactDesign ? 8 : height / 2
    property bool iconOnly: false
    property string iconName: ""
    property bool iconFilled: false
    property real iconSize: 16
    property color textColor: destructive ? Foundation.AppTheme.destructive : Foundation.AppTheme.text
    property color iconColor: textColor
    property color surfaceColor: Foundation.AppTheme.compactDesign ? Foundation.AppTheme.controlBackground
        : root.darkAppearance ? "#20252f" : "#ffffff"
    property color accentColor: Foundation.AppTheme.accent
    property color focusRingColor: Foundation.AppTheme.focusRing
    property bool keyboardFocusOnly: false
    readonly property bool sampling: !materialForm && buttonGlass.sampling
    readonly property real opticalExpansion: buttonGlass.scale
    readonly property real opticalRefraction: buttonGlass.refractionStrength
    readonly property real opticalMagnification: buttonGlass.magnification
    readonly property real opticalReflection: buttonGlass.reflectionStrength
    hoverEnabled: true
    implicitHeight: Foundation.AppTheme.compactDesign ? 28 : 36
    Binding {
        target: root; property: "font.pixelSize"
        value: Foundation.AppTheme.compactControlFontSize; when: Foundation.AppTheme.compactDesign
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding {
        target: root; property: "font.weight"
        value: Font.Normal; when: Foundation.AppTheme.compactDesign
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding {
        target: root; property: "topPadding"
        value: 4; when: Foundation.AppTheme.compactDesign
        restoreMode: Binding.RestoreBindingOrValue
    }
    Binding {
        target: root; property: "bottomPadding"
        value: 4; when: Foundation.AppTheme.compactDesign
        restoreMode: Binding.RestoreBindingOrValue
    }
    implicitWidth: iconOnly ? implicitHeight : Math.max(76, contentItem.implicitWidth + leftPadding + rightPadding)
    leftPadding: iconOnly ? 0 : Foundation.AppTheme.compactDesign ? 12 : 14
    rightPadding: iconOnly ? 0 : Foundation.AppTheme.compactDesign ? 12 : 14
    scale: Foundation.AppTheme.compactDesign || adaptiveGlass ? 1 : materialForm ? (down ? .98 : 1) : hovered ? 1.03 : 1
    Behavior on scale { NumberAnimation { duration: root.reduceMotion ? 0 : Foundation.AppTheme.motionFast; easing.type: Easing.OutCubic } }
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
    background: Item {
        // Independent sibling behind the glass, never part of its material.
        LiquidOuterShadow {
            anchors.fill: parent
            z: -1
            radius: buttonGlass.radius
            outwardOffset: LiquidStyle.controlShadowOutset
            shadowLevel: root.shadowLevel
            visible: !root.materialForm && root.shadowEnabled
            shadowOpacity: root.shadowOpacity
        }
        Rectangle {
            anchors.fill: parent
            visible: root.materialForm
            radius: root.cornerRadius
            color: root.highlighted || root.checked ? root.accentColor
                : root.flat && !root.hovered && !root.down ? "transparent" : root.surfaceColor
            Rectangle {
                anchors.fill: parent; radius: parent.radius
                color: Foundation.AppTheme.text
                opacity: root.down ? .13 : root.hovered ? .07 : 0
            }
        }
        LiquidSurface {
        id: buttonGlass
        anchors.fill: parent
        visible: !root.materialForm
        darkAppearance: root.darkAppearance
        adaptiveGlass: root.adaptiveGlass
        convexLens: root.convexLens
        edgeShadeStrength: 0
        fullHighlight: !root.adaptiveGlass
        gradientFill: !root.adaptiveGlass
        fillCenterExtent: LiquidStyle.controlFillCenterExtent
        fillWhiteRimX: LiquidStyle.controlFillWhiteRimX
        fillWhiteRimY: root.darkAppearance ? 0 : LiquidStyle.controlFillWhiteRimY
        fillEdgeSpanY: root.darkAppearance ? LiquidStyle.controlFillEdgeSpanDark : -1
        fillEdgeColor: root.highlighted || root.checked ? root.accentColor : root.darkAppearance ? LiquidStyle.controlFillEdgeDark : LiquidStyle.controlFillEdge
        whiteEdgeDepth: 0
        whiteEdgeAlpha: 0
        // Preserve the actual sampled texture; the bezel supplies depth.
        blurStrength: root.convexLens ? root._intensity.blur : .45
        readability: 0
        edgeWidth: Math.min(10, height * .28)
        refractionStrength: root.adaptiveGlass ? .6 : root.hovered ? root._intensity.hoverRefraction : root._intensity.refraction
        magnification: root.adaptiveGlass ? 1 : root.hovered ? root._intensity.hoverMagnification : root._intensity.magnification
        Behavior on refractionStrength { NumberAnimation { duration: root.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        Behavior on magnification { NumberAnimation { duration: root.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        radius: root.cornerRadius
        backdrop: root.materialForm ? null : root.backdrop
        reflectionStrength: root.adaptiveGlass ? .12 : root.hovered ? root._intensity.hoverReflection : root._intensity.reflection
        Behavior on reflectionStrength { NumberAnimation { duration: root.reduceMotion ? 0 : Foundation.AppTheme.motionFast } }
        tintColor: root.highlighted || root.checked ? root.accentColor : root.darkAppearance ? LiquidStyle.controlFillCenterDark : LiquidStyle.controlFillCenter
        tintStrength: root.highlighted || root.checked ? 0.24 : LiquidStyle.controlFillOpacity
        Behavior on tintStrength {
            NumberAnimation { duration: root.reduceMotion ? 0 : Foundation.AppTheme.motionFast }
        }
        opacity: root.flat && !root.hovered && !root.checked && !root.visualFocus ? 0.45 : 1
        }
        Rectangle {
            anchors.fill: parent
            visible: !root.materialForm && root.adaptiveGlass
            radius: root.cornerRadius
            color: root.checked ? root.accentColor : Foundation.AppTheme.text
            opacity: root.down ? .10 : root.hovered ? .06 : root.checked ? .13 : 0
            Behavior on opacity { NumberAnimation { duration: root.reduceMotion ? 0 : 150 } }
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: root.cornerRadius + 2
            color: "transparent"
            border.width: 2
            border.color: root.focusRingColor
            visible: root.visualFocus
        }
    }
}
