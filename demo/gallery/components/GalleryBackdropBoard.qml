import QtQuick

// Controlled high-contrast scene for in-window texture sampling.
Item {
    id: root

    Rectangle {
        anchors.fill: parent

        Rectangle {
            x: 0; y: 0
            width: parent.width * 0.5
            height: parent.height * 0.5
            color: "#e53935"
        }
        Rectangle {
            x: parent.width * 0.5; y: 0
            width: parent.width * 0.5
            height: parent.height * 0.5
            color: "#fdd835"
        }
        Rectangle {
            x: 0; y: parent.height * 0.5
            width: parent.width * 0.5
            height: parent.height * 0.5
            color: "#00acc1"
        }
        Rectangle {
            x: parent.width * 0.5; y: parent.height * 0.5
            width: parent.width * 0.5
            height: parent.height * 0.5
            color: "#d81b60"
        }

        Repeater {
            model: 40
            Rectangle {
                required property int index
                x: (index % 8) * (parent.width / 8) + parent.width / 16 - 18
                y: Math.floor(index / 8) * (parent.height / 5) + parent.height / 10 - 18
                width: 36
                height: 36
                radius: 18
                color: index % 2 === 0 ? "#ffffff" : "#000000"
                opacity: 0.85
            }
        }
    }
}
