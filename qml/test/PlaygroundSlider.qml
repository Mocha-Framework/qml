import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Slider"
    description: "Controle deslizante para seleção de valor numérico."

    property real sliderValue: 50
    property real slider2Value: 25

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent
            width: parent.width * 0.6

            Column {
                spacing: DS.Theme.spacing.sm
                width: parent.width

                Text {
                    text: "Volume: " + Math.round(pg.sliderValue) + "%"
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeSm
                    color: DS.Theme.colors.text
                }

                DS.Slider {
                    width: parent.width
                    value: pg.sliderValue
                    minimum: 0
                    maximum: 100
                    step: 1
                    size: sizeSelect.model[sizeSelect.currentIndex]
                    onValueChanged: pg.sliderValue = value
                }
            }

            Column {
                spacing: DS.Theme.spacing.sm
                width: parent.width

                Text {
                    text: "Temperatura: " + Math.round(pg.slider2Value) + "°C"
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeSm
                    color: DS.Theme.colors.text
                }

                DS.Slider {
                    width: parent.width
                    value: pg.slider2Value
                    minimum: -10
                    maximum: 45
                    step: 5
                    size: sizeSelect.model[sizeSelect.currentIndex]
                    onValueChanged: pg.slider2Value = value
                }
            }

            DS.Slider {
                width: parent.width
                value: 75
                disabled: disabledSwitch.checked
                size: sizeSelect.model[sizeSelect.currentIndex]
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        },
        PlaygroundCtrlSwitch {
            id: disabledSwitch
            label: "Desabilitado"
        }
    ]
}
