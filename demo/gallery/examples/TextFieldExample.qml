import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    property string submitted: "Nothing submitted yet."
    id: example
    spacing: 12
    Controls.LiquidTextField {
        materialForm: false
        liquidFinish: true
        textColor: Ui.AppTheme.text
        mutedTextColor: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
        glassColor: Qt.rgba(1, 1, 1, 0.08)
        id: input
        Layout.fillWidth: true
        placeholderText: "Type a name, then press Enter"
        Accessible.name: "Name"
        onAccepted: example.submitted = "Submitted: " + text
    }
    Label { text: "Current input: " + input.text; color: Ui.AppTheme.text }
    Label { text: example.submitted; color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82) }
}
