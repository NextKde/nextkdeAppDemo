import QtQuick
import QtQuick.Window
import QtQuick.Controls
import "../foundation" as Foundation

Pane {
    id: root
    property real radius: 22
    property real readability: 0.47
    property LiquidBackdrop backdrop: LiquidStyle.backdropFor(root.Window.window)
    property color tintColor: Foundation.AppTheme.dark ? "#141c30" : "#ffffff"
    property real tintStrength: .08
    property real blurStrength: .45
    property real refractionStrength: 3
    property real magnification: 1.025
    property real reflectionStrength: 1
    property bool shadowEnabled: false
    property color shadowColor: "#000000"
    property real shadowOpacity: .16
    readonly property bool sampling: cardGlass.sampling
    padding: 18
    background: Item {
        ShaderEffect {
            x: -18; y: -18; width: parent.width + 36; height: parent.height + 36
            visible: root.shadowEnabled && GraphicsInfo.api !== GraphicsInfo.Software
            vertexShader: Qt.resolvedUrl("shaders/liquid_shadow.vert.qsb")
            fragmentShader: Qt.resolvedUrl("shaders/liquid_shadow.frag.qsb")
            property vector2d bodySize: Qt.vector2d(root.width, root.height)
            property vector2d shadowOffset: Qt.vector2d(0, 3)
            property real padding: 18
            property real radius: root.radius
            property real softness: 6
            property real shadowOpacity: root.shadowOpacity
            property color shadowColor: root.shadowColor
        }
        LiquidSurface {
            id: cardGlass
            anchors.fill: parent
            radius: root.radius; readability: root.readability; backdrop: root.backdrop
            tintColor: root.tintColor; tintStrength: root.tintStrength
            blurStrength: root.blurStrength; refractionStrength: root.refractionStrength
            magnification: root.magnification; reflectionStrength: root.reflectionStrength
        }
    }
}
