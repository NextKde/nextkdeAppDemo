import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property int viewIndex: 0
    spacing: 16
    Controls.LiquidSegmentedControl {
        materialForm: false
        mutedTextColor: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
        backgroundColor: Qt.rgba(1, 1, 1, 0.08)
        selectionColor: Qt.rgba(1, 1, 1, 0.24)
        Layout.preferredWidth: 300
        labels: ["Day", "Week", "Month"]
        currentIndex: example.viewIndex
        onSelectionRequested: function(index) { example.viewIndex = index }
    }
    Label {
        text: ["Day view", "Week view", "Month view"][example.viewIndex]
        color: Ui.AppTheme.text
        font.pixelSize: 20
    }
}
