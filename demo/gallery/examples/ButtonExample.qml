import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property string result: "Choose an action."
    spacing: 16

    Flow {
        Layout.fillWidth: true
        spacing: 12
        Controls.LiquidActionButton { text: "Save"; highlighted: true; onClicked: example.result = "Saved." }
        Controls.LiquidActionButton { text: "Cancel"; secondary: true; onClicked: example.result = "Cancelled." }
        Controls.LiquidActionButton { text: "Delete"; destructive: true; onClicked: example.result = "Deleted the example item." }
        Controls.LiquidActionButton { text: "Unavailable"; enabled: false }
    }
    Label { text: "Compact icon actions · active and disabled"; color: Ui.AppTheme.mutedText }
    RowLayout {
        spacing: 12
        Controls.LiquidActionButton { iconOnly: true; text: "◀◀"; Accessible.name: "Previous"; onClicked: example.result = "Previous requested." }
        Controls.LiquidActionButton { iconOnly: true; text: "▶"; Accessible.name: "Play"; onClicked: example.result = "Play requested." }
        Controls.LiquidActionButton { iconOnly: true; text: "▶▶"; enabled: false; Accessible.name: "Next unavailable" }
        Controls.LiquidActionButton { iconOnly: true; text: "+"; Accessible.name: "Add"; onClicked: example.result = "Add requested." }
    }
    Label { text: example.result; color: Ui.AppTheme.text }
}
