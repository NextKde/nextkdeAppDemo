import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls

Item {
    id: root
    property string kind: "button"
    Loader {
        anchors.centerIn: parent
        width: Math.min(240, parent.width - 12)
        height: Math.min(104, parent.height)
        sourceComponent: {
            switch (root.kind) {
            case "button": return button
            case "text-field": return field
            case "checkbox": return checkbox
            case "switch": return toggle
            case "slider": return slider
            case "combo-box": return select
            case "segmented": return segmented
            case "bottom-navigation": return bottomNav
            case "navigation": return sidebar
            case "empty-state": return empty
            case "scroll": return sidebar
            case "liquid-number": return glassNumber
            case "settings": return settings
            case "tooltip": return helpTip
            case "dialog": return dialog
            default: return surface
            }
        }
    }
    Component {
        id: helpTip
        Item {
            Controls.LiquidActionButton {
                id: helpAction
                anchors.centerIn: parent
                implicitWidth: 26; implicitHeight: 26
                iconOnly: true; iconName: "settings"; iconSize: 16
                Accessible.name: "Open settings"
                Ui.KosToolTip { target: helpAction; text: helpAction.Accessible.name }
            }
        }
    }
    Component {
        id: settings
        Ui.SettingsGroup {
            title: "Appearance"
            Ui.SettingsItem {
                title: "Material"
                Ui.KosSwitch { checked: true }
            }
        }
    }
    Component {
        id: glassNumber
        Item {
            Rectangle {
                id: numberScene
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#18476a" }
                    GradientStop { position: .55; color: "#82acba" }
                    GradientStop { position: 1; color: "#514a7e" }
                }
            }
            Controls.LiquidBackdrop { id: numberBackdrop; sourceItem: numberScene; registerAsDefault: false }
            Controls.LiquidGlassNumber { anchors.centerIn: parent; text: "18°"; font.pixelSize: 68; thickness: 3; backdrop: numberBackdrop; fallbackColor: "white" }
        }
    }
    Component {
        id: button
        Item { Controls.LiquidActionButton { anchors.centerIn: parent; text: "Continue"; highlighted: true } }
    }
    Component {
        id: field
        Item {
            Controls.LiquidTextField {
                anchors.centerIn: parent
                width: parent.width
                placeholderText: "Search your library"
                materialForm: false
                liquidFinish: true
                glassColor: Qt.rgba(1, 1, 1, 0.06)
            }
        }
    }
    Component {
        id: checkbox
        Item { Controls.LiquidCheckBox { anchors.centerIn: parent; text: "Keep offline"; checked: true } }
    }
    Component {
        id: toggle
        Item { Controls.LiquidGlassSwitch { anchors.centerIn: parent; checked: true; materialForm: false } }
    }
    Component {
        id: slider
        Item { Controls.LiquidSlider { anchors.centerIn: parent; width: parent.width; value: 0.62; materialForm: false } }
    }
    Component {
        id: select
        Item {
            Controls.LiquidSelect {
                anchors.centerIn: parent
                width: parent.width
                model: ["Automatic", "Light", "Dark"]
                materialForm: false
                appearanceMode: Ui.AppTheme.dark ? "dark" : "light"
            }
        }
    }
    Component {
        id: segmented
        Item {
            Controls.LiquidSegmentedControl {
                anchors.centerIn: parent
                width: parent.width
                labels: ["Day", "Week", "Month"]
                currentIndex: 1
                materialForm: false
                mutedTextColor: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                backgroundColor: Qt.rgba(1, 1, 1, 0.06)
                selectionColor: Qt.rgba(1, 1, 1, 0.24)
            }
        }
    }
    Component {
        id: bottomNav
        Item {
            Controls.LiquidNavBar {
                anchors.centerIn: parent
                model: [{id: "home", label: "Home", icon: "H"}, {id: "library", label: "Library", icon: "L"}]
                size: "small"
                currentIndex: 1
                materialForm: false
                itemColor: Ui.AppTheme.text
                trackColor: Qt.rgba(1, 1, 1, 0.06)
            }
        }
    }
    Component {
        id: sidebar
        Column {
            spacing: 4
            Controls.LiquidNavigationButton { specificationForm: true; width: parent.width; text: "Library"; checked: true }
            Controls.LiquidNavigationButton { specificationForm: true; width: parent.width; text: "Favorites" }
        }
    }
    Component {
        id: empty
        Ui.KosEmptyState { title: "Nothing here yet"; description: "" }
    }
    Component {
        id: dialog
        Controls.LiquidCard {
            materialForm: true
            radius: 14
            padding: 12
            contentItem: ColumnLayout {
                Label { text: "Save changes?"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
                Controls.LiquidActionButton { materialForm: true; text: "Save"; highlighted: true; Layout.alignment: Qt.AlignRight }
            }
        }
    }
    Component {
        id: surface
        Item {
            Controls.LiquidSurface {
                anchors.centerIn: parent
                width: parent.width * 0.85
                height: 80
                radius: 12
                Label { anchors.centerIn: parent; text: "Liquid glass"; color: Ui.AppTheme.text }
            }
        }
    }
}
