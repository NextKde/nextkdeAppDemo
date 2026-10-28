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
    readonly property alias toolTipBackdrop: helpBackdrop
    property string language: Quickshell.env("GALLERY_LANGUAGE") === "zh" ? "zh" : "en"
    property string themeMode: Quickshell.env("GALLERY_THEME") === "dark" ? "dark" : "light"
    property string backgroundMode: "gradient"
    property string currentId: "overview-intro"
    readonly property var selected: Catalog.find(currentId)
    readonly property var filteredEntries: Catalog.filter(search.text)
    font.pixelSize: 13
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
    Binding { target: Ui.AppTheme; property: "compactDesign"; value: true }

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
            id: sidebar
            Layout.preferredWidth: navigationTokens.sidebarWidth
            Layout.minimumWidth: navigationTokens.sidebarWidth
            Layout.maximumWidth: navigationTokens.sidebarWidth
            Layout.fillHeight: true
            padding: 0
            background: Rectangle {
                color: navigationTokens.secondaryFill
                Rectangle {
                    anchors.right: parent.right
                    width: 1; height: parent.height
                    color: navigationTokens.separator
                }
            }

            Controls.LiquidBackdrop {
                id: searchBackdrop
                sourceItem: sidebar.background
                registerAsDefault: false
                active: !Ui.AppTheme.reduceTransparency
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
                    specificationForm: Ui.AppTheme.reduceTransparency
                    materialForm: false
                    liquidFinish: !Ui.AppTheme.reduceTransparency
                    liquidIntensity: "light"
                    backdrop: searchBackdrop
                    cornerRadius: height / 2
                    focusedOutlineColor: navigationTokens.focusAccent
                    textColor: Ui.AppTheme.reduceTransparency
                        ? (Ui.AppTheme.dark ? Ui.AppTheme.text : "#000000")
                        : (Ui.AppTheme.dark ? "#D6D6DA" : "#55555A")
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
                    spacing: 0
                    model: root.filteredEntries
                    delegate: Column {
                        id: destination
                        required property var modelData
                        required property int index
                        width: navigation.width
                        Label {
                            width: parent.width
                            visible: destination.index === 0 || root.filteredEntries[destination.index - 1].group !== destination.modelData.group
                            topPadding: 12
                            bottomPadding: 4
                            text: Catalog.groupTitle(destination.modelData.group, root.language)
                            color: navigationTokens.labelSecondary
                            font.pixelSize: navigationTokens.captionSize
                            font.weight: Font.DemiBold
                        }
                        Controls.LiquidNavigationButton {
                            width: parent.width
                            specificationForm: true
                            specificationFontSize: 12
                            specificationSelectedVerticalInset: 2
                            specificationSelectedFillColor: Ui.AppTheme.accent
                            specificationSelectedTextColor: "#ffffff"
                            specificationHoverFillColor: Ui.AppTheme.dark ? Qt.rgba(1, 1, 1, .08) : "#dbdbdd"
                            implicitHeight: navigationTokens.navigationHeight
                            text: Catalog.title(destination.modelData, root.language)
                            checked: root.currentId === destination.modelData.id
                            font.weight: Font.Medium
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
                    specificationFontSize: 12
                    specificationHoverFillColor: Ui.AppTheme.dark ? Qt.rgba(1, 1, 1, .08) : "#dbdbdd"
                    Layout.preferredHeight: navigationTokens.navigationHeight
                    checkable: false
                    font.weight: Font.Medium
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
            background: Rectangle { color: navigationTokens.contentFill }
            contentItem: Item {
                clip: true
                Item {
                    id: contentScene
                    anchors.fill: parent
                    Rectangle { anchors.fill: parent; color: navigationTokens.contentFill }
                    Loader {
                        id: content
                        anchors.fill: parent
                        anchors.leftMargin: navigationTokens.pageInset
                        anchors.rightMargin: navigationTokens.pageInset
                        anchors.bottomMargin: navigationTokens.pageInset
                        sourceComponent: !root.selected ? overviewPage
                        : root.selected.id === "overview-intro" ? introPage
                        : componentPage
                    }
                }
                Controls.LiquidBackdrop {
                    id: mainBackdrop
                    sourceItem: contentScene
                    registerAsDefault: false
                    active: floatingRegion.liquidActive
                    blur: navigationTokens.mainBackdropBlur
                }
                Controls.LiquidBackdrop {
                    id: helpBackdrop
                    sourceItem: contentScene
                    registerAsDefault: false
                    active: !Ui.AppTheme.reduceTransparency
                }
                Controls.LiquidBackdrop {
                    id: toolbarControlsBackdrop
                    sourceItem: headerMaterialLayer
                    registerAsDefault: false
                    active: !Ui.AppTheme.reduceTransparency
                }
                Pane {
                    id: floatingRegion
                    // Only raise the material once actual page content passes underneath.
                    readonly property bool raised: content.item !== null
                        && content.item.scrollOffset > navigationTokens.sectionGap
                    readonly property bool liquidActive: raised && !Ui.AppTheme.reduceTransparency
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    z: 10
                    height: navigationTokens.windowChromeHeight + navigationTokens.pageInset + navigationTokens.toolbarHeight
                    padding: 0
                    // Original full-width rectangle: no inset, rounded island or decoration offset.
                    background: Item {
                        Item {
                            id: headerMaterialLayer
                            anchors.fill: parent
                            Rectangle {
                                anchors.fill: parent
                                visible: !floatingRegion.liquidActive
                                color: navigationTokens.contentFill
                            }
                            Controls.LiquidSurface {
                                anchors.fill: parent
                                visible: floatingRegion.liquidActive
                                layer.enabled: true
                                opacity: navigationTokens.mainMaterialOpacity
                                adaptiveGlass: true
                                fullHighlight: true
                                backdrop: mainBackdrop
                                radius: 0
                                blurStrength: 0
                                refractionStrength: navigationTokens.toolbarOptics.refraction
                                magnification: navigationTokens.toolbarOptics.magnification
                                reflectionStrength: navigationTokens.toolbarOptics.reflection
                            }
                        }
                    }
                    contentItem: ColumnLayout {
                        spacing: 0
                        // Preserve the original window-control coordinates for KWin decoration coverage.
                        GalleryWindowChrome {
                            Layout.fillWidth: true
                            Layout.preferredHeight: navigationTokens.windowChromeHeight
                            targetWindow: root.targetWindow
                        }
                        Pane {
                            Layout.fillWidth: true
                            Layout.preferredHeight: navigationTokens.toolbarHeight
                            Layout.leftMargin: navigationTokens.pageInset
                            Layout.rightMargin: navigationTokens.pageInset
                            Layout.topMargin: navigationTokens.pageInset
                            padding: navigationTokens.gap
                            background: Item {}
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
                                    visible: root.currentId !== "settings"
                                    Layout.preferredWidth: 140
                                    Layout.preferredHeight: navigationTokens.controlHeight
                                    Layout.maximumHeight: navigationTokens.controlHeight
                                    Layout.alignment: Qt.AlignVCenter
                                    appearanceMode: root.themeMode
                                    model: root.language === "zh" ? ["示例：渐变", "示例：对比", "示例：无背景"] : ["Example: Gradient", "Example: Contrast", "Example: None"]
                                    currentIndex: ["gradient", "contrast", "desktop"].indexOf(root.backgroundMode)
                                    materialForm: Ui.AppTheme.reduceTransparency
                                    liquidIntensity: "light"
                                    backdrop: toolbarControlsBackdrop
                                    cornerRadius: height / 2
                                    focusRingColor: navigationTokens.focusAccent
                                    textColor: Ui.AppTheme.reduceTransparency
                                        ? (Ui.AppTheme.dark ? Ui.AppTheme.text : "#000000")
                                        : (Ui.AppTheme.dark ? "#D6D6DA" : "#55555A")
                                    mutedTextColor: Ui.AppTheme.withAlpha(Ui.AppTheme.text, 0.82)
                                    onActivated: function(index) { root.backgroundMode = ["gradient", "contrast", "desktop"][index] }
                                }
                                RowLayout {
                                    spacing: navigationTokens.toolbarGroupGap
                                    Layout.alignment: Qt.AlignVCenter
                                    Controls.LiquidActionButton {
                                        materialForm: Ui.AppTheme.reduceTransparency
                                        liquidIntensity: "light"
                                        backdrop: toolbarControlsBackdrop
                                        scale: 1
                                        cornerRadius: height / 2
                                        surfaceColor: navigationTokens.plainFill
                                        focusRingColor: navigationTokens.focusAccent
                                        Layout.preferredHeight: navigationTokens.controlHeight
                                        Layout.maximumHeight: navigationTokens.controlHeight
                                        font.pixelSize: navigationTokens.searchFontSize
                                        leftPadding: navigationTokens.sidebarSpacing
                                        rightPadding: navigationTokens.sidebarSpacing
                                        text: root.language === "en" ? "中文" : "English"
                                        onClicked: root.language = root.language === "en" ? "zh" : "en"
                                    }
                                    Controls.LiquidActionButton {
                                        materialForm: Ui.AppTheme.reduceTransparency
                                        liquidIntensity: "light"
                                        backdrop: toolbarControlsBackdrop
                                        scale: 1
                                        cornerRadius: height / 2
                                        surfaceColor: navigationTokens.plainFill
                                        focusRingColor: navigationTokens.focusAccent
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
                    }
                }
            }
        }
    }

    Component {
        id: overviewPage
        OverviewPage {
            toolbarScrollInset: floatingRegion.height + navigationTokens.sectionGap
            language: root.language
            onComponentSelected: function(id) { root.select(id) }
        }
    }
    Component {
        id: introPage
        IntroPage { language: root.language; toolbarScrollInset: floatingRegion.height + navigationTokens.sectionGap }
    }
    Component {
        id: componentPage
        ComponentPage { entry: root.selected; language: root.language; backgroundMode: root.backgroundMode; toolbarScrollInset: floatingRegion.height + navigationTokens.sectionGap }
    }
}
