import QtQuick
import Quickshell
import "gallery"

ShellRoot {
    FloatingWindow {
        title: "NextKde · Liquid Sidebar"
        implicitWidth: 1040
        implicitHeight: 700
        minimumSize: Qt.size(840, 580)
        visible: true
        color: "transparent"
        onClosed: Qt.quit()

        SidebarDemo { anchors.fill: parent }
    }
}
