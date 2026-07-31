import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".."

Item {
    id: root
    width: parent.width
    height: parent.height

    ScrollView {
        anchors.fill: parent
        anchors.margins: Theme.spacing.xl
        contentWidth: column.width
        contentHeight: column.height

        ColumnLayout {
            id: column
            width: root.width - Theme.spacing.xl * 2
            spacing: Theme.spacing.xl

            // ------------------------------------------
            // 1. Popover Genérico
            // ------------------------------------------
            Text {
                text: "Popover"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.text
            }
            Text {
                text: "O Popover é ideal para mini-formulários ou filtros acionados por clique."
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.subtext1
            }

            Card {
                Layout.fillWidth: true
                
                RowLayout {
                    spacing: Theme.spacing.md

                    // Anchor item
                    Button {
                        id: filterBtn
                        text: "Filtros Avançados"
                        icon: "filter"
                        onClicked: filterPopover.toggle(this)
                    }

                    Popover {
                        id: filterPopover
                        placement: "bottom-start"
                        contentItem: Column {
                            spacing: Theme.spacing.md
                            width: 280

                            Text {
                                text: "Filtros"
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeLg
                                color: Theme.colors.text
                            }
                            
                            Separator {}

                            FormField {
                                label: "Status"
                                Select {
                                    width: parent.width
                                    model: ["Ativo", "Inativo", "Pendente"]
                                }
                            }
                            
                            FormField {
                                label: "Data de Criação"
                                TextField {
                                    placeholderText: "DD/MM/AAAA"
                                    width: parent.width
                                }
                            }

                            RowLayout {
                                width: parent.width
                                spacing: Theme.spacing.sm
                                Button {
                                    text: "Cancelar"
                                    variant: "secondary"
                                    Layout.fillWidth: true
                                    onClicked: filterPopover.close()
                                }
                                Button {
                                    text: "Aplicar"
                                    variant: "primary"
                                    Layout.fillWidth: true
                                    onClicked: {
                                        ToastManager.success("Filtros aplicados com sucesso!")
                                        filterPopover.close()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ------------------------------------------
            // 2. HoverCard
            // ------------------------------------------
            Separator { Layout.fillWidth: true; Layout.topMargin: Theme.spacing.xl; Layout.bottomMargin: Theme.spacing.xl }

            Text {
                text: "HoverCard"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.text
            }
            Text {
                text: "Cartões ricos que abrem no hover, ideais para espiar perfis ou resumos."
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.subtext1
            }

            Card {
                Layout.fillWidth: true
                
                RowLayout {
                    spacing: Theme.spacing.md

                    Text {
                        text: "Passe o mouse no nome ao lado:"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext1
                    }

                    // Anchor item (a username link)
                    Text {
                        id: userLink
                        text: "@is-suzart"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.primary
                        
                        HoverCard {
                            placement: "top"
                            contentItem: Column {
                                spacing: Theme.spacing.md
                                width: 240

                                RowLayout {
                                    spacing: Theme.spacing.md
                                    Avatar {
                                        source: ""
                                        text: "IS"
                                        size: 48
                                    }
                                    Column {
                                        Text { text: "Isaque Suzart"; font.family: Theme.typography.familyBold; color: Theme.colors.text; font.pixelSize: Theme.typography.sizeLg }
                                        Text { text: "@is-suzart"; font.family: Theme.typography.family; color: Theme.colors.subtext1 }
                                    }
                                }
                                
                                Text {
                                    text: "Engenheiro de Software apaixonado por Design Systems e UI/UX."
                                    font.family: Theme.typography.family
                                    font.pixelSize: Theme.typography.sizeSm
                                    color: Theme.colors.text
                                    wrapMode: Text.WordWrap
                                    width: parent.width
                                }
                                
                                RowLayout {
                                    spacing: Theme.spacing.xl
                                    Row {
                                        spacing: 4
                                        LucideIcon { name: "users"; size: 14; color: Theme.colors.subtext1; anchors.verticalCenter: parent.verticalCenter }
                                        Text { text: "<b>124</b> Seguidores"; font.family: Theme.typography.family; color: Theme.colors.subtext1; font.pixelSize: 12; anchors.verticalCenter: parent.verticalCenter }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
