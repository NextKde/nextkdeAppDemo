import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

// Input follows the button page's material, placement, corner and colour order.
ColumnLayout {
    id: example
    property string language: "en"
    property string sectionPrefix: "01"
    function tr(en, zh) { return language === "zh" ? zh : en }
    spacing: 20

    component RuleBlock: ColumnLayout {
        property string title
        property string line
        default property alias content: body.data
        Layout.fillWidth: true
        spacing: 8
        Label {
            Layout.fillWidth: true
            text: parent.title
            color: Ui.AppTheme.text
            font.pixelSize: 17; font.weight: Font.DemiBold
        }
        Label {
            Layout.fillWidth: true
            text: parent.line
            color: Ui.AppTheme.mutedText
            font.pixelSize: 13
            wrapMode: Text.WordWrap
        }
        ColumnLayout { id: body; Layout.fillWidth: true; spacing: 8 }
    }

    RuleBlock {
        title: example.tr("01 · Material", "01 · 先定材质")
        line: example.tr("Floating above content → liquid input. Inside content → solid input, just like Button.",
                         "浮在内容之上用液态输入框；内容之内用实色输入框，与 Button 一致。")
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            materialForm: false; liquidFinish: true; implicitHeight: 28
            placeholderText: example.tr("Liquid input", "液态输入")
            Accessible.name: placeholderText
        }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 28
            placeholderText: example.tr("Solid input", "实色输入")
            Accessible.name: placeholderText
        }
    }

    RuleBlock {
        title: example.tr("02 · Height by placement", "02 · 再按位置定高度")
        line: example.tr("At the same placement, an input uses the corresponding button height. Inline 20 remains provisional.",
                         "同一位置的输入框与按钮等高；行内 20 仍为暂定值。")

        Label { text: example.tr("02.1 · Inline content · 20", "02.1 · 内容区行内 · 20"); color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 20
            leftPadding: 10; rightPadding: 10
            placeholderText: example.tr("Inline value", "行内数值")
            Accessible.name: placeholderText
        }

        Label { text: example.tr("02.2 · Secondary Dialog · 24", "02.2 · 非主 Dialog · 24"); color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 24
            leftPadding: 10; rightPadding: 10
            placeholderText: example.tr("Server address", "服务器地址")
            Accessible.name: placeholderText
        }

        Label { text: example.tr("02.3 · Floating toolbar · 26", "02.3 · 浮动工具栏 · 26"); color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            materialForm: false; liquidFinish: true; implicitHeight: 26
            leftPadding: 30
            placeholderText: example.tr("Search", "搜索")
            Accessible.name: placeholderText
            Controls.VectorIcon {
                x: 8; anchors.verticalCenter: parent.verticalCenter
                name: "search"; size: 14; color: parent.textColor
            }
        }

        Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; text: example.tr("02.4 · Solid input inside an important liquid Dialog · 30", "02.4 · 重要液态 Dialog 内的实色输入 · 30"); color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 30
            placeholderText: example.tr("Dialog input", "弹窗输入")
            Accessible.name: placeholderText
        }
    }

    RuleBlock {
        title: example.tr("03 · Corner from material and height", "03 · 再按材质和高度定圆角")
        line: example.tr("Liquid inputs are capsules. Solid inputs at 20 and 24 use 6pt corners; 28 and 30 are capsules, matching Button.",
                         "液态输入框为药丸形；实色输入框在 20、24 高时用 6 点圆角，28、30 高时用药丸形，与 Button 一致。")
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            materialForm: false; liquidFinish: true; implicitHeight: 26
            placeholderText: example.tr("Liquid · capsule", "液态 · 药丸形")
            Accessible.name: placeholderText
        }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 24
            placeholderText: example.tr("Solid 24 · 6pt", "实色 24 · 6 点")
            Accessible.name: placeholderText
        }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 30
            placeholderText: example.tr("Solid 30 · capsule", "实色 30 · 药丸形")
            Accessible.name: placeholderText
        }
    }

    RuleBlock {
        title: example.tr("04 · Colour and input states", "04 · 最后定颜色和输入状态")
        line: example.tr("In light mode, liquid input text is soft dark gray and solid input text is black. Placeholders and disabled text are muted. Liquid inputs show no focus outline; solid inputs use the theme accent. Input text stays normal weight.",
                         "浅色主题下，液态输入文字用稍浅的深灰，实色输入文字用纯黑。占位与禁用文字淡化。液态输入不显示焦点描边；实色输入使用主题强调色。输入文字保持常规字重。")
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            materialForm: false; liquidFinish: true; implicitHeight: 28
            text: example.tr("Editable liquid text", "可编辑的液态文字")
            Accessible.name: example.tr("Filled input", "已填内容")
        }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 28
            placeholderText: example.tr("Enter password", "输入密码")
            echoMode: TextInput.Password
            Accessible.name: example.tr("Password input", "密码输入")
        }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 28
            text: example.tr("Read-only text", "只读文字")
            readOnly: true
            Accessible.name: example.tr("Read-only input", "只读输入")
        }
        Controls.LiquidTextField {
            Layout.fillWidth: true; Layout.maximumWidth: 360
            specificationForm: true; materialForm: true; implicitHeight: 28
            placeholderText: example.tr("Disabled input", "禁用输入")
            enabled: false
            Accessible.name: placeholderText
        }
    }
}
