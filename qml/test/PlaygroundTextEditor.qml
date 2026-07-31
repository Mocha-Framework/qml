import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "TextEditor"
    description: "Editor de texto multi-linha com suporte a placeholder e redimensionamento."

    componentItem: [
        DS.TextEditor {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl
            text: sampleText.text
            placeholder: placeholderInput.text
            size: sizeSelect.model[sizeSelect.currentIndex]
            status: statusSelect.model[statusSelect.currentIndex]
            disabled: disabledSwitch.checked
            readOnly: readOnlySwitch.checked
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: sampleText
            label: "Texto"
            text: "Este é um exemplo de texto.\nCom múltiplas linhas.\nO editor se adapta ao conteúdo."
        },
        PlaygroundCtrlTextField {
            id: placeholderInput
            label: "Placeholder"
            text: "Digite aqui..."
        },
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        },
        PlaygroundCtrlSelect {
            id: statusSelect
            label: "Status"
            model: ["normal", "success", "error"]
            currentIndex: 0
        },
        PlaygroundCtrlSwitch {
            id: disabledSwitch
            label: "Desabilitado"
        },
        PlaygroundCtrlSwitch {
            id: readOnlySwitch
            label: "Somente Leitura"
        }
    ]
}
