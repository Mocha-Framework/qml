import QtQuick 2.15
import MochaDS as DS

Column {
    property string label: ""
    property real from: 0
    property real to: 100
    property real step: 1
    property real value: 50
    spacing: DS.Theme.spacing.sm
    width: parent.width

    Text {
        text: ctrlBase.label + ": " + Math.round(ctrlBase.value)
        font.family: DS.Theme.typography.familyMedium
        font.pixelSize: DS.Theme.typography.sizeSm
        color: DS.Theme.colors.subtext0
    }

    DS.Slider {
        width: parent.width
        minimum: ctrlBase.from
        maximum: ctrlBase.to
        step: ctrlBase.step
        value: ctrlBase.value
        onValueChanged: ctrlBase.value = value
    }
}
