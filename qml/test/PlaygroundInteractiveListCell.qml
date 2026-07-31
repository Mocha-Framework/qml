import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "InteractiveListCell"
    description: "Célula de lista interativa com hover e clique, usando rowContent personalizado."

    componentItem: [
        Column {
            spacing: 0
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl

            Repeater {
                model: [
                    { name: "João Silva", email: "joao@email.com", role: "Admin" },
                    { name: "Maria Santos", email: "maria@email.com", role: "Editor" },
                    { name: "Carlos Souza", email: "carlos@email.com", role: "Viewer" }
                ]

                delegate: DS.InteractiveListCell {
                    width: parent.width

                    rowContent: Row {
                        spacing: DS.Theme.spacing.md
                        anchors.verticalCenter: parent.verticalCenter

                        DS.Avatar { name: modelData.name; size: "sm" }

                        Column {
                            spacing: 2
                            anchors.verticalCenter: parent.verticalCenter
                            Text {
                                text: modelData.name
                                font.family: DS.Theme.typography.familyBold
                                font.pixelSize: DS.Theme.typography.sizeMd
                                color: DS.Theme.colors.text
                            }
                            Text {
                                text: modelData.email
                                font.family: DS.Theme.typography.family
                                font.pixelSize: DS.Theme.typography.sizeXs
                                color: DS.Theme.colors.subtext0
                            }
                        }

                        Item { width: 1; height: 1 }

                        DS.Badge {
                            text: modelData.role
                            size: "sm"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    onClicked: print("Clicked:", modelData.name)
                }
            }
        }
    ]

    controls: []
}
