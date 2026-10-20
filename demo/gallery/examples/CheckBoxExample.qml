import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    spacing: 12
    Controls.LiquidCheckBox { id: option; text: "Show completed items" }
    Label {
        text: option.checked ? "Completed items are visible." : "Completed items are hidden."
        color: Ui.AppTheme.text
    }
}
