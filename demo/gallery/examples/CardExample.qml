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
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".1"; title: galleryExample.tr("Content card", "内容卡片") }
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
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".2"; title: galleryExample.tr("Diffuse surface", "漫反射表面") }
    Controls.LiquidSurface {
        Layout.fillWidth: true; Layout.preferredHeight: 96
        radius: 0; backdrop: null; diffuseStrength: .8; tintStrength: .95
        tintColor: Ui.AppTheme.dark ? "#24282b" : "#eceef0"; reflectionStrength: .08
        Label { anchors.centerIn: parent; text: "Diffuse face · static pigment, no backdrop sampling"; color: Ui.AppTheme.text }
    }
    Sections.ExampleHeading { number: galleryExample.sectionPrefix + ".3"; title: galleryExample.tr("Floating card over content", "覆盖内容的悬浮卡片") }
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
