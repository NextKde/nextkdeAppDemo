import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtCore
import Qt.labs.folderlistmodel
import "../foundation" as Foundation

// In-window file selection shares the application's dialog, fields and rows.
// Selection only returns URLs; reading, import and export remain host operations.
LiquidDialog {
    id: root
    property string mode: "openFile" // openFile, openFiles, folder, saveFile
    property url currentFolder: toUrl(StandardPaths.writableLocation(StandardPaths.HomeLocation))
    property url selectedFile
    property url selectedFolder
    property var selectedFiles: []
    property var nameFilters: ["*"]
    property string defaultSuffix: ""
    property string locationPlaceholder: qsTr("Folder location")
    property string fileNamePlaceholder: qsTr("File name")
    property string unavailableText: qsTr("Folder unavailable")
    property string emptyText: qsTr("No matching files")
    property string overwriteTitle: qsTr("Replace this file?")
    property string overwriteText: qsTr("A file with this name already exists.")
    property string overwriteAcceptText: qsTr("Replace")
    property var selection: []
    property int selectionAnchor: -1
    readonly property bool loading: files.status === FolderListModel.Loading
    width: Math.min(640, parent ? parent.width - 40 : 640)
    height: Math.min(520, parent ? parent.height - 40 : 520)
    standardButtons: Dialog.NoButton
    acceptText: mode === "saveFile" ? qsTr("Save") : qsTr("Open")
    rejectText: qsTr("Cancel")
    function toUrl(path) {
        if (String(path).startsWith("file:")) return path
        return "file://" + String(path).split("/").map(encodeURIComponent).join("/")
    }
    function displayPath(url) { return decodeURIComponent(String(url).replace(/^file:\/\//, "")) }
    function navigate(url) {
        currentFolder = toUrl(url); selection = []; selectionAnchor = -1; fileList.currentIndex = -1
    }
    function urlForName(name) { return String(currentFolder).replace(/\/$/, "") + "/" + encodeURIComponent(name) }
    function choose(index, modifiers) {
        fileList.forceActiveFocus()
        const url = String(files.get(index, "fileUrl")), directory = files.get(index, "fileIsDir")
        fileList.currentIndex = index
        if (directory) { selection = [url]; selectionAnchor = index; return }
        if (mode === "folder") return
        if (mode === "saveFile") { saveName.text = files.get(index, "fileName"); selection = [url]; return }
        if (mode === "openFiles" && (modifiers & Qt.ShiftModifier) && selectionAnchor >= 0) {
            let next = []
            for (let i = Math.min(index, selectionAnchor); i <= Math.max(index, selectionAnchor); ++i)
                if (!files.get(i, "fileIsDir")) next.push(String(files.get(i, "fileUrl")))
            selection = next
        } else if (mode === "openFiles" && (modifiers & (Qt.ControlModifier | Qt.MetaModifier))) {
            let next = selection.slice(), at = next.indexOf(url)
            if (at >= 0) next.splice(at, 1); else next.push(url)
            selection = next; selectionAnchor = index
        } else { selection = [url]; selectionAnchor = index }
    }
    function submit() {
        if (loading || files.status !== FolderListModel.Ready) return
        if (mode === "folder") { selectedFolder = selection.length ? selection[0] : currentFolder; accept(); return }
        if (mode === "saveFile") {
            let name = saveName.text.trim()
            if (!name || /[\\/]/.test(name) || name === "." || name === "..") return
            if (defaultSuffix && !name.toLowerCase().endsWith("." + defaultSuffix.toLowerCase())) name += "." + defaultSuffix
            selectedFile = urlForName(name)
            for (let i = 0; i < files.count; ++i) {
                if (files.get(i, "fileName") === name) {
                    if (files.get(i, "fileIsDir")) { navigate(files.get(i, "fileUrl")); return }
                    overwrite.open(); return
                }
            }
            accept(); return
        }
        if (!selection.length) return
        const selectedIndex = fileList.currentIndex
        if (selection.length === 1 && selectedIndex >= 0 && files.get(selectedIndex, "fileIsDir")) { navigate(selection[0]); return }
        selectedFiles = selection.slice(); selectedFile = selectedFiles[0]; accept()
    }
    onAboutToShow: {
        selection = []; selectionAnchor = -1
        if (mode === "saveFile" && String(selectedFile)) saveName.text = displayPath(selectedFile).split("/").pop()
    }
    Shortcut { sequence: "Ctrl+L"; enabled: root.visible; onActivated: { location.forceActiveFocus(); location.selectAll() } }
    FolderListModel {
        id: files
        folder: root.currentFolder
        nameFilters: root.nameFilters
        showFiles: root.mode !== "folder"
        showDirs: true; showDirsFirst: true; showDotAndDotDot: false; showHidden: false
        sortField: FolderListModel.Name
    }
    contentItem: ColumnLayout {
        spacing: 12
        RowLayout {
            Layout.fillWidth: true; spacing: 6
            LiquidActionButton { text: "↑"; materialForm: true; implicitWidth: 30; Accessible.name: qsTr("Parent folder"); enabled: String(files.parentFolder) !== String(root.currentFolder); onClicked: root.navigate(files.parentFolder) }
            LiquidTextField { id: location; Layout.fillWidth: true; materialForm: true; text: root.displayPath(root.currentFolder); placeholderText: root.locationPlaceholder; Accessible.name: root.locationPlaceholder; onAccepted: if (!inputMethodComposing) root.navigate(text.trim()) }
        }
        ListView {
            id: fileList
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: 2
            model: files; activeFocusOnTab: true
            keyNavigationEnabled: false
            Keys.onPressed: function(event) {
                if ([Qt.Key_Up, Qt.Key_Down, Qt.Key_Home, Qt.Key_End].indexOf(event.key) >= 0 && files.count) {
                    const next = event.key === Qt.Key_Home ? 0 : event.key === Qt.Key_End ? files.count - 1 : Math.max(0, Math.min(files.count - 1, currentIndex + (event.key === Qt.Key_Down ? 1 : -1)))
                    root.choose(next, event.modifiers); positionViewAtIndex(next, ListView.Contain); event.accepted = true
                } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) { root.submit(); event.accepted = true }
            }
            delegate: ItemDelegate {
                id: row
                required property int index
                required property string fileName
                required property url fileUrl
                required property bool fileIsDir
                width: ListView.view.width; height: 34
                highlighted: root.selection.indexOf(String(fileUrl)) >= 0
                background: Rectangle { radius: 6; color: row.highlighted || row.hovered ? Foundation.AppTheme.controlBackground : "transparent" }
                contentItem: RowLayout {
                    spacing: 8
                    VectorIcon { name: row.fileIsDir ? "folder" : "album"; size: 16; color: Foundation.AppTheme.mutedText }
                    Label { Layout.fillWidth: true; text: row.fileName; textFormat: Text.PlainText; elide: Text.ElideMiddle; color: Foundation.AppTheme.text; font.pixelSize: 13 }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: function(mouse) { root.choose(row.index, mouse.modifiers) }
                    onDoubleClicked: { if (row.fileIsDir) root.navigate(row.fileUrl); else { root.choose(row.index, Qt.NoModifier); root.submit() } }
                }
                Accessible.name: fileName; Accessible.role: Accessible.ListItem; Accessible.selected: highlighted
                Accessible.onPressAction: root.choose(index, Qt.NoModifier)
            }
            ScrollBar.vertical: ScrollBar {}
            Label { anchors.centerIn: parent; width: parent.width; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.Wrap; visible: files.count === 0; text: root.loading ? "…" : files.status === FolderListModel.Null ? root.unavailableText : root.emptyText; color: Foundation.AppTheme.mutedText; font.pixelSize: 13 }
        }
        LiquidTextField { id: saveName; visible: root.mode === "saveFile"; Layout.fillWidth: true; materialForm: true; placeholderText: root.fileNamePlaceholder; Accessible.name: root.fileNamePlaceholder; onAccepted: if (!inputMethodComposing) root.submit() }
    }
    footer: DialogButtonBox {
        buttonLayout: DialogButtonBox.MacLayout
        padding: 24; topPadding: 12; spacing: 8; alignment: Qt.AlignRight; background: Item {}
        LiquidDialogButton { text: root.rejectText; onClicked: root.reject() }
        LiquidDialogButton { text: root.acceptText; primaryAction: true; enabled: files.status === FolderListModel.Ready && (root.mode === "folder" || root.mode === "saveFile" && !!saveName.text.trim() || root.selection.length > 0); onClicked: root.submit() }
    }
    LiquidDialog {
        id: overwrite; sourceItem: root.sourceItem
        title: root.overwriteTitle; acceptText: root.overwriteAcceptText; rejectText: root.rejectText
        standardButtons: Dialog.Ok | Dialog.Cancel
        contentItem: Label { width: parent.width; text: root.overwriteText + "\n" + root.displayPath(root.selectedFile); wrapMode: Text.Wrap; color: Foundation.AppTheme.text }
        onAccepted: root.accept()
    }
}
