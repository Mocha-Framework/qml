import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".."

Item {
    // This file just exports multiple internal components
    
    component PlaygroundControl : Column {
        property string label: ""
        spacing: Theme.spacing.xs
        width: parent.width
        
        Text {
            text: label
            font.family: Theme.typography.familyMedium
            font.pixelSize: Theme.typography.sizeSm
            color: Theme.colors.subtext0
        }
    }

    component PlaygroundCtrlTextField : PlaygroundControl {
        property alias text: field.text
        TextField {
            id: field
            width: parent.width
        }
    }

    component PlaygroundCtrlSwitch : Row {
        property string label: ""
        property alias checked: sw.checked
        spacing: Theme.spacing.md
        width: parent.width

        ToggleButton {
            id: sw
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: label
            font.family: Theme.typography.familyMedium
            font.pixelSize: Theme.typography.sizeMd
            color: Theme.colors.text
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    component PlaygroundCtrlSelect : PlaygroundControl {
        property alias model: sel.model
        property alias currentIndex: sel.currentIndex
        Select {
            id: sel
            width: parent.width
        }
    }
}
