import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "RangeSelector"
    description: "Seletor de intervalo com dois controles deslizantes (mínimo e máximo)."

    property real rangeMin: 20
    property real rangeMax: 80

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.lg
            anchors.centerIn: parent
            width: parent.width * 0.6

            DS.RangeSelector {
                width: parent.width
                min: 0
                max: 100
                firstValue: pg.rangeMin
                secondValue: pg.rangeMax
                step: 1
                onValuesChanged: {
                    pg.rangeMin = first;
                    pg.rangeMax = second;
                }
            }

            Text {
                text: "Intervalo: " + Math.round(pg.rangeMin) + " — " + Math.round(pg.rangeMax)
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    ]

    controls: []
}
