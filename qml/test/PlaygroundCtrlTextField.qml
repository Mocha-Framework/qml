import QtQuick 2.15
import MochaDS as DS

Column {
    id: rootCtrl
    property string label: ""
    property alias text: field.text
    spacing: DS.Theme.spacing.xs
    width: parent.width

    Text {
        text: rootCtrl.label
        font.family: DS.Theme.typography.familyMedium
        font.pixelSize: DS.Theme.typography.sizeSm
        color: DS.Theme.colors.subtext0
    }

    DS.TextField {
        id: field
        width: parent.width
        height: 40
    }
}
