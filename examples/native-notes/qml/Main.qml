import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kos.Ui

KosAppWindow {
    id: root
    required property var store
    visible: true
    title: qsTr("Kos Notes")
    property string selectedId: ""
    property string deletionTarget: ""
    property string deletionTitle: ""
    Binding { target: root.store; property: "editorOpen"; value: editor.visible }
    function confirmDeletion() {
        if (!store.deleteNote(deletionTarget)) return
        // Keep another selection intact; never jump to an unrelated row.
        if (selectedId === deletionTarget) selectedId = ""
        deleteDecision.close()
    }
    function undoDeletion() {
        const restoredId = store.undoDelete()
        if (restoredId) selectedId = restoredId
    }
    property bool quitting: false
    property bool recoveryChecked: false
    function checkRecovery() {
        if (recoveryChecked || store.state !== "ready") return
        recoveryChecked = true
        if (store.draft.version === 1) editor.recover(store.draft)
    }
    Component.onCompleted: checkRecovery()
    Connections { target: root.store; function onChanged() { root.checkRecovery() } }
    readonly property var filtered: store.notes.filter(note =>
        (note.title + " " + note.body).toLocaleLowerCase().indexOf(search.text.toLocaleLowerCase()) >= 0)
    readonly property var selected: store.notes.find(note => note.id === selectedId) || null
    function begin(note) {
        if (editor.visible) { editor.raise(); editor.requestActivate(); return }
        if (store.draftError) return
        editor.begin(note)
    }
    function finishQuit() { quitting = true; root.close() }
    onClosing: event => {
        if (!quitting && editor.visible) {
            event.accepted = false
            editor.quitAfterClose = true
            editor.close()
        }
    }
    Binding { target: AppTheme; property: "appearanceMode"; value: root.store.preferences.theme }
    Binding { target: AppTheme; property: "reduceTransparency"; value: root.store.preferences.reduced }
    Binding { target: AppTheme; property: "compactDesign"; value: true }
    Shortcut { sequences: [StandardKey.New]; enabled: root.store.state === "ready"; onActivated: root.begin(null) }
    Shortcut { sequences: [StandardKey.Find]; onActivated: search.forceActiveFocus() }
    Shortcut { sequences: [StandardKey.Quit]; context: Qt.ApplicationShortcut; onActivated: root.close() }

    Rectangle {
        id: scene
        anchors.fill: parent
        color: AppTheme.contentBackground
    ColumnLayout {
        anchors.fill: parent
        spacing: 0
        RowLayout {
            Layout.fillWidth: true; Layout.margins: 12; spacing: 8
            LiquidTextField {
                id: search
                objectName: "search"
                Layout.fillWidth: true
                materialForm: true
                implicitHeight: 28
                placeholderText: qsTr("Filter notes")
                Accessible.name: placeholderText
            }
            LiquidActionButton {
                materialForm: true; implicitHeight: 28
                objectName: "newNote"
                text: qsTr("New"); enabled: root.store.state === "ready"
                onClicked: root.begin(null)
            }
            LiquidActionButton {
                materialForm: true; implicitHeight: 28
                objectName: "taskExample"
                text: qsTr("Task demo")
                onClicked: taskDialog.open()
            }
            LiquidActionButton {
                materialForm: true; implicitHeight: 28
                objectName: "settingsButton"
                text: qsTr("Settings"); enabled: root.store.state === "ready"
                onClicked: preferences.openDraft()
            }
        }
        Label {
            Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
            visible: !!root.store.draftError; wrapMode: Text.Wrap; color: AppTheme.destructive
            text: qsTr("Recovery file unavailable. It is preserved; repair it before editing or explicitly discard it.")
        }
        LiquidActionButton {
            materialForm: true; visible: !!root.store.draftError && !editor.visible
            text: qsTr("Discard recovery file")
            onClicked: recoveryDecision.open()
        }
        RowLayout {
            Layout.fillWidth: true; Layout.leftMargin: 12; Layout.rightMargin: 12
            visible: root.store.canUndoDelete || !!root.store.deletionError
            Label {
                Layout.fillWidth: true; wrapMode: Text.Wrap; color: AppTheme.mutedText
                text: root.store.deletionError
                    ? qsTr("Delete or undo failed. Close the editor and resolve recovery/storage errors, then retry.")
                    : qsTr("Deleted. Undo lasts until the next successful deletion, reload or exit.")
            }
            LiquidActionButton {
                objectName: "undoDelete"
                materialForm: true; implicitHeight: 28
                text: qsTr("Undo delete")
                enabled: root.store.canUndoDelete && root.store.state === "ready"
                onClicked: root.undoDeletion()
            }
        }
        Item {
            Layout.fillWidth: true; Layout.fillHeight: true
            RowLayout {
                anchors.fill: parent; spacing: 0
                visible: root.store.state === "ready"
                // This is a content list, not a navigation glass sidebar.
                Rectangle {
                    Layout.preferredWidth: Math.min(280, root.width * 0.36)
                    Layout.fillHeight: true
                    color: AppTheme.contentSecondaryBackground
                    ListView {
                        id: list
                        objectName: "noteList"
                        anchors.fill: parent; anchors.margins: 8
                        clip: true; model: root.filtered
                        currentIndex: root.filtered.findIndex(note => note.id === root.selectedId)
                        // Only explicit user navigation changes the selected ID.
                        // Model replacement/filtering must not select a different note.
                        keyNavigationEnabled: false
                        activeFocusOnTab: true
                        function moveSelection(step) {
                            if (root.filtered.length === 0) return
                            const selectedIndex = root.filtered.findIndex(note => note.id === root.selectedId)
                            const nextIndex = selectedIndex < 0
                                ? (step > 0 ? 0 : root.filtered.length - 1)
                                : Math.max(0, Math.min(root.filtered.length - 1, selectedIndex + step))
                            root.selectedId = root.filtered[nextIndex].id
                            positionViewAtIndex(nextIndex, ListView.Contain)
                        }
                        Keys.onUpPressed: event => { moveSelection(-1); event.accepted = true }
                        Keys.onDownPressed: event => { moveSelection(1); event.accepted = true }
                        delegate: KosItemDelegate {
                            required property var modelData
                            width: ListView.view.width; height: 32
                            text: modelData.title
                            palette.text: AppTheme.text
                            palette.highlightedText: AppTheme.text
                            highlighted: root.selectedId === modelData.id
                            Accessible.name: modelData.title
                            onClicked: { root.selectedId = modelData.id; list.forceActiveFocus() }
                        }
                        ScrollBar.vertical: ScrollBar {}
                    }
                    Label {
                        anchors.centerIn: parent; width: parent.width - 24
                        visible: root.filtered.length === 0
                        text: search.text.length ? qsTr("No matching notes") : qsTr("No notes yet")
                        color: AppTheme.mutedText; wrapMode: Text.Wrap; horizontalAlignment: Text.AlignHCenter
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true; Layout.margins: 20
                    spacing: 12
                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            Layout.fillWidth: true
                            text: root.selected ? root.selected.title : qsTr("Select a note")
                            color: AppTheme.text; font.pixelSize: 22; font.bold: true; wrapMode: Text.Wrap
                            maximumLineCount: 3; elide: Text.ElideRight
                            textFormat: Text.PlainText
                        }
                        LiquidActionButton {
                            objectName: "editNote"
                            text: qsTr("Edit"); materialForm: true; implicitHeight: 28
                            enabled: !!root.selected
                            onClicked: root.begin(root.selected)
                        }
                    }
                    LiquidActionButton {
                        objectName: "deleteNote"
                        text: qsTr("Delete note…")
                        materialForm: true; implicitHeight: 28; destructive: true
                        enabled: !!root.selected
                        onClicked: {
                            root.deletionTarget = root.selected.id
                            root.deletionTitle = root.selected.title
                            deleteDecision.open()
                        }
                    }
                    ScrollView {
                        Layout.fillWidth: true; Layout.fillHeight: true
                        contentWidth: availableWidth
                        clip: true
                        TextArea {
                            text: root.selected ? root.selected.body : qsTr("Create a note or select one from the list.")
                            readOnly: true; selectByMouse: true; wrapMode: TextEdit.Wrap
                            textFormat: TextEdit.PlainText; color: AppTheme.text; font.pixelSize: 13
                            background: null
                            Accessible.name: qsTr("Note contents")
                        }
                    }
                }
            }
            KosEmptyState {
                anchors.fill: parent
                visible: root.store.state !== "ready"
                title: root.store.state === "loading" ? qsTr("Loading notes…") : qsTr("Could not load notes")
                description: root.store.error === "locked" ? qsTr("Another instance owns this data directory, or it cannot be locked. Close it or repair access, then Retry.")
                    : root.store.state === "failed" ? qsTr("The saved file is unreadable or invalid. Fix it and retry; it will not be overwritten.") : ""
                actionText: root.store.state === "failed" ? qsTr("Retry") : ""
                onActionTriggered: root.store.reload()
            }
        }
    }
    }
    LiquidDialog {
        id: recoveryDecision; parent: Overlay.overlay; anchors.centerIn: parent
        sourceItem: scene; title: qsTr("Discard recovery file?")
        footer: Control {
            padding: 24; topPadding: 12
            implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
            contentItem: RowLayout {
                Item { Layout.fillWidth: true }

            LiquidDialogButton { text: qsTr("Cancel"); onClicked: recoveryDecision.close() }
            LiquidDialogButton {
                text: qsTr("Discard"); destructive: true
                onClicked: { if (root.store.clearDraft()) recoveryDecision.close() }
            }

            }
        }
    }
    LiquidDialog {
        id: deleteDecision
        objectName: "deleteDecision"
        parent: Overlay.overlay; anchors.centerIn: parent
        width: Math.min(440, root.width - 32)
        sourceItem: scene
        title: qsTr("Delete note?")
        contentItem: ColumnLayout {
            Label {
                Layout.fillWidth: true; wrapMode: Text.Wrap; maximumLineCount: 3; elide: Text.ElideRight
                textFormat: Text.PlainText; text: root.deletionTitle; color: AppTheme.text
            }
            Label {
                Layout.fillWidth: true; wrapMode: Text.Wrap; color: AppTheme.mutedText
                text: editor.visible || root.store.draft.version === 1 || !!root.store.draftError
                    ? qsTr("Save or discard edits and close the editor first. Resolve any recovery-file error before deleting. Your draft is preserved.")
                    : root.store.deletionError
                    ? qsTr("Deletion failed. Check storage access and retry. The note and previous undo remain unchanged.")
                    : qsTr("Only the most recent deletion can be undone, until the next successful deletion, reload or exit.")
            }
        }
        footer: Control {
            padding: 24; topPadding: 12
            implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
            contentItem: RowLayout {
                spacing: 8
                Item { Layout.fillWidth: true }
                LiquidDialogButton { objectName: "cancelDelete"; text: qsTr("Cancel"); onClicked: deleteDecision.close() }
                LiquidDialogButton {
                    objectName: "confirmDelete"
                    text: qsTr("Delete"); destructive: true
                    enabled: !editor.visible && root.store.draft.version !== 1 && !root.store.draftError && root.store.state === "ready"
                    onClicked: root.confirmDeletion()
                }
            }
        }
    }
    TaskDemo { id: taskDialog; store: root.store; host: root; sourceItem: scene }
    EditorWindow { id: editor; store: root.store; host: root }
    Preferences { id: preferences; store: root.store; host: root; sourceItem: scene }
}
