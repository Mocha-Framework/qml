import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Avatar"
    description: "Avatar/Foto de perfil com fallback de iniciais e indicador de status."

    componentItem: [
        Row {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent

            Column {
                spacing: DS.Theme.spacing.md
                DS.Avatar { name: "João Silva"; size: sizeSelect.model[sizeSelect.currentIndex] }
                Text {
                    text: "Iniciais"
                    font.pixelSize: DS.Theme.typography.sizeXs
                    color: DS.Theme.colors.subtext0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                spacing: DS.Theme.spacing.md
                DS.Avatar { name: "Maria Santos"; variant: "accent"; size: sizeSelect.model[sizeSelect.currentIndex] }
                Text {
                    text: "Accent"
                    font.pixelSize: DS.Theme.typography.sizeXs
                    color: DS.Theme.colors.subtext0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                spacing: DS.Theme.spacing.md
                DS.Avatar { name: "Carlos"; showStatus: true; isOnline: true; size: sizeSelect.model[sizeSelect.currentIndex] }
                Text {
                    text: "Online"
                    font.pixelSize: DS.Theme.typography.sizeXs
                    color: DS.Theme.colors.subtext0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Column {
                spacing: DS.Theme.spacing.md
                DS.Avatar { name: "Ana"; showStatus: true; isOnline: false; size: sizeSelect.model[sizeSelect.currentIndex] }
                Text {
                    text: "Offline"
                    font.pixelSize: DS.Theme.typography.sizeXs
                    color: DS.Theme.colors.subtext0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg", "xl"]
            currentIndex: 1
        }
    ]
}
