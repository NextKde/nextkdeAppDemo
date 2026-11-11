import QtQuick
import "../../Icons" as Symbols
import QtQuick.Controls
import QtQuick.Window

Row {
    id: root
    required property var targetWindow
    // Keep legacy fullscreen behaviour by default; square desktop apps opt in.
    property bool maximizeMode: false
    property real circleSize: 18
    property real buttonWidth: 22
    property real buttonHeight: 32
    objectName: "windowControls"
    spacing: 10
    HoverHandler { id: groupHover }
    Repeater {
        model: ["fullscreen", "minimize", "close"]
        delegate: AbstractButton {
            id: button
            required property string modelData
            objectName: "window" + modelData + "Button"
            width: root.buttonWidth; height: root.buttonHeight
            hoverEnabled: true
            focusPolicy: Qt.StrongFocus
            Accessible.name: modelData === "fullscreen"
                ? (root.maximizeMode
                    ? (root.targetWindow.visibility === Window.Maximized ? qsTr("Restore") : qsTr("Maximize"))
                    : (root.targetWindow.visibility === Window.FullScreen ? qsTr("Exit full screen") : qsTr("Full screen")))
                : modelData === "minimize" ? qsTr("Minimize") : qsTr("Close")
            KosToolTip { target: button; text: button.Accessible.name }
            onClicked: {
                if (modelData === "fullscreen") {
                    if (root.maximizeMode) {
                        if (root.targetWindow.visibility === Window.Maximized) root.targetWindow.showNormal()
                        else root.targetWindow.showMaximized()
                    } else root.targetWindow.toggleFullScreen()
                }
                else if (modelData === "minimize") root.targetWindow.showMinimized()
                else root.targetWindow.close()
            }
            background: Item {
                Rectangle {
                    anchors.centerIn: parent
                    width: root.circleSize; height: root.circleSize; radius: width / 2
                    color: button.modelData === "fullscreen" ? "#2fc866" : button.modelData === "minimize" ? "#ffbf18" : "#ff5f57"
                    border.width: button.activeFocus ? 2 : 1
                    border.color: button.activeFocus ? AppTheme.text : Qt.darker(color, 1.28)
                    scale: button.down ? .88 : button.hovered ? 1.04 : 1
                    Behavior on scale { NumberAnimation { duration: AppTheme.motionFast } }
                    Symbols.Icon {
                        anchors.centerIn: parent
                        size: 9
                        name: button.modelData === "maximize" ? "square" : button.modelData === "minimize" ? "minus" : "xmark"
                        color: "black"
                        opacity: !root.hoverGlyphs || groupHover.hovered || button.activeFocus ? .72 : 0
                        Behavior on opacity { NumberAnimation { duration: AppTheme.motionFast } }
                    }
                }
            }
        }
    }
}
