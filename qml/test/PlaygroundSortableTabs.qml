import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Sortable Tabs"
    description: "Abas com suporte a Drag and Drop (Reordenação). A mesma interface limpa, mas altamente interativa."

    componentItem: [
        Column {
            anchors.centerIn: parent
            width: 500
            spacing: 50

            Column {
                width: parent.width
                spacing: DS.Theme.spacing.md
                Text { text: "Arraste as abas para reordenar (Variant: Line)"; color: DS.Theme.colors.subtext0; font.pixelSize: 12 }
                
                property var dynamicTabs: ["Visão Geral", "Relatórios", "Configurações", "Ajuda"]
                
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
                    }
                }
            }

            Column {
                width: parent.width
                spacing: DS.Theme.spacing.md
                Text { text: "Arraste as abas para reordenar (Variant: Segmented)"; color: DS.Theme.colors.subtext0; font.pixelSize: 12 }
                
                property var segmentedTabs: ["Diário", "Semanal", "Mensal"]
                
                DS.Tabs {
                    width: parent.width
                    model: parent.segmentedTabs
                    variant: "segmented"
                    sortable: true
                    
                    onTabsReordered: function(fromIndex, toIndex) {
                        var newTabs = parent.segmentedTabs.slice()
                        var item = newTabs.splice(fromIndex, 1)[0]
                        newTabs.splice(toIndex, 0, item)
                        parent.segmentedTabs = newTabs
                    }
                }
            }
            
            Column {
                width: parent.width
                spacing: DS.Theme.spacing.md
                Text { text: "Arraste as abas para reordenar (Variant: Pill)"; color: DS.Theme.colors.subtext0; font.pixelSize: 12 }
                
                property var pillTabs: ["Design", "Código", "Testes", "Deploy"]
                
                DS.Tabs {
                    width: parent.width
                    model: parent.pillTabs
                    variant: "pill"
                    sortable: true
                    
                    onTabsReordered: function(fromIndex, toIndex) {
                        var newTabs = parent.pillTabs.slice()
                        var item = newTabs.splice(fromIndex, 1)[0]
                        newTabs.splice(toIndex, 0, item)
                        parent.pillTabs = newTabs
                    }
                }
            }
        }
    ]

    controls: [
        Text {
            text: "Adicione a propriedade 'sortable: true' no componente Tabs para transformar qualquer aba instantaneamente."
            color: DS.Theme.colors.subtext0
            font.pixelSize: DS.Theme.typography.sizeMd
            wrapMode: Text.WordWrap
            width: parent.width
        }
    ]
}
