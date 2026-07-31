import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "AdvancedSelect"
    description: "Seletor avançado com suporte a múltipla escolha, busca e tags."

    componentItem: [
        Column {
            anchors.centerIn: parent
            width: 350
            spacing: DS.Theme.spacing.lg

            DS.AdvancedSelect {
                width: parent.width
                placeholder: "Selecione tecnologias..."
                multiple: multiSwitch.checked
                searchable: searchSwitch.checked
                size: sizeSelect.model[sizeSelect.currentIndex]
                
                options: [
                    { value: "react", label: "React" },
                    { value: "vue", label: "Vue.js" },
                    { value: "angular", label: "Angular" },
                    { value: "qml", label: "Qt/QML" },
                    { value: "flutter", label: "Flutter" },
                    { value: "svelte", label: "Svelte" }
                ]
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        },
        PlaygroundCtrlSwitch {
            id: multiSwitch
            label: "Múltipla Seleção"
            checked: true
        },
        PlaygroundCtrlSwitch {
            id: searchSwitch
            label: "Habilitar Busca"
            checked: true
        }
    ]
}
