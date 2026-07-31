import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "SortableList"
    description: "Lista com reordenação por drag & drop usando DelegateModel."

    componentItem: [
        DS.SortableList {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl

            model: ListModel {
                ListElement { label: "Introdução ao Mocha-DS"; icon: "file-text" }
                ListElement { label: "Componentes Foundation"; icon: "box" }
                ListElement { label: "Sistema de Temas"; icon: "palette" }
                ListElement { label: "Interatividade & DND"; icon: "move" }
                ListElement { label: "Casos de Uso"; icon: "layout" }
            }

            delegate: Item {
                width: parent.width
                height: 48

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: DS.Theme.spacing.sm
                    anchors.rightMargin: DS.Theme.spacing.sm
                    color: DS.Theme.colors.surface0
                    radius: DS.Theme.geometry.radiusMd

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: DS.Theme.spacing.md
                        spacing: DS.Theme.spacing.md

                        DS.LucideIcon {
                            name: "grip-vertical"
                            size: 18
                            color: DS.Theme.colors.overlay0
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        DS.LucideIcon {
                            name: model.icon
                            size: 20
                            color: DS.Theme.colors.primary
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "#" + index + " - " + model.label
                            font.family: DS.Theme.typography.familyMedium
                            font.pixelSize: DS.Theme.typography.sizeMd
                            color: DS.Theme.colors.text
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }

            onItemsReordered: function(fromIndex, toIndex) {
                console.log("Reordenado:", fromIndex, "->", toIndex)
            }
        }
    ]

    controls: []
}
