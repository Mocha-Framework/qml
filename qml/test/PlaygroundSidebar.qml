import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".."

Playground {
    id: pg
    title: "Sidebar"
    description: "Menu de navegação lateral principal para aplicações complexas."

    componentItem: [
        Row {
            anchors.centerIn: parent
            spacing: 50
            
            // 1. Sidebar Estática (Padrão)
            Rectangle {
                width: 240
                height: 500
                color: Theme.colors.mantle
                border.color: Theme.colors.surface0
                border.width: 1
                
                Sidebar {
                    anchors.fill: parent
                    
                    SidebarHeader { title: "Estática"; subtitle: "v1.2.0"; logoIcon: "coffee" }
                    
                    Column {
                        spacing: 2
                        Item { height: 16; Text { text: "SISTEMA"; color: Theme.colors.subtext0; font.pixelSize: Theme.typography.sizeXs; anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: Theme.spacing.sm } }
                        SidebarItem { label: "Configurações"; icon: "settings" }
                        SidebarItem { label: "Usuários"; icon: "users" }
                    }
                    
                    SidebarFooter { username: "Admin"; email: "admin@mocha.io"; avatarIcon: "log-out" }
                }
            }
            
            // 2. Sidebar Ordenável (Drag and Drop)
            Rectangle {
                width: 240
                height: 500
                color: Theme.colors.mantle
                border.color: Theme.colors.surface0
                border.width: 1
                
                Sidebar {
                    anchors.fill: parent
                    
                    SidebarHeader { title: "Sortable"; subtitle: "Drag & Drop"; logoIcon: "move" }
                    
                    Column {
                        spacing: 2
                        Item { height: 16; Text { text: "PRINCIPAL"; color: Theme.colors.subtext0; font.pixelSize: Theme.typography.sizeXs; anchors.verticalCenter: parent.verticalCenter; anchors.left: parent.left; anchors.leftMargin: Theme.spacing.sm } }
                        
                        property var menuItems: [
                            { label: "Dashboard", icon: "layout", active: true },
                            { label: "Projetos", icon: "folder", active: false },
                            { label: "Tarefas", icon: "check-square", active: false },
                            { label: "Relatórios", icon: "pie-chart", active: false }
                        ]
                        
                        SortableList {
                            width: parent.width
                            height: 160 // Altura fixa suficiente para os itens
                            paddingLeft: 0; paddingRight: 0; paddingTop: 0; paddingBottom: 0
                            model: parent.menuItems
                            
                            delegate: SidebarItem {
                                width: ListView.view ? ListView.view.width : 240
                                label: typeof modelData !== "undefined" && modelData ? modelData.label : ""
                                icon: typeof modelData !== "undefined" && modelData ? modelData.icon : ""
                                isActive: typeof modelData !== "undefined" && modelData ? modelData.active : false
                            }
                            
                            onItemsReordered: function(fromIndex, toIndex) {
                                var newItems = parent.menuItems.slice()
                                var item = newItems.splice(fromIndex, 1)[0]
                                newItems.splice(toIndex, 0, item)
                                parent.menuItems = newItems
                            }
                        }
                    }
                    
                    SidebarFooter { username: "User"; email: "user@mocha.io"; avatarIcon: "user" }
                }
            }
        }
    ]

    controls: [
        Text {
            text: "Exemplo de uma sidebar estruturada com cabeçalho e rodapé."
            color: Theme.colors.subtext0
            font.pixelSize: Theme.typography.sizeMd
            width: parent.width
            wrapMode: Text.WordWrap
        }
    ]
}
