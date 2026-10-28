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
    property string value: "18°"
    property real numberSize: 156
    property real depth: 5
    property real refraction: 8
    property real blur: 1.5
    property bool motion: true
    property bool plain: false
    spacing: 16

    Sections.ExampleHeading {
        number: example.sectionPrefix + ".1"
        title: example.tr("Sculpted glass numerals", "有厚度的玻璃数字")
    }
    Item {
        id: stage
        Layout.fillWidth: true
        Layout.preferredHeight: 300
        clip: true
        Item {
            id: scene
            anchors.fill: parent
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "#163c60" }
                    GradientStop { position: .55; color: "#547ca3" }
                    GradientStop { position: 1; color: "#323958" }
                }
            }
            Item {
                id: ribbons
                width: parent.width + 280
                height: parent.height
                x: -140
                Repeater {
                    model: 8
                    Rectangle {
                        required property int index
                        x: index * 130
                        y: -120
                        width: 65
                        height: 580
                        rotation: 28
                        opacity: .55
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: "transparent" }
                            GradientStop { position: .5; color: index % 2 ? "#9da5d8" : "#79cbd6" }
                            GradientStop { position: 1; color: "transparent" }
                        }
                    }
                }
                SequentialAnimation on x {
                    running: example.visible && example.motion && !Ui.AppTheme.reduceMotion
                    loops: Animation.Infinite
                    NumberAnimation { to: -10; duration: 6000; easing.type: Easing.InOutSine }
                    NumberAnimation { to: -140; duration: 6000; easing.type: Easing.InOutSine }
                }
            }
            Repeater {
                model: 10
                Rectangle {
                    required property int index
                    y: 25 + index * 28
                    width: scene.width
                    height: 1
                    color: "#1affffff"
                }
            }
        }
        Controls.LiquidBackdrop { id: glassBackdrop; sourceItem: scene; registerAsDefault: false }
        Controls.LiquidGlassNumber {
            id: number
            objectName: "galleryGlassNumber"
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -8
            text: example.value
            font.pixelSize: Math.min(example.numberSize, (stage.width - 48) / Math.max(1, text.length) * 1.35)
            backdrop: glassBackdrop
            thickness: example.depth
            refractionStrength: example.refraction
            blurRadius: example.blur
            reduceTransparency: example.plain || Ui.AppTheme.reduceTransparency
            fallbackColor: "white"
        }
        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 22
            text: example.tr("Light · depth · transmission", "光泽 · 厚度 · 通透")
            color: "#dce9f5"
            font.pixelSize: 12
            font.letterSpacing: 1
        }
    }
    RowLayout {
        Layout.fillWidth: true
        TextField {
            Layout.fillWidth: true
            text: example.value
            maximumLength: 12
            Accessible.name: example.tr("Displayed number", "显示的数字")
            onTextEdited: example.value = text
        }
        Repeater {
            model: ["18°", "−3.5°", "10:09"]
            Controls.LiquidActionButton {
                required property string modelData
                text: modelData
                materialForm: true
                onClicked: example.value = modelData
            }
        }
    }
    GridLayout {
        Layout.fillWidth: true
        columns: 2
        columnSpacing: 16
        Label { text: example.tr("Size", "字号") + " · " + Math.round(example.numberSize); color: Ui.AppTheme.text }
        Slider { Layout.fillWidth: true; from: 80; to: 196; value: example.numberSize; Accessible.name: example.tr("Number size", "数字字号"); onMoved: example.numberSize = value }
        Label { text: example.tr("Thickness", "厚度") + " · " + example.depth.toFixed(1); color: Ui.AppTheme.text }
        Slider { Layout.fillWidth: true; from: 1; to: 12; value: example.depth; Accessible.name: example.tr("Glass thickness", "玻璃厚度"); onMoved: example.depth = value }
        Label { text: example.tr("Refraction", "折射") + " · " + example.refraction.toFixed(1); color: Ui.AppTheme.text }
        Slider { Layout.fillWidth: true; from: 0; to: 18; value: example.refraction; Accessible.name: example.tr("Refraction strength", "折射强度"); onMoved: example.refraction = value }
        Label { text: example.tr("Blur", "模糊") + " · " + example.blur.toFixed(1); color: Ui.AppTheme.text }
        Slider { Layout.fillWidth: true; from: 0; to: 5; value: example.blur; Accessible.name: example.tr("Background blur", "背景模糊"); onMoved: example.blur = value }
    }
    Flow {
        Layout.fillWidth: true
        spacing: 20
        CheckBox { text: example.tr("Moving background", "背景流动"); checked: example.motion; onToggled: example.motion = checked }
        CheckBox { text: example.tr("Reduced transparency", "减少透明效果"); checked: example.plain; onToggled: example.plain = checked }
    }
    Label {
        Layout.fillWidth: true
        wrapMode: Text.WordWrap
        color: Ui.AppTheme.mutedText
        text: example.tr("Use for large temperatures, clocks and prominent values. Keep compact labels in ordinary type.",
                         "适合大号温度、时钟和突出展示的数值；小字号标签保持普通文字。")
    }
}
