import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kos.Ui

LiquidDialog {
    id: root
    objectName: "preferences"
    required property var store
    required property var host
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(520, host.width - 32)
    title: qsTr("Settings")
    property string draftTheme: "system"
    property string draftLanguage: "en"
    property bool draftReduced: false
    property bool failed: false
    function openDraft() {
        draftTheme = store.preferences.theme
        draftLanguage = store.preferences.language
        draftReduced = store.preferences.reduced
        failed = false; open()
    }
    contentItem: ColumnLayout {
        spacing: 12
        SettingsGroup {
            Layout.fillWidth: true
            title: qsTr("Appearance")
            SettingsItem {
                title: qsTr("Theme")
                LiquidSelect {
                    Layout.preferredWidth: 155; implicitHeight: 24
                    objectName: "themeSelect"
                    model: [qsTr("System"), qsTr("Light"), qsTr("Dark")]
                    currentIndex: ["system", "light", "dark"].indexOf(root.draftTheme)
                    Accessible.name: qsTr("Theme")
                    appearanceMode: AppTheme.dark ? "dark" : "light"
                    materialForm: true; plainTrigger: true
                    indicatorStyle: "upDown"; indicatorBackground: true
                    popupMaterialForm: true; compactPopup: true; neutralOptionHighlight: true
                    popupFontWeight: Font.Normal; popupBorderWidth: 0; popupShadowEnabled: true
                    onActivated: index => root.draftTheme = ["system", "light", "dark"][index]
                }
            }
            SettingsItem {
                title: qsTr("Language")
                LiquidSelect {
                    Layout.preferredWidth: 155; implicitHeight: 24
                    objectName: "languageSelect"
                    model: ["English", "简体中文"]
                    currentIndex: root.draftLanguage === "zh" ? 1 : 0
                    Accessible.name: qsTr("Language")
                    appearanceMode: AppTheme.dark ? "dark" : "light"
                    materialForm: true; plainTrigger: true
                    indicatorStyle: "upDown"; indicatorBackground: true
                    popupMaterialForm: true; compactPopup: true; neutralOptionHighlight: true
                    popupFontWeight: Font.Normal; popupBorderWidth: 0; popupShadowEnabled: true
                    onActivated: index => root.draftLanguage = index === 1 ? "zh" : "en"
                }
            }
            SettingsItem {
                title: qsTr("Reduce transparency")
                SettingsSwitch {
                    objectName: "reducedSwitch"
                    checked: root.draftReduced
                    Accessible.name: qsTr("Reduce transparency")
                    onToggled: checked => root.draftReduced = checked
                }
            }
        }
        Label {
            objectName: "preferencesError"
            Layout.fillWidth: true; visible: root.failed; wrapMode: Text.Wrap
            color: AppTheme.destructive
            text: qsTr("Settings could not be saved. Previous settings remain active.")
        }
    }
    footer: Control {
            padding: 24; topPadding: 12
            implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
            contentItem: RowLayout {
                Item { Layout.fillWidth: true }

        LiquidDialogButton { objectName: "cancelPreferences"; text: qsTr("Cancel"); onClicked: root.close() }
        LiquidDialogButton {
            objectName: "savePreferences"
            text: qsTr("Save"); primaryAction: true
            onClicked: {
                if (root.store.savePreferences(root.draftTheme, root.draftLanguage, root.draftReduced)) root.close()
                else root.failed = true
            }
        }

            }
        }
}
