import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "ComponentCatalog.mjs" as Catalog
import "components"

ScrollView {
    id: page
    property real toolbarScrollInset: 0
    readonly property real scrollOffset: contentItem && contentItem.contentY !== undefined
        ? Math.max(0, contentItem.contentY - (contentItem.originY || 0)) : 0
    property string language: "en"
    signal componentSelected(string id)
    function tr(en, zh) { return language === "zh" ? zh : en }
    MaterialSpecTokens { id: tokens; dark: Ui.AppTheme.dark }

    clip: true
    contentWidth: availableWidth
    ColumnLayout {
        width: page.availableWidth
        Item { visible: page.toolbarScrollInset > 0; Layout.fillWidth: true; Layout.preferredHeight: Math.max(0, page.toolbarScrollInset - parent.spacing) }
        spacing: tokens.sectionGap

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: page.tr("Choose a component to try it and copy its QML.",
                    "选择组件，操作示例并复制 QML 代码。")
                color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                wrapMode: Text.WordWrap
            }
            Label {
                text: Catalog.entries.length + page.tr(" components", " 个组件")
                color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                font.pixelSize: 12
            }
        }
        GridLayout {
            id: directory
            Layout.fillWidth: true
            columns: width >= 1000 ? 3 : width >= 540 ? 2 : 1
            columnSpacing: tokens.sectionGap
            rowSpacing: tokens.sectionGap
            Repeater {
                model: Catalog.entries
                delegate: ComponentTile {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredWidth: 280
                    Layout.minimumWidth: 0
                    entry: modelData
                    language: page.language
                    onClicked: page.componentSelected(modelData.id)
                }
            }
        }
        Item { Layout.preferredHeight: 8 }
    }
}
