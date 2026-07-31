import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "AlertDialog"
    description: "Diálogos de confirmação e alerta com variantes de tipo."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.lg
            anchors.centerIn: parent

            DS.Button {
                text: "Info"
                variant: "outline"
                onClicked: infoDialog.open = true
            }

            DS.Button {
                text: "Sucesso"
                variant: "outline"
                color: "green"
                onClicked: successDialog.open = true
            }

            DS.Button {
                text: "Aviso"
                variant: "outline"
                color: "yellow"
                onClicked: warningDialog.open = true
            }

            DS.Button {
                text: "Erro"
                variant: "outline"
                color: "red"
                onClicked: errorDialog.open = true
            }

            DS.Button {
                text: "Confirmar"
                variant: "primary"
                onClicked: confirmDialog.open = true
            }
        }
    ]

    controls: []

    DS.AlertDialog {
        id: infoDialog
        dialogType: "info"
        dialogTitle: "Informação"
        dialogMessage: "Esta é uma mensagem informativa para o usuário."
        showCancel: false
    }

    DS.AlertDialog {
        id: successDialog
        dialogType: "success"
        dialogTitle: "Operação Concluída"
        dialogMessage: "O arquivo foi salvo com sucesso."
        showCancel: false
    }

    DS.AlertDialog {
        id: warningDialog
        dialogType: "warning"
        dialogTitle: "Atenção"
        dialogMessage: "Esta ação não pode ser desfeita. Deseja continuar?"
        confirmLabel: "Continuar"
        cancelLabel: "Cancelar"
    }

    DS.AlertDialog {
        id: errorDialog
        dialogType: "error"
        dialogTitle: "Erro"
        dialogMessage: "Ocorreu um erro ao processar sua solicitação."
        confirmLabel: "Ok"
        showCancel: false
    }

    DS.AlertDialog {
        id: confirmDialog
        dialogType: "confirm"
        dialogTitle: "Confirmar Exclusão"
        dialogMessage: "Tem certeza que deseja excluir este item permanentemente?"
        confirmLabel: "Excluir"
        cancelLabel: "Cancelar"
        onConfirmed: print("Confirmado!")
        onCancelled: print("Cancelado!")
    }
}
