import QtQuick
import Quickshell
import "Kos/Ui/foundation" as Ui
import "Kos/Ui/controls" as Controls
import "gallery"

ShellRoot {
    FloatingWindow {
        title: "NextKde App Demo"
        implicitWidth: 1180
        implicitHeight: 780
        minimumSize: Qt.size(900, 560)
        visible: true
        color: "transparent"
        onClosed: Qt.quit()

        GalleryBackdrop {
            id: scene
            anchors.fill: parent
            mode: gallery.backgroundMode
            visible: mode !== "desktop"
        }
        Controls.LiquidBackdrop {
            sourceItem: scene
            active: gallery.backgroundMode !== "desktop"
        }
        GalleryRoot { id: gallery; anchors.fill: parent }
    }
}
