import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls
import "ComponentCatalog.mjs" as Catalog
import "components"

ScrollView {
    id: page
    required property var entry
    property real toolbarScrollInset: 0
    property string language: "en"
    property string backgroundMode: "gradient"
    property string exampleCode: ""
    property string sourceError: ""
    property bool demoEnabled: true
    readonly property bool isButtonPage: entry !== null && entry.id === "button"
    readonly property int contentIndent: 16
    readonly property int exampleSection: whitePanel.visible ? 2 : 1
    readonly property int apiSection: isButtonPage ? 4 : exampleSection + 1

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


        Label {
            visible: whitePanel.visible
            text: page.isButtonPage ? page.tr("01 · Button catalogue", "01 · 按钮分类示例") : page.tr("01 · Component examples", "01 · 组件分类示例")
            color: Ui.AppTheme.text
            font.pixelSize: 20; font.weight: Font.Bold
            topPadding: 16; bottomPadding: 16
        }

        // Unbacked and selected-background control groups are sibling previews.
        Pane {
            id: whitePanel
            Layout.fillWidth: true
            visible: page.entry !== null && ["button", "text-field", "segmented", "bottom-navigation", "navigation"].indexOf(page.entry.id) >= 0
            padding: page.contentIndent
            implicitHeight: whitePreview.item ? whitePreview.item.implicitHeight + padding * 2 : 0
            background: Item {}
            contentItem: Loader {
                id: whitePreview
                active: whitePanel.visible
                enabled: page.demoEnabled
                onLoaded: {
                    if (item && "language" in item)
                        item.language = Qt.binding(function() { return page.language })
                    if (item && "sectionPrefix" in item) item.sectionPrefix = "01"
                }
                source: whitePanel.visible ? Qt.resolvedUrl("examples/" + page.entry.example
                    + "?revision=unbacked-controls-6") : ""
            }
        }

        Label {
            Layout.topMargin: 16
            text: ("0" + page.exampleSection) + " · " + (whitePanel.visible
                ? page.tr("Background comparison", "背景对照") : page.tr("Interactive examples", "交互示例"))
            color: Ui.AppTheme.text
            font.pixelSize: 20; font.weight: Font.Bold
            topPadding: 16; bottomPadding: 16
        }
        Pane {
            Layout.fillWidth: true
            padding: page.contentIndent
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
                    onLoaded: {
                        if (item && "language" in item)
                            item.language = Qt.binding(function() { return page.language })
                        if (item && "sectionPrefix" in item)
                            item.sectionPrefix = Qt.binding(function() { return "0" + page.exampleSection })
                        if (page.isButtonPage) item.sceneOnly = true
                    }
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

        Loader {
            Layout.fillWidth: true
            Layout.topMargin: 16
            active: page.entry !== null && page.entry.id === "button"
            visible: active
            enabled: page.demoEnabled
            sourceComponent: MaterialToolbarPilot { language: page.language; contentIndent: page.contentIndent }
        }

        Label {
            Layout.topMargin: 24
            text: "0" + page.apiSection + " · " + page.tr("API reference", "接口说明")
            color: Ui.AppTheme.text
            font.pixelSize: 20
            font.weight: Font.Bold
            topPadding: 16
            bottomPadding: 16
        }
        Repeater {
            model: page.entry ? page.entry.api : []
            delegate: ColumnLayout {
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.topMargin: 8
                Layout.bottomMargin: 16
                Layout.leftMargin: page.contentIndent
                Layout.rightMargin: page.contentIndent
                spacing: 8
                Label {
                    Layout.fillWidth: true
                    text: "0" + page.apiSection + "." + (index + 1) + " · " + modelData[0]
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
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

        Label {
            Layout.fillWidth: true
            text: "0" + (page.apiSection + 1) + " · " + page.tr("Code example", "代码示例")
            color: Ui.AppTheme.text
            font.pixelSize: 20; font.weight: Font.Bold
            topPadding: 16; bottomPadding: 16
        }
        CodeBlock {
            Layout.fillWidth: true
            Layout.leftMargin: page.contentIndent
            Layout.rightMargin: page.contentIndent
            code: page.exampleCode; language: page.language
        }
        Label {
            visible: page.sourceError.length > 0
            text: page.sourceError
            color: Ui.AppTheme.destructive
        }
        Label {
            Layout.fillWidth: true
            Layout.leftMargin: page.contentIndent
            Layout.rightMargin: page.contentIndent
            text: page.entry ? page.entry.source : ""
            color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
            font.family: "monospace"
            wrapMode: Text.WrapAnywhere
        }
        Controls.LiquidActionButton {
            Layout.leftMargin: page.contentIndent
            text: page.tr("Open component source", "查看组件源码")
            onClicked: Qt.openUrlExternally("file://" + Quickshell.shellDir + "/../" + page.entry.source)
        }
        Item { Layout.preferredHeight: 12 }
    }
}
