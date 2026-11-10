import QtQuick
import "../../Icons" as Symbols
import QtQuick.Window
import QtQuick.Controls
import "../foundation" as Foundation

CheckBox {
    id: root
    implicitHeight: Foundation.AppTheme.compactDesign ? 28 : 34
    Binding {
        target: root; property: "font.pixelSize"
        value: 13; when: Foundation.AppTheme.compactDesign
        restoreMode: Binding.RestoreBindingOrValue
    }
    spacing: 10
    indicator: LiquidSurface {
        implicitWidth: 22
        implicitHeight: 22
        x: root.leftPadding
        y: (root.height - height) / 2
        radius: 7
        backdrop: LiquidStyle.backdropForItem(root, root.Window.window)
        tintColor: root.checked ? Foundation.AppTheme.accent : "#ffffff"
        tintStrength: root.checked ? 0.38 : 0.05
        Symbols.Icon {
            anchors.centerIn: parent
            name: root.checkState === Qt.PartiallyChecked ? "minus" : "checkmark"
            visible: root.checkState !== Qt.Unchecked
            color: Foundation.AppTheme.text
            size: 15
        }
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: 9
            color: "transparent"
            border.width: 2
            border.color: Foundation.AppTheme.focusRing
            visible: root.activeFocus
        }
    }
    contentItem: Label {
        text: root.text
        font: root.font
        leftPadding: root.indicator.width + root.spacing
        verticalAlignment: Text.AlignVCenter
        color: Foundation.AppTheme.text
    }
    opacity: enabled ? 1 : 0.38
}
