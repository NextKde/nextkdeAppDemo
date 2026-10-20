import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui
import "../../Kos/Ui/controls" as Controls

Controls.LiquidCard {
    id: example
    property bool saved: false
    contentItem: ColumnLayout {
        spacing: 12
        Label { text: "A reusable content card"; color: Ui.AppTheme.text; font.bold: true }
        Label {
            Layout.fillWidth: true
            text: example.saved ? "Your example item was saved." : "Use layouts to arrange real content and actions."
            color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
            wrapMode: Text.WordWrap
        }
        Controls.LiquidActionButton { text: "Save item"; onClicked: example.saved = true }
    }
}
