import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Playground {
    id: pg
    title: "Checkbox"
    description: "Controle de seleção binária simples com rótulos personalizáveis."

    componentItem: [
        Column {
            anchors.centerIn: parent
            spacing: DS.Theme.spacing.lg

            DS.Checkbox {
                label: labelText.text
                checked: checkedSwitch.checked
                disabled: disabledSwitch.checked
            }
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: labelText
            label: "Rótulo (Label)"
            text: "Aceito os termos e condições"
        },
        PlaygroundCtrlSwitch {
            id: checkedSwitch
            label: "Marcado"
        },
        PlaygroundCtrlSwitch {
            id: disabledSwitch
            label: "Desativado"
        }
    ]
}
