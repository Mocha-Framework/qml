import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Playground {
    id: pg
    title: "Dropdown"
    description: "Menu contextual de ações que abre perto de um elemento gatilho."

    componentItem: [
        Item {
            anchors.fill: parent
            
            DS.Dropdown {
                id: myMenu
                items: [
                    { label: "Editar", icon: "pencil" },
                    { label: "Duplicar", icon: "copy" },
                    { separator: true },
                    { label: "Excluir", icon: "trash-2", variant: "danger" }
                ]
                onItemSelected: function(item) { 
                    statusText.text = "Selecionado: " + item.label;
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 20
                
                DS.Button {
                    text: "Abrir Dropdown"
                    variant: "primary"
                    onClicked: myMenu.toggle(this)
                }

                Text {
                    id: statusText
                    text: "Selecione uma opção..."
                    color: DS.Theme.colors.subtext0
                    font.family: DS.Theme.typography.family
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    ]

    controls: [
        Text {
            text: "Interaja com o botão para ver o menu."
            color: DS.Theme.colors.subtext0
            font.pixelSize: DS.Theme.typography.sizeMd
        }
    ]
}
