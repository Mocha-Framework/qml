import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "CozyGrid"
    description: "Sistema de grid responsivo com layout flexível."

    componentItem: [
        Column {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl
            spacing: DS.Theme.spacing.md

            Text {
                text: "Grid com model + delegate:"
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0
            }

            DS.CozyGrid {
                width: parent.width
                model: 6
                delegate: Rectangle {
                    height: 80
                    color: [DS.Theme.colors.mauve, DS.Theme.colors.blue, DS.Theme.colors.teal,
                            DS.Theme.colors.peach, DS.Theme.colors.green, DS.Theme.colors.sky][index % 6]
                    radius: DS.Theme.geometry.radiusMd

                    Text {
                        text: "Item " + (index + 1)
                        color: "white"
                        font.family: DS.Theme.typography.familyBold
                        anchors.centerIn: parent
                    }
                }
            }

            Text {
                text: "Grid com children diretos:"
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0
            }

            DS.CozyGrid {
                width: parent.width

                Rectangle { height: 60; color: DS.Theme.colors.surface0; radius: DS.Theme.geometry.radiusSm }
                Rectangle { height: 60; color: DS.Theme.colors.surface0; radius: DS.Theme.geometry.radiusSm }
                Rectangle { height: 60; color: DS.Theme.colors.surface0; radius: DS.Theme.geometry.radiusSm }
                Rectangle { height: 60; color: DS.Theme.colors.surface0; radius: DS.Theme.geometry.radiusSm }
            }
        }
    ]

    controls: []
}
