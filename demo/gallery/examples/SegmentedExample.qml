import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    objectName: "reviewSegmented"
    property int viewIndex: 0
    property bool confirmRequests: true
    property int requestCount: 0
    spacing: 16
    function beginReviewPress(index) { sample._beginPress(index) }
    function endReviewPress(index) { sample._endPress(); sample.select(index) }
    function cancelReviewPress() { sample._endPress() }
    function focusReviewControl() { sample._beginPress(sample.safeIndex); sample._endPress() }
    function setReviewConfirmation(value) { confirmRequests = value }
    function resetReview() { sample._endPress(); confirmRequests = true; viewIndex = 0; requestCount = 0 }
    function previewState() { return JSON.stringify({ currentIndex: sample.currentIndex, visualIndex: sample._visualIndex, pendingIndex: sample._pendingIndex, pressedIndex: sample._pressedIndex, lensX: sample._lensPosition, requestCount: requestCount, confirmRequests: confirmRequests, sampling: sample.sampling }) }

    Label { text: "Liquid selection · real host confirmation"; color: Ui.AppTheme.text }
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 112
        clip: true
        Item {
            id: selectionScene
            anchors.fill: parent
            clip: true
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#527d99" }
                    GradientStop { position: .5; color: "#a181a0" }
                    GradientStop { position: 1; color: "#c7a77f" }
                }
            }
            Repeater { model: 20; Rectangle { required property int index; x: index * 32; width: 5; height: selectionScene.height; color: "#55ffffff" } }
        }
        Controls.LiquidBackdrop { id: selectionBackdrop; sourceItem: selectionScene; registerAsDefault: false }
        Controls.LiquidSegmentedControl {
            id: sample
            x: 24; y: 40; width: Math.min(330, parent.width - 48)
            backdrop: selectionBackdrop
            materialForm: false
            mutedTextColor: Ui.AppTheme.mutedText
            backgroundColor: Ui.AppTheme.withAlpha(Ui.AppTheme.windowRaised, .48)
            selectionColor: Ui.AppTheme.withAlpha(Ui.AppTheme.windowRaised, .70)
            labels: ["Day", "Week", "Month"]
            currentIndex: example.viewIndex
            onSelectionRequested: function(index) { example.requestCount++; if (example.confirmRequests) example.viewIndex = index }
        }
    }
    Label { text: "Disabled"; color: Ui.AppTheme.mutedText }
    Controls.LiquidSegmentedControl { Layout.preferredWidth: 330; materialForm: false; labels: ["Day", "Week", "Month"]; currentIndex: example.viewIndex; enabled: false }
    Label { text: "Preserved Material"; color: Ui.AppTheme.mutedText }
    Controls.LiquidSegmentedControl { Layout.preferredWidth: 330; materialForm: true; labels: ["Day", "Week", "Month"]; currentIndex: example.viewIndex; onSelectionRequested: index => example.viewIndex = index }
    Label { text: ["Day view", "Week view", "Month view"][example.viewIndex]; color: Ui.AppTheme.text; font.pixelSize: 20 }
    Label { text: "Click or use arrow keys. The host confirms selectionRequested; unconfirmed requests roll back after the existing deadline. Review hooks sample the actual moving lens, not pointer events."; color: Ui.AppTheme.mutedText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
}
