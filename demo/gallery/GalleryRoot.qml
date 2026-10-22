import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls
import "ComponentCatalog.mjs" as Catalog
import "components"

Pane {
    id: root

    required property var targetWindow
    property string language: Quickshell.env("GALLERY_LANGUAGE") === "zh" ? "zh" : "en"
    property string themeMode: Quickshell.env("GALLERY_THEME") === "dark" ? "dark" : "light"
    property string backgroundMode: "gradient"
    property string currentId: "overview"
    readonly property var selected: Catalog.find(currentId)
    readonly property var filteredEntries: Catalog.filter(search.text)
    padding: 0
    MaterialSpecTokens { id: navigationTokens; dark: Ui.AppTheme.dark }
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
        spacing: 0

        Pane {
            Layout.preferredWidth: navigationTokens.sidebarWidth
            Layout.minimumWidth: navigationTokens.sidebarWidth
            Layout.maximumWidth: navigationTokens.sidebarWidth
            Layout.fillHeight: true
            padding: 0
            background: Rectangle {
                color: Ui.AppTheme.dark ? "#242426" : "#f2f2f4"
                Rectangle {
                    anchors.right: parent.right
                    width: 1; height: parent.height
                    color: Ui.AppTheme.dark ? "#343436" : "#dedee0"
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: navigationTokens.sidebarPadding
                spacing: navigationTokens.sidebarSpacing

                Label {
                    text: "NextKde UI"
                    color: navigationTokens.labelPrimary
                    font.pixelSize: navigationTokens.titleSize
                    font.weight: Font.DemiBold
                }
                Label {
                    text: root.tr("Component gallery", "组件示例库")
                    color: navigationTokens.labelSecondary
                    font.pixelSize: navigationTokens.captionSize
                }
                Controls.LiquidTextField {
                    materialForm: false
                    liquidFinish: true
                    liquidIntensity: "strong"
                    cornerRadius: height / 2
                    textColor: navigationTokens.labelPrimary
                    mutedTextColor: navigationTokens.labelTertiary
                    font.pixelSize: navigationTokens.searchFontSize
                    font.weight: Font.Normal
                    leftPadding: navigationTokens.searchInset + navigationTokens.searchIconSize + navigationTokens.searchIconGap
                    rightPadding: searchShortcut.visible
                        ? searchShortcut.implicitWidth + navigationTokens.searchInset + navigationTokens.searchIconGap
                        : navigationTokens.searchInset
                    id: search
                    Layout.fillWidth: true
                    Layout.preferredHeight: navigationTokens.searchHeight
                    placeholderText: root.tr("Search", "搜索")
                    Accessible.name: root.tr("Search components", "搜索组件")
                    Controls.VectorIcon {
                        x: navigationTokens.searchInset
                        anchors.verticalCenter: parent.verticalCenter
                        name: "search"
                        size: navigationTokens.searchIconSize
                        color: navigationTokens.labelSecondary
                    }
                    Label {
                        id: searchShortcut
                        anchors.right: parent.right
                        anchors.rightMargin: navigationTokens.searchInset
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Ctrl+K"
                        visible: search.text.length === 0 && !search.activeFocus
                        font.pixelSize: navigationTokens.captionSize
                        font.weight: Font.Normal
                        color: navigationTokens.labelTertiary
                    }
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
                            color: navigationTokens.labelSecondary
                            font.pixelSize: navigationTokens.captionSize
                            font.weight: Font.DemiBold
                        }
                        Controls.LiquidNavigationButton {
                            width: parent.width
                            specificationForm: true
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
                        color: navigationTokens.labelSecondary
                        font.pixelSize: navigationTokens.bodySize
                    }
                }
                RowLayout {
                    Label {
                        Layout.fillWidth: true
                        text: root.tr("Reduce motion", "减少动态效果")
                        color: navigationTokens.labelPrimary
                        font.pixelSize: navigationTokens.bodySize
                    }
                    Switch {
                        checked: Ui.AppTheme.reduceMotion
                        Accessible.name: root.tr("Reduce motion", "减少动态效果")
                        onToggled: Ui.AppTheme.reduceMotion = checked
                    }
                }
                Controls.LiquidNavigationButton {
                    Layout.fillWidth: true
                    specificationForm: true
                    checkable: false
                    text: root.tr("Developer guide", "开发接入指南")
                    onClicked: Qt.openUrlExternally("file://" + Quickshell.shellDir + "/../docs/Components"
                        + (root.language === "zh" ? ".zh-CN" : "") + ".md")
                }
            }
        }

        Pane {
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 0
            background: Rectangle { color: Ui.AppTheme.dark ? "#1c1c1e" : "#ffffff" }
            contentItem: ColumnLayout {
                spacing: 0

                GalleryWindowChrome {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    targetWindow: root.targetWindow
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 20
                    clip: true

                Controls.LiquidBackdrop {
                    id: toolbarBackdrop
                    sourceItem: content
                    registerAsDefault: false
                    blur: navigationTokens.toolbarBlur
                }
                Pane {
                    id: galleryToolbar
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    z: 10
                    height: navigationTokens.toolbarHeight
                    padding: navigationTokens.gap
                    background: Controls.LiquidSurface {
                        backdrop: toolbarBackdrop
                        radius: 0
                        tintColor: Ui.AppTheme.dark ? "#1c1c1e" : "#ffffff"
                        tintStrength: .90
                        blurStrength: 0
                        readability: 0
                        refractionStrength: 0
                        magnification: 1
                        reflectionStrength: 0
                    }
                    contentItem: RowLayout {
                        spacing: navigationTokens.gap
                        Label {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: root.selected ? Catalog.title(root.selected, root.language)
                                : root.tr("Components", "组件")
                            color: Ui.AppTheme.text
                            font.pixelSize: navigationTokens.toolbarTitleSize
                            font.weight: Font.DemiBold
                            elide: Text.ElideRight
                        }
                        Controls.LiquidSelect {
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: navigationTokens.controlHeight
                            Layout.maximumHeight: navigationTokens.controlHeight
                            Layout.alignment: Qt.AlignVCenter
                            appearanceMode: root.themeMode
                            model: root.language === "zh" ? ["渐变背景", "对比背景", "透明桌面"] : ["Gradient", "Contrast", "Desktop"]
                            currentIndex: ["gradient", "contrast", "desktop"].indexOf(root.backgroundMode)
                            materialForm: false
                            textColor: Ui.AppTheme.text
                            mutedTextColor: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                            onActivated: function(index) { root.backgroundMode = ["gradient", "contrast", "desktop"][index] }
                        }
                        RowLayout {
                            spacing: navigationTokens.toolbarGroupGap
                            Layout.alignment: Qt.AlignVCenter
                            Controls.LiquidActionButton {
                                Layout.preferredHeight: navigationTokens.controlHeight
                                Layout.maximumHeight: navigationTokens.controlHeight
                                font.pixelSize: navigationTokens.searchFontSize
                                leftPadding: navigationTokens.sidebarSpacing
                                rightPadding: navigationTokens.sidebarSpacing
                                text: root.language === "en" ? "中文" : "English"
                                onClicked: root.language = root.language === "en" ? "zh" : "en"
                            }
                            Controls.LiquidActionButton {
                                Layout.preferredHeight: navigationTokens.controlHeight
                                Layout.maximumHeight: navigationTokens.controlHeight
                                font.pixelSize: navigationTokens.searchFontSize
                                leftPadding: navigationTokens.sidebarSpacing
                                rightPadding: navigationTokens.sidebarSpacing
                                text: root.themeMode === "dark" ? root.tr("Light", "浅色") : root.tr("Dark", "深色")
                                onClicked: root.themeMode = root.themeMode === "dark" ? "light" : "dark"
                            }
                        }
                    }
                }

                Loader {
                    id: content
                    anchors.fill: parent
                    sourceComponent: root.selected ? componentPage : overviewPage
                }
                }
            }
        }
    }

    Component {
        id: overviewPage
        OverviewPage {
            toolbarScrollInset: galleryToolbar.height + navigationTokens.sidebarPadding
            language: root.language
            onComponentSelected: function(id) { root.select(id) }
        }
    }
    Component {
        id: componentPage
        ComponentPage { entry: root.selected; language: root.language; backgroundMode: root.backgroundMode; toolbarScrollInset: galleryToolbar.height + navigationTokens.sidebarPadding }
    }
}
