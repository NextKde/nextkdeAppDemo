import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    spacing: 12

    Label { text: "Default"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        placeholderText: "Enter text"
        Accessible.name: "Default input"
    }
    Label { text: "Filled"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        text: "Liquid glass"
        Accessible.name: "Filled input"
    }
    Label { text: "Password"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        placeholderText: "Enter password"
        echoMode: TextInput.Password
        Accessible.name: "Password input"
    }
    Label { text: "Read only"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        text: "Read-only text"
        readOnly: true
        Accessible.name: "Read-only input"
    }
    Label { text: "Disabled"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Controls.LiquidTextField {
        Layout.fillWidth: true
        materialForm: false; liquidFinish: true
        placeholderText: "Disabled input"
        enabled: false
        Accessible.name: "Disabled input"
    }
}
