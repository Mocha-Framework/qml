import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Router"
    description: "Sistema de roteamento declarativo e dinâmico inspirado no React Router. Suporta parâmetros de URL, links ativos e controle de histórico."

    componentItem: [
        DS.Card {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.lg
            title: "Mini-App com Roteador MochaDS"
            subtitle: "Experimente navegar entre as abas e passar parâmetros de rota dinâmicos."
            variant: "accent"

            // Layout do mini-app
            ColumnLayout {
                anchors.fill: parent
                spacing: DS.Theme.spacing.md

                // 1. Barra de Navegação Superior (Header / Navbar)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: DS.Theme.colors.mantle
                    radius: DS.Theme.geometry.radiusMd

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: DS.Theme.spacing.md
                        anchors.rightMargin: DS.Theme.spacing.md
                        spacing: DS.Theme.spacing.lg

                        // Links declarativos
                        DS.RouterLink {
                            to: "/home"
                            router: appRouter
                            text: "Início"
                            icon: "home"
                            activeColor: DS.Theme.colors.mauve
                        }

                        DS.RouterLink {
                            to: "/about"
                            router: appRouter
                            text: "Sobre"
                            icon: "info"
                            activeColor: DS.Theme.colors.mauve
                        }

                        DS.RouterLink {
                            to: "/users"
                            router: appRouter
                            text: "Usuários"
                            icon: "users"
                            activeColor: DS.Theme.colors.mauve
                        }

                        Item { Layout.fillWidth: true }

                        // Botões de Histórico
                        DS.Button {
                            text: "<-"
                            variant: "ghost"
                            size: "sm"
                            disabled: !appRouter.canGoBack
                            onClicked: appRouter.back()
                        }

                        DS.Button {
                            text: "->"
                            variant: "ghost"
                            size: "sm"
                            disabled: !appRouter.canGoForward
                            onClicked: appRouter.forward()
                        }
                    }
                }

                // 2. Área de Visualização Principal (Router Loader)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: DS.Theme.colors.crust
                    border.color: DS.Theme.colors.surface0
                    border.width: 1
                    radius: DS.Theme.geometry.radiusMd
                    clip: true

                    // Definição do Router
                    DS.Router {
                        id: appRouter
                        anchors.fill: parent
                        initialRoute: "/home"
                        transitionDuration: 300

                        // Rota Início
                        DS.Route {
                            path: "/home"
                            view: Component {
                                Item {
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: DS.Theme.spacing.md
                                        
                                        DS.LucideIcon {
                                            name: "home"
                                            size: 48
                                            color: DS.Theme.colors.mauve
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "Página Inicial"
                                            color: DS.Theme.colors.text
                                            font.family: DS.Theme.typography.familyBold
                                            font.pixelSize: DS.Theme.typography.sizeH2
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "Você está no início do mini-app."
                                            color: DS.Theme.colors.subtext0
                                            font.family: DS.Theme.typography.family
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }

                        // Rota Sobre
                        DS.Route {
                            path: "/about"
                            view: Component {
                                Item {
                                    Column {
                                        anchors.centerIn: parent
                                        spacing: DS.Theme.spacing.md
                                        
                                        DS.LucideIcon {
                                            name: "info"
                                            size: 48
                                            color: DS.Theme.colors.blue
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "Sobre o Roteador"
                                            color: DS.Theme.colors.text
                                            font.family: DS.Theme.typography.familyBold
                                            font.pixelSize: DS.Theme.typography.sizeH2
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                        Text {
                                            text: "Este roteador faz transições de fade automáticas de " + appRouter.transitionDuration + "ms."
                                            color: DS.Theme.colors.subtext0
                                            font.family: DS.Theme.typography.family
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }
                                    }
                                }
                            }
                        }

                        // Rota Lista de Usuários
                        DS.Route {
                            path: "/users"
                            view: Component {
                                Item {
                                    property var router: null // Recebe referência ao roteador automaticamente
                                    
                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: DS.Theme.spacing.md
                                        width: 300

                                        Text {
                                            text: "Selecione um usuário:"
                                            color: DS.Theme.colors.text
                                            font.family: DS.Theme.typography.familyBold
                                            font.pixelSize: DS.Theme.typography.sizeLg
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        DS.Button {
                                            text: "Ver Perfil de Alice (ID: alice)"
                                            variant: "tonal"
                                            Layout.fillWidth: true
                                            onClicked: router.push("/users/alice")
                                        }

                                        DS.Button {
                                            text: "Ver Perfil de Bob (ID: bob)"
                                            variant: "tonal"
                                            Layout.fillWidth: true
                                            onClicked: router.push("/users/bob")
                                        }
                                        
                                        DS.Button {
                                            text: "Ver Perfil de Charlie (ID: charlie)"
                                            variant: "tonal"
                                            Layout.fillWidth: true
                                            onClicked: router.push("/users/charlie")
                                        }
                                    }
                                }
                            }
                        }

                        // Rota Perfil do Usuário (Parâmetro Dinâmico)
                        DS.Route {
                            path: "/users/:id"
                            view: Component {
                                Item {
                                    // As seguintes propriedades são injetadas automaticamente pelo Router:
                                    property var params: ({})
                                    property var router: null

                                    Column {
                                        anchors.centerIn: parent
                                        spacing: DS.Theme.spacing.md
                                        
                                        DS.Avatar {
                                            name: params.id ? params.id.toUpperCase() : "?"
                                            size: "xl"
                                            color: "pink"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "Perfil do Usuário"
                                            color: DS.Theme.colors.text
                                            font.family: DS.Theme.typography.familyBold
                                            font.pixelSize: DS.Theme.typography.sizeH2
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        Text {
                                            text: "ID carregado da URL (:id): " + params.id
                                            color: DS.Theme.colors.primary
                                            font.family: DS.Theme.typography.familyBold
                                            font.pixelSize: DS.Theme.typography.sizeMd
                                            anchors.horizontalCenter: parent.horizontalCenter
                                        }

                                        DS.Button {
                                            text: "Voltar para Lista de Usuários"
                                            variant: "outline"
                                            leftIcon: "arrow-left"
                                            anchors.horizontalCenter: parent.horizontalCenter
                                            onClicked: router.push("/users")
                                        }
                                    }
                                }
                            }
                        }

                        // Catch-all (404)
                        DS.Route {
                            path: "*"
                            view: Component {
                                Item {
                                    Text {
                                        text: "Página não encontrada!"
                                        color: DS.Theme.colors.danger
                                        anchors.centerIn: parent
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    ]

    controls: [
        DS.VStack {
            spacing: DS.Theme.spacing.md
            width: parent.width

            Text {
                text: "Status do Roteador"
                color: DS.Theme.colors.text
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeMd
            }

            Text {
                text: "Caminho Atual: " + appRouter.currentPath
                color: DS.Theme.colors.subtext1
                font.family: DS.Theme.typography.family
            }

            Text {
                text: "Histórico: " + (appRouter.historyIndex + 1) + " / " + appRouter.historyLength
                color: DS.Theme.colors.subtext1
                font.family: DS.Theme.typography.family
            }

            DS.Separator {}

            DS.Button {
                text: "Resetar para Início"
                variant: "outline"
                width: parent.width
                onClicked: appRouter.reset("/home")
            }

            DS.Button {
                text: "Simular Rota 404"
                variant: "ghost"
                width: parent.width
                onClicked: appRouter.push("/qualquer-caminho-invalido")
            }
        }
    ]
}
