import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "PinInput"
    description: "Entrada de código PIN com slots individuais e autofoco."

    property string pinValue: ""

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.lg
            anchors.centerIn: parent

            DS.PinInput {
                id: pin
                length: lengthSelect.model[lengthSelect.currentIndex]
                type: typeSelect.model[typeSelect.currentIndex]
                mask: maskSwitch.checked
                size: sizeSelect.model[sizeSelect.currentIndex]
                onCompleted: {
                    pg.pinValue = pin.text;
                }
            }

            Text {
                text: "PIN digitado: " + (pg.pinValue !== "" ? pg.pinValue : "---")
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: lengthSelect
            label: "Tamanho"
            model: [4, 5, 6]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: typeSelect
            label: "Tipo"
            model: ["number", "text"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        },
        PlaygroundCtrlSwitch {
            id: maskSwitch
            label: "Mascarar"
        }
    ]
}
