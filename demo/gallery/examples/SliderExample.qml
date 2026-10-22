import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls
import "../components" as Sections

ColumnLayout {
    id: example
    property string language: "en"
    property string sectionPrefix: "01"
    function tr(en, zh) { return language === "zh" ? zh : en }
    property real volume: 0.4
    property real savedVolume: 0.4
    spacing: 16
    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Drag and adjust", "拖动调节") }
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
    Sections.ExampleHeading { number: example.sectionPrefix + ".2"; title: example.tr("Live values", "实时数值") }
    Label { text: "Volume: " + Math.round(example.volume * 100) + "%"; color: Ui.AppTheme.text }
    Label { text: "Committed: " + Math.round(example.savedVolume * 100) + "%"; color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82) }
}
