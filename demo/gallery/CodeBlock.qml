import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls

ColumnLayout {
    id: root
    property string code: ""
    property string language: "en"

    spacing: 8
    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: root.language === "zh" ? "可复制的 QML 示例" : "Copyable QML example"
            color: Ui.AppTheme.text
            font.weight: Font.DemiBold
        }
        Controls.LiquidActionButton {
            text: root.language === "zh" ? "复制代码" : "Copy code"
            enabled: root.code.length > 0
            onClicked: {
                codeText.selectAll()
                codeText.copy()
                codeText.deselect()
                copyNotice.visible = true
                noticeTimer.restart()
            }
        }
        Label {
            id: copyNotice
            visible: false
            text: root.language === "zh" ? "已复制" : "Copied"
            color: Ui.AppTheme.accent
        }
    }
    ScrollView {
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(340, Math.max(140, codeText.implicitHeight))
        clip: true
        TextArea {
            id: codeText
            text: root.code
            readOnly: true
            selectByMouse: true
            textFormat: TextEdit.PlainText
            wrapMode: TextEdit.NoWrap
            font.family: "monospace"
            font.pixelSize: 12
            padding: 16
            color: Ui.AppTheme.text
            selectionColor: Ui.AppTheme.accent
            selectedTextColor: Ui.AppTheme.accentText
            background: Controls.LiquidSurface { radius: 14; readability: 0.60 }
        }
    }
    Timer { id: noticeTimer; interval: 1800; onTriggered: copyNotice.visible = false }
    onCodeChanged: copyNotice.visible = false
}
