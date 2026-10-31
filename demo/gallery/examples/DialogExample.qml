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
    property string result: tr("No action yet.", "尚未操作。")
    function findDialogScene() {
        for (let host = parent; host; host = host.parent)
            if ("dialogScene" in host) return host.dialogScene
        return null
    }
    spacing: 16
    Sections.ExampleHeading { number: example.sectionPrefix + ".1"; title: example.tr("Open and respond", "打开与响应") }
    Controls.LiquidActionButton { materialForm: true; text: example.tr("Open dialog", "打开对话框"); onClicked: dialog.open() }
    Label { text: example.result; color: Ui.AppTheme.text }

    Sections.ExampleHeading { number: example.sectionPrefix + ".2"; title: example.tr("Anchored action popover", "带箭头的操作弹层") }
    Controls.LiquidActionButton {
        id: addButton
        text: example.tr("Add…", "添加…")
        onClicked: actions.openAtAnchor()
    }
    Controls.LiquidPopover {
        id: actions
        anchorItem: addButton
        sourceItem: example.findDialogScene()
        Controls.LiquidPopoverItem {
            text: example.tr("New event", "新建日程")
            iconName: "calendar"
            onTriggered: dialog.open()
        }
        Controls.LiquidPopoverItem {
            text: example.tr("New reminder", "新建提醒事项")
            iconName: "reminder"
            onTriggered: dialog.open()
        }
    }

    Sections.ExampleHeading { number: example.sectionPrefix + ".3"; title: example.tr("Contextual editor", "锚定内容编辑") }
    Controls.LiquidActionButton {
        id: editorTrigger
        text: example.tr("Edit here", "在此编辑")
        onClicked: contentEditor.open()
    }
    Controls.LiquidContentPopover {
        id: contentEditor
        sourceItem: example.findDialogScene()
        anchorItem: editorTrigger
        width: 300
        title: example.tr("Edit item", "编辑项目")
        contentItem: TextField { placeholderText: example.tr("Title", "标题") }
        footer: DialogButtonBox {
            standardButtons: Dialog.Save | Dialog.Cancel
            delegate: Controls.LiquidDialogButton {
                primaryAction: DialogButtonBox.buttonRole === DialogButtonBox.AcceptRole
            }
        }
    }

    Controls.LiquidDialog {
        id: dialog
        objectName: "galleryLiquidDialog"
        sourceItem: example.findDialogScene()
        materialOpacity: 0.95
        cornerRadius: 32
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(380, parent.width - 32)
        title: example.tr("Save example item?", "保存示例项目？")
        modal: true
        standardButtons: Dialog.Ok | Dialog.Cancel
        onAccepted: example.result = example.tr("Confirmed.", "已确认。")
        onRejected: example.result = example.tr("Cancelled.", "已取消。")
        contentItem: Label {
            text: example.tr("This only changes the example; no files are written.", "此操作仅更新示例，不会写入文件。")
            wrapMode: Text.WordWrap
            color: Ui.AppTheme.text
        }
    }
}
