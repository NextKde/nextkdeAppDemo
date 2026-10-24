import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls
import "../components" as Sections

ColumnLayout {
    id: example
    property string language: "en"
    property string sectionPrefix: "01"
    function tr(en, zh) { return language === "zh" ? zh : en }
    property int currentPage: 0
    readonly property var destinations: ["Library", "Favorites", "Downloads"]
    implicitHeight: 220
    spacing: 16

    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Sidebar and destination", "侧栏与内容联动") }
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 20
    Controls.LiquidCard {
        materialForm: true
        Layout.preferredWidth: 180
        Layout.fillHeight: true
        padding: 0
        background: Rectangle {
            radius: 8
            color: Ui.AppTheme.contentSecondaryBackground
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            Repeater {
                model: example.destinations
                delegate: Controls.LiquidNavigationButton {
                    specificationForm: true
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
}
