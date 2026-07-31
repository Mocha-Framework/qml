import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "CozyColorPicker"
    description: "Seletor de cor compacto com pré-visualização de cor e valor hex."

    property color selected: DS.Theme.colors.mauve

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent

            DS.CozyColorPicker {
                id: picker
                onColorChanged: pg.selected = picker.selectedColor
            }

            Rectangle {
                width: 80
                height: 40
                radius: DS.Theme.geometry.radiusSm
                color: pg.selected
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    ]

    controls: []
}
