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
    property string result: "No action yet."
    spacing: 16
    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Open and respond", "打开与响应") }
    Controls.LiquidActionButton { text: "Open dialog"; onClicked: dialog.open() }
    Label { text: example.result; color: Ui.AppTheme.text }

    Controls.LiquidDialog {
        id: dialog
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(380, parent.width - 32)
        title: "Save example item?"
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: example.result = "Confirmed."
        onRejected: example.result = "Cancelled."
        contentItem: Label {
            text: "This only changes the example; no files are written."
            wrapMode: Text.WordWrap
            color: Ui.AppTheme.text
        }
    }
}
