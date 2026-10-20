import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property int destination: 0
    spacing: 24
    Controls.LiquidNavBar {
        Layout.alignment: Qt.AlignHCenter
        model: [{id: "home", label: "Home", icon: "H"},
                {id: "search", label: "Search", icon: "S"},
                {id: "library", label: "Library", icon: "L"}]
        currentIndex: example.destination
        materialForm: false
        itemColor: Ui.AppTheme.text
        trackColor: Qt.rgba(1, 1, 1, 0.10)
        onSelectionChanged: function(index) { example.destination = index }
    }
    Label {
        Layout.alignment: Qt.AlignHCenter
        text: ["Home content", "Search content", "Your library"][example.destination]
        font.pixelSize: 20
        color: Ui.AppTheme.text
    }
}
