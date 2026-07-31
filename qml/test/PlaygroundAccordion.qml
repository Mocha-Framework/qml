import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Accordion"
    description: "Painéis colapsáveis para organizar grandes volumes de informação."

    componentItem: [
        Column {
            anchors.centerIn: parent
            width: 400
            spacing: DS.Theme.spacing.md
            
            DS.Accordion {
                id: acc1
                width: parent.width
                title: "Configurações de Perfil"
                icon: "user"
                variant: variantSelect.model[variantSelect.currentIndex]
                backgroundColor: bgSelect.model[bgSelect.currentIndex] === "none" ? "" : bgSelect.model[bgSelect.currentIndex]
                expanded: true
                
                Text {
                    width: parent.width
                    text: "Altere seu nome, email, senha e foto de perfil nesta seção."
                    color: acc1.isColored ? acc1.finalTextColor : DS.Theme.colors.subtext0
                    wrapMode: Text.WordWrap
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeMd
                }
            }

            DS.Accordion {
                id: acc2
                width: parent.width
                title: "Segurança e Acesso"
                icon: "lock"
                variant: variantSelect.model[variantSelect.currentIndex]
                backgroundColor: bgSelect.model[bgSelect.currentIndex] === "none" ? "" : bgSelect.model[bgSelect.currentIndex]
                
                Text {
                    width: parent.width
                    text: "Gerencie suas senhas, chaves de API e ative a autenticação em duas etapas para garantir a segurança dos seus dados."
                    color: acc2.isColored ? acc2.finalTextColor : DS.Theme.colors.subtext0
                    wrapMode: Text.WordWrap
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeMd
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["default", "outline", "tonal", "split", "filled"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: bgSelect
            label: "Cor de Fundo"
            model: ["none", "base", "surface0", "mantle", "crust", "mauve", "lavender", "blue", "sapphire", "sky", "teal", "green", "yellow", "peach", "maroon", "red", "pink", "flamingo", "rosewater"]
            currentIndex: 0
            visible: variantSelect.model[variantSelect.currentIndex] === "filled"
        }
    ]
}
