import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kos.Ui

KosAppWindow {
    id: root
    objectName: "editor"
    required property var store
    required property var host
    width: 720; height: 540; minimumWidth: 500; minimumHeight: 400
    visible: false
    transientParent: null
    modality: Qt.NonModal
    property string noteId: ""
    property string originalTitle: ""
    property string originalBody: ""
    property bool quitAfterClose: false
    property bool allowClose: false
    property bool cleanupPending: false
    property string status: ""
    readonly property bool dirty: titleField.text !== originalTitle || bodyField.text !== originalBody
    title: (dirty ? "• " : "") + (titleField.text || qsTr("New note"))
    function begin(note) {
        noteId = note ? note.id : ""
        originalTitle = note ? note.title : ""
        originalBody = note ? note.body : ""
        titleField.text = originalTitle; bodyField.text = originalBody
        status = ""; allowClose = false; quitAfterClose = false; cleanupPending = false
        show(); raise(); requestActivate(); titleField.forceActiveFocus()
    }
    function recover(draft) {
        begin({ id: draft.id, title: draft.originalTitle, body: draft.originalBody })
        titleField.text = draft.title; bodyField.text = draft.body
        status = "recovered"
    }
    function checkpoint() {
        if (!visible) return
        if (dirty) store.saveDraft(noteId, titleField.text, bodyField.text, originalTitle, originalBody)
        else clearRecovery()
    }
    Timer { id: autosave; interval: 600; onTriggered: root.checkpoint() }
    function clearRecovery() {
        cleanupPending = !store.clearDraft()
        if (cleanupPending) status = "draftFailed"
        return !cleanupPending
    }
    function save() {
        if (!dirty && cleanupPending) {
            if (!clearRecovery()) return false
            status = "saved"
            return true
        }
        const id = store.saveNote(noteId, titleField.text, bodyField.text)
        if (!id) { status = "failed"; return false }
        noteId = id
        titleField.text = titleField.text.trim()
        originalTitle = titleField.text; originalBody = bodyField.text
        host.selectedId = id
        autosave.stop()
        if (!clearRecovery()) return false
        status = "saved"
        return true
    }
    function finishClose() {
        autosave.stop()
        if (!clearRecovery()) { decision.open(); return }
        decision.close(); allowClose = true; close()
    }
    onClosing: event => {
        if (!allowClose) {
            if (dirty) { checkpoint(); event.accepted = false; decision.open(); return }
            autosave.stop()
            if (!clearRecovery()) { event.accepted = false; decision.open(); return }
        }
        if (quitAfterClose) Qt.callLater(host.finishQuit)
    }
    Shortcut { sequences: [StandardKey.Save]; enabled: root.visible && !decision.visible; onActivated: root.save() }
    Shortcut { sequences: [StandardKey.Close]; enabled: root.visible; onActivated: root.close() }
    Rectangle {
        id: scene
        anchors.fill: parent
        color: AppTheme.contentBackground
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 20; spacing: 12
        SettingsGroup {
            Layout.fillWidth: true
            title: qsTr("Note")
            SettingsItem {
                title: qsTr("Title")
                SettingsTextField {
                    id: titleField
                    objectName: "titleField"
                    Layout.fillWidth: true; Layout.minimumWidth: 0; Layout.preferredWidth: 420
                    Accessible.name: qsTr("Title")
                    placeholderText: qsTr("Required")
                    onTextChanged: { root.status = ""; if (root.visible) autosave.restart() }
                }
            }
        }
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true
            contentWidth: availableWidth; clip: true
            SettingsTextArea {
                id: bodyField
                objectName: "bodyField"
                textFormat: TextEdit.PlainText
                Accessible.name: qsTr("Note body")
                placeholderText: qsTr("Write a note…")
                onTextChanged: { root.status = ""; if (root.visible) autosave.restart() }
            }
        }
        Label {
            objectName: "editorStatus"
            Layout.fillWidth: true; wrapMode: Text.Wrap
            color: root.status === "failed" ? AppTheme.destructive : AppTheme.mutedText
            text: root.cleanupPending ? qsTr("Recovery cleanup failed. Retry Save or Close after repairing storage access.")
                : root.store.draftError ? qsTr("Recovery copy could not be updated. Keep this window open and retry Save; your edits remain here.")
                : root.status === "recovered" ? qsTr("Recovered draft — review and Save to confirm.")
                : root.status === "failed" ? qsTr("Save failed. Your edits are still here; check storage access and retry.")
                : root.status === "saved" ? qsTr("Saved")
                : root.dirty ? qsTr("Unsaved changes") : ""
        }
        RowLayout {
            Layout.alignment: Qt.AlignRight
            LiquidActionButton {
                materialForm: true; implicitHeight: 28
                text: qsTr("Close"); onClicked: root.close()
            }
            LiquidActionButton {
                materialForm: true; implicitHeight: 28
                text: qsTr("Save")
                enabled: root.cleanupPending || (titleField.text.trim().length > 0 && root.dirty)
                onClicked: root.save()
            }
        }
    }
    }
    LiquidDialog {
        id: decision
        objectName: "decision"
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(420, root.width - 32)
        sourceItem: scene
        title: root.dirty ? qsTr("Save changes?") : qsTr("Recovery cleanup required")
        closePolicy: Popup.NoAutoClose
        contentItem: Label {
            text: root.cleanupPending
                ? qsTr("Recovery file could not be removed. Repair storage access and retry; this window must stay open until cleanup succeeds.")
                : root.status === "failed"
                ? qsTr("Save failed. Retry or cancel to keep editing.")
                : qsTr("Closing without saving discards your edits.")
            color: AppTheme.text; wrapMode: Text.Wrap
        }
        footer: Control {
            padding: 24; topPadding: 12
            implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
            contentItem: RowLayout {
                Item { Layout.fillWidth: true }

            spacing: 8
            LiquidDialogButton {
                objectName: "cancelClose"
                text: qsTr("Cancel")
                onClicked: { root.quitAfterClose = false; decision.close() }
            }
            LiquidDialogButton {
                objectName: "discardClose"
                text: root.dirty ? qsTr("Don't Save") : qsTr("Retry Close"); destructive: root.dirty
                onClicked: root.finishClose()
            }
            LiquidDialogButton {
                objectName: "saveClose"
                text: qsTr("Save"); primaryAction: true
                visible: root.dirty
                enabled: titleField.text.trim().length > 0
                onClicked: { if (root.save()) root.finishClose() }
            }

            }
        }
        Shortcut {
            sequence: "Escape"; enabled: decision.visible
            onActivated: { root.quitAfterClose = false; decision.close() }
        }
    }
}
