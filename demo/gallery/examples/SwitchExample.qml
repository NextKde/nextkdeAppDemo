import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    objectName: "reviewSwitch"
    property bool notificationsEnabled: true
    property bool confirmRequests: true
    property int requestCount: 0
    spacing: 16
    function beginReviewPress(index) { sample._beginPress() }
    function endReviewPress(index) { sample._endPress(); sample.toggle() }
    function cancelReviewPress() { sample._endPress() }
    function setReviewHovered(value) { sample._setHovered(value) }
    function focusReviewControl() { sample.forceActiveFocus() }
    function setReviewConfirmation(value) { confirmRequests = value }
    function resetReview() { sample._endPress(); sample._setHovered(false); notificationsEnabled = false; confirmRequests = true; requestCount = 0 }
    function previewState() { return JSON.stringify({ checked: sample.checked, pressed: sample._pressed, hovered: sample._hovered, expansion: sample._expansion, thumbX: sample._thumbX, stretch: sample._stretch, focus: sample.activeFocus, requestCount: requestCount, confirmRequests: confirmRequests, sampling: sample.sampling }) }

    RowLayout {
        spacing: 24
        Label { text: "Notifications"; color: Ui.AppTheme.text; Layout.preferredWidth: 150 }
        Controls.LiquidGlassSwitch {
            id: sample
            materialForm: false
            checked: example.notificationsEnabled
            Accessible.name: "Enable notifications"
            onToggled: function(checked) { example.requestCount++; if (example.confirmRequests) example.notificationsEnabled = checked }
        }
    }
    RowLayout {
        spacing: 24
        Label { text: "Disabled · off / on"; color: Ui.AppTheme.mutedText; Layout.preferredWidth: 150 }
        Controls.LiquidGlassSwitch { materialForm: false; enabled: false; checked: false; Accessible.name: "Disabled off switch" }
        Controls.LiquidGlassSwitch { materialForm: false; enabled: false; checked: true; Accessible.name: "Disabled on switch" }
    }
    RowLayout {
        spacing: 24
        Label { text: "Preserved Material"; color: Ui.AppTheme.mutedText; Layout.preferredWidth: 150 }
        Controls.LiquidGlassSwitch { materialForm: true; accentColor: Ui.AppTheme.accent; checked: example.notificationsEnabled; Accessible.name: "Material notifications"; onToggled: checked => example.notificationsEnabled = checked }
    }
    Label { text: example.notificationsEnabled ? "Notifications enabled." : "Notifications disabled."; color: Ui.AppTheme.text }
    Label { text: "Press and hold to inspect the expanded lens; release to request a change. Tab/Space uses the same state path. Review hooks drive actual states, not pointer events."; color: Ui.AppTheme.mutedText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
}
