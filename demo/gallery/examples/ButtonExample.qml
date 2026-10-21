import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

ColumnLayout {
    spacing: 16
    Label { text: "Styles"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Flow {
        Layout.fillWidth: true
        spacing: 12
        Controls.LiquidActionButton { text: "Default" }
        Controls.LiquidActionButton { text: "Primary"; highlighted: true }
        Controls.LiquidActionButton { text: "Secondary"; secondary: true }
        Controls.LiquidActionButton { text: "Destructive"; destructive: true }
        Controls.LiquidActionButton { text: "Flat"; flat: true }
    }

    Label { text: "Ordinary content actions · no backdrop sampling"; color: Ui.AppTheme.mutedText }
    RowLayout {
        Controls.LiquidActionButton { text: "Content action"; materialForm: true }
        Controls.LiquidActionButton { text: "Primary action"; materialForm: true; highlighted: true }
        Controls.LiquidActionButton { text: "Disabled"; materialForm: true; enabled: false }
    }
    Label { text: "Sizes"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Flow {
        Layout.fillWidth: true
        spacing: 12
        Controls.LiquidActionButton { text: "Small"; implicitHeight: 28; font.pixelSize: 12 }
        Controls.LiquidActionButton { text: "Medium" }
        Controls.LiquidActionButton { text: "Large"; implicitHeight: 44; font.pixelSize: 16 }
    }

    Label { text: "Icon buttons"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Flow {
        Layout.fillWidth: true
        spacing: 12
        Controls.LiquidActionButton { iconOnly: true; iconName: "mediaPrevious"; iconFilled: true; Accessible.name: "Previous" }
        Controls.LiquidActionButton {
            id: playButton
            iconOnly: true
            iconName: checked ? "mediaPause" : "mediaPlay"
            iconFilled: true
            checkable: true
            Accessible.name: checked ? "Pause" : "Play"
        }
        Controls.LiquidActionButton { iconOnly: true; iconName: "mediaNext"; iconFilled: true; Accessible.name: "Next" }
    }

    Label { text: "States"; color: Ui.AppTheme.text; font.weight: Font.DemiBold }
    Flow {
        Layout.fillWidth: true
        spacing: 12
        Controls.LiquidActionButton { text: "Toggle"; checkable: true }
        Controls.LiquidActionButton { text: "Selected"; checkable: true; checked: true }
        Controls.LiquidActionButton { text: "Disabled"; enabled: false }
    }
}
