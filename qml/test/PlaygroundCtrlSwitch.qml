import QtQuick 2.15
import MochaDS as DS

Row {
    property string label: ""
    property alias checked: sw.checked
    spacing: DS.Theme.spacing.md
    width: parent.width

    DS.ToggleButton {
        id: sw
        anchors.verticalCenter: parent.verticalCenter
    }

    Text {
        text: label
        font.family: DS.Theme.typography.familyMedium
        font.pixelSize: DS.Theme.typography.sizeMd
        color: DS.Theme.colors.text
        anchors.verticalCenter: parent.verticalCenter
    }
}
