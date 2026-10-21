import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    id: example
    property string result: "Choose an action."
    spacing: 16

    Flow {
        Layout.fillWidth: true
        spacing: 12
        Controls.LiquidActionButton { text: "Save"; highlighted: true; onClicked: example.result = "Saved." }
        Controls.LiquidActionButton { text: "Cancel"; secondary: true; onClicked: example.result = "Cancelled." }
        Controls.LiquidActionButton { text: "Delete"; destructive: true; onClicked: example.result = "Deleted the example item." }
        Controls.LiquidActionButton { text: "Unavailable"; enabled: false }
    }
    RowLayout {
        Controls.LiquidActionButton { text: "Default selected"; checked: true }
        Controls.LiquidActionButton {
            text: "Neutral opt-in"; checked: true; keyboardFocusOnly: true
            accentColor: Ui.AppTheme.dark ? "#a0a5ac" : "#707780"
            surfaceColor: Ui.AppTheme.dark ? "#30343a" : "#ffffff"
            focusRingColor: Ui.AppTheme.focusRing
        }
    }
    RowLayout {
        Controls.LiquidActionButton { iconOnly: true; iconName: "mediaPrevious"; iconFilled: true; Accessible.name: "Filled previous" }
        Controls.LiquidActionButton { iconOnly: true; iconName: "mediaPause"; iconFilled: true; Accessible.name: "Filled pause" }
        Controls.LiquidActionButton { iconOnly: true; iconName: "mediaNext"; iconFilled: true; Accessible.name: "Filled next" }
    }
    RowLayout {
        Controls.LiquidActionButton { backdrop: null; shadowEnabled: true; shadowOpacity: .06; text: "No-source fallback" }
        Controls.LiquidTextField { backdrop: null; shadowEnabled: true; shadowOpacity: .06; materialForm: false; liquidFinish: true; placeholderText: "Fallback input"; Layout.preferredWidth: 180 }
    }
    Label { text: "Compact icon actions · active and disabled"; color: Ui.AppTheme.mutedText }
    RowLayout {
        spacing: 12
        Controls.LiquidActionButton { iconOnly: true; text: "◀◀"; Accessible.name: "Previous"; onClicked: example.result = "Previous requested." }
        Controls.LiquidActionButton { iconOnly: true; text: "▶"; Accessible.name: "Play"; onClicked: example.result = "Play requested." }
        Controls.LiquidActionButton { iconOnly: true; text: "▶▶"; enabled: false; Accessible.name: "Next unavailable" }
        Controls.LiquidActionButton { iconOnly: true; text: "+"; Accessible.name: "Add"; onClicked: example.result = "Add requested." }
    }
    Label { text: "Live sampled backdrop · move the pointer, press, tab and type"; color: Ui.AppTheme.mutedText; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 180
        Item {
            id: colouredScene
            anchors.fill: parent
            clip: true
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#528e9e" }
                    GradientStop { position: .48; color: "#a688ab" }
                    GradientStop { position: 1; color: "#d7ac85" }
                }
            }
            Repeater {
                model: 14
                Rectangle {
                    required property int index
                    x: index * 56 - 20; y: 0; width: 7; height: colouredScene.height
                    color: "#55ffffff"; rotation: 18
                }
            }
            Label { x: 18; y: 76; text: "Actual background text / Music 0123456789"; color: "#b8242531"; font.pixelSize: 16 }
            Label { x: 18; y: 15; text: "COLOURED SCENE / REAL TEXTURE"; color: "#ccffffff"; font.pixelSize: 10 }
        }
        Controls.LiquidBackdrop { id: controlBackdrop; sourceItem: colouredScene; registerAsDefault: false }
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 24; anchors.topMargin: 48; spacing: 16
            RowLayout {
                Controls.LiquidActionButton { backdrop: controlBackdrop; text: "Default"; onClicked: example.result = "Sampled action requested." }
                Controls.LiquidActionButton { backdrop: controlBackdrop; text: "Disabled"; enabled: false }
                Controls.LiquidActionButton { backdrop: controlBackdrop; iconOnly: true; text: "▶"; Accessible.name: "Sampled play" }
            }
            Controls.LiquidTextField {
                objectName: "reviewTextField"
                Layout.fillWidth: true
                backdrop: controlBackdrop; materialForm: false; liquidFinish: true
                text: "Readable input · 浅色与深色"
                placeholderText: "Search"
                Accessible.name: "Sampled search input"
            }
        }
    }
    Label { text: example.result; color: Ui.AppTheme.text }
}
