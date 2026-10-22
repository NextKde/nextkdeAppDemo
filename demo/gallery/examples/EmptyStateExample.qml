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
    spacing: 16
    property bool hasItem: false
    implicitHeight: 250

    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Empty and populated states", "空状态与有内容状态") }
    Ui.KosEmptyState {
        Layout.fillWidth: true
        Layout.fillHeight: true
        visible: !example.hasItem
        title: "No items yet"
        description: "Create your first item to get started."
    }
    Controls.LiquidActionButton {
        Layout.alignment: Qt.AlignHCenter
        visible: !example.hasItem
        text: "Create example item"
        onClicked: example.hasItem = true
    }
    Label { visible: example.hasItem; text: "Your first item is ready."; color: Ui.AppTheme.text }
    Controls.LiquidActionButton { visible: example.hasItem; text: "Remove item"; onClicked: example.hasItem = false }
}
