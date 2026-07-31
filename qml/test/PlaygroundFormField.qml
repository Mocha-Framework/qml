import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "FormField"
    description: "Formulário de testes completo para validação de foco e navegação via teclado (Tab)."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.md
            anchors.centerIn: parent
            width: 400

            Text {
                text: "Pressione Tab para navegar sequencialmente entre os campos:"
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0
                Layout.alignment: Qt.AlignHCenter
            }

            // 1. Campo de Texto (Nome)
            DS.FormField {
                width: parent.width
                label: "Nome Completo"
                required: true
                DS.TextField {
                    id: nameField
                    width: parent.width
                    placeholder: "Digite seu nome..."
                }
            }

            // 2. Campo de Seleção (Cargo)
            DS.FormField {
                width: parent.width
                label: "Função / Cargo"
                required: true
                DS.Select {
                    id: roleSelect
                    width: parent.width
                    placeholder: "Selecione seu cargo..."
                    options: ["Desenvolvedor Frontend", "Desenvolvedor Backend", "UI/UX Designer", "Gerente de Produto"]
                }
            }

            // 3. Campo de Texto Longo (Biografia)
            DS.FormField {
                width: parent.width
                label: "Biografia"
                DS.TextEditor {
                    id: bioEditor
                    width: parent.width
                    height: 100
                    placeholder: "Conte um pouco sobre suas habilidades..."
                }
            }

            // 4. Checkbox (Aceitar Termos)
            DS.Checkbox {
                id: termsCheckbox
                width: parent.width
                label: "Aceito os termos e condições de uso"
            }

            // 5. Switch (Notificações)
            DS.Switch {
                id: notifSwitch
                width: parent.width
                label: "Desejo receber notificações por email"
            }

            // 6. Botões de Ação
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: DS.Theme.spacing.sm
                spacing: DS.Theme.spacing.md

                DS.Button {
                    text: "Cancelar"
                    variant: "outline"
                    Layout.fillWidth: true
                }

                DS.Button {
                    text: "Enviar Formulário"
                    variant: "primary"
                    Layout.fillWidth: true
                    onClicked: {
                        console.log("Nome:", nameField.text)
                        console.log("Cargo:", roleSelect.selectedLabel)
                        console.log("Bio:", bioEditor.text)
                        console.log("Termos:", termsCheckbox.checked)
                        console.log("Notificações:", notifSwitch.checked)
                    }
                }
            }
        }
    ]

    controls: []
}
