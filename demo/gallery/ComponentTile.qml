import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls
import "ComponentCatalog.mjs" as Catalog
import "components"

AbstractButton {
    id: tile
    required property var entry
    property string language: "en"
    implicitWidth: 280
    implicitHeight: tokens.cardHeight
    padding: tokens.cardPadding
    hoverEnabled: true
    Accessible.name: Catalog.title(entry, language)
    MaterialSpecTokens { id: tokens; dark: Ui.AppTheme.dark }

    background: Item {
        Rectangle {
            anchors.fill: parent
            radius: tokens.cardRadius
            color: tile.down || pointer.pressed ? tokens.cardPressFill
                : tile.hovered ? tokens.cardHoverFill : tokens.cardFill
            Behavior on color { ColorAnimation { duration: Ui.AppTheme.reduceMotion ? 0 : tokens.fast } }
        }
        Rectangle {
            anchors.fill: parent
            radius: tokens.cardRadius
            color: "transparent"
            border.width: tile.activeFocus ? 2 : 0
            border.color: tokens.focusAccent
        }
    }
    contentItem: ColumnLayout {
        spacing: tokens.gap
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: tokens.thumbnailHeight
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
