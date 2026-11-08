import QtQuick
import QtQuick.Controls
import QtQuick.Window
import "../foundation" as Foundation

// One floating liquid background; its form fields and action buttons are solid.
Foundation.KosDialog {
    id: root
    property Item sourceItem: null
    property string acceptText: ""
    property string rejectText: ""
    property string closeText: ""
    property bool acceptEnabled: true
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(440, parent ? parent.width - 40 : 440)
    height: Math.min(implicitHeight, parent ? parent.height - 40 : implicitHeight)
    property LiquidBackdrop backdrop: LiquidStyle.backdropFor(root.parent ? root.parent.Window.window : null)
    property alias contentBackdrop: sceneBackdrop
    property real cornerRadius: 32
    property real materialOpacity: LiquidStyle.panelMaterialOpacity
    readonly property real actionHeight: 30
    property bool reduceTransparency: Foundation.AppTheme.reduceTransparency
    readonly property bool sampling: dialogSurface.sampling
    popupType: Popup.Item
    modal: true
    closePolicy: Popup.CloseOnEscape
    padding: 24
    header: Label {
        text: root.title
        padding: 24
        topPadding: 20
        bottomPadding: 12
        color: Foundation.AppTheme.text
        font.pixelSize: Foundation.AppTheme.compactDesign ? 17 : 20
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }
    Overlay.modal: Rectangle { color: Qt.rgba(0, 0, 0, 0.16 * root.revealProgress) }
    background: LiquidDialogSurface {
        id: dialogSurface
        cornerRadius: root.cornerRadius
        materialOpacity: root.materialOpacity
        reduceTransparency: root.reduceTransparency
        backdrop: root.sourceItem ? sceneBackdrop : root.backdrop
        LiquidBackdrop {
            id: sceneBackdrop
            sourceItem: root.sourceItem
            registerAsDefault: false
            active: root.visible && !root.reduceTransparency
            blur: 0.85
        }
    }
    footer: DialogButtonBox {
        buttonLayout: DialogButtonBox.MacLayout
        visible: root.standardButtons !== Dialog.NoButton
        implicitHeight: visible ? implicitContentHeight + topPadding + bottomPadding : 0
        padding: 24
        topPadding: 12
        spacing: 8
        alignment: Qt.AlignRight
        standardButtons: root.standardButtons
        delegate: LiquidDialogButton {
            id: footerButton
            readonly property int role: DialogButtonBox.buttonRole
            enabled: role === DialogButtonBox.AcceptRole || role === DialogButtonBox.ApplyRole ? root.acceptEnabled : true
            Binding { target: footerButton; property: "text"; when: root.acceptText.length > 0 && (footerButton.role === DialogButtonBox.AcceptRole || footerButton.role === DialogButtonBox.ApplyRole); value: root.acceptText }
            Binding { target: footerButton; property: "text"; when: root.rejectText.length > 0 && footerButton.role === DialogButtonBox.RejectRole && (root.standardButtons & Dialog.Cancel); value: root.rejectText }
            Binding { target: footerButton; property: "text"; when: root.closeText.length > 0 && footerButton.role === DialogButtonBox.RejectRole && (root.standardButtons & Dialog.Close); value: root.closeText }
            primaryAction: DialogButtonBox.buttonRole === DialogButtonBox.AcceptRole
                || DialogButtonBox.buttonRole === DialogButtonBox.ApplyRole
            implicitHeight: root.actionHeight
        }
        background: Item {}
        // Dialog automatically forwards its DialogButtonBox lifecycle signals.
    }
}
