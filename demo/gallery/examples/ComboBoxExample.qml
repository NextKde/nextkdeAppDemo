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
    objectName: "reviewSelect"
    function openReviewMenu() { selector.openMenu() }
    function closeReviewMenu() { selector.closeMenu() }
    property int selection: 0
    readonly property var options: ["Automatic", "Light", "Dark"]
    spacing: 16
    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Selection", "常规选择") }
    Controls.LiquidSelect {
        id: selector
        objectName: "reviewSelectControl"
        Layout.preferredWidth: 240
        model: example.options
        currentIndex: example.selection
        materialForm: false
        appearanceMode: Ui.AppTheme.dark ? "dark" : "light"
        textColor: Ui.AppTheme.text
        mutedTextColor: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
        sheetColor: Ui.AppTheme.withAlpha(Ui.AppTheme.windowRaised, 0.88)
        Accessible.name: "Appearance"
        onActivated: function(index) { example.selection = index }
    }
    Sections.ExampleHeading { number: example.sectionPrefix + ".2"; title: example.tr("Disabled", "禁用") }
    Controls.LiquidSelect {
        Layout.preferredWidth: 240
        model: example.options
        currentIndex: example.selection
        materialForm: false
        appearanceMode: Ui.AppTheme.dark ? "dark" : "light"
        enabled: false
        Accessible.name: "Disabled appearance"
    }
    Sections.ExampleHeading { number: example.sectionPrefix + ".3"; title: example.tr("Solid variant", "实色形态") }
    Controls.LiquidSelect {
        Layout.preferredWidth: 240
        model: example.options
        currentIndex: example.selection
        materialForm: true
        appearanceMode: Ui.AppTheme.dark ? "dark" : "light"
        Accessible.name: "Material appearance"
        onActivated: function(index) { example.selection = index }
    }
    Label { text: "Liquid / disabled / preserved Material. Tab, arrows and Enter select; Escape closes."; color: Ui.AppTheme.mutedText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
    Label { text: "Selected: " + example.options[example.selection]; color: Ui.AppTheme.text }
}
