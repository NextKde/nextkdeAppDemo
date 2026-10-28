import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io
import "Kos/Ui/foundation" as Ui
import "gallery/examples"

ShellRoot {
    Window {
        id: demoWindow
        title: "NextKde · SettingsGroup / SettingsItem"
        flags: Qt.Window | Qt.FramelessWindowHint
        width: 850
        height: 650
        minimumWidth: 440
        minimumHeight: 400
        visible: true
        color: Ui.AppTheme.contentBackground
        onClosing: Qt.quit()
        property string language: Quickshell.env("GALLERY_LANGUAGE") === "zh" ? "zh" : "en"
        property bool darkMode: Quickshell.env("GALLERY_THEME") === "dark"
        Binding { target: Ui.AppTheme; property: "appearanceMode"; value: demoWindow.darkMode ? "dark" : "light" }
        Binding { target: Ui.AppTheme; property: "compactDesign"; value: true }

        Item {
            id: scene
            anchors.fill: parent
            Rectangle { anchors.fill: parent; color: Ui.AppTheme.contentBackground }
            MouseArea {
                anchors { left: parent.left; right: parent.right; top: parent.top }
                height: 38
                onPressed: demoWindow.startSystemMove()
                onDoubleClicked: demoWindow.visibility === Window.Maximized ? demoWindow.showNormal() : demoWindow.showMaximized()
            }
            Text {
                x: 24
                y: 11
                text: demoWindow.language === "zh" ? "主题" : "Theme"
                color: Ui.AppTheme.text
                font.pixelSize: 16
                font.weight: Font.DemiBold
            }
            Ui.KosWindowControls {
                anchors { top: parent.top; right: parent.right; rightMargin: 12; topMargin: 4 }
                targetWindow: demoWindow
                maximizeMode: true
                circleSize: 14
                buttonWidth: 18
                buttonHeight: 30
                spacing: 10
            }
            Flickable {
                id: scroll
                anchors { fill: parent; topMargin: 58; bottomMargin: 20; leftMargin: 24; rightMargin: 24 }
                contentWidth: width
                contentHeight: example.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                SettingsExample {
                    id: example
                    width: Math.min(660, scroll.width)
                    x: Math.max(0, (scroll.width - width) / 2)
                    language: demoWindow.language
                    showVariants: true
                }
                Ui.KosKineticScroll { flickable: scroll }
            }
            Ui.KosWindowResizeHandles { targetWindow: demoWindow }
        }

        IpcHandler {
            target: "settingsDemo"
            function capture(path: string): void {
                scene.grabToImage(result => console.log("Settings demo capture", path, result.saveToFile(path)))
            }
            function setTheme(mode: string): void { demoWindow.darkMode = mode === "dark" }
            function resize(width: int, height: int): void { demoWindow.width = width; demoWindow.height = height }
            function state(): string {
                return JSON.stringify({width: demoWindow.width, height: demoWindow.height,
                    shape: example.selectedShape, material: example.selectedMaterial,
                    blur: example.blurValue, savedBlur: example.savedBlur,
                    liquid: example.liquidValue, savedLiquid: example.savedLiquid})
            }
        }
    }
}
