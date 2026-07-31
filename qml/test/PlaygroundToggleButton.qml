import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Playground {
    id: pg
    title: "ToggleButton"
    description: "Interruptor simples para alternar estados booleanos."

    componentItem: [
        DS.ToggleButton {
            anchors.centerIn: parent
            checked: false
            onCheckedChanged: {
                console.log("Checked: " + checked)
            }
        }
    ]

    controls: [
        Text {
            text: "Interaja com o componente ao lado."
            color: DS.Theme.colors.subtext0
            font.pixelSize: DS.Theme.typography.sizeMd
        }
    ]
}
