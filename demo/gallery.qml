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
                // Quickshell's native content parent has no QML engine.
                // Capture the owned QML scene; native popup acceptance is separate.
                reviewSurface.grabToImage(function(result) {
                    console.log("Gallery review capture", path, result.saveToFile(path))
                })
            }
            function openSelect(): bool {
                const pending = [reviewSurface]
                while (pending.length) {
                    const item = pending.pop()
                    if (item.objectName === "reviewSelect" && typeof item.openReviewMenu === "function") {
                        item.openReviewMenu()
                        return true
                    }
                    for (let i = 0; i < item.children.length; ++i) pending.push(item.children[i])
                }
                return false
            }
            function focusInput(): bool {
                const pending = [reviewSurface]
                while (pending.length) {
                    const item = pending.pop()
                    if (item.objectName === "reviewTextField") {
                        item.forceActiveFocus(Qt.TabFocusReason)
                        return true
                    }
                    for (let i = 0; i < item.children.length; ++i) pending.push(item.children[i])
                }
                return false
            }
            function showPage(page: string): void { gallery.select(page) }
            function setTheme(theme: string): void {
                if (theme === "light" || theme === "dark") gallery.themeMode = theme
            }
            // Controlled state-path sampling; this does not replace pointer/keyboard QA.
            function controlState(name: string, action: string, value: string): string {
                if (name !== "reviewSwitch" && name !== "reviewSegmented" && name !== "reviewNav")
                    return JSON.stringify({ok: false, error: "Unknown review control"})
                const allowed = ["beginReviewPress", "endReviewPress", "cancelReviewPress",
                    "focusReviewControl", "resetReview", "setReviewConfirmation", "previewState"]
                if (action === "setReviewHovered" && name === "reviewSwitch") allowed.push(action)
                if (action === "startReviewSequence" && name === "reviewNav") allowed.push(action)
                if (action === "clearReviewFocus" && name === "reviewNav") allowed.push(action)
                if (allowed.indexOf(action) < 0)
                    return JSON.stringify({ok: false, error: "Unknown review action"})
                const pending = [reviewSurface]
                while (pending.length) {
                    const item = pending.pop()
                    if (item.objectName === name && typeof item[action] === "function") {
                        if (action === "previewState") return item.previewState()
                        if (action === "startReviewSequence") item.startReviewSequence(value)
                        else if (action === "beginReviewPress" || action === "endReviewPress")
                            item[action](Number(value) || 0)
                        else if (action === "setReviewConfirmation" || action === "setReviewHovered")
                            item[action](value === "true")
                        else item[action]()
                        return JSON.stringify({ok: true})
                    }
                    for (let i = 0; i < item.children.length; ++i) pending.push(item.children[i])
                }
                return JSON.stringify({ok: false, error: "Review example is not loaded"})
            }
        }
    }
}
