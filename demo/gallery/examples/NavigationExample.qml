import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

RowLayout {
    id: example
    property int currentPage: 0
    readonly property var destinations: ["Library", "Favorites", "Downloads"]
    implicitHeight: 220
    spacing: 20

    Controls.LiquidCard {
        Layout.preferredWidth: 180
        Layout.fillHeight: true
        padding: 0
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            Repeater {
                model: example.destinations
                delegate: Controls.LiquidNavigationButton {
                    required property string modelData
                    required property int index
                    Layout.fillWidth: true
                    text: modelData
                    checked: example.currentPage === index
                    onClicked: example.currentPage = index
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
    ColumnLayout {
        Layout.fillWidth: true
        Label {
            text: example.destinations[example.currentPage]
            color: Ui.AppTheme.text
            font.pixelSize: 22
        }
        Label {
            Layout.fillWidth: true
            text: ["Browse everything in your library.", "Your saved favorites appear here.",
                "Manage downloaded items here."][example.currentPage]
            wrapMode: Text.WordWrap
            color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
        }
    }
}
