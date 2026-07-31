import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Navigation"
    description: "Componentes de navegação estrutural como Tabs e Steps."

    componentItem: [
        Column {
            anchors.centerIn: parent
            width: 500
            spacing: 50

            Column {
                width: parent.width
                spacing: DS.Theme.spacing.md
                Text { text: "Tabs (Pill variant)"; color: DS.Theme.colors.subtext0; font.pixelSize: 12 }
                DS.Tabs {
                    width: parent.width
                    model: ["Visão Geral", "Relatórios", "Configurações"]
                    variant: "pill"
                }
            }

            Column {
                width: parent.width
                spacing: DS.Theme.spacing.md
                Text { text: "Sortable Tabs (Line variant)"; color: DS.Theme.colors.subtext0; font.pixelSize: 12 }
                
                property var dynamicTabs: ["Documentos", "Imagens", "Vídeos", "Músicas"]
                
                DS.Tabs {
                    width: parent.width
                    model: parent.dynamicTabs
                    variant: "line"
                    sortable: true
                    
                    onTabsReordered: function(fromIndex, toIndex) {
                        var newTabs = parent.dynamicTabs.slice()
                        var item = newTabs.splice(fromIndex, 1)[0]
                        newTabs.splice(toIndex, 0, item)
                        parent.dynamicTabs = newTabs
                        console.log("Nova ordem das abas:", newTabs)
                    }
                }
            }

            Column {
                width: parent.width
                spacing: DS.Theme.spacing.md
                Text { text: "Steps (Timeline horizontal)"; color: DS.Theme.colors.subtext0; font.pixelSize: 12 }
                DS.Steps {
                    width: parent.width
                    stepsCount: 3
                    labels: ["Carrinho", "Pagamento", "Concluído"]
                    currentStep: 1
                }
            }
        }
    ]

    controls: [
        Text {
            text: "Exemplos de componentes de navegação interna."
            color: DS.Theme.colors.subtext0
            font.pixelSize: DS.Theme.typography.sizeMd
        }
    ]
}
