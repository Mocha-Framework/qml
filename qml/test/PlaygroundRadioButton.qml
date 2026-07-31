import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "RadioButton"
    description: "Botão de opção única com suporte a grupos."

    property var selected: ""

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.lg
            anchors.centerIn: parent

            DS.RadioGroup {
                selectedValue: pg.selected

                DS.RadioButton { label: "Opção A"; value: "op1"; size: sizeSelect.model[sizeSelect.currentIndex] }
                DS.RadioButton { label: "Opção B"; value: "op2"; size: sizeSelect.model[sizeSelect.currentIndex] }
                DS.RadioButton { label: "Opção C"; value: "op3"; size: sizeSelect.model[sizeSelect.currentIndex] }
                DS.RadioButton { label: "Desabilitado"; value: "op4"; disabled: true; size: sizeSelect.model[sizeSelect.currentIndex] }
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
