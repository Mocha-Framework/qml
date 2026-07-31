import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "DropZone"
    description: "Zona de drop com highlight visual ao receber itens arrastáveis."

    // State for items and their current zones ("" = source list, "green", "red", "blue")
    property var items: [
        { uid: "item1", label: "Item 1", zone: "", color: DS.Theme.colors.green },
        { uid: "item2", label: "Item 2", zone: "", color: DS.Theme.colors.red },
        { uid: "item3", label: "Item 3", zone: "", color: DS.Theme.colors.blue }
    ]

    function updateItemZone(uid, newZone) {
        var newItems = []
        for (var i = 0; i < pg.items.length; i++) {
            var item = pg.items[i]
            var updatedItem = {
                uid: item.uid,
                label: item.label,
                zone: item.uid === uid ? newZone : item.zone,
                color: item.color
            }
            newItems.push(updatedItem)
        }
        pg.items = newItems
    }

    componentItem: [
        Column {
            anchors.centerIn: parent
            spacing: DS.Theme.spacing.xl

            Text {
                text: "Arraste os cards sobre as zonas correspondentes:"
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeMd
                color: DS.Theme.colors.subtext0
                anchors.horizontalCenter: parent.horizontalCenter
            }

            // Source list of items (only showing items with zone === "")
            Row {
                spacing: DS.Theme.spacing.lg
                anchors.horizontalCenter: parent.horizontalCenter
                height: 80

                Repeater {
                    model: pg.items
                    delegate: DS.Draggable {
                        visible: modelData.zone === ""
                        key: "zone"
                        width: 120
                        height: 80
                        dragData: modelData

                        DS.Card {
                            anchors.fill: parent
                            variant: "tonal"
                            title: modelData.label
                            icon: "move"
                        }
                    }
                }
            }

            // Drop zones row
            Row {
                spacing: DS.Theme.spacing.lg
                anchors.horizontalCenter: parent.horizontalCenter

                // 1. Green Zone
                DS.DropZone {
                    id: greenZone
                    key: "zone"
                    width: 180
                    height: 120
                    accentColor: DS.Theme.colors.green

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: DS.Theme.geometry.radiusMd
                        border.color: greenZone.containsDrag ? DS.Theme.colors.green : DS.Theme.colors.surface0
                        border.width: 2

                        Column {
                            anchors.centerIn: parent
                            spacing: DS.Theme.spacing.xs

                            Text {
                                text: greenZone.containsDrag ? "✅ Soltar!" : "🟢 Zona Verde"
                                font.family: DS.Theme.typography.family
                                font.pixelSize: DS.Theme.typography.sizeSm
                                color: greenZone.containsDrag ? DS.Theme.colors.green : DS.Theme.colors.subtext0
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Display items dropped here
                            Repeater {
                                model: pg.items
                                delegate: Text {
                                    visible: modelData.zone === "green"
                                    text: modelData.label
                                    font.family: DS.Theme.typography.familyMedium
                                    font.pixelSize: DS.Theme.typography.sizeSm
                                    color: DS.Theme.colors.green
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    onDropped: function(source) {
                        pg.updateItemZone(source.dragData.uid, "green")
                    }
                }

                // 2. Red Zone
                DS.DropZone {
                    id: redZone
                    key: "zone"
                    width: 180
                    height: 120
                    accentColor: DS.Theme.colors.red

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: DS.Theme.geometry.radiusMd
                        border.color: redZone.containsDrag ? DS.Theme.colors.red : DS.Theme.colors.surface0
                        border.width: 2

                        Column {
                            anchors.centerIn: parent
                            spacing: DS.Theme.spacing.xs

                            Text {
                                text: redZone.containsDrag ? "❌ Soltar!" : "🔴 Zona Vermelha"
                                font.family: DS.Theme.typography.family
                                font.pixelSize: DS.Theme.typography.sizeSm
                                color: redZone.containsDrag ? DS.Theme.colors.red : DS.Theme.colors.subtext0
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Display items dropped here
                            Repeater {
                                model: pg.items
                                delegate: Text {
                                    visible: modelData.zone === "red"
                                    text: modelData.label
                                    font.family: DS.Theme.typography.familyMedium
                                    font.pixelSize: DS.Theme.typography.sizeSm
                                    color: DS.Theme.colors.red
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    onDropped: function(source) {
                        pg.updateItemZone(source.dragData.uid, "red")
                    }
                }

                // 3. Blue Zone
                DS.DropZone {
                    id: blueZone
                    key: "zone"
                    width: 180
                    height: 120
                    accentColor: DS.Theme.colors.blue

                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                        radius: DS.Theme.geometry.radiusMd
                        border.color: blueZone.containsDrag ? DS.Theme.colors.blue : DS.Theme.colors.surface0
                        border.width: 2

                        Column {
                            anchors.centerIn: parent
                            spacing: DS.Theme.spacing.xs

                            Text {
                                text: blueZone.containsDrag ? "🔵 Soltar!" : "🔵 Zona Azul"
                                font.family: DS.Theme.typography.family
                                font.pixelSize: DS.Theme.typography.sizeSm
                                color: blueZone.containsDrag ? DS.Theme.colors.blue : DS.Theme.colors.subtext0
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            // Display items dropped here
                            Repeater {
                                model: pg.items
                                delegate: Text {
                                    visible: modelData.zone === "blue"
                                    text: modelData.label
                                    font.family: DS.Theme.typography.familyMedium
                                    font.pixelSize: DS.Theme.typography.sizeSm
                                    color: DS.Theme.colors.blue
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    onDropped: function(source) {
                        pg.updateItemZone(source.dragData.uid, "blue")
                    }
                }
            }
        }
    ]

    controls: [
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: DS.Theme.spacing.md

            Button {
                text: "Resetar Itens"
                onClicked: {
                    pg.items = [
                        { uid: "item1", label: "Item 1", zone: "", color: DS.Theme.colors.green },
                        { uid: "item2", label: "Item 2", zone: "", color: DS.Theme.colors.red },
                        { uid: "item3", label: "Item 3", zone: "", color: DS.Theme.colors.blue }
                    ]
                }
            }
        }
    ]
}
