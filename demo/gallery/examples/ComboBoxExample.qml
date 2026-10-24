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
    readonly property var options: [tr("Automatic", "自动"), tr("Light", "浅色"), tr("Dark", "深色")]
    spacing: 16
    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Liquid combo box", "液态下拉框") }
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
        sheetColor: Ui.AppTheme.dark ? Ui.AppTheme.withAlpha(Ui.AppTheme.windowRaised, 0.88) : "#ffffff"
        Accessible.name: example.tr("Appearance", "外观")
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
        Accessible.name: example.tr("Disabled appearance", "外观（禁用）")
    }
    Sections.ExampleHeading { number: example.sectionPrefix + ".3"; title: example.tr("Standard combo box", "普通下拉框") }
    Controls.LiquidSelect {
        Layout.preferredWidth: 240
        model: example.options
        currentIndex: example.selection
        materialForm: true
        appearanceMode: Ui.AppTheme.dark ? "dark" : "light"
        Accessible.name: example.tr("Standard appearance", "普通外观选择")
        onActivated: function(index) { example.selection = index }
    }
    Label { text: example.tr("Liquid uses the same surface as Button; standard uses a solid fill. Tab to focus, arrows or Enter to open, Escape to close.", "液态款与 Button 共用外观，普通款使用实色填充。Tab 聚焦，方向键或 Enter 打开，Escape 关闭。"); color: Ui.AppTheme.mutedText; Layout.fillWidth: true; wrapMode: Text.WordWrap }
    Label { text: example.tr("Selected: ", "已选择：") + example.options[example.selection]; color: Ui.AppTheme.text }
}
