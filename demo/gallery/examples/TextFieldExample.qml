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
        glassColor: Qt.rgba(1, 1, 1, 0.08)
        id: input
        Layout.fillWidth: true
        placeholderText: "Type a name, then press Enter"
        Accessible.name: "Name"
        onAccepted: example.submitted = "Submitted: " + text
    }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        placeholderText: "Disabled input"
        text: "Disabled · 禁用文本"
        enabled: false
        Accessible.name: "Disabled search input"
    }
    Label { text: "Semantic defaults; tab to focus, type, select, hover and press."; color: Ui.AppTheme.mutedText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
    Label { text: "Current input: " + input.text; color: Ui.AppTheme.text }
    Label { text: example.submitted; color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82) }
}
