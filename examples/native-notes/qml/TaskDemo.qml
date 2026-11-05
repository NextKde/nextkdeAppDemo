import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Kos.Ui

LiquidDialog {
    id: root
    required property var store
    required property var host
    objectName: "taskDialog"
    parent: Overlay.overlay
    anchors.centerIn: parent
    width: Math.min(460, host.width - 32)
    title: qsTr("Sample data task")
    // Closing cancels pending batches; generation checks reject old callbacks.
    onClosed: store.cancelTask()
    contentItem: ColumnLayout {
        spacing: 12
        Label {
            Layout.fillWidth: true; wrapMode: Text.Wrap; color: AppTheme.mutedText
            text: qsTr("Loads three fictional items in timed batches. No network or changes to your notes. Try a simulated failure, then Retry for a successful run.")
        }
        Label {
            objectName: "taskStatus"
            Layout.fillWidth: true; wrapMode: Text.Wrap; color: AppTheme.text
            Accessible.name: text
            text: root.store.taskState === "running"
                ? qsTr("Loading sample data: %1%2").arg(Number(root.store.taskProgress).toLocaleString(Qt.locale(root.store.preferences.language === "zh" ? "zh_CN" : "en_US"), "f", 0)).arg(Qt.locale(root.store.preferences.language === "zh" ? "zh_CN" : "en_US").percent)
                : root.store.taskState === "failed" ? qsTr("Simulated failure. Retry will run without the injected failure.")
                : root.store.taskState === "cancelled" ? qsTr("Cancelled. No sample results were applied.")
                : root.store.taskState === "succeeded" ? qsTr("Complete — %n sample item(s) loaded.", "", root.store.taskResult.length)
                : qsTr("Ready to load sample data.")
        }
        Label {
            Layout.fillWidth: true; wrapMode: Text.Wrap; color: AppTheme.text
            visible: root.store.taskState === "succeeded"
            text: root.store.taskResult.map(value => value === "Sample A" ? qsTr("Sample A")
                : value === "Sample B" ? qsTr("Sample B") : value === "Sample C" ? qsTr("Sample C") : value).join(" · ")
            textFormat: Text.PlainText
        }
    }
    footer: Control {
        padding: 24; topPadding: 12
        implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
        contentItem: ColumnLayout {
            spacing: 8
            RowLayout {
                Layout.alignment: Qt.AlignRight
                LiquidDialogButton {
                    objectName: "failTask"
                    text: qsTr("Simulate failure")
                    enabled: root.store.taskState !== "running"
                    onClicked: root.store.startTask(true)
                }
                LiquidDialogButton {
                    objectName: "startTask"
                    text: root.store.taskState === "failed" || root.store.taskState === "cancelled"
                        ? qsTr("Retry") : qsTr("Load sample data")
                    primaryAction: true; enabled: root.store.taskState !== "running"
                    onClicked: {
                        if (root.store.taskState === "failed" || root.store.taskState === "cancelled") root.store.retryTask()
                        else root.store.startTask(false)
                    }
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                LiquidDialogButton {
                    objectName: "cancelTask"
                    text: qsTr("Cancel task")
                    visible: root.store.taskState === "running"
                    onClicked: root.store.cancelTask()
                }
                LiquidDialogButton { objectName: "closeTask"; text: qsTr("Close"); onClicked: root.close() }
            }
        }
    }
}
