import QtQuick
import QtQuick.Controls
import "../foundation" as Foundation

Foundation.KosDialog {
    id: root
    property alias contentBackdrop: dialogBackdrop
    property real cornerRadius: Foundation.AppTheme.compactDesign ? 16 : 24
    Binding {
        target: root; property: "font.pixelSize"
        value: 13; when: Foundation.AppTheme.compactDesign
        restoreMode: Binding.RestoreBindingOrValue
    }
    padding: Foundation.AppTheme.compactDesign ? 16 : 20
    header: Label {
        text: root.title
        padding: Foundation.AppTheme.compactDesign ? 16 : 20
        color: Foundation.AppTheme.text
        font.pixelSize: Foundation.AppTheme.compactDesign ? 17 : 20
        font.weight: Font.DemiBold
    }
    Overlay.modal: Rectangle { color: Qt.rgba(0, 0, 0, 0.25) }
    background: Item {
        LiquidOuterShadow {
            anchors.fill: parent; radius: root.cornerRadius
            shadowColor: Foundation.AppTheme.compactDesign ? "#000000" : Foundation.AppTheme.dark ? "#606064" : "#000000"
            shadowOpacity: Foundation.AppTheme.compactDesign ? .12 : .32
            softness: Foundation.AppTheme.compactDesign ? 8 : 20
            spread: Foundation.AppTheme.compactDesign ? 16 : 52
            outwardOffset: 0; offset: Qt.vector2d(0, 0)
        }
        Rectangle {
            id: dialogFill
            anchors.fill: parent; radius: root.cornerRadius
            color: Foundation.AppTheme.compactDesign ? Foundation.AppTheme.dialogBackground
                : Foundation.AppTheme.dark ? "#29292d" : "#ffffff"
        }
        LiquidBackdrop { id: dialogBackdrop; sourceItem: dialogFill; registerAsDefault: false; active: false }
    }
    footer: DialogButtonBox {
        alignment: Qt.AlignHCenter
        standardButtons: root.standardButtons
        delegate: LiquidActionButton {
            materialForm: true
            cornerRadius: Foundation.AppTheme.compactDesign ? 8 : height / 2
            implicitHeight: Foundation.AppTheme.compactDesign ? 28 : 36
            surfaceColor: Foundation.AppTheme.compactDesign ? Foundation.AppTheme.controlBackground
                : Foundation.AppTheme.dark ? "#454549" : "#d2d2d7"
            textColor: Foundation.AppTheme.text
        }
        background: Item {}
        onAccepted: root.accept()
        onRejected: root.reject()
    }
}
