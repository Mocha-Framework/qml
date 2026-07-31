import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "ContextMenu"
    description: "Menu de contexto pop-over com suporte a ícones, atalhos e separadores."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.lg
            anchors.centerIn: parent

            DS.Button {
                text: "Clique direito aqui"
                variant: "outline"

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: ctxMenu.showAt(
                        mapToItem(pg, 0, 0).x,
                        mapToItem(pg, 0, 0).y)
                }
            }

            Text {
                text: "Ou clique com o botão direito em qualquer lugar aqui"
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.RightButton
                    onClicked: ctxMenu.showAt(
                        mapToItem(pg, mouse.x, mouse.y).x,
                        mapToItem(pg, mouse.x, mouse.y).y)
                }
            }
        }
    ]

    controls: []

    DS.ContextMenu {
        id: ctxMenu
        items: [
            { icon: "copy", label: "Copiar", shortcut: "Ctrl+C", onClicked: print("Copiar") },
            { icon: "scissors", label: "Recortar", shortcut: "Ctrl+X", onClicked: print("Recortar") },
            { icon: "clipboard", label: "Colar", shortcut: "Ctrl+V", onClicked: print("Colar") },
            { separator: true },
            { icon: "edit", label: "Renomear", shortcut: "F2", onClicked: print("Renomear") },
            { icon: "trash-2", label: "Excluir", shortcut: "Del", onClicked: print("Excluir") },
            { separator: true },
            { icon: "info", label: "Propriedades", shortcut: "Ctrl+I", onClicked: print("Propriedades") }
        ]
    }
}
