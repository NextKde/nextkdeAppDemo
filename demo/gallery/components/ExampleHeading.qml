import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../Kos/Ui/foundation" as Ui

// Page furniture only; does not wrap, capture or restyle the demonstrated control.
Label {
    property string number: ""
    property string title: ""
    Layout.fillWidth: true
    Layout.topMargin: 8
    text: number + " · " + title
    color: Ui.AppTheme.text
    font.pixelSize: 17
    font.weight: Font.DemiBold
    topPadding: 8
    bottomPadding: 8
    wrapMode: Text.WordWrap
}
