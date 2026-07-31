import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "AdvancedTextEditor"
    description: "Editor Markdown com alternância entre visual WYSIWYG e código fonte."

    componentItem: [
        DS.AdvancedTextEditor {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl
            text: sampleText.text
            placeholder: placeholderInput.text
            visualMode: visualSwitch.checked
            showToolbar: toolbarSwitch.checked
            showStatusbar: statusbarSwitch.checked
            readOnly: readOnlySwitch.checked
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: sampleText
            label: "Texto (Markdown)"
            text: "# Título\n\nEste é um **texto** com *formatação*.\n\n- Item 1\n- Item 2\n\n> Citação importante"
        },
        PlaygroundCtrlTextField {
            id: placeholderInput
            label: "Placeholder"
            text: "Digite em Markdown..."
        },
        PlaygroundCtrlSwitch {
            id: visualSwitch
            label: "Modo Visual"
            checked: true
        },
        PlaygroundCtrlSwitch {
            id: toolbarSwitch
            label: "Mostrar Toolbar"
            checked: true
        },
        PlaygroundCtrlSwitch {
            id: statusbarSwitch
            label: "Mostrar Status Bar"
            checked: true
        },
        PlaygroundCtrlSwitch {
            id: readOnlySwitch
            label: "Somente Leitura"
        }
    ]
}
