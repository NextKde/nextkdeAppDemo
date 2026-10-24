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
    spacing: 16
    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Ordinary content card", "普通内容卡片") }
    Controls.LiquidCard {
        id: card
        Layout.fillWidth: true
        materialForm: true; radius: 8; padding: 12
        property bool saved: false
        contentItem: ColumnLayout {
            spacing: 12
            Label { text: example.tr("A reusable content card", "可复用内容卡片"); color: Ui.AppTheme.text; font.bold: true }
            Label {
                Layout.fillWidth: true
                text: card.saved ? example.tr("Saved.", "已保存。")
                    : example.tr("Content uses ordinary material.", "内容表面使用普通材质。")
                color: Ui.AppTheme.mutedText; wrapMode: Text.WordWrap
            }
            Controls.LiquidActionButton { materialForm: true; text: example.tr("Save item", "保存"); onClicked: card.saved = true }
        }
    }
    Sections.ExampleHeading { number: example.sectionPrefix + ".2"; title: example.tr("Floating search panel", "浮动搜索面板") }
    Label {
        Layout.fillWidth: true
        text: example.tr("One adaptive glass container; ordinary search and list inside.", "外层一层自适应玻璃，内部搜索和列表使用普通材质。")
        color: Ui.AppTheme.mutedText; wrapMode: Text.WordWrap
    }
    Item {
        Layout.fillWidth: true; Layout.preferredHeight: 240
        Item {
            id: scene
            anchors.fill: parent
            Flickable {
                anchors.fill: parent; contentHeight: rows.height; clip: true
                Column {
                    id: rows
                    width: parent.width
                    Repeater {
                        model: 16
                        Rectangle {
                            required property int index
                            width: rows.width; height: 32
                            color: index % 2 ? Ui.AppTheme.contentSecondaryBackground : Ui.AppTheme.contentBackground
                            Label { anchors.centerIn: parent; text: example.tr("Content row ", "内容行 ") + (index + 1); color: Ui.AppTheme.text; font.pixelSize: 13 }
                        }
                    }
                }
            }
        }
        Controls.LiquidBackdrop {
            id: sampled
            sourceItem: scene; registerAsDefault: false; blur: .30
            active: !Ui.AppTheme.reduceTransparency
        }
        Controls.LiquidCard {
            anchors.centerIn: parent
            width: Math.min(360, parent.width - 32); height: 184
            materialForm: false; adaptiveGlass: true
            radius: 12; padding: 12
            backdrop: sampled; shadowEnabled: true; shadowOpacity: .08
            refractionStrength: .6; magnification: 1; reflectionStrength: .12
            contentItem: ColumnLayout {
                spacing: 8
                Controls.LiquidTextField {
                    id: query
                    Layout.fillWidth: true
                    specificationForm: true
                    placeholderText: example.tr("Find an action", "查找操作")
                    Accessible.name: placeholderText
                }
                ListView {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    clip: true
                    model: [example.tr("Open item", "打开项目"), example.tr("Save item", "保存项目"), example.tr("Share item", "共享项目")]
                        .filter(value => value.toLowerCase().indexOf(query.text.toLowerCase()) >= 0)
                    delegate: Controls.LiquidNavigationButton {
                        required property string modelData
                        width: ListView.view.width; implicitHeight: 32
                        specificationForm: true; text: modelData
                        onClicked: query.text = modelData
                    }
                }
            }
        }
    }
}
