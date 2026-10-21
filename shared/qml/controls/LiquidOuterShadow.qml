import QtQuick
import QtQuick.Window

// Source-free outer shadow. The shared SDF shader has exactly zero alpha inside.
Item {
    id: root
    property real radius: 22
    property color shadowColor: "#000000"
    property real shadowOpacity: .06
    property real softness: 6
    property real spread: 18
    property vector2d offset: Qt.vector2d(0, 2)
    ShaderEffect {
        x: -root.spread; y: -root.spread
        width: root.width + 2 * root.spread; height: root.height + 2 * root.spread
        visible: GraphicsInfo.api !== GraphicsInfo.Software
        vertexShader: Qt.resolvedUrl("shaders/liquid_shadow.vert.qsb")
        fragmentShader: Qt.resolvedUrl("shaders/liquid_shadow.frag.qsb")
        property vector2d bodySize: Qt.vector2d(root.width, root.height)
        property vector2d shadowOffset: root.offset
        property real padding: root.spread
        property real radius: root.radius
        property real softness: root.softness
        property real shadowOpacity: root.shadowOpacity
        property color shadowColor: root.shadowColor
    }
}
