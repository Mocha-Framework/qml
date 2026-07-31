import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "RadioGroup"
    description: "Container que gerencia seleção exclusiva entre RadioButtons."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent

            DS.RadioGroup {
                selectedValue: "sm"

                Text {
                    text: "Selecione o tamanho:"
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeMd
                    color: DS.Theme.colors.text
                }

                DS.RadioButton { label: "Pequeno"; value: "sm" }
                DS.RadioButton { label: "Médio"; value: "md" }
                DS.RadioButton { label: "Grande"; value: "lg" }
            }

            DS.RadioGroup {
                direction: "horizontal"
                selectedValue: "blue"

                Text {
                    text: "Cor:"
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeMd
                    color: DS.Theme.colors.text
                }

                DS.RadioButton { label: "Azul"; value: "blue" }
                DS.RadioButton { label: "Verde"; value: "green" }
                DS.RadioButton { label: "Vermelho"; value: "red" }
            }
        }
    ]

    controls: []
}
