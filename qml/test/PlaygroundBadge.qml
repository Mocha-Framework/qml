import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Playground {
    id: pg
    title: "Badge"
    description: "Pequenos rótulos visuais para estados, contadores ou categorias."
    codeSnippet: "Badge {\n    text: \"" + badgeText.text + "\"\n    variant: \"" + variantSelect.model[variantSelect.currentIndex] + "\"\n    size: \"" + sizeSelect.model[sizeSelect.currentIndex] + "\"\n    color: \"" + colorSelect.model[colorSelect.currentIndex] + "\"\n    " + (iconSwitch.checked ? "icon: \"sparkles\"\n    " : "") + "}"

    componentItem: [
        Row {
            anchors.centerIn: parent
            spacing: DS.Theme.spacing.md

            DS.Badge {
                text: badgeText.text
                variant: variantSelect.model[variantSelect.currentIndex]
                size: sizeSelect.model[sizeSelect.currentIndex]
                color: colorSelect.model[colorSelect.currentIndex]
                icon: iconSwitch.checked ? "sparkles" : ""
            }
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: badgeText
            label: "Texto"
            text: "Novo"
        },
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["filled", "outline", "tonal"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md"]
            currentIndex: 1
        },
        PlaygroundCtrlSelect {
            id: colorSelect
            label: "Cor"
            model: ["mauve", "blue", "green", "yellow", "red", "peach", "teal"]
            currentIndex: 0
        },
        PlaygroundCtrlSwitch {
            id: iconSwitch
            label: "Mostrar Ícone"
        }
    ]
}
