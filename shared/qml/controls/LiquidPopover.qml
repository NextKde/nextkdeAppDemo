import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "../foundation" as Foundation

// An anchored action menu, not a modal editor dialog.
Menu {
    id: root
    property Item anchorItem: null
    property Item sourceItem: null
    property real highlightStrength: 0.32
    property real borderWidth: 0
    property color borderColor: "transparent"
    property real materialOpacity: LiquidStyle.panelMaterialOpacity
    property real cornerRadius: 12
    property string preferredSide: "bottom"
    property string anchorAlignment: "center"
    property real sideGap: anchorGap
    property real pointerOffset: 32
    readonly property bool sideways: preferredSide === "right"
    property real arrowY: pointerOffset
    property bool arrowEnabled: !sideways
    property bool arrowFits: false
    readonly property bool arrowVisible: arrowEnabled && arrowFits
    property real arrowHeight: 8
    readonly property real effectiveArrowHeight: arrowVisible ? arrowHeight : 0
    readonly property real reservedArrowInset: arrowEnabled ? arrowHeight : 0
    property real arrowWidth: 18
    property real anchorGap: 4
    property bool arrowOnBottom: false
    property real arrowX: width / 2
    parent: Overlay.overlay
    popupType: Popup.Item
    modal: false
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    implicitWidth: {
        let widest = 168
        for (let i = 0; i < count; ++i) {
            const entry = itemAt(i)
            if (entry && entry.visible) widest = Math.max(widest, entry.implicitWidth)
        }
        const available = parent ? parent.width - margins * 2 : 600
        return Math.min(widest + leftPadding + rightPadding, Math.max(100, available))
    }
    // Placement may hide or flip the pointer. Its reserved inset must not
    // feed back into the measured menu height while positioning runs.
    implicitHeight: {
        let total = padding * 2 + (sideways ? 0 : reservedArrowInset)
        let rows = 0
        for (let i = 0; i < count; ++i) {
            const entry = itemAt(i)
            if (entry && entry.visible) { total += entry.implicitHeight; ++rows }
        }
        const gap = contentItem && contentItem.spacing !== undefined ? contentItem.spacing : 0
        return total + Math.max(0, rows - 1) * gap
    }
    margins: 8
    padding: 6
    topPadding: padding + (!sideways && !arrowOnBottom ? reservedArrowInset : 0)
    bottomPadding: padding + (!sideways && arrowOnBottom ? reservedArrowInset : 0)
    leftPadding: padding + (sideways ? reservedArrowInset : 0)
    function updatePosition() {
        if (!anchorItem || !parent) return
        if (sideways) {
            const point = anchorItem.mapToItem(parent, anchorItem.width, anchorItem.height / 2)
            x = Math.max(margins, Math.min(parent.width - width - margins, point.x + sideGap))
            y = Math.max(margins, Math.min(parent.height - height - margins, point.y - pointerOffset))
            arrowY = pointerOffset
            const inset = cornerRadius + arrowWidth / 2
            arrowFits = x >= point.x && Math.abs(y + arrowY - point.y) < 1
                && arrowY >= inset && arrowY <= height - inset
                && point.y >= 0 && point.y <= parent.height
            return
        }
        const point = anchorItem.mapToItem(parent, anchorItem.width / 2, 0)
        const below = point.y + anchorItem.height + anchorGap
        arrowOnBottom = below + height > parent.height - margins && point.y > parent.height / 2
        x = Math.max(margins, Math.min(parent.width - width - margins, (anchorAlignment === "end" ? point.x + anchorItem.width / 2 - width : point.x - width / 2)))
        y = Math.max(margins, Math.min(parent.height - height - margins, arrowOnBottom ? point.y - anchorGap - height : below))
        arrowX = point.x - x
        const inset = cornerRadius + arrowWidth / 2
        arrowFits = (arrowOnBottom ? y + height <= point.y : y >= point.y + anchorItem.height)
            && arrowX >= inset && arrowX <= width - inset
            && point.x >= 0 && point.x <= parent.width && point.y >= 0
            && point.y + anchorItem.height <= parent.height
    }
    function openAtAnchor() {
        if (!anchorItem || !parent) return
        updatePosition()
        open()
        Qt.callLater(updatePosition)
    }
    onAboutToShow: updatePosition()
    onWidthChanged: if (visible) updatePosition()
    onHeightChanged: if (visible) updatePosition()
    Connections {
        target: root.anchorItem ? root.anchorItem.Window.window : null
        enabled: root.visible
        function onAfterAnimating() { root.updatePosition() }
    }
    background: Item {
        LiquidBackdrop {
            id: menuBackdrop
            sourceItem: root.sourceItem; registerAsDefault: false
            active: root.visible && !Foundation.AppTheme.reduceTransparency; blur: 0.85
        }
        LiquidPopoverSurface {
            anchors.centerIn: parent
            width: root.sideways ? parent.height : parent.width
            height: root.sideways ? parent.width : parent.height
            rotation: root.sideways ? -90 : 0
            backdrop: menuBackdrop
            highlightStrength: root.highlightStrength
            borderWidth: root.borderWidth; borderColor: root.borderColor
            materialOpacity: root.materialOpacity; cornerRadius: root.cornerRadius
            arrowHeight: root.effectiveArrowHeight; arrowWidth: root.arrowWidth
            arrowX: root.sideways ? root.height - root.arrowY : root.arrowX
            arrowOnBottom: !root.sideways && root.arrowOnBottom
        }
    }
}
