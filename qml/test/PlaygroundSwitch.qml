import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Switch"
    description: "Controle liga/desliga com animação de slide."
    codeSnippet: "Switch {\n    checked: false\n    label: \"Notificações\"\n    size: \"" + sizeSelect.model[sizeSelect.currentIndex] + "\"\n    " + (disabledSwitch.checked ? "disabled: true\n    " : "") + "onToggled: function(checked) { /* ação */ }\n}"

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent

            DS.Switch {
                checked: false
                label: "Notificações"
                size: sizeSelect.model[sizeSelect.currentIndex]
            }

            DS.Switch {
                checked: true
                label: "Modo escuro"
                size: sizeSelect.model[sizeSelect.currentIndex]
            }

            DS.Switch {
                checked: false
                disabled: disabledSwitch.checked
                label: "Modo avião"
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
