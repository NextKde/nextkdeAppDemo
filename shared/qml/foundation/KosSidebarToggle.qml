import QtQuick
import "../../Icons" as Symbols
import QtQuick.Controls

KosToolButton {
    id: root
    property var targetWindow: null
    property color glyphColor: AppTheme.text
    property color glyphPaneColor: root.targetWindow && root.targetWindow.sidebarExpanded ? AppTheme.accent : AppTheme.mutedText
    objectName: "sidebarToggle"
    implicitWidth: AppTheme.controlHeight
    implicitHeight: AppTheme.controlHeight
    Accessible.name: targetWindow && targetWindow.sidebarExpanded ? qsTr("Collapse sidebar") : qsTr("Expand sidebar")
    KosToolTip { target: root; text: root.Accessible.name }
    onClicked: if (targetWindow) targetWindow.sidebarExpanded = !targetWindow.sidebarExpanded
    contentItem: Symbols.Icon { name: "sidebar_left"; color: root.glyphColor; size: 18 }
}
