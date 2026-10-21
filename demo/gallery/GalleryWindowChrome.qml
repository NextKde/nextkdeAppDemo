import QtQuick
import "../Kos/Ui/foundation" as Ui

Item {
    id: chrome
    required property var targetWindow
    height: 30
    MouseArea {
        anchors.fill: parent
        anchors.rightMargin: controls.width + 22
        property point pressPosition
        property bool moveArmed: false
        onPressed: mouse => { pressPosition = Qt.point(mouse.x, mouse.y); moveArmed = true }
        onReleased: moveArmed = false
        onCanceled: moveArmed = false
        onPositionChanged: mouse => {
            if (pressed && moveArmed && (Math.abs(mouse.x - pressPosition.x) > 4 || Math.abs(mouse.y - pressPosition.y) > 4)) {
                moveArmed = false
                chrome.targetWindow.startSystemMove()
            }
        }
        onDoubleClicked: { moveArmed = false; chrome.targetWindow.toggleMaximized() }
    }
    Ui.KosWindowControls {
        id: controls
        targetWindow: chrome.targetWindow
        maximizeMode: true
        circleSize: 14; buttonWidth: 14; buttonHeight: 14; spacing: 14
        anchors.right: parent.right; anchors.rightMargin: 14.5
        anchors.top: parent.top; anchors.topMargin: 10.5
    }
}
