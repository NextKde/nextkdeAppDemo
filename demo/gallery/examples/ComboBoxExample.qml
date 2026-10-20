import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    objectName: "reviewSelect"
    function openReviewMenu() { selector.openMenu() }
    function closeReviewMenu() { selector.closeMenu() }
    property int selection: 0
    readonly property var options: ["Automatic", "Light", "Dark"]
    spacing: 12
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
    Controls.LiquidSelect {
        Layout.preferredWidth: 240
        model: example.options
        currentIndex: example.selection
        materialForm: false
        appearanceMode: Ui.AppTheme.dark ? "dark" : "light"
        enabled: false
        Accessible.name: "Disabled appearance"
    }
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
