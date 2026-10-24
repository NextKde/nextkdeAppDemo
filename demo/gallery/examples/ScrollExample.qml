import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls
import "../components" as Sections

ColumnLayout {
    id: galleryExample
    property string language: "en"
    property string sectionPrefix: "01"
    function tr(en, zh) { return language === "zh" ? zh : en }
    spacing: 16
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".1"; title: galleryExample.tr("Scrollable selection", "滚动与选择") }
    Label { text: list.currentIndex < 0 ? "Choose a row." : "Selected row: " + (list.currentIndex + 1); color: Ui.AppTheme.text }
    ListView {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: 220
        clip: true
        currentIndex: -1
        model: 40
        delegate: Controls.LiquidNavigationButton {
            id: row
            required property int index
            width: list.width
            implicitHeight: 32
            specificationForm: true
            text: "Example item " + (index + 1)
            checked: list.currentIndex === index
            onClicked: list.currentIndex = index
            contentItem: Label { text: row.text; color: Ui.AppTheme.text }
        }
        ScrollBar.vertical: ScrollBar {}
        Ui.KosKineticScroll {}
    }
}
