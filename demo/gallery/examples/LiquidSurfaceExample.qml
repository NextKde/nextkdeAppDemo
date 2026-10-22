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
    property real lensPosition: 0.45
    property real refraction: 5
    property bool frosted: false
    spacing: 16

    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Material preview", "材质预览") }
    Item {
        id: stage
        Layout.fillWidth: true
        Layout.preferredHeight: 224
        clip: true

        Item {
            id: scene
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#157e9c" }
                    GradientStop { position: 0.5; color: "#905fb9" }
                    GradientStop { position: 1; color: "#d49c5d" }
                }
            }
            Repeater {
                model: Math.ceil(stage.width / 24)
                Rectangle {
                    required property int index
                    x: index * 24
                    width: 2
                    height: stage.height
                    color: Qt.rgba(1, 1, 1, 0.28)
                }
            }
            Repeater {
                model: 7
                Rectangle {
                    required property int index
                    y: index * 32
                    width: stage.width
                    height: 2
                    color: Qt.rgba(1, 1, 1, 0.28)
                }
            }
        }
        Controls.LiquidBackdrop {
            id: sceneBackdrop
            sourceItem: scene
            registerAsDefault: false
        }
        Controls.LiquidSurface {
            width: Math.min(280, Math.max(1, stage.width - 48))
            height: 144
            x: 24 + example.lensPosition * Math.max(0, stage.width - width - 48)
            y: 40
            radius: 24
            backdrop: sceneBackdrop
            refractionStrength: example.refraction
            magnification: 1.12
            blurStrength: example.frosted ? 0.65 : 0
            readability: 0.22
            Label {
                anchors.centerIn: parent
                text: "Move the lens"
                color: Ui.AppTheme.text
                font.pixelSize: 20
            }
        }
    }
    Sections.ExampleHeading { number: example.sectionPrefix + ".2"; title: example.tr("Lens position", "透镜位置") }
    Controls.LiquidSlider {
        Layout.fillWidth: true
        value: example.lensPosition
        materialForm: false
        Accessible.name: "Lens position"
        onPreviewChanged: function(value) { example.lensPosition = value }
        onCommitRequested: function(value) { example.lensPosition = value }
    }
    Sections.ExampleHeading { number: example.sectionPrefix + ".3"; title: example.tr("Refraction strength", "折射强度") }
    Label { text: "Edge refraction: " + example.refraction.toFixed(1) + " px"; color: Ui.AppTheme.text }
    Controls.LiquidSlider {
        Layout.fillWidth: true
        value: example.refraction / 12
        materialForm: false
        Accessible.name: "Edge refraction"
        onPreviewChanged: function(value) { example.refraction = value * 12 }
        onCommitRequested: function(value) { example.refraction = value * 12 }
    }
    Sections.ExampleHeading { number: example.sectionPrefix + ".4"; title: example.tr("Blur option", "模糊选项") }
    Controls.LiquidCheckBox {
        text: "Frosted blur"
        checked: example.frosted
        onToggled: example.frosted = checked
    }
}
