import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Spinner"
    description: "Indicador de carregamento animado e minimalista."

    componentItem: [
        DS.CozySpinner {
            anchors.centerIn: parent
            size: sizeSelect.model[sizeSelect.currentIndex] === "sm" ? 24 : (sizeSelect.model[sizeSelect.currentIndex] === "md" ? 48 : 64)
            color: colorSelect.model[colorSelect.currentIndex]
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: colorSelect
            label: "Cor"
            model: ["mauve", "blue", "green", "yellow", "red", "peach", "teal"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        }
    ]
}
