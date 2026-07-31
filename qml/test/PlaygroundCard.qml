import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Card"
    description: "Contêiner flexível para agrupar conteúdos relacionados com estilo Catppuccin."

    componentItem: [
        DS.Card {
            id: cardComponent
            anchors.centerIn: parent
            width: 350
            height: 250
            
            title: titleText.text
            subtitle: subtitleText.text
            variant: variantSelect.model[variantSelect.currentIndex]
            backgroundColor: bgSelect.model[bgSelect.currentIndex] === "none" ? "" : bgSelect.model[bgSelect.currentIndex]
            customAccentColor: DS.Theme.colors[accentSelect.model[accentSelect.currentIndex]]
            accentPosition: posSelect.model[posSelect.currentIndex]
            
            Text {
                anchors.fill: parent
                anchors.margins: DS.Theme.spacing.lg
                text: "Conteúdo interno do Card. Você pode colocar qualquer elemento QML aqui dentro."
                color: cardComponent.isColored ? cardComponent.finalTextColor : DS.Theme.colors.subtext0
                wrapMode: Text.WordWrap
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeMd
            }
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: titleText
            label: "Título"
            text: "Título do Card"
        },
        PlaygroundCtrlTextField {
            id: subtitleText
            label: "Subtítulo"
            text: "Subtítulo informativo"
        },
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["default", "accent", "tonal", "outline", "filled"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: bgSelect
            label: "Cor de Fundo"
            model: ["none", "base", "surface0", "mantle", "crust", "mauve", "lavender", "blue", "sapphire", "sky", "teal", "green", "yellow", "peach", "maroon", "red", "pink", "flamingo", "rosewater"]
            currentIndex: 0
            visible: variantSelect.model[variantSelect.currentIndex] === "filled"
        },
        PlaygroundCtrlSelect {
            id: accentSelect
            label: "Cor de Destaque"
            model: ["mauve", "blue", "green", "yellow", "red", "peach", "teal"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: posSelect
            label: "Posição do Destaque"
            model: ["left", "top", "none"]
            currentIndex: 0
        }
    ]
}
