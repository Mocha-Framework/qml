import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Tooltip"
    description: "Dicas flutuantes que aparecem ao passar o mouse sobre elementos."

    componentItem: [
        Column {
            anchors.centerIn: parent
            spacing: 20

            Rectangle {
                width: 150
                height: 150
                color: DS.Theme.colors.surface0
                radius: DS.Theme.geometry.radiusMd
                border.color: DS.Theme.colors.surface1
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Passe o mouse"
                    color: DS.Theme.colors.text
                }

                DS.Tooltip {
                    text: tooltipText.text
                    placement: posSelect.model[posSelect.currentIndex]
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: tooltipText
            label: "Texto do Tooltip"
            text: "Esta é uma dica informativa!"
        },
        PlaygroundCtrlSelect {
            id: posSelect
            label: "Posição"
            model: ["top", "bottom", "left", "right"]
            currentIndex: 0
        }
    ]
}
