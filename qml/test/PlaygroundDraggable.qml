import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Draggable"
    description: "Wrapper que transforma qualquer conteúdo em algo arrastável com feedback visual."

    // State for source and dropped items
    property var sourceItems: [
        { uid: "card1", label: "Bloco A", color: DS.Theme.colors.mauve },
        { uid: "card2", label: "Bloco B", color: DS.Theme.colors.blue },
        { uid: "card3", label: "Bloco C", color: DS.Theme.colors.green }
    ]
    property var droppedItems: []

    componentItem: [
        Column {
            anchors.centerIn: parent
            spacing: DS.Theme.spacing.xl

            Text {
                text: pg.sourceItems.length > 0 ? "Arraste os blocos abaixo para a zona de drop:" : "Todos os blocos foram movidos!"
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeMd
                color: DS.Theme.colors.subtext0
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: DS.Theme.spacing.lg
                anchors.horizontalCenter: parent.horizontalCenter
                height: 100

                Repeater {
                    model: pg.sourceItems
                    delegate: DS.Draggable {
                        key: "card"
                        width: 160
                        height: 100
                        dragData: modelData

                        Rectangle {
                            anchors.fill: parent
                            radius: DS.Theme.geometry.radiusMd
                            color: DS.Theme.colors.surface0
                            border.color: modelData.color
                            border.width: 2

                            Column {
                                anchors.centerIn: parent
                                spacing: 4
                                DS.LucideIcon { name: "move"; size: 24; color: modelData.color; anchors.horizontalCenter: parent.horizontalCenter }
                                Text { text: modelData.label; font.family: DS.Theme.typography.familyMedium; font.pixelSize: DS.Theme.typography.sizeMd; color: DS.Theme.colors.text; anchors.horizontalCenter: parent.horizontalCenter }
                            }
                        }
                    }
                }
            }

            DS.DropZone {
                id: cardDropZone
                key: "card"
                width: 500
                height: 120
                anchors.horizontalCenter: parent.horizontalCenter

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    radius: DS.Theme.geometry.radiusMd
                    border.color: cardDropZone.containsDrag ? DS.Theme.colors.mauve : DS.Theme.colors.surface0
                    border.width: 2

                    Text {
                        text: cardDropZone.containsDrag ? "🔥 Solte aqui!" : "⬇ Zona de Drop"
                        font.family: DS.Theme.typography.family
                        font.pixelSize: DS.Theme.typography.sizeMd
                        color: cardDropZone.containsDrag ? DS.Theme.colors.mauve : DS.Theme.colors.subtext0
                        anchors.centerIn: parent
                        visible: pg.droppedItems.length === 0
                    }

                    // Display dropped items
                    Row {
                        anchors.centerIn: parent
                        spacing: DS.Theme.spacing.md
                        visible: pg.droppedItems.length > 0

                        Repeater {
                            model: pg.droppedItems
                            delegate: Rectangle {
                                width: 120
                                height: 80
                                radius: DS.Theme.geometry.radiusMd
                                color: DS.Theme.colors.surface1
                                border.color: modelData.color
                                border.width: 1

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 2
                                    DS.LucideIcon { name: "check-circle-2"; size: 16; color: modelData.color; anchors.horizontalCenter: parent.horizontalCenter }
                                    Text { text: modelData.label; font.family: DS.Theme.typography.familyMedium; font.pixelSize: DS.Theme.typography.sizeSm; color: DS.Theme.colors.text; anchors.horizontalCenter: parent.horizontalCenter }
                                }
                            }
                        }
                    }
                }

                onDropped: function(source) {
                    var data = source.dragData
                    if (!data) return
                    
                    // Remove from sourceItems
                    var newSource = []
                    for (var i = 0; i < pg.sourceItems.length; i++) {
                        if (pg.sourceItems[i].uid !== data.uid) {
                            newSource.push(pg.sourceItems[i])
                        }
                    }
                    pg.sourceItems = newSource

                    // Add to droppedItems
                    var newDropped = []
                    for (var j = 0; j < pg.droppedItems.length; j++) {
                        newDropped.push(pg.droppedItems[j])
                    }
                    newDropped.push(data)
                    pg.droppedItems = newDropped
                }
            }
        }
    ]

    controls: [
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: DS.Theme.spacing.md

            Button {
                text: "Resetar Blocos"
                onClicked: {
                    pg.sourceItems = [
                        { uid: "card1", label: "Bloco A", color: DS.Theme.colors.mauve },
                        { uid: "card2", label: "Bloco B", color: DS.Theme.colors.blue },
                        { uid: "card3", label: "Bloco C", color: DS.Theme.colors.green }
                    ]
                    pg.droppedItems = []
                }
            }
        }
    ]
}
