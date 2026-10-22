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
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".1"; title: galleryExample.tr("Selection and result", "勾选与结果") }
    Controls.LiquidCheckBox { id: option; text: "Show completed items" }
    Label {
        text: option.checked ? "Completed items are visible." : "Completed items are hidden."
        color: Ui.AppTheme.text
    }
}
