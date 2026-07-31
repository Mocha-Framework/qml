import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "ButtonGroup"
    description: "Grupos de botões segmentados com indicadores deslizantes."

    componentItem: [
        DS.ButtonGroup {
            anchors.centerIn: parent
            currentIndex: 0
            expand: expandSwitch.checked
            variant: variantSelect.model[variantSelect.currentIndex]
            
            DS.ButtonGroupItem { text: "Opção 1"; iconName: "monitor" }
            DS.ButtonGroupItem { text: "Opção 2"; iconName: "sun" }
            DS.ButtonGroupItem { text: "Opção 3"; iconName: "moon" }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["line", "pill", "segmented", "card"]
            currentIndex: 2
        },
        PlaygroundCtrlSwitch {
            id: expandSwitch
            label: "Expandir"
        }
    ]
}
