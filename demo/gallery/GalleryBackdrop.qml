import QtQuick
import "components"

Item {
    id: root
    property string mode: "gradient"
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
    GalleryBackdropBoard { anchors.fill: parent; visible: root.mode === "contrast" }
}
