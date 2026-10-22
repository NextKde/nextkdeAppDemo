import QtQuick
import QtQuick.Controls
import "../foundation" as Foundation

Foundation.KosDialog {
    id: root
    padding: 20
    header: Label {
        text: root.title
        padding: 20
        color: Foundation.AppTheme.text
        font.pixelSize: 20
        font.weight: Font.DemiBold
    }
    Overlay.modal: Rectangle { color: "transparent" }
    background: Item {
        LiquidOuterShadow {
            anchors.fill: parent; radius: 24
            shadowColor: Foundation.AppTheme.dark ? "#606064" : "#000000"
            shadowOpacity: .22; softness: 14; spread: 36
            outwardOffset: 0; offset: Qt.vector2d(0, 0)
        }
        LiquidSurface { anchors.fill: parent; radius: 24; readability: 0.60 }
    }
    footer: DialogButtonBox {
        standardButtons: root.standardButtons
        delegate: LiquidActionButton {
            materialForm: true
            surfaceColor: Foundation.AppTheme.dark ? "#3a3a3c" : "#e8e8ed"
            textColor: Foundation.AppTheme.text
        }
        background: Item {}
        onAccepted: root.accept()
        onRejected: root.reject()
    }
}
