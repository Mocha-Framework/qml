import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Tile"
    description: "Blocos informativos compactos para dashboards e resumos de dados. Suporta drag para dashboards modulares."

    componentItem: [
        Column {
            anchors.centerIn: parent
            spacing: DS.Theme.spacing.xl

            Row {
                spacing: DS.Theme.spacing.lg
                anchors.horizontalCenter: parent.horizontalCenter

                DS.Tile {
                    width: 200
                    height: 120
                    title: "Faturamento"
                    description: "R$ 45.200 (+15%)"
                    icon: "dollar-sign"
                    variant: variantSelect.model[variantSelect.currentIndex]
                    backgroundColor: bgSelect.model[bgSelect.currentIndex] === "none" ? "" : bgSelect.model[bgSelect.currentIndex]
                    active: activeSwitch.checked
                    interactive: interactiveSwitch.checked
                    draggable: draggableSwitch.checked
                }

                DS.Tile {
                    width: 200
                    height: 120
                    title: "Usuários"
                    description: "2.847 ativos"
                    icon: "users"
                    variant: variantSelect.model[variantSelect.currentIndex]
                    backgroundColor: bgSelect.model[bgSelect.currentIndex] === "none" ? "" : bgSelect.model[bgSelect.currentIndex]
                    interactive: interactiveSwitch.checked
                    draggable: draggableSwitch.checked
                }
            }

            DS.DropZone {
                id: tileDropZone
                key: "mochads-tile"
                width: 450
                height: 60
                anchors.horizontalCenter: parent.horizontalCenter
                visible: draggableSwitch.checked
                accentColor: DS.Theme.colors.primary

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: DS.Theme.geometry.radiusMd
                    border.color: tileDropZone.containsDrag ? DS.Theme.colors.primary : DS.Theme.colors.surface0
                    border.width: 2

                    Text {
                        text: tileDropZone.containsDrag ? "Solte aqui para adicionar ao dashboard" : "Zona de Dashboard (arraste um tile)"
                        font.family: DS.Theme.typography.family
                        font.pixelSize: DS.Theme.typography.sizeSm
                        color: tileDropZone.containsDrag ? DS.Theme.colors.primary : DS.Theme.colors.subtext0
                        anchors.centerIn: parent
                    }
                }

                onDropped: function(source) {
                    console.log("Tile adicionado ao dashboard:", source.title)
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: tileTitle
            label: "Título"
            text: "Faturamento"
        },
        PlaygroundCtrlTextField {
            id: tileDesc
            label: "Descrição"
            text: "R$ 45.200 (+15%)"
        },
        PlaygroundCtrlTextField {
            id: tileIcon
            label: "Ícone (Lucide Name)"
            text: "dollar-sign"
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
        PlaygroundCtrlSwitch {
            id: activeSwitch
            label: "Ativo"
            checked: false
        },
        PlaygroundCtrlSwitch {
            id: interactiveSwitch
            label: "Interativo"
            checked: true
        },
        PlaygroundCtrlSwitch {
            id: draggableSwitch
            label: "Draggable (Arrastável)"
            checked: false
        }
    ]
}
