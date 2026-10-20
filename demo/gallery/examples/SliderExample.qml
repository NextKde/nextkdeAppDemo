import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property real volume: 0.4
    property real savedVolume: 0.4
    spacing: 12
    Controls.LiquidSlider {
        Layout.fillWidth: true
        materialForm: false
        value: example.volume
        thumbColor: Qt.rgba(1, 1, 1, 0.42)
        Accessible.name: "Volume"
        onPreviewChanged: function(value) { example.volume = value }
        onCommitRequested: function(value) { example.volume = value; example.savedVolume = value }
        onCanceled: example.volume = example.savedVolume
    }
    Label { text: "Volume: " + Math.round(example.volume * 100) + "%"; color: Ui.AppTheme.text }
    Label { text: "Committed: " + Math.round(example.savedVolume * 100) + "%"; color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82) }
}
