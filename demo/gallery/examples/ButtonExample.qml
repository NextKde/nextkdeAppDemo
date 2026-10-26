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
//   02 大小：再按按钮所在位置取高度（工具栏 22 / 内容区 28 / 弹窗 32 / 浮层 28）
//   03 圆角：由 01 的材质 + 02 的大小共同决定（液态一律胶囊；实色 28、32 胶囊，22、18 用 6pt）
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

    // 02 大小：implicitHeight 按位置取值；22 高度时字号降到 12 以保持可读
    RuleBlock {
        title: example.tr("02 · Size by placement", "02 · 再按位置定大小")
        line: example.tr("Toolbar 22 · content 28 · dialog 32 · floating bar 28.", "工具栏 22 · 内容区 28 · 弹窗 32 · 浮层 28。")
        Controls.LiquidActionButton { text: example.tr("Toolbar 22", "工具栏 22"); implicitHeight: 22; font.pixelSize: 12 }
        Controls.LiquidActionButton { text: example.tr("Content 28", "内容区 28"); implicitHeight: 28 }
        Controls.LiquidActionButton { text: example.tr("Dialog 32", "弹窗 32"); implicitHeight: 32 }
        Controls.LiquidActionButton { text: example.tr("Floating 28", "浮层 28"); implicitHeight: 28 }
    }

    // 03 圆角：液态无需指定（内部恒为胶囊 height/2）；实色小尺寸（22、18）必须显式 cornerRadius: 6，
    //     实色 28、32 保持胶囊。唯一允许覆盖 cornerRadius 的场景就是"实色 + 小尺寸"。
    RuleBlock {
        title: example.tr("03 · Corner from material + size", "03 · 再按材质和大小定圆角")
        line: example.tr("Liquid is always a capsule. Solid is a capsule at 28 and 32, and 6pt at 22 and 18.", "液态一律胶囊；实色 28、32 是胶囊，22、18 是 6 点圆角。")
        Controls.LiquidActionButton { text: example.tr("Liquid 22", "液态 22"); implicitHeight: 22; font.pixelSize: 12 }
        Controls.LiquidActionButton { text: example.tr("Liquid 28", "液态 28"); implicitHeight: 28 }
        Controls.LiquidActionButton { text: example.tr("Solid 22", "实色 22"); materialForm: true; implicitHeight: 22; font.pixelSize: 12; cornerRadius: 6 }
        Controls.LiquidActionButton { text: example.tr("Solid 28", "实色 28"); materialForm: true; implicitHeight: 28 }
    }

    // 04 颜色：highlighted=主操作（强调色底白字）；默认普通；destructive=危险（红字，底不变）；
    //     禁用只降文字不降底。颜色不在此处指定，由组件按 AppTheme 自动取值。
    RuleBlock {
        title: example.tr("04 · Colour from function, theme and material", "04 · 最后按功能、主题、材质定颜色")
        line: example.tr("Primary → accent fill with white text; normal → control fill with label colour; destructive → red text; disabled → muted text, fill unchanged.",
                         "主操作 → 强调色底白字；普通 → 控件底色 + 文字色；危险 → 红字；禁用 → 淡字，底不变。")
        Controls.LiquidActionButton { text: example.tr("Primary", "主操作"); highlighted: true; implicitHeight: 28 }
        Controls.LiquidActionButton { text: example.tr("Normal", "普通"); implicitHeight: 28 }
        Controls.LiquidActionButton { text: example.tr("Delete", "危险"); destructive: true; implicitHeight: 28 }
        Controls.LiquidActionButton { text: example.tr("Disabled", "禁用"); enabled: false; implicitHeight: 28 }
    }
}
