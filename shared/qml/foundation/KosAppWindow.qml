import QtQuick
import QtQuick.Controls
import QtQuick.Window

// Recommended portable app shell. Application state and platform negotiation
// belong to the host; this type never changes the global theme or saves settings.
ApplicationWindow {
    id: root
    width: 960
    height: 660
    minimumWidth: 640
    minimumHeight: 420
    flags: Qt.Window | Qt.FramelessWindowHint
    color: AppTheme.contentBackground
    property var windowActions: ["maximize", "minimize", "close"]
    // Optional host-owned adapter: { available, takeoverConfirmed, hoverGlyphs }.
    // Feed it targetWindow and windowControls; it owns protocol/event handling.
    property var windowControlsAdapter: null
    readonly property alias windowControls: controls
    property real titleBarHeight: 36
    function toggleMaximized() {
        if (visibility === Window.Maximized) showNormal()
        else showMaximized()
    }
    palette.window: AppTheme.contentBackground
    palette.windowText: AppTheme.text
    palette.text: AppTheme.text
    palette.base: AppTheme.contentBackground
    palette.buttonText: AppTheme.text
    palette.highlight: AppTheme.accent
    palette.highlightedText: AppTheme.accentText
    background: Rectangle { color: AppTheme.contentBackground }
    header: Item {
        height: root.visibility === Window.FullScreen ? 0 : root.titleBarHeight
        visible: height > 0
        MouseArea {
            anchors.fill: parent
            anchors.rightMargin: controls.width + 24
            property point origin
            property bool armed: false
            onPressed: mouse => { origin = Qt.point(mouse.x, mouse.y); armed = true }
            onReleased: armed = false
            onCanceled: armed = false
            onPositionChanged: mouse => {
                if (pressed && armed && (Math.abs(mouse.x-origin.x) > 4 || Math.abs(mouse.y-origin.y) > 4)) {
                    armed = false
                    root.startSystemMove()
                }
            }
            onDoubleClicked: {
                armed = false
                if (root.windowActions.indexOf("maximize") >= 0) root.toggleMaximized()
            }
        }
        Label {
            anchors.left: parent.left; anchors.leftMargin: 16
            anchors.right: controls.left; anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            text: root.title; color: AppTheme.text; elide: Text.ElideRight
            font.pixelSize: 12
        }
        KosWindowControls {
            id: controls
            targetWindow: root
            actions: root.windowActions
            maximizeMode: true
            circleSize: 14; buttonWidth: 22; buttonHeight: 22; spacing: 6
            anchors.right: parent.right; anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            externalDrawing: !!root.windowControlsAdapter
                && root.windowControlsAdapter.available === true
                && root.windowControlsAdapter.takeoverConfirmed === true
            hoverGlyphs: !root.windowControlsAdapter || root.windowControlsAdapter.hoverGlyphs !== false
        }
    }
    // Include header edges as well as the client area in resize hit regions.
    KosWindowResizeHandles { parent: root.contentItem.parent; targetWindow: root }
}
