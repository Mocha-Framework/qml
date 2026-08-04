import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "If"
    description: "Renderiza then/else condicionalmente com transicao. Reativo: re-avalia quando condition muda."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.lg
            anchors.centerIn: parent
            width: Math.min(parent.width - 80, 500)

            Row {
                spacing: DS.Theme.spacing.md
                DS.Button {
                    text: "Toggle (count: " + pg.showThen + ")"
                    onClicked: pg.showThen = !pg.showThen
                }
            }

            DS.If {
                condition: pg.showThen
                then: Component {
                    Rectangle {
                        width: 400
                        height: 120
                        color: DS.Theme.colors.green
                        radius: DS.Theme.geometry.radiusMd
                        Text {
                            anchors.centerIn: parent
                            text: "THEN (true)"
                            color: "white"
                            font.pixelSize: 20
                        }
                    }
                }
                else: Component {
                    Rectangle {
                        width: 400
                        height: 120
                        color: DS.Theme.colors.red
                        radius: DS.Theme.geometry.radiusMd
                        Text {
                            anchors.centerIn: parent
                            text: "ELSE (false)"
                            color: "white"
                            font.pixelSize: 20
                        }
                    }
                }
                transition: transitionSelect.model[transitionSelect.currentIndex]
                duration: durationSlider.value
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: transitionSelect
            label: "Transition"
            model: ["none", "fade", "slide", "zoom", "bounce", "spin", "flip", "all"]
            currentIndex: 1
        },
        PlaygroundCtrlSlider {
            id: durationSlider
            label: "Duration (ms)"
            from: 0
            to: 1000
            step: 50
            value: 250
        }
    ]

    property bool showThen: true
}
