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
    function tr(en, zh) {
        return language === "zh" ? zh : en;
    }
    spacing: 16

    Sections.ExampleHeading {
        number: example.sectionPrefix + ".1"
        title: example.tr("Icon actions: hover or focus with Tab", "图标操作：悬停或按 Tab 聚焦")
    }
    RowLayout {
        spacing: 12
        Controls.LiquidActionButton {
            id: settings
            objectName: "toolTipSettingsAction"
            implicitWidth: 26
            implicitHeight: 26
            iconOnly: true
            iconName: "settings"
            iconSize: 16
            Accessible.name: example.tr("Open settings", "打开设置")
            Ui.KosToolTip {
                target: settings
                text: settings.Accessible.name
            }
        }
        Controls.LiquidActionButton {
            id: create
            implicitWidth: 26
            implicitHeight: 26
            iconOnly: true
            iconName: "plus"
            iconSize: 16
            Accessible.name: example.tr("Create an item", "新建条目")
            Ui.KosToolTip {
                target: create
                text: create.Accessible.name
            }
        }
        Text {
            Layout.fillWidth: true
            text: example.tr("Hints never take focus or trigger an action.", "提示不抢焦点，也不会触发操作。")
            font.pixelSize: 12
            color: Ui.AppTheme.mutedText
            wrapMode: Text.Wrap
        }
    }
    Sections.ExampleHeading {
        number: example.sectionPrefix + ".2"
        title: example.tr("Navigation: show only when the label is elided", "导航名称：仅在文字截断时提示")
    }
    Text {
        id: navigationName
        objectName: "toolTipElidedLabel"
        Layout.preferredWidth: 148
        text: example.tr("Window appearance and animation preferences", "窗口外观、动画与其他显示偏好设置")
        font.pixelSize: 13
        color: Ui.AppTheme.text
        elide: Text.ElideRight
        activeFocusOnTab: true
        HoverHandler {
            id: labelHover
        }
        Ui.KosToolTip {
            target: navigationName
            hovered: labelHover.hovered
            text: navigationName.text
            onlyWhenTruncated: true
            truncated: navigationName.truncated
        }
    }
    Sections.ExampleHeading {
        number: example.sectionPrefix + ".3"
        title: example.tr("Long hints wrap within the window", "长提示自动换行并避开窗口边缘")
    }
    Controls.LiquidActionButton {
        id: details
        Layout.alignment: Qt.AlignRight
        implicitHeight: 26
        text: example.tr("Inspect", "查看")
        Ui.KosToolTip {
            target: details
            maximumWidth: 240
            text: example.tr("Inspect the selected item's details without changing its saved settings", "查看当前条目的详细信息，不会修改已经保存的设置")
        }
    }
}
