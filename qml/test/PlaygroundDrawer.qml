import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Drawer"
    description: "Painéis laterais deslizantes para navegação ou configurações extras."

    componentItem: [
        Item {
            anchors.fill: parent
            
            DS.Drawer {
                id: myDrawer
                title: titleText.text
                subtitle: "Painel deslizante interativo"
                position: posSelect.model[posSelect.currentIndex]
                open: false
                
                Column {
                    width: parent.width
                    spacing: DS.Theme.spacing.lg
                    
                    Text {
                        width: parent.width
                        text: "O Drawer é ideal para filtros, configurações rápidas ou navegação mobile."
                        color: DS.Theme.colors.text
                        wrapMode: Text.WordWrap
                        font.family: DS.Theme.typography.family
                    }
                    
                    DS.Button {
                        text: "Fechar"
                        variant: "outline"
                        width: parent.width
                        onClicked: myDrawer.open = false
                    }
                }
            }

            DS.Button {
                anchors.centerIn: parent
                text: "Abrir Drawer"
                variant: "primary"
                onClicked: myDrawer.open = true
            }
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: titleText
            label: "Título"
            text: "Configurações"
        },
        PlaygroundCtrlSelect {
            id: posSelect
            label: "Posição"
            model: ["right", "left", "top", "bottom"]
            currentIndex: 0
        }
    ]
}
