import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Select"
    description: "Menu suspenso personalizável para seleção de opções individuais."

    componentItem: [
        DS.Select {
            id: selectComponent
            anchors.centerIn: parent
            width: 280
            
            placeholder: placeholderInput.text
            disabled: disabledSwitch.checked
            size: sizeSelect.model[sizeSelect.currentIndex]
            status: statusSelect.model[statusSelect.currentIndex]
            
            options: [
                { value: "opt1", label: "Café Espresso" },
                { value: "opt2", label: "Café Latte" },
                { value: "opt3", label: "Capuccino" },
                { value: "opt4", label: "Macchiato" }
            ]
            
            onValueChanged: {
                console.log("Selected value: " + val)
            }
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: placeholderInput
            label: "Placeholder"
            text: "Escolha seu café..."
        },
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        },
        PlaygroundCtrlSelect {
            id: statusSelect
            label: "Status de Validação"
            model: ["normal", "success", "error"]
            currentIndex: 0
        },
        PlaygroundCtrlSwitch {
            id: disabledSwitch
            label: "Desativado"
        }
    ]
}
