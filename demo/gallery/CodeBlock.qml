import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls
import "components"

ColumnLayout {
    id: root
    property string code: ""
    property string language: "en"

    MaterialSpecTokens { id: tokens; dark: Ui.AppTheme.dark }

    spacing: tokens.gap
    RowLayout {
        Layout.fillWidth: true
        Label {
            Layout.fillWidth: true
            text: root.language === "zh" ? "可复制的 QML 示例" : "Copyable QML example"
            color: Ui.AppTheme.text
            font.weight: Font.DemiBold
        }
        Controls.LiquidActionButton {
            materialForm: true
            scale: 1
            cornerRadius: tokens.controlRadius
            focusRingColor: tokens.focusAccent
            surfaceColor: tokens.plainFill
            Layout.preferredHeight: tokens.controlHeight
            font.pixelSize: tokens.searchFontSize
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
            padding: tokens.cardPadding
            color: Ui.AppTheme.text
            selectionColor: Ui.AppTheme.accent
            selectedTextColor: Ui.AppTheme.accentText
            background: Rectangle {
                radius: tokens.cardRadius
                color: tokens.cardFill
                border.width: 1
                border.color: tokens.separator
            }
        }
    }
    Timer { id: noticeTimer; interval: 1800; onTriggered: copyNotice.visible = false }
    onCodeChanged: copyNotice.visible = false
}
