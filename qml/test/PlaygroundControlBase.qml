import QtQuick 2.15
import MochaDS as DS

Column {
    property string label: ""
    spacing: DS.Theme.spacing.xs
    width: parent.width
    
    Text {
        text: label
        font.family: DS.Theme.typography.familyMedium
        font.pixelSize: DS.Theme.typography.sizeSm
        color: DS.Theme.colors.subtext0
    }
}
