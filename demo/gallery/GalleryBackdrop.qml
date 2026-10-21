import QtQuick
import "../Kos/Ui/foundation" as Ui
import "components"

Item {
    id: root
    property string mode: "gradient"
    property real motionPhase: 0
    clip: true

    Rectangle {
        anchors.fill: parent
        visible: root.mode === "gradient"
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0; color: "#243d51" }
            GradientStop { position: 0.36; color: "#435274" }
            GradientStop { position: 0.66; color: "#705c7b" }
            GradientStop { position: 1; color: "#816c62" }
        }
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0; color: Qt.rgba(1, 1, 1, 0.06) }
                GradientStop { position: 1; color: Qt.rgba(0, 0, 0, 0.08) }
            }
        }
    }
    GalleryBackdropBoard {
        anchors.fill: parent
        visible: root.mode === "contrast" && movingPhoto.status !== Image.Ready
    }
    Image {
        id: movingPhoto
        visible: root.mode === "contrast"
        source: "../assets/contrast-flow.jpg"
        asynchronous: true
        fillMode: Image.PreserveAspectCrop
        smooth: true
        width: root.width * 1.2
        height: root.height * 1.2
        // Overscan keeps every edge covered while one real image pans beneath
        // the glass. Both sine waves meet continuously at the loop boundary.
        x: (root.width - width) * (.5 + .5 * Math.sin(root.motionPhase))
        y: (root.height - height) * (.5 + .5 * Math.sin(root.motionPhase * 2))
    }
    NumberAnimation on motionPhase {
        from: 0
        to: Math.PI * 2
        duration: 30000
        loops: Animation.Infinite
        running: root.visible && root.mode === "contrast"
            && movingPhoto.status === Image.Ready && !Ui.AppTheme.reduceMotion
    }
}
