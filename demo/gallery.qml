import QtQuick
import Quickshell
import Quickshell.Io
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

        Item {
            id: reviewSurface
            anchors.fill: parent

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

        // Explicit local review of the live window, without desktop capture.
        IpcHandler {
            target: Quickshell.env("GALLERY_REVIEW") === "1" ? "galleryReview" : ""
            function capture(path: string): void {
                reviewSurface.grabToImage(function(result) {
                    console.log("Gallery review capture", path, result.saveToFile(path))
                })
            }
            function showPage(page: string): void { gallery.select(page) }
            function setTheme(theme: string): void {
                if (theme === "light" || theme === "dark") gallery.themeMode = theme
            }
        }
    }
}
