import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

// Select follows the Button and Input pages' material, placement, corner and colour order.
ColumnLayout {
    id: example
    property string language: "en"
    function tr(en, zh) { return language === "zh" ? zh : en }
    objectName: "reviewSelect"
    function openReviewMenu() { selector.openMenu() }
    function closeReviewMenu() { selector.closeMenu() }
    property int selection: 0
    readonly property var options: [tr("Automatic", "自动"), tr("Light", "浅色"), tr("Dark", "深色")]
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

    component Choice: Controls.LiquidSelect {
        Layout.preferredWidth: 240
        model: example.options
        currentIndex: example.selection
        appearanceMode: Ui.AppTheme.dark ? "dark" : "light"
        onActivated: function(index) { example.selection = index }
    }

    RuleBlock {
        title: example.tr("01 · Material", "01 · 先定材质")
        line: example.tr("Floating above content → liquid select. Inside content → solid select, matching Button and Input.",
                         "浮在内容之上用液态下拉选择；内容之内用实色下拉选择，与 Button、Input 一致。")
        Choice {
            id: selector
            objectName: "reviewSelectControl"
            materialForm: false; implicitHeight: 28
            Accessible.name: example.tr("Liquid appearance", "液态外观选择")
        }
        Choice {
            materialForm: true; implicitHeight: 28
            Accessible.name: example.tr("Solid appearance", "实色外观选择")
        }
    }

    RuleBlock {
        title: example.tr("02 · Height by placement", "02 · 再按位置定高度")
        line: example.tr("At the same placement, Select uses the corresponding Button and Input height. Inline 20 remains provisional.",
                         "同一位置的下拉选择与 Button、Input 等高；行内 20 仍为暂定值。")

        Label { text: example.tr("02.1 · Inline content · 20", "02.1 · 内容区行内 · 20"); color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold }
        Choice {
            materialForm: true; implicitHeight: 20
            Accessible.name: example.tr("Inline appearance", "行内外观选择")
        }

        Label { text: example.tr("02.2 · Secondary Dialog · 24", "02.2 · 非主 Dialog · 24"); color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold }
        Choice {
            materialForm: true; implicitHeight: 24
            Accessible.name: example.tr("Secondary dialog appearance", "非主弹窗外观选择")
        }

        Label { text: example.tr("02.3 · Floating toolbar · 26", "02.3 · 浮动工具栏 · 26"); color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold }
        Choice {
            materialForm: false; implicitHeight: 26
            Accessible.name: example.tr("Toolbar appearance", "工具栏外观选择")
        }

        Label { Layout.fillWidth: true; wrapMode: Text.WordWrap; text: example.tr("02.4 · Solid select inside an important liquid Dialog · 30", "02.4 · 重要液态 Dialog 内的实色选择 · 30"); color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold }
        Choice {
            materialForm: true; implicitHeight: 30
            Accessible.name: example.tr("Important dialog appearance", "重要弹窗外观选择")
        }
    }

    RuleBlock {
        title: example.tr("03 · Trigger and popup corners", "03 · 触发框与弹框圆角")
        line: example.tr("The closed select stays a capsule in both forms. Its popup uses smaller 8pt corners and compact 24px option rows; each hover fill covers one row.",
                         "闭合的下拉框在两种材质下都保持药丸形。展开弹框用较小的 8 点圆角，选项行高 24，每行的悬停背景刚好覆盖一行。")
        Choice {
            materialForm: false; implicitHeight: 26
            Accessible.name: example.tr("Liquid capsule and compact popup", "液态药丸框与紧凑弹框")
        }
        Choice {
            materialForm: true; implicitHeight: 24
            Accessible.name: example.tr("Solid capsule and compact popup", "实色药丸框与紧凑弹框")
        }
    }

    RuleBlock {
        title: example.tr("04 · Colour and selection states", "04 · 最后定颜色和选择状态")
        line: example.tr("Liquid text is softer and has no focus outline. Solid text is black in light mode and keeps its accent focus ring. Disabled text is muted.",
                         "液态文字稍浅且无焦点描边；浅色主题下实色文字为黑色，并保留强调色焦点环。禁用文字淡化。")
        Choice {
            materialForm: false; implicitHeight: 28
            Accessible.name: example.tr("Liquid selection", "液态选择")
        }
        Choice {
            materialForm: true; implicitHeight: 28
            Accessible.name: example.tr("Solid selection", "实色选择")
        }
        Choice {
            materialForm: false; implicitHeight: 28
            enabled: false
            Accessible.name: example.tr("Disabled selection", "禁用选择")
        }
    }
}
