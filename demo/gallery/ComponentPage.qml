import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls
import "ComponentCatalog.mjs" as Catalog

ScrollView {
    id: page
    required property var entry
    property real toolbarScrollInset: 0
    property string language: "en"
    property string backgroundMode: "gradient"
    property string exampleCode: ""
    property string sourceError: ""
    property bool demoEnabled: true

    function tr(en, zh) { return language === "zh" ? zh : en }
    function resetExample() {
        preview.active = false
        preview.active = true
        whitePreview.active = false
        whitePreview.active = Qt.binding(function() { return whitePanel.visible })
    }

    clip: true
    contentWidth: availableWidth
    onEntryChanged: {
        exampleCode = ""
        sourceError = ""
        demoEnabled = true
        if (contentItem) contentItem.contentY = 0
    }

    property FileView exampleSource: FileView {
        path: page.entry ? Quickshell.shellDir + "/gallery/examples/" + page.entry.example : ""
        preload: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            // The source-tree import maps to the same Kos.Ui types linked by applications.
            page.exampleCode = text()
                .replace('import "../../Kos/Ui/foundation" as Ui', 'import Kos.Ui as Ui')
                .replace('import "../../Kos/Ui/controls" as Controls', 'import Kos.Ui as Controls')
            page.sourceError = ""
        }
        onLoadFailed: page.sourceError = page.tr("Could not read the example source.", "无法读取示例源码。")
    }

    ColumnLayout {
        width: page.availableWidth
        Item { Layout.fillWidth: true; Layout.preferredHeight: Math.max(0, page.toolbarScrollInset - parent.spacing) }
        spacing: 16

        Label {
            Layout.fillWidth: true
            text: page.entry ? Catalog.summary(page.entry, page.language) : ""
            color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
            wrapMode: Text.WordWrap
        }
        Label {
            text: page.entry ? page.entry.type : ""
            color: Ui.AppTheme.text
            font.family: "monospace"
        }

        RowLayout {
            Layout.fillWidth: true
            Label {
                Layout.fillWidth: true
                text: page.tr("Interactive example", "交互示例")
                color: Ui.AppTheme.text
                font.weight: Font.DemiBold
            }
            Label { text: page.tr("Enabled", "启用"); color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82) }
            Controls.LiquidGlassSwitch {
                materialForm: false
                checked: page.demoEnabled
                Accessible.name: page.tr("Enable example", "启用示例")
                onToggled: function(checked) { page.demoEnabled = checked }
            }
            Controls.LiquidActionButton {
                text: page.tr("Reset", "重置")
                onClicked: page.resetExample()
            }
        }

        // Unbacked and selected-background control groups are sibling previews.
        Pane {
            id: whitePanel
            Layout.fillWidth: true
            visible: page.entry !== null && ["button", "text-field", "segmented", "bottom-navigation", "navigation"].indexOf(page.entry.id) >= 0
            padding: 20
            implicitHeight: whitePreview.item ? whitePreview.item.implicitHeight + padding * 2 : 0
            background: Item {}
            contentItem: Loader {
                id: whitePreview
                active: whitePanel.visible
                enabled: page.demoEnabled
                source: whitePanel.visible ? Qt.resolvedUrl("examples/" + page.entry.example
                    + "?revision=unbacked-controls-6") : ""
            }
        }

        Pane {
            Layout.fillWidth: true
            padding: 20
            clip: true
            implicitHeight: previewHost.implicitHeight + padding * 2
            background: GalleryBackdrop { id: previewScene; mode: page.backgroundMode }
            readonly property alias contentBackdrop: previewBackdrop
            Controls.LiquidBackdrop {
                id: previewBackdrop
                sourceItem: previewScene
                registerAsDefault: false
                active: page.backgroundMode !== "desktop"
            }
            contentItem: Item {
                id: previewHost
                implicitHeight: preview.item ? Math.max(160, preview.item.implicitHeight) : 160

                Loader {
                    id: preview
                    anchors.fill: parent
                    enabled: page.demoEnabled
                    // Use a new URL for the reorganized examples so the live
                    // QQmlEngine cannot reuse their previous compiled component.
                    source: page.entry ? Qt.resolvedUrl("examples/" + page.entry.example
                        + ((page.entry.id === "button" || page.entry.id === "text-field" || page.entry.id === "switch")
                            ? "?revision=switch-jelly-7" : "")) : ""
                }

                Label {
                    anchors.centerIn: parent
                    width: parent.width
                    visible: preview.status === Loader.Error
                    text: page.tr("Example unavailable. Check its runtime dependencies.", "示例无法加载，请检查所需的运行环境。")
                    color: Ui.AppTheme.destructive
                    wrapMode: Text.WordWrap
                }
            }
        }

        Label {
            text: page.tr("Properties & signals", "属性与信号")
            color: Ui.AppTheme.text
            font.weight: Font.DemiBold
        }
        Repeater {
            model: page.entry ? page.entry.api : []
            delegate: ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 4
                Label {
                    Layout.fillWidth: true
                    text: modelData[0]
                    font.family: "monospace"
                    color: Ui.AppTheme.text
                    wrapMode: Text.WrapAnywhere
                }
                Label {
                    Layout.fillWidth: true
                    text: modelData[page.language === "zh" ? 2 : 1]
                    color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                    wrapMode: Text.WordWrap
                }
            }
        }

        CodeBlock { Layout.fillWidth: true; code: page.exampleCode; language: page.language }
        Label {
            visible: page.sourceError.length > 0
            text: page.sourceError
            color: Ui.AppTheme.destructive
        }
        Label {
            Layout.fillWidth: true
            text: page.entry ? page.entry.source : ""
            color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
            font.family: "monospace"
            wrapMode: Text.WrapAnywhere
        }
        Controls.LiquidActionButton {
            text: page.tr("Open component source", "查看组件源码")
            onClicked: Qt.openUrlExternally("file://" + Quickshell.shellDir + "/../" + page.entry.source)
        }
        Item { Layout.preferredHeight: 12 }
    }
}
