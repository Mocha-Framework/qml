import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "ProgressBar"
    description: "Indicadores de progresso visual com suporte a animações e estados."

    property real progressValue: 45

    componentItem: [
        Column {
            anchors.centerIn: parent
            width: 400
            spacing: DS.Theme.spacing.xl

            DS.ProgressBar {
                width: parent.width
                value: pg.progressValue / 100
                variant: variantSelect.model[variantSelect.currentIndex]
                showLabel: labelSwitch.checked
                indeterminate: indetSwitch.checked
            }

            Slider {
                id: progressSlider
                width: parent.width
                from: 0
                to: 100
                value: 45
                visible: !indetSwitch.checked
                onValueChanged: pg.progressValue = value
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["primary", "success", "warning", "danger", "peach", "mauve"]
            currentIndex: 0
        },
        PlaygroundCtrlSwitch {
            id: labelSwitch
            label: "Mostrar Label"
            checked: true
        },
        PlaygroundCtrlSwitch {
            id: indetSwitch
            label: "Indeterminado"
        }
    ]
}
