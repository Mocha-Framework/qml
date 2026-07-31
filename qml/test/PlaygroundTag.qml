import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Tag"
    description: "Chips/Tags para filtros, labels e categorias com suporte a remoção e drag."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent

            Row {
                spacing: DS.Theme.spacing.sm
                DS.Tag { text: "React"; color: "blue"; icon: "code"; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
                DS.Tag { text: "TypeScript"; color: "sapphire"; icon: "file-text"; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
                DS.Tag { text: "QML"; color: "green"; icon: "layout"; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
            }

            Row {
                spacing: DS.Theme.spacing.sm
                DS.Tag { text: "Importante"; color: "red"; removable: true; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
                DS.Tag { text: "Design"; color: "mauve"; removable: true; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
                DS.Tag { text: "Backlog"; color: "yellow"; removable: true; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
            }

            Row {
                spacing: DS.Theme.spacing.sm
                DS.Tag { text: "Selecionado"; color: "teal"; selected: true; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
                DS.Tag { text: "Normal"; color: "peach"; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
                DS.Tag { text: "Ícone"; color: "sky"; icon: "star"; variant: variantSelect.model[variantSelect.currentIndex]; draggable: draggableSwitch.checked }
            }

            DS.DropZone {
                id: tagTrashZone
                key: "mochads-tag"
                width: 300
                height: 60
                anchors.horizontalCenter: parent.horizontalCenter
                visible: draggableSwitch.checked
                accentColor: DS.Theme.colors.red

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: DS.Theme.geometry.radiusMd
                    border.color: tagTrashZone.containsDrag ? DS.Theme.colors.red : DS.Theme.colors.surface0
                    border.width: 2
                    border.style: tagTrashZone.containsDrag ? Qt.SolidLine : Qt.DashLine

                    Row {
                        anchors.centerIn: parent
                        spacing: DS.Theme.spacing.sm
                        DS.LucideIcon {
                            name: "trash-2"
                            size: 20
                            color: tagTrashZone.containsDrag ? DS.Theme.colors.red : DS.Theme.colors.subtext0
                        }
                        Text {
                            text: tagTrashZone.containsDrag ? "Solte para remover" : "Arraste uma tag para a lixeira"
                            font.family: DS.Theme.typography.family
                            font.pixelSize: DS.Theme.typography.sizeSm
                            color: tagTrashZone.containsDrag ? DS.Theme.colors.red : DS.Theme.colors.subtext0
                        }
                    }
                }

                onDropped: function(source) {
                    console.log("Tag removida:", source.text)
                    source.visible = false
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["tonal", "filled", "outline"]
            currentIndex: 0
        },
        PlaygroundCtrlSwitch {
            id: draggableSwitch
            label: "Draggable (Arrastável)"
            checked: false
        }
    ]
}
