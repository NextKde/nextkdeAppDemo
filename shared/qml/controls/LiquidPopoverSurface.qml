import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import "../foundation" as Foundation

// One sampled material, clipped once to the complete body-and-arrow silhouette.
Item {
    id: root
    property LiquidBackdrop backdrop: null
    property real materialOpacity: LiquidStyle.panelMaterialOpacity
    property real cornerRadius: 12
    property real arrowHeight: 8
    property real arrowWidth: 18
    property real arrowX: width / 2
    property bool arrowOnBottom: false
    property bool reduceTransparency: Foundation.AppTheme.reduceTransparency
    readonly property bool sampling: material.sampling
    readonly property real tipX: Math.max(cornerRadius + arrowWidth / 2,
        Math.min(width - cornerRadius - arrowWidth / 2, arrowX))
    readonly property string contour: {
        const w = width, h = height, a = arrowHeight
        const t = arrowOnBottom ? 0 : a, b = arrowOnBottom ? h-a : h
        const r = Math.max(0, Math.min(cornerRadius, w/2, (b-t)/2))
        const x = tipX, half = arrowWidth/2
        let p = "M " + r + " " + t
        if (!arrowOnBottom)
            p += " L " + (x-half) + " " + t + " L " + x + " 0 L " + (x+half) + " " + t
        p += " L " + (w-r) + " " + t + " Q " + w + " " + t + " " + w + " " + (t+r)
        p += " L " + w + " " + (b-r) + " Q " + w + " " + b + " " + (w-r) + " " + b
        if (arrowOnBottom)
            p += " L " + (x+half) + " " + b + " L " + x + " " + h + " L " + (x-half) + " " + b
        p += " L " + r + " " + b + " Q 0 " + b + " 0 " + (b-r)
        p += " L 0 " + (t+r) + " Q 0 " + t + " " + r + " " + t + " Z"
        return p
    }
    layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowOpacity: 0.16
        shadowBlur: 0.65
        shadowVerticalOffset: 4
        blurMax: 32
        autoPaddingEnabled: true
    }
    Shape {
        id: silhouette
        anchors.fill: parent
        visible: !root.sampling
        layer.enabled: true
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: -1
            fillColor: root.sampling ? "white" : (Foundation.AppTheme.dark ? "#29292D" : "#F7F7F9")
            PathSvg { path: root.contour }
        }
    }
    LiquidPanelSurface {
        id: material
        anchors.fill: parent
        backdrop: root.backdrop
        materialOpacity: root.materialOpacity
        reduceTransparency: root.reduceTransparency
        cornerRadius: 0
        shadowEnabled: false
    }
    ShaderEffectSource {
        id: materialTexture
        anchors.fill: parent
        sourceItem: material
        hideSource: true
        live: true
        visible: false
    }
    MultiEffect {
        anchors.fill: parent
        visible: root.sampling
        source: materialTexture
        maskEnabled: true
        maskSource: silhouette
    }
}
