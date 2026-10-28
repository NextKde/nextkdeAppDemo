import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

// 按钮页（演示用）。
//
// 本页只演示规则本身；规则的唯一权威来源是组件源码注释：
//   shared/qml/controls/LiquidActionButton.qml  —— 头部注释写明完整取值规则
//
// 四步定义，顺序固定，后一步依赖前一步的结论：
//   01 材质：先判断按钮浮在什么上面（浮在内容之上=液态；嵌在内容之内=实色 materialForm）
//   02 大小：正文旁行内按钮暂用 20 / 非主 Dialog 底栏 24 / 工具栏 26 /
//            重要液态 Dialog 的实色底部按钮 30
//   03 圆角：由 01 的材质 + 02 的大小共同决定（液态一律胶囊；实色 28、30 胶囊，26、24、20、18 用 6pt）
//   04 颜色：最后按功能、主题、材质取色（主操作强调色底白字；普通控件底色；危险红字；禁用淡字）
//
// 改动规则时先改 LiquidActionButton.qml 的注释与实现，再回来同步本页示例。
ColumnLayout {
    id: example
    property string language: "en"
    // sceneOnly=true 时不渲染标题行，仅输出按钮行本身（供背景对照场景使用）
    property bool sceneOnly: false
    function tr(en, zh) { return language === "zh" ? zh : en }
    spacing: 20

    // 单条规则 = 标题 + 一句话规则 + 一排示例按钮
    component RuleBlock: ColumnLayout {
        property string title
        property string line
        default property alias content: row.data
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
        Row { id: row; spacing: 8; Layout.topMargin: 4 }
    }

    // 01 材质：默认即液态（悬浮采样背景）；materialForm=true 切换为实色，用于嵌在内容里的按钮
    RuleBlock {
        title: example.tr("01 · Material", "01 · 先定材质")
        line: example.tr("Floating above content → liquid. Inside content → solid.", "浮在内容之上用液态；内容之内用实色。")
        Controls.LiquidActionButton { text: example.tr("Liquid", "液态"); implicitHeight: 28 }
        Controls.LiquidActionButton { text: example.tr("Solid", "实色"); materialForm: true; implicitHeight: 28 }
    }

    // 02 大小：按具体场景逐项说明；20 高度是待确认的项目取值。
    RuleBlock {
        title: example.tr("02 · Size by placement and use", "02 · 再按位置和用途定大小")
        line: example.tr("Choose the height for the button's actual role. The inline value is provisional.",
                         "根据按钮的实际用途选高度；行内按钮的取值暂定。")
        Column {
            width: example.width
            spacing: 6
            Label {
                width: parent.width; wrapMode: Text.WordWrap
                text: example.tr("02.1 · Main content: inline action", "02.1 · 主体内容区：行内按钮")
                color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold
            }
            Label {
                width: parent.width; wrapMode: Text.WordWrap
                text: example.tr("Next to normal body text. Keep its label close to body-text size; 20 high is a provisional choice.",
                                 "放在正常正文文字旁，按钮文字与正文大小接近；按钮高度暂用 20。")
                color: Ui.AppTheme.mutedText; font.pixelSize: 13
            }
            Image {
                width: Math.min(parent.width, 760)
                height: implicitWidth > 0 ? width * implicitHeight / implicitWidth : 0
                source: Qt.resolvedUrl("../../assets/15-Sequoia-Settings-Screen-Saver.png")
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }
            Label {
                text: example.tr("macOS 15 System Settings reference", "macOS 15 系统设置参考图")
                color: Ui.AppTheme.mutedText; font.pixelSize: 12
            }
            Controls.LiquidActionButton {
                text: example.tr("Inline 20", "行内 20")
                materialForm: true; implicitHeight: 20; cornerRadius: 6
                leftPadding: 10; rightPadding: 10; font.pixelSize: 11
            }
            Item { width: 1; height: 8 }
            Label {
                text: example.tr("02.2 · Secondary dialog footer", "02.2 · 非主 Dialog 弹出窗底部")
                color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold
            }
            Label {
                text: example.tr("An action at the bottom of a secondary dialog; 24 high.", "非主 Dialog 弹出窗底部的操作按钮，高 24。")
                color: Ui.AppTheme.mutedText; font.pixelSize: 13
            }
            Image {
                width: Math.min(parent.width, 760)
                height: implicitWidth > 0 ? width * implicitHeight / implicitWidth : 0
                source: Qt.resolvedUrl("../../assets/27-Golden-Gate-Finder-Connect-to-Server.png")
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }
            Label {
                text: example.tr("macOS 27 Finder dialog reference", "macOS 27 Finder 弹窗参考图")
                color: Ui.AppTheme.mutedText; font.pixelSize: 12
            }
            Controls.LiquidActionButton {
                text: example.tr("Secondary dialog 24", "非主弹窗 24")
                materialForm: true; implicitHeight: 24; cornerRadius: 6
                leftPadding: 10; rightPadding: 10; font.pixelSize: 11
            }
            Item { width: 1; height: 8 }
            Label {
                text: example.tr("02.3 · Toolbar", "02.3 · 工具栏")
                color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold
            }
            Label {
                text: example.tr("Three icon actions share one toolbar surface; each button is 26 high.", "三个图标按钮共用一块工具栏材质，每个按钮高 26。")
                color: Ui.AppTheme.mutedText; font.pixelSize: 13
            }
            Controls.LiquidActionButtonGroup {
                buttonSize: 26
                icons: ["search", "grid", "more"]
                labels: [example.tr("Search", "搜索"), example.tr("View", "视图"), example.tr("More", "更多")]
            }
            Item { width: 1; height: 8 }
            Label {
                width: parent.width; wrapMode: Text.WordWrap
                text: example.tr("02.4 · Solid footer buttons in an important liquid Dialog", "02.4 · 非常重要的液态 Dialog 底部实色按钮")
                color: Ui.AppTheme.text; font.pixelSize: 15; font.weight: Font.DemiBold
            }
            Label {
                width: parent.width; wrapMode: Text.WordWrap
                text: example.tr("These footer buttons are 30 high, usually solid, and capsule shaped.", "行高 30，一般使用实体材质和药丸形圆角。")
                color: Ui.AppTheme.mutedText; font.pixelSize: 13
            }
            Image {
                width: Math.min(parent.width, 610)
                height: implicitWidth > 0 ? width * implicitHeight / implicitWidth : 0
                source: Qt.resolvedUrl("../../assets/Screenshot_20261026_195104.png")
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }
            Label {
                text: example.tr("Important liquid Dialog reference", "重要液态 Dialog 参考图")
                color: Ui.AppTheme.mutedText; font.pixelSize: 13
            }
            Controls.LiquidActionButton {
                text: example.tr("Save · 30", "保存 · 30")
                materialForm: true; highlighted: true; implicitHeight: 30
                cornerRadius: height / 2
            }
        }
    }

    // 03 圆角：对应 02 的四种位置。小实色按钮用 6 点圆角；工具栏液态按钮组共用胶囊外轮廓；
    //     重要 Dialog 的 30 高实色按钮用药丸形圆角。
    RuleBlock {
        title: example.tr("03 · Corner by the four placements", "03 · 按上面四种位置定圆角")
        line: example.tr("Solid inline and secondary-dialog buttons use 6pt corners. The liquid toolbar group has one capsule outline. The important Dialog's solid footer button is a capsule.",
                         "行内与非主弹窗的小实色按钮用 6 点圆角；液态工具栏按钮组共用药丸形外轮廓；重要 Dialog 的实色底部按钮也是药丸形。")
        Column {
            width: example.width
            spacing: 8
            Controls.LiquidActionButton { text: example.tr("Inline · 20 · 6pt", "行内 · 20 · 6 点"); materialForm: true; implicitHeight: 20 }
            Controls.LiquidActionButton { text: example.tr("Secondary Dialog · 24 · 6pt", "非主弹窗 · 24 · 6 点"); materialForm: true; implicitHeight: 24 }
            Controls.LiquidActionButtonGroup {
                buttonSize: 26
                icons: ["search", "grid", "more"]
                labels: [example.tr("Search", "搜索"), example.tr("View", "视图"), example.tr("More", "更多")]
            }
            Controls.LiquidActionButton { text: example.tr("Important Dialog · 30 · capsule", "重要弹窗 · 30 · 药丸"); materialForm: true; implicitHeight: 30 }
        }
    }

    // 04 颜色：小实色按钮浅色纯黑中等字重；液态按钮与图标用稍浅的深灰；重要 Dialog 底栏
    //     主操作蓝底白字、危险操作红字、取消为普通实色。
    RuleBlock {
        title: example.tr("04 · Colour by the four placements", "04 · 按上面四种位置定颜色")
        line: example.tr("Small solid actions use black medium-weight labels in light mode; liquid actions and toolbar icons use a softer dark gray. In an important Dialog, the primary action is blue with white text, the destructive action uses red text, and Cancel stays neutral.",
                         "小实色按钮在浅色主题用纯黑色、中等字重；液态按钮和工具栏图标用稍浅的深灰。重要 Dialog 中，主操作蓝底白字，危险操作红字，取消保持普通实色。")
        Column {
            width: example.width
            spacing: 8
            Controls.LiquidActionButton { text: example.tr("Inline", "行内"); materialForm: true; implicitHeight: 20 }
            Controls.LiquidActionButton { text: example.tr("Secondary dialog", "非主弹窗"); materialForm: true; implicitHeight: 24 }
            Controls.LiquidActionButtonGroup {
                buttonSize: 26
                icons: ["search", "grid", "more"]
                labels: [example.tr("Search", "搜索"), example.tr("View", "视图"), example.tr("More", "更多")]
            }
            Controls.LiquidActionButton {
                width: 260; text: example.tr("Save", "保存")
                materialForm: true; highlighted: true; implicitHeight: 30
            }
            Controls.LiquidActionButton {
                width: 260; text: example.tr("Don't Save", "不保存")
                materialForm: true; destructive: true; implicitHeight: 30
                // This alert's destructive action has the pale red fill in the reference image.
                surfaceColor: Ui.AppTheme.dark ? "#5A3338" : "#F3C3C6"
            }
            Controls.LiquidActionButton {
                width: 260; text: example.tr("Cancel", "取消")
                materialForm: true; implicitHeight: 30
            }
        }
    }
}
