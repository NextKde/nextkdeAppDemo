import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls
import "ComponentCatalog.mjs" as Catalog

Pane {
    id: root

    property string language: Quickshell.env("GALLERY_LANGUAGE") === "zh" ? "zh" : "en"
    property string themeMode: Quickshell.env("GALLERY_THEME") === "light" ? "light" : "dark"
    property string backgroundMode: "gradient"
    property string currentId: "overview"
    readonly property var selected: Catalog.find(currentId)
    readonly property var filteredEntries: Catalog.filter(search.text)
    padding: 0
    palette.window: Ui.AppTheme.window
    palette.windowText: Ui.AppTheme.text
    palette.text: Ui.AppTheme.text
    palette.buttonText: Ui.AppTheme.text
    palette.button: Ui.AppTheme.button
    palette.base: Ui.AppTheme.windowRaised
    palette.highlight: Ui.AppTheme.accent
    palette.highlightedText: Ui.AppTheme.accentText

    function tr(en, zh) { return language === "zh" ? zh : en }
    function select(id) {
        currentId = id
        content.forceActiveFocus()
    }

    Binding { target: Ui.AppTheme; property: "appearanceMode"; value: root.themeMode }
    Binding { target: Ui.AppTheme; property: "modernDesign"; value: true }

    Shortcut {
        sequence: "Ctrl+K"
        onActivated: { search.forceActiveFocus(); search.selectAll() }
    }
    Shortcut { sequence: "Alt+Left"; onActivated: root.select("overview") }

    background: Item {}

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20

        Controls.LiquidCard {
            Layout.preferredWidth: 224
            Layout.minimumWidth: 224
            Layout.maximumWidth: 224
            Layout.fillHeight: true
            padding: 0
            radius: 18
            readability: 0.62

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 12

                Label {
                    text: "NextKde UI"
                    color: Ui.AppTheme.text
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                }
                Label {
                    text: root.tr("Component gallery", "组件示例库")
                    color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                }
                Controls.LiquidTextField {
                    materialForm: false
                    textColor: Ui.AppTheme.text
                    mutedTextColor: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                    glassColor: Qt.rgba(1, 1, 1, 0.08)
                    id: search
                    Layout.fillWidth: true
                    placeholderText: root.tr("Search · Ctrl+K", "搜索 · Ctrl+K")
                    Accessible.name: root.tr("Search components", "搜索组件")
                }
                Controls.LiquidNavigationButton {
                    Layout.fillWidth: true
                    text: root.tr("All components", "全部组件")
                    checked: root.currentId === "overview"
                    onClicked: root.select("overview")
                }
                ListView {
                    id: navigation
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    model: root.filteredEntries
                    delegate: Column {
                        id: destination
                        required property var modelData
                        required property int index
                        width: navigation.width
                        Label {
                            width: parent.width
                            visible: destination.index === 0 || root.filteredEntries[destination.index - 1].group !== destination.modelData.group
                            topPadding: 16
                            bottomPadding: 6
                            text: Catalog.groupTitle(destination.modelData.group, root.language)
                            color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                            font.pixelSize: 11
                            font.weight: Font.DemiBold
                        }
                        Controls.LiquidNavigationButton {
                            width: parent.width
                            text: Catalog.title(destination.modelData, root.language)
                            checked: root.currentId === destination.modelData.id
                            onClicked: root.select(destination.modelData.id)
                        }
                    }
                    ScrollBar.vertical: ScrollBar {}
                    Ui.KosKineticScroll {}
                    Label {
                        anchors.centerIn: parent
                        visible: root.filteredEntries.length === 0
                        text: root.tr("No matching components", "没有匹配的组件")
                        color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                    }
                }
                RowLayout {
                    Label {
                        Layout.fillWidth: true
                        text: root.tr("Reduce motion", "减少动态效果")
                        color: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                    }
                    Controls.LiquidGlassSwitch {
                        materialForm: false
                        checked: Ui.AppTheme.reduceMotion
                        Accessible.name: root.tr("Reduce motion", "减少动态效果")
                        onToggled: function(checked) { Ui.AppTheme.reduceMotion = checked }
                    }
                }
                Controls.LiquidActionButton {
                    Layout.fillWidth: true
                    flat: true
                    text: root.tr("Developer guide", "开发接入指南")
                    onClicked: Qt.openUrlExternally("file://" + Quickshell.shellDir + "/../docs/Components"
                        + (root.language === "zh" ? ".zh-CN" : "") + ".md")
                }
            }
        }

        Controls.LiquidCard {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 20
            radius: 18
            readability: 0.62
            contentItem: ColumnLayout {
                spacing: 18

                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        Layout.fillWidth: true
                        text: root.selected ? Catalog.title(root.selected, root.language)
                            : root.tr("Components", "组件")
                        color: Ui.AppTheme.text
                        font.pixelSize: 22
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Controls.LiquidSelect {
                        Layout.preferredWidth: 140
                        appearanceMode: root.themeMode
                        model: root.language === "zh" ? ["渐变背景", "对比背景", "透明桌面"] : ["Gradient", "Contrast", "Desktop"]
                        currentIndex: ["gradient", "contrast", "desktop"].indexOf(root.backgroundMode)
                        materialForm: false
                        textColor: Ui.AppTheme.text
                        mutedTextColor: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                        onActivated: function(index) { root.backgroundMode = ["gradient", "contrast", "desktop"][index] }
                    }
                    Controls.LiquidActionButton {
                        text: root.language === "en" ? "中文" : "English"
                        onClicked: root.language = root.language === "en" ? "zh" : "en"
                    }
                    Controls.LiquidActionButton {
                        text: root.themeMode === "dark" ? root.tr("Light", "浅色") : root.tr("Dark", "深色")
                        onClicked: root.themeMode = root.themeMode === "dark" ? "light" : "dark"
                    }
                }

                Loader {
                    id: content
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    sourceComponent: root.selected ? componentPage : overviewPage
                }
            }
        }
    }

    Component {
        id: overviewPage
        OverviewPage {
            language: root.language
            onComponentSelected: function(id) { root.select(id) }
        }
    }
    Component {
        id: componentPage
        ComponentPage { entry: root.selected; language: root.language }
    }
}
