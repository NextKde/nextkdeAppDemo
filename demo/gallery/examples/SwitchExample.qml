import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property bool notificationsEnabled: false
    spacing: 12
    RowLayout {
        Label { text: "Notifications"; color: Ui.AppTheme.text }
        Controls.LiquidGlassSwitch {
            materialForm: false
            checked: example.notificationsEnabled
            Accessible.name: "Enable notifications"
            onToggled: function(checked) { example.notificationsEnabled = checked }
        }
    }
    Label {
        text: example.notificationsEnabled ? "Notifications enabled." : "Notifications disabled."
        color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
    }
}
