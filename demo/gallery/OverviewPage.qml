import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "ComponentCatalog.mjs" as Catalog

ScrollView {
    id: page
    property string language: "en"
    signal componentSelected(string id)
    function tr(en, zh) { return language === "zh" ? zh : en }

    clip: true
    contentWidth: availableWidth
    ColumnLayout {
        width: page.availableWidth
        spacing: 18

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
            columnSpacing: 16
            rowSpacing: 16
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
