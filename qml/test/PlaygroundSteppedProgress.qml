import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "SteppedProgress"
    description: "Barra de progresso com etapas definidas e indicador visual de conclusão."

    property int currentStep: 2

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent
            width: parent.width * 0.7

            DS.SteppedProgress {
                width: parent.width
                totalSteps: 5
                currentStep: pg.currentStep
            }

            Row {
                spacing: DS.Theme.spacing.sm
                anchors.horizontalCenter: parent.horizontalCenter

                DS.Button {
                    text: "<"
                    size: "sm"
                    variant: "ghost"
                    onClicked: pg.currentStep = Math.max(0, pg.currentStep - 1)
                }

                Repeater {
                    model: 5
                    delegate: DS.Button {
                        text: index + 1
                        size: "sm"
                        variant: pg.currentStep === index ? "primary" : "ghost"
                        onClicked: pg.currentStep = index
                    }
                }

                DS.Button {
                    text: ">"
                    size: "sm"
                    variant: "ghost"
                    onClicked: pg.currentStep = Math.min(4, pg.currentStep + 1)
                }
            }
        }
    ]

    controls: []
}
