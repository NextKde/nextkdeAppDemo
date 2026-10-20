import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    objectName: "reviewNav"
    property int destination: 0
    property int requestCount: 0
    property var navigationItems: [{id: "home", label: "Home", icon: "H"},
        {id: "search", label: "Search", icon: "S"}, {id: "library", label: "Library", icon: "L"}]
    property var sequenceFrames: []
    property var _pendingGrabs: []
    property string _directory: ""
    property double _startedAt: 0
    property int _nextFrame: 0
    property bool _released: false
    readonly property var _delays: [0, 40, 100, 160, 240, 300, 380, 500]
    spacing: 16
    function beginReviewPress(index) { sample._beginPress(index) }
    function endReviewPress(index) { sample._endPress(); sample.select(index) }
    function cancelReviewPress() { sample._endPress() }
    function focusReviewControl() { sample._selectAndFocus(sample.currentIndex) }
    function clearReviewFocus() {
        const pending = [sample]
        while (pending.length) {
            const item = pending.pop()
            if (item.activeFocus) item.focus = false
            for (let i = 0; i < item.children.length; ++i) pending.push(item.children[i])
        }
        example.forceActiveFocus(Qt.OtherFocusReason)
    }
    function resetReview() { sample._endPress(); sample.currentIndex = 0; destination = 0; requestCount = 0 }
    function controlState() { return { currentIndex: sample.currentIndex, destination: destination,
        requestCount: requestCount, pressedIndex: sample._pressedIndex, active: sample._isActive,
        displayX: sample._displayX, scaleX: sample._displayScaleX, scaleY: sample._displayScaleY,
        focusIndex: sample._focusedIndex, sampling: sample.sampling } }
    function previewState() { const state = controlState(); state.sequenceFrames = sequenceFrames; return JSON.stringify(state) }
    function startReviewSequence(directory) {
        if (!directory || directory.charAt(0) !== "/" || sequenceTimer.running) return
        resetReview()
        _directory = directory; _nextFrame = 0; _released = false
        sequenceFrames = []; _pendingGrabs = []
        // Start after the previous selected position has settled.
        settleTimer.restart()
    }
    function collectFrame(delay, elapsed) {
        const state = controlState()
        navScene.grabToImage(function(result) {
            const next = _pendingGrabs.slice()
            next.push({ result: result, scheduledMs: delay, requestedAtMs: elapsed, stateAtRequest: state })
            _pendingGrabs = next
            // Retain actual GPU grab results. Compress only AFTER all frames;
            // synchronous PNG encoding must not stall the observed animation.
            if (_pendingGrabs.length === _delays.length) Qt.callLater(saveFrames)
        })
    }
    function saveFrames() {
        const frames = []
        for (const frame of _pendingGrabs) {
            const path = _directory + "/nav-" + String(frame.scheduledMs).padStart(3, "0") + ".png"
            frames.push({ path: path, scheduledMs: frame.scheduledMs, requestedAtMs: frame.requestedAtMs,
                saved: frame.result.saveToFile(path), stateAtRequest: frame.stateAtRequest })
        }
        sequenceFrames = frames
        _pendingGrabs = []
    }
    Timer {
        id: settleTimer; interval: 500
        onTriggered: { example.beginReviewPress(2); example._startedAt = Date.now(); sequenceTimer.start() }
    }
    Timer {
        id: sequenceTimer; interval: 8; repeat: true
        onTriggered: {
            const elapsed = Date.now() - example._startedAt
            if (!example._released && elapsed >= 200) { example._released = true; example.endReviewPress(2) }
            while (example._nextFrame < example._delays.length && elapsed >= example._delays[example._nextFrame]) {
                example.collectFrame(example._delays[example._nextFrame], elapsed); example._nextFrame++
            }
            if (example._nextFrame === example._delays.length) stop()
        }
    }
    Item {
        id: navScene
        Layout.fillWidth: true; Layout.preferredHeight: 156
        clip: true
        Item {
            id: textureScene
            anchors.fill: parent
            clip: true
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#547d9a" }
                    GradientStop { position: .5; color: "#a582a5" }
                    GradientStop { position: 1; color: "#cba776" }
                }
            }
            Repeater { model: 24; Rectangle { required property int index; x: index * 29; width: 5; height: textureScene.height; color: "#66ffffff" } }
        }
        Controls.LiquidBackdrop { id: texture; sourceItem: textureScene; registerAsDefault: false }
        Controls.LiquidNavBar {
            id: sample
            anchors.centerIn: parent
            model: example.navigationItems
            currentIndex: example.destination
            materialForm: false
            backdrop: texture
            accentColor: Ui.AppTheme.accent
            itemColor: Ui.AppTheme.text
            trackColor: Ui.AppTheme.withAlpha(Ui.AppTheme.windowRaised, .42)
            onSelectionChanged: function(index) { example.requestCount++; example.destination = index }
        }
    }
    Label { text: "Disabled"; color: Ui.AppTheme.mutedText }
    Controls.LiquidNavBar {
        model: example.navigationItems; disabled: true; materialForm: false
        itemColor: Ui.AppTheme.text; accentColor: Ui.AppTheme.accent
        trackColor: Ui.AppTheme.withAlpha(Ui.AppTheme.windowRaised, .5)
    }
    Label { text: "Preserved Material"; color: Ui.AppTheme.mutedText }
    Controls.LiquidNavBar {
        model: example.navigationItems; materialForm: true
        currentIndex: example.destination
        itemColor: Ui.AppTheme.text; selectedItemColor: Ui.AppTheme.accentText
        accentColor: Ui.AppTheme.accent; trackColor: Ui.AppTheme.windowRaised
        onSelectionChanged: index => example.destination = index
    }
    Label { text: ["Home content", "Search content", "Your library"][example.destination]; color: Ui.AppTheme.text; font.pixelSize: 20 }
    Label {
        Layout.fillWidth: true; wrapMode: Text.WordWrap; color: Ui.AppTheme.mutedText
        text: "Click a destination to slide and briefly expand the lens. The original click-only desktop navigation and selectionChanged contract remain. Review sequences drive the same state paths and save real scene frames after capture; they are not pointer/keyboard event acceptance."
    }
}
