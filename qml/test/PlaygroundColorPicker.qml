import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "ColorPicker"
    description: "Seletor de cor com paleta de cores e valor hex."

    property color selected: DS.Theme.colors.mauve

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent
            width: 350

            DS.ColorPicker {
                width: parent.width
                selectedColor: pg.selected
                placeholder: "Escolha uma cor..."
                size: sizeSelect.model[sizeSelect.currentIndex]
                onSelectedColorChanged: pg.selected = selectedColor
            }

            Rectangle {
                width: 60
                height: 60
                radius: DS.Theme.geometry.radiusMd
                color: pg.selected
                anchors.horizontalCenter: parent.horizontalCenter

                Text {
                    text: pg.selected.toString().substring(0, 7)
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeXs
                    color: DS.Theme.isDarkColor(pg.selected) ? "white" : "black"
                    anchors.centerIn: parent
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        }
    ]
}
