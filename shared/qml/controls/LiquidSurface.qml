import QtQuick
import QtQuick.Window
import "../foundation" as Foundation

Item {
    id: root
    property real radius: 22
    property LiquidBackdrop backdrop: LiquidStyle.backdropFor(root.Window.window)
    property bool darkAppearance: Foundation.AppTheme.dark
    property color tintColor: darkAppearance ? "#141c30" : "#ffffff"
    property real tintStrength: 0.08
    property real blurStrength: 0.45
    property real readability: 0.47
    property real refractionStrength: 3
    property real magnification: 1.025
    property real edgeWidth: 12
    property real reflectionStrength: 1
    property color rimColor: Qt.rgba(1, 1, 1, 0.30)
    readonly property bool sampling: canSampleBackdrop && _mappingValid
        && optics.status !== ShaderEffect.Error
    readonly property bool canSampleBackdrop: backdrop !== null && backdrop.canSample(root)
        && width > 0 && height > 0 && GraphicsInfo.api !== GraphicsInfo.Software
    property bool _mappingValid: false
    property vector2d _sampleOrigin: Qt.vector2d(0, 0)
    property vector2d _sampleAxisX: Qt.vector2d(1, 0)
    property vector2d _sampleAxisY: Qt.vector2d(0, 1)

    function updateMapping() {
        if (!canSampleBackdrop) { _mappingValid = false; return }
        const source = backdrop.sourceItem
        const origin = mapToItem(source, 0, 0)
        const endX = mapToItem(source, width, 0)
        const endY = mapToItem(source, 0, height)
        _sampleOrigin = Qt.vector2d(origin.x / source.width, origin.y / source.height)
        _sampleAxisX = Qt.vector2d((endX.x - origin.x) / source.width, (endX.y - origin.y) / source.height)
        _sampleAxisY = Qt.vector2d((endY.x - origin.x) / source.width, (endY.y - origin.y) / source.height)
        _mappingValid = true
    }

    Component.onCompleted: Qt.callLater(updateMapping)
    onBackdropChanged: { _mappingValid = false; Qt.callLater(updateMapping) }
    onCanSampleBackdropChanged: Qt.callLater(updateMapping)
    onXChanged: updateMapping()
    onYChanged: updateMapping()
    onWidthChanged: updateMapping()
    onHeightChanged: updateMapping()
    Connections {
        target: root.Window.window
        enabled: root.visible && root.canSampleBackdrop
        // Also follows ancestor scrolling, rotation and animated scale.
        function onAfterAnimating() { root.updateMapping() }
    }

    Rectangle {
        anchors.fill: parent
        visible: !root.sampling
        radius: root.radius
        color: root.tintColor
        opacity: Math.max(0, Math.min(1, root.tintStrength))
    }
    ShaderEffect {
        id: optics
        anchors.fill: parent
        visible: root.canSampleBackdrop && root._mappingValid
        vertexShader: Qt.resolvedUrl("shaders/liquid_surface.vert.qsb")
        fragmentShader: Qt.resolvedUrl("shaders/liquid_surface.frag.qsb")
        property var source: root.canSampleBackdrop ? root.backdrop.texture : null
        property vector2d surfaceSize: Qt.vector2d(Math.max(1, root.width), Math.max(1, root.height))
        property vector2d sampleOrigin: root._sampleOrigin
        property vector2d sampleAxisX: root._sampleAxisX
        property vector2d sampleAxisY: root._sampleAxisY
        property real radius: root.radius
        property color tintColor: root.tintColor
        property real tintStrength: root.tintStrength
        property real blurRadius: Math.max(0, root.blurStrength) * 8
        property real readability: root.readability
        property real lightAppearance: root.darkAppearance ? 0 : 1
        property real refractionStrength: root.refractionStrength
        property real magnification: root.magnification
        property real edgeWidth: root.edgeWidth
    }
    // One directional reflection pass, independent of backdrop sampling.
    // Light follows the shape normal; no full-perimeter rim or inner bevel.
    ShaderEffect {
        anchors.fill: parent
        visible: GraphicsInfo.api !== GraphicsInfo.Software
        vertexShader: Qt.resolvedUrl("shaders/liquid_reflection.vert.qsb")
        fragmentShader: Qt.resolvedUrl("shaders/liquid_reflection.frag.qsb")
        property vector2d surfaceSize: Qt.vector2d(Math.max(1, root.width), Math.max(1, root.height))
        property real radius: root.radius
        property real reflectionStrength: root.reflectionStrength
        property color rimColor: root.rimColor
    }
    // Software rendering cannot run ShaderEffect. Keep a restrained, open
    // directional arc instead of restoring the former all-around outline.
    Canvas {
        id: softReflection
        anchors.fill: parent
        visible: GraphicsInfo.api === GraphicsInfo.Software
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: root
            function onRadiusChanged() { softReflection.requestPaint() }
            function onReflectionStrengthChanged() { softReflection.requestPaint() }
            function onRimColorChanged() { softReflection.requestPaint() }
        }
        onPaint: {
            const ctx = getContext("2d")
            ctx.reset()
            if (width < 2 || height < 2) return
            const r = Math.min(root.radius, width / 2, height / 2)
            const strength = Math.max(0, Math.min(2, root.reflectionStrength))
            const fade = ctx.createLinearGradient(0, 0, width * .72, height)
            fade.addColorStop(0, Qt.rgba(1, 1, 1, .065 * strength))
            fade.addColorStop(.45, Qt.rgba(1, 1, 1, .022 * strength))
            fade.addColorStop(.75, "transparent")
            fade.addColorStop(1, "transparent")
            ctx.beginPath()
            ctx.moveTo(r, 2)
            ctx.lineTo(width - r, 2)
            ctx.arcTo(width - 2, 2, width - 2, r, r)
            ctx.lineTo(width - 2, height - r)
            ctx.arcTo(width - 2, height - 2, width - r, height - 2, r)
            ctx.lineTo(r, height - 2)
            ctx.arcTo(2, height - 2, 2, height - r, r)
            ctx.lineTo(2, r)
            ctx.arcTo(2, 2, r, 2, r)
            ctx.strokeStyle = fade
            ctx.lineWidth = 3
            ctx.stroke()
        }
    }
}
