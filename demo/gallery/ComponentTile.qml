import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls
import "ComponentCatalog.mjs" as Catalog

AbstractButton {
    id: tile
    required property var entry
    property string language: "en"
    implicitWidth: 280
    implicitHeight: 232
    padding: 16
    hoverEnabled: true
    Accessible.name: Catalog.title(entry, language)

    background: Item {
        Controls.LiquidOuterShadow {
            anchors.fill: parent
            radius: 16
            shadowOpacity: Ui.AppTheme.dark ? .18 : .07
            offset: Qt.vector2d(0, 2)
        }
        Rectangle {
            id: panelBase
            anchors.fill: parent
            radius: 16
            color: Ui.AppTheme.dark ? "#2b2b2e" : "#f1f1f4"
        }
        Controls.LiquidBackdrop {
            id: panelBackdrop
            sourceItem: panelBase
            registerAsDefault: false
        }
        Controls.LiquidSurface {
            anchors.fill: parent
            backdrop: panelBackdrop
            convexLens: true
            radius: 16
            readability: .06
            blurStrength: 0
            reflectionStrength: tile.hovered ? .72 : .50
            tintColor: Ui.AppTheme.dark ? "#353538" : "#ffffff"
            tintStrength: tile.hovered ? .12 : .05
        }
        Rectangle {
            anchors.fill: parent
            radius: 16
            color: "transparent"
            border.width: tile.activeFocus ? 2 : 0
            border.color: Ui.AppTheme.focusRing
        }
    }
    contentItem: ColumnLayout {
        spacing: 10
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 112
            clip: true
            ComponentThumbnail { anchors.fill: parent; kind: tile.entry.id }
        }
        Label {
            Layout.fillWidth: true
            text: Catalog.title(tile.entry, tile.language)
            font.pixelSize: 15
            font.weight: Font.DemiBold
            color: Ui.AppTheme.text
            elide: Text.ElideRight
        }
        Label {
            Layout.fillWidth: true
            text: tile.entry.type
            font.family: "monospace"
            font.pixelSize: 11
            color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
            elide: Text.ElideRight
        }
        Label {
            text: tile.language === "zh" ? "查看示例 →" : "View example →"
            color: Ui.AppTheme.text
            font.pixelSize: 12
        }
    }
    // Thumbnails show enabled controls; opening the card leads to the interactive example.
    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { tile.forceActiveFocus(); tile.clicked() }
    }
}
