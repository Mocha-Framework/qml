import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Shell"
    description: "Estrutura de layout principal para aplicações com sidebar, header e footer."

    componentItem: [
        DS.Shell {
            anchors.fill: parent

            header: Rectangle {
                height: 48
                color: DS.Theme.colors.mantle

                Text {
                    text: "Header"
                    font.family: DS.Theme.typography.familyBold
                    color: DS.Theme.colors.text
                    anchors.centerIn: parent
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: DS.Theme.colors.surface0
                }
            }

            sidebar: Rectangle {
                width: 200
                color: DS.Theme.colors.base

                Column {
                    anchors.fill: parent
                    anchors.margins: DS.Theme.spacing.lg
                    spacing: DS.Theme.spacing.md

                    Text {
                        text: "Sidebar"
                        font.family: DS.Theme.typography.familyBold
                        color: DS.Theme.colors.subtext1
                    }

                    Repeater {
                        model: ["Dashboard", "Usuários", "Configurações"]
                        delegate: Text {
                            text: modelData
                            font.family: DS.Theme.typography.family
                            color: DS.Theme.colors.primary
                        }
                    }
                }
            }

            footer: Rectangle {
                height: 40
                color: DS.Theme.colors.mantle
                Rectangle {
                    anchors.top: parent.top
                    width: parent.width
                    height: 1
                    color: DS.Theme.colors.surface0
                }

                Text {
                    text: "Footer © 2026"
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeSm
                    color: DS.Theme.colors.subtext0
                    anchors.centerIn: parent
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"

                Text {
                    text: "Conteúdo principal"
                    font.family: DS.Theme.typography.family
                    color: DS.Theme.colors.text
                    anchors.centerIn: parent
                }
            }
        }
    ]

    controls: []
}
