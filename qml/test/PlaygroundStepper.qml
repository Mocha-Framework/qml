import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Stepper"
    description: "Componente de passos para formulários multi-etapas com ícones e descrição."

    property int step: 0

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent
            width: parent.width * 0.8

            DS.Stepper {
                id: stepper
                width: parent.width
                currentStep: pg.step
                orientation: orientationSelect.model[orientationSelect.currentIndex]
                variant: variantSelect.model[variantSelect.currentIndex]

                steps: [
                    { label: "Informações", description: "Dados pessoais", icon: "user" },
                    { label: "Endereço", description: "Localização", icon: "map-pin" },
                    { label: "Pagamento", description: "Forma de pagamento", icon: "credit-card" },
                    { label: "Revisão", description: "Confirme os dados", icon: "check-circle" }
                ]
            }

            Text {
                text: "Passo atual: " + (pg.step + 1) + " de 4"
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Row {
                spacing: DS.Theme.spacing.sm
                anchors.horizontalCenter: parent.horizontalCenter

                DS.Button {
                    text: "Anterior"
                    variant: "ghost"
                    disabled: pg.step === 0
                    onClicked: pg.step--
                }

                DS.Button {
                    text: "Próximo"
                    variant: "primary"
                    disabled: pg.step === 3
                    onClicked: pg.step++
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: orientationSelect
            label: "Orientação"
            model: ["horizontal", "vertical"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["default", "dots", "icon", "labeled-icon"]
            currentIndex: 3
        }
    ]
}
