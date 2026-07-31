import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "StripedFill"
    description: "Preenchimento listrado animado usando shader effect."

    componentItem: [
        Row {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent

            Rectangle {
                width: 150
                height: 150
                radius: DS.Theme.geometry.radiusMd
                clip: true

                DS.StripedFill {
                    anchors.fill: parent
                    color1: DS.Theme.colors.mauve
                    color2: DS.Theme.colors.base
                }
            }

            Rectangle {
                width: 150
                height: 150
                radius: DS.Theme.geometry.radiusMd
                clip: true

                DS.StripedFill {
                    anchors.fill: parent
                    color1: DS.Theme.colors.green
                    color2: DS.Theme.colors.teal
                }
            }

            Rectangle {
                width: 150
                height: 150
                radius: DS.Theme.geometry.radiusMd
                clip: true

                DS.StripedFill {
                    anchors.fill: parent
                    color1: DS.Theme.colors.sky
                    color2: DS.Theme.colors.sapphire
                }
            }
        }
    ]

    controls: []
}
