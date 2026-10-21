import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    spacing: 16
    Controls.LiquidCard {
        id: example
        Layout.fillWidth: true
        property bool saved: false
        contentItem: ColumnLayout {
            spacing: 12
            Label { text: "A reusable content card"; color: Ui.AppTheme.text; font.bold: true }
            Label { Layout.fillWidth: true; text: example.saved ? "Your example item was saved." : "Default card appearance remains unchanged."; color: Ui.AppTheme.mutedText; wrapMode: Text.WordWrap }
            Controls.LiquidActionButton { text: "Save item"; onClicked: example.saved = true }
        }
    }
    Label { text: "Floating card · scroll the real content behind the glass"; color: Ui.AppTheme.mutedText; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    Item {
        Layout.fillWidth: true; Layout.preferredHeight: 240
        Item {
            id: scene
            anchors.fill: parent; clip: true
            Rectangle { anchors.fill: parent; color: Ui.AppTheme.dark ? "#292d33" : "#e3e5e7" }
            Flickable {
                anchors.fill: parent; contentHeight: rows.height + 120; clip: true
                Column {
                    id: rows
                    width: parent.width; spacing: 8
                    Repeater {
                        model: 8
                        Rectangle {
                            required property int index
                            width: rows.width; height: 44
                            color: index % 2 ? "#7d9da9" : "#ba9d8a"
                            Label { anchors.centerIn: parent; text: "Real scrolling row " + (index + 1); color: "#ffffff" }
                        }
                    }
                }
            }
        }
        Controls.LiquidBackdrop { id: sampled; sourceItem: scene; registerAsDefault: false; blur: .45 }
        Controls.LiquidCard {
            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
            anchors.margins: 16; height: 76; radius: 20; padding: 14
            backdrop: sampled; shadowEnabled: true; shadowOpacity: .16
            readability: .12; blurStrength: .25; refractionStrength: 5
            magnification: 1.035; reflectionStrength: .55
            tintColor: Ui.AppTheme.dark ? "#282c32" : "#f8f9fa"; tintStrength: .22
            Label { anchors.centerIn: parent; text: "Sampled sibling scene · clear glass body"; color: Ui.AppTheme.text }
        }
    }
}
