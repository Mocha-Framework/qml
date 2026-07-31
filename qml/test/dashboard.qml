import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".."

Item {
    id: root
    width: 1280
    height: 800

    property int activeTab: 0 // 0: Analytics, 1: Inventory, 2: Settings
    
    // --- Mock Data ---
    property var ordersData: [
        { id: 1, client: "Alice Smith", type: "Espresso", amount: 5, status: "Sucesso" },
        { id: 2, client: "Bob Jones", type: "Latte", amount: 2, status: "Pendente" },
        { id: 3, client: "Charlie Brown", type: "Cappuccino", amount: 10, status: "Cancelado" },
        { id: 4, client: "Diana Prince", type: "Americano", amount: 3, status: "Sucesso" },
        { id: 5, client: "Ethan Hunt", type: "Macchiato", amount: 8, status: "Pendente" },
        { id: 6, client: "Fiona Gallagher", type: "Mocha", amount: 4, status: "Sucesso" },
        { id: 7, client: "George Miller", type: "Espresso", amount: 1, status: "Sucesso" },
        { id: 8, client: "Hannah Abbott", type: "Latte", amount: 3, status: "Pendente" },
        { id: 9, client: "Ian Wright", type: "Cappuccino", amount: 6, status: "Sucesso" }
    ]

    property var selectedOrder: null

    Shell {
        id: shell
        anchors.fill: parent
        
        columnCount: activeTab === 0 ? 3 : (activeTab === 1 ? 2 : 1)
        secondarySidebarVisible: activeTab === 2

        // Sidebar Navigation
        sidebar: [
            Sidebar {
                id: dashboardSidebar
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                collapsedWidth: 64
                expandedWidth: shell.sidebarWidth
                isCollapsed: shell.sidebarCollapsed
                expandOnHover: true

                SidebarHeader {
                    title: "Mocha Coffee"
                    subtitle: "Dashboard"
                    logoIcon: "coffee"
                }

                SidebarSection {
                    SidebarItem {
                        label: "Resumo Analítico"
                        icon: "bar-chart-2"
                        isActive: root.activeTab === 0
                        onClicked: root.activeTab = 0
                    }
                    SidebarItem {
                        label: "Gestão de Pedidos"
                        icon: "package"
                        isActive: root.activeTab === 1
                        onClicked: root.activeTab = 1
                    }
                    SidebarItem {
                        label: "Configurações"
                        icon: "settings"
                        isActive: root.activeTab === 2
                        onClicked: root.activeTab = 2
                        expanded: root.activeTab === 2

                        SidebarItem {
                            label: "Preferências Visuais"
                            icon: "palette"
                            isActive: root.activeTab === 2
                        }
                        SidebarItem {
                            label: "Logs do Sistema"
                            icon: "file-text"
                            isActive: root.activeTab === 2
                        }
                    }
                }

                SidebarFooter {
                    username: "Administrador"
                    email: "admin@mocha.com"
                    avatarIcon: "user"
                }
            }
        ]

        // Content Loaders per Column
        col1: [
            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if (root.activeTab === 0) return analyticsCol1;
                    if (root.activeTab === 1) return inventoryCol1;
                    if (root.activeTab === 2) return settingsCol1;
                    return null;
                }
            }
        ]

        col2: [
            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if (root.activeTab === 0) return analyticsCol2;
                    if (root.activeTab === 1) return inventoryCol2;
                    return null;
                }
            }
        ]

        col3: [
            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if (root.activeTab === 0) return analyticsCol3;
                    return null;
                }
            }
        ]
    }

    // ==========================================
    // SCREEN 0: ANALYTICS COMPONENTS
    // ==========================================
    Component {
        id: analyticsCol1
        Column {
            spacing: Theme.spacing.lg
            width: parent.width

            Card {
                title: "Desempenho Financeiro"
                width: parent.width
                content: Column {
                    width: parent.width
                    spacing: Theme.spacing.md
                    RowLayout {
                        width: parent.width
                        Text { text: "Faturamento"; color: Theme.colors.subtext1; Layout.fillWidth: true }
                        Badge { text: "+12.4%"; variant: "success" }
                    }
                    Text { text: "R$ 48.250,00"; font.family: Theme.typography.familyBold; font.pixelSize: 24; color: Theme.colors.text }
                }
            }

            Card {
                title: "Produção Ativa"
                width: parent.width
                content: GaugeChart {
                    width: parent.width; height: 160
                    value: 0.68; label: "Progresso da Torra"; color: Theme.colors.peach
                }
            }

            Card {
                title: "Saúde do Sistema"
                width: parent.width
                content: GaugeChart {
                    width: parent.width; height: 160
                    value: 0.24; label: "Carga do Servidor"; color: Theme.colors.green
                }
            }
        }
    }

    Component {
        id: analyticsCol2
        Column {
            spacing: Theme.spacing.lg
            width: parent.width

            Card {
                title: "Tendência de Vendas (Semanal)"
                width: parent.width
                content: LineChart {
                    width: parent.width; height: 250; lineColor: Theme.colors.mauve
                    chartData: [ {label:"Seg", value:10}, {label:"Ter", value:25}, {label:"Qua", value:18}, {label:"Qui", value:42}, {label:"Sex", value:38}, {label:"Sab", value:60} ]
                }
            }

            Card {
                title: "Distribuição de Tipos"
                width: parent.width
                content: PieChart {
                    width: parent.width; height: 250; donutRatio: 0.6
                    chartData: [ {label:"Espresso", value:45}, {label:"Latte", value:30}, {label:"Mocha", value:25} ]
                }
            }
        }
    }

    Component {
        id: analyticsCol3
        Column {
            spacing: Theme.spacing.lg
            width: parent.width

            Card {
                title: "Análise de Qualidade"
                width: parent.width
                content: RadarChart {
                    width: parent.width; height: 250; color: Theme.colors.blue
                    chartData: [ {label:"Aroma", value:85}, {label:"Acidez", value:60}, {label:"Corpo", value:75}, {label:"Doçura", value:90}, {label:"Final", value:80} ]
                }
            }

            Card {
                title: "Central de Notificações"
                width: parent.width
                content: Column {
                    width: parent.width
                    spacing: Theme.spacing.md
                    Text { text: "Simule alertas em tempo real:"; color: Theme.colors.subtext1; font.pixelSize: 12 }
                    Flow {
                        width: parent.width; spacing: Theme.spacing.sm
                        Button { text: "Sucesso"; size: "sm"; onClicked: toastManager.show("Lote aprovado!", "success") }
                        Button { text: "Erro"; size: "sm"; variant: "outline"; onClicked: toastManager.show("Falha na ignição", "danger") }
                        Button { text: "Aviso"; size: "sm"; variant: "outline"; onClicked: toastManager.show("Estoque em 15%", "warning") }
                    }
                }
            }
        }
    }

    // ==========================================
    // SCREEN 1: INVENTORY & ORDERS
    // ==========================================
    Component {
        id: inventoryCol1
        Card {
            anchors.fill: parent
            title: "Registro de Pedidos e Lotes"
            subtitle: "Gerenciamento completo da base de dados"
            icon: "database"
            
            content: Column {
                width: parent.width
                spacing: Theme.spacing.md
                Table {
                    id: mainTable
                    width: parent.width; height: 550
                    pageSize: 8; selectable: true
                    columns: [
                        { name: "id", label: "ID", width: 60, type: "bold" },
                        { name: "client", label: "Cliente", width: 200, sortable: true },
                        { name: "type", label: "Grão", width: 120 },
                        { name: "status", label: "Status", width: 120, type: "badge" }
                    ]
                    rows: root.ordersData
                }
            }
        }
    }

    Component {
        id: inventoryCol2
        Column {
            spacing: Theme.spacing.lg
            width: parent.width

            Card {
                title: "Novo Lote"
                width: parent.width
                variant: "accent"
                content: Column {
                    width: parent.width; spacing: Theme.spacing.md
                    DynamicForm {
                        id: entryForm
                        width: parent.width
                        schema: [
                            { name: "client", label: "Cliente", required: true, type: "text", iconLeft: "user" },
                            { name: "type", label: "Tipo de Café", type: "select", options: ["Espresso", "Latte", "Mocha"] },
                            { name: "amount", label: "Qtd Lotes", type: "number" }
                        ]
                    }
                    Button {
                        text: "Cadastrar Registro"
                        variant: "primary"; width: parent.width
                        onClicked: {
                            if (entryForm.validate()) {
                                var v = entryForm.getValues();
                                var newData = root.ordersData.slice();
                                newData.push({ id: root.ordersData.length + 1, client: v.client, type: v.type, status: "Pendente" });
                                root.ordersData = newData;
                                toastManager.success("Pedido registrado!");
                                entryForm.clear();
                            }
                        }
                    }
                }
            }

            Card {
                title: "Ações Selecionadas"
                width: parent.width
                visible: true
                content: Column {
                    width: parent.width; spacing: Theme.spacing.md
                    Text { text: "Selecione itens na tabela para habilitar ações em massa."; color: Theme.colors.subtext1; font.pixelSize: 12; wrapMode: Text.WordWrap; width: parent.width }
                    Row {
                        spacing: Theme.spacing.sm
                        Button { text: "Exportar CSV"; variant: "outline"; size: "sm"; icon: "download" }
                        Button { text: "Deletar"; variant: "danger"; size: "sm"; icon: "trash-2" }
                    }
                }
            }
        }
    }

    // ==========================================
    // SCREEN 2: SETTINGS
    // ==========================================
    Component {
        id: settingsCol1
        Grid {
            columns: 2; spacing: Theme.spacing.xl; width: parent.width
            Column {
                width: (parent.width - parent.spacing) / 2; spacing: Theme.spacing.lg
                Accordion {
                    title: "Preferências Visuais"; expanded: true; width: parent.width
                    Column {
                        width: parent.width; spacing: Theme.spacing.md
                        ToggleButton { label: "Modo de Alta Performance"; checked: true }
                        ToggleButton { label: "Som de Notificações"; checked: false }
                    }
                }
            }
            Column {
                width: (parent.width - parent.spacing) / 2; spacing: Theme.spacing.lg
                Card {
                    title: "Logs de Auditoria"; width: parent.width
                    Button { text: "Visualizar Console"; onClicked: logDrawer.open = true; width: parent.width }
                }
            }
        }
    }

    // --- Overlays ---
    ToastManager { id: toastManager }
    Drawer {
        id: logDrawer; title: "Console do Sistema"; width: 400
        content: Text { text: "12:00 - Database Sync\n12:05 - Torra #12 finalizada\n12:10 - Backup S3 OK"; font.family: "Monospace"; color: Theme.colors.subtext0 }
    }
}
