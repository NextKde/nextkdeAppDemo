import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property bool hasItem: false
    implicitHeight: 250

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
