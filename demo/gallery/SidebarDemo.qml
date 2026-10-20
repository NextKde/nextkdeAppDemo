import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Kos/Ui/foundation" as Ui
import "../Kos/Ui/controls" as Controls

Item {
    id: root
    implicitWidth: 1040
    implicitHeight: 700
    property string language: "en"
    property real sidebarOpacity: 0.95
    property real committedOpacity: 0.95
    property bool useWindowScene: false
    property bool blurEnabled: true
    property int sceneIndex: 0
    property real sceneShift: 0
    property int currentSection: 0
    property string selectedId: ""
    readonly property color ink: "#263244"
    readonly property color mutedInk: "#627086"
    readonly property var sections: [
        { en: "All files", zh: "全部文件" },
        { en: "Favorites", zh: "收藏" },
        { en: "Recent", zh: "最近使用" }
    ]
    readonly property var documents: [
        { id: "aurora", en: "Aurora UI", zh: "Aurora 界面", kind: "Design", kindZh: "设计", color: "#607bd1", favorite: true, recent: true,
          detail: "Layouts, typography and shared components.", detailZh: "布局、字体和共享组件。" },
        { id: "field", en: "Field notes", zh: "随手记录", kind: "Notes", kindZh: "笔记", color: "#599e8c", favorite: false, recent: true,
          detail: "Small observations worth keeping.", detailZh: "值得留下的日常观察。" },
        { id: "coast", en: "Coastal light", zh: "海岸光影", kind: "Collection", kindZh: "合集", color: "#c08b65", favorite: true, recent: false,
          detail: "A collection of colour and material references.", detailZh: "颜色与材质参考合集。" },
        { id: "release", en: "Release checklist", zh: "发布清单", kind: "Document", kindZh: "文档", color: "#9a7bb6", favorite: false, recent: false,
          detail: "The next steps for the current workspace.", detailZh: "当前工作区接下来要完成的事情。" }
    ]
    readonly property var visibleDocuments: {
        const query = search.text.trim().toLowerCase()
        return documents.filter(document =>
            (currentSection === 0 || (currentSection === 1 ? document.favorite : document.recent))
            && [document.en, document.zh, document.kind, document.kindZh].join(" ").toLowerCase().includes(query))
    }
    readonly property var selectedDocument: documents.find(document => document.id === selectedId) || null
    onCurrentSectionChanged: selectedId = ""

    function tr(en, zh) { return language === "zh" ? zh : en }
    function resetMaterial() {
        sidebarOpacity = 0.95
        committedOpacity = 0.95
        useWindowScene = false
        blurEnabled = true
        sceneIndex = 0
        sceneShift = 0
    }

    Binding { target: Ui.AppTheme; property: "appearanceMode"; value: "light" }
    Shortcut { sequence: "Ctrl+K"; onActivated: { search.forceActiveFocus(); search.selectAll() } }

    // This sibling scene is the entire optical source. It contains no controls.
    Item {
        id: scene
        anchors.fill: parent
        visible: root.useWindowScene
        clip: true
        Rectangle { anchors.fill: parent; color: "#27424b" }
        Image {
            width: scene.width + 160
            height: scene.height
            x: -80 + root.sceneShift
            fillMode: Image.PreserveAspectCrop
            source: !root.useWindowScene ? "" : root.sceneIndex === 0
                ? Qt.resolvedUrl("../assets/forest.png")
                : Qt.resolvedUrl("../assets/underwater.png")
            Behavior on x { NumberAnimation { duration: Ui.AppTheme.reduceMotion ? 0 : 500; easing.type: Easing.InOutCubic } }
        }
    }
    Controls.LiquidBackdrop {
        id: sceneBackdrop
        sourceItem: scene
        active: root.useWindowScene
        registerAsDefault: false
        resolutionScale: root.blurEnabled ? 0.4 : 1
    }

    Item {
        id: sidebar
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 16 }
        width: 244

        Controls.LiquidSurface {
            anchors.fill: parent
            radius: 20
            backdrop: root.useWindowScene ? sceneBackdrop : null
            // Apply opacity to the material as a group, without fading its content.
            layer.enabled: true
            opacity: root.sidebarOpacity
            darkAppearance: true
            tintColor: "#14212c"
            tintStrength: root.useWindowScene ? 0.16 : 1
            readability: 0.28
            blurStrength: root.blurEnabled ? 1.25 : 0
            refractionStrength: 2.5
            magnification: 1.012
            edgeWidth: 14
            reflectionStrength: 0.5
            rimColor: Qt.rgba(1, 1, 1, 0.22)
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            ColumnLayout {
                Layout.topMargin: 6
                Layout.bottomMargin: 6
                spacing: 5
                Label { text: "Studio"; color: "#ffffff"; font.pixelSize: 22; font.weight: Font.DemiBold }
                Label { text: root.tr("Personal workspace", "个人工作区"); color: "#d6e0e8"; font.pixelSize: 12 }
            }
            Controls.LiquidTextField {
                id: search
                Layout.fillWidth: true
                implicitHeight: 36
                materialForm: false
                liquidFinish: true
                backdrop: root.useWindowScene ? sceneBackdrop : null
                darkAppearance: true
                glassColor: Qt.rgba(1, 1, 1, 0.08)
                textColor: "#ffffff"
                mutedTextColor: "#d6e0e8"
                outlineColor: Qt.rgba(1, 1, 1, 0.14)
                focusedOutlineColor: "#a3c7ff"
                cornerRadius: 10
                blurStrength: root.blurEnabled ? 1.25 : 0
                readability: 0.30
                magnification: 1.015
                scale: 1
                font.pixelSize: 13
                placeholderText: root.tr("Search files", "搜索文件")
                Accessible.name: placeholderText
            }
            Label {
                Layout.topMargin: 8
                text: root.tr("WORKSPACE", "工作区")
                color: "#c8d5e0"
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Repeater {
                    model: root.sections
                    delegate: Button {
                        id: destination
                        required property var modelData
                        required property int index
                        Layout.fillWidth: true
                        implicitHeight: 40
                        leftPadding: 12
                        rightPadding: 12
                        checkable: true
                        autoExclusive: true
                        checked: root.currentSection === index
                        hoverEnabled: true
                        text: root.tr(modelData.en, modelData.zh)
                        onClicked: root.currentSection = index
                        contentItem: Label {
                            text: destination.text
                            color: "#f5f8fc"
                            font.pixelSize: 13
                            font.weight: destination.checked ? Font.DemiBold : Font.Normal
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                        }
                        background: Rectangle {
                            radius: 10
                            color: Qt.rgba(1, 1, 1, destination.down ? 0.24
                                : destination.checked ? 0.17 : destination.hovered ? 0.08 : 0)
                            border.width: destination.activeFocus ? 2 : 1
                            border.color: destination.activeFocus ? "#a3c7ff"
                                : Qt.rgba(1, 1, 1, destination.checked ? 0.13 : 0)
                            Behavior on color { ColorAnimation { duration: Ui.AppTheme.motionFast } }
                        }
                    }
                }
            }
            Item { Layout.fillHeight: true }
            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Qt.rgba(1, 1, 1, 0.13) }
            RowLayout {
                spacing: 10
                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 12
                    color: Qt.rgba(1, 1, 1, 0.15)
                    Label { anchors.centerIn: parent; text: "A"; color: "white"; font.pixelSize: 14; font.weight: Font.DemiBold }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 3
                    Label { text: "Amao"; color: "#ffffff"; font.pixelSize: 13; font.weight: Font.DemiBold }
                    Label { text: root.tr("Local workspace", "本地工作区"); color: "#d6e0e8"; font.pixelSize: 11 }
                }
            }
        }
    }

    Rectangle {
        anchors { left: sidebar.right; leftMargin: 12; right: parent.right; top: parent.top; bottom: parent.bottom; rightMargin: 16; topMargin: 16; bottomMargin: 16 }
        radius: 20
        color: "#f8f9fc"
        border.color: "#e2e7ee"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 26
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: root.tr(root.sections[root.currentSection].en, root.sections[root.currentSection].zh)
                    color: root.ink
                    font.pixelSize: 26
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Controls.LiquidActionButton {
                    text: root.language === "en" ? "中文" : "English"
                    secondary: true
                    onClicked: root.language = root.language === "en" ? "zh" : "en"
                }
            }
            Label {
                text: root.visibleDocuments.length + root.tr(" files in your workspace", " 个文件")
                color: root.mutedInk
                font.pixelSize: 13
            }
            ListView {
                id: fileList
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumHeight: 72
                clip: true
                spacing: 6
                boundsBehavior: Flickable.StopAtBounds
                model: root.visibleDocuments
                ScrollBar.vertical: ScrollBar {}
                delegate: Button {
                    id: fileRow
                    required property var modelData
                    readonly property color accent: modelData.color
                    width: fileList.width
                    height: 64
                    padding: 12
                    hoverEnabled: true
                    checkable: true
                    autoExclusive: true
                    checked: root.selectedId === modelData.id
                    text: root.tr(modelData.en, modelData.zh)
                    onClicked: root.selectedId = modelData.id
                    contentItem: RowLayout {
                        spacing: 12
                        Rectangle {
                            implicitWidth: 32
                            implicitHeight: 36
                            radius: 8
                            color: Qt.rgba(fileRow.accent.r, fileRow.accent.g, fileRow.accent.b, 0.12)
                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                Repeater {
                                    model: 3
                                    Rectangle { width: 14; height: 2; radius: 1; color: fileRow.accent }
                                }
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Label { Layout.fillWidth: true; text: fileRow.text; color: root.ink; font.pixelSize: 13; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Label { text: root.tr(fileRow.modelData.kind, fileRow.modelData.kindZh); color: root.mutedInk; font.pixelSize: 11 }
                        }
                        Label { visible: fileRow.checked; text: root.tr("Selected", "已选择"); color: "#5069af"; font.pixelSize: 11 }
                    }
                    background: Rectangle {
                        radius: 12
                        color: fileRow.down ? "#e4eafa" : fileRow.checked ? "#edf1fb" : fileRow.hovered ? "#f0f3f8" : "#ffffff"
                        border.color: fileRow.activeFocus ? "#7088ce" : fileRow.checked ? "#ccd7f1" : "#e7ebf1"
                        border.width: fileRow.activeFocus ? 2 : 1
                    }
                }
                Label {
                    anchors.centerIn: parent
                    visible: fileList.count === 0
                    text: root.tr("No matching files", "没有匹配的文件")
                    color: root.mutedInk
                }
            }
            Label {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                text: root.selectedDocument
                    ? root.tr(root.selectedDocument.detail, root.selectedDocument.detailZh)
                    : root.tr("Choose a file to see its description.", "选择文件查看说明。")
                color: root.mutedInk
                font.pixelSize: 12
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: "#e1e6ee" }
            RowLayout {
                Layout.fillWidth: true
                Label { Layout.fillWidth: true; text: root.tr("Sidebar opacity", "侧栏背景不透明度"); color: root.ink; font.pixelSize: 13; font.weight: Font.DemiBold }
                Label { text: root.sidebarOpacity.toFixed(2); color: root.ink; font.pixelSize: 13; font.family: "monospace" }
            }
            Controls.LiquidSlider {
                Layout.fillWidth: true
                implicitHeight: 28
                materialForm: false
                darkAppearance: false
                value: root.sidebarOpacity
                accentColor: "#627dcd"
                trackColor: "#dce3ef"
                thumbBorderColor: "#8a9bbd"
                Accessible.name: root.tr("Sidebar background opacity", "侧栏背景不透明度")
                onPreviewChanged: function(value) { root.sidebarOpacity = value }
                onCommitRequested: function(value) { root.sidebarOpacity = value; root.committedOpacity = value }
                onCanceled: root.sidebarOpacity = root.committedOpacity
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Controls.LiquidCheckBox {
                    text: root.tr("Window scene", "窗口内背景")
                    checked: root.useWindowScene
                    onToggled: root.useWindowScene = checked
                }
                Controls.LiquidCheckBox {
                    text: root.tr("Blur", "模糊")
                    checked: root.useWindowScene && root.blurEnabled
                    enabled: root.useWindowScene
                    onToggled: root.blurEnabled = checked
                }
                Item { Layout.fillWidth: true }
                Controls.LiquidActionButton { text: root.tr("Reset", "重置"); secondary: true; onClicked: root.resetMaterial() }
            }
            Label {
                Layout.fillWidth: true
                text: root.useWindowScene
                    ? root.tr("Background drawn inside this window.", "当前背景由窗口内部绘制。")
                    : root.tr("Desktop transparency without background blur.", "当前透出桌面，不对桌面做模糊。")
                color: root.mutedInk
                font.pixelSize: 11
                wrapMode: Text.WordWrap
            }
            RowLayout {
                Layout.fillWidth: true
                visible: root.useWindowScene
                spacing: 8
                Controls.LiquidActionButton {
                    text: root.tr("Change scene", "切换背景")
                    secondary: true
                    onClicked: root.sceneIndex = (root.sceneIndex + 1) % 2
                }
                Controls.LiquidActionButton {
                    text: root.tr("Move scene", "移动背景")
                    secondary: true
                    onClicked: root.sceneShift = root.sceneShift === 0 ? 80 : root.sceneShift > 0 ? -80 : 0
                }
                Item { Layout.fillWidth: true }
            }
        }
    }
}
