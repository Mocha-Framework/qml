import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "TextField"
    description: "Campos de entrada de texto flexíveis com ícones e validações."
    codeSnippet: "TextField {\n    text: \"" + textInputVal.text + "\"\n    placeholder: \"" + placeholderInput.text + "\"\n    type: \"" + typeSelect.model[typeSelect.currentIndex] + "\"\n    size: \"" + sizeSelect.model[sizeSelect.currentIndex] + "\"\n    status: \"" + statusSelect.model[statusSelect.currentIndex] + "\"\n    " + (iconLeftInput.text !== "" ? "iconLeft: \"" + iconLeftInput.text + "\"\n    " : "") + (iconRightInput.text !== "" ? "iconRight: \"" + iconRightInput.text + "\"\n    " : "") + (disabledSwitch.checked ? "disabled: true\n    " : "") + (readOnlySwitch.checked ? "readOnly: true\n    " : "") + "onAccepted: { /* ação */ }\n}"

    componentItem: [
        DS.TextField {
            id: textComponent
            anchors.centerIn: parent
            width: 280
            
            text: textInputVal.text
            placeholder: placeholderInput.text
            type: typeSelect.model[typeSelect.currentIndex]
            size: sizeSelect.model[sizeSelect.currentIndex]
            status: statusSelect.model[statusSelect.currentIndex]
            disabled: disabledSwitch.checked
            readOnly: readOnlySwitch.checked
            iconLeft: iconLeftInput.text
            iconRight: iconRightInput.text
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: textInputVal
            label: "Valor do Texto"
            text: ""
        },
        PlaygroundCtrlTextField {
            id: placeholderInput
            label: "Placeholder"
            text: "Digite alguma coisa..."
        },
        PlaygroundCtrlTextField {
            id: iconLeftInput
            label: "Ícone Esquerdo (Lucide Name)"
            text: "mail"
        },
        PlaygroundCtrlTextField {
            id: iconRightInput
            label: "Ícone Direito (Lucide Name)"
            text: ""
        },
        PlaygroundCtrlSelect {
            id: typeSelect
            label: "Tipo de Entrada"
            model: ["text", "password", "email", "number"]
            currentIndex: 0
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
        },
        PlaygroundCtrlSwitch {
            id: readOnlySwitch
            label: "Somente Leitura"
        }
    ]
}
