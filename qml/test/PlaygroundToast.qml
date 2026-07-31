import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Toast"
    description: "Notificações temporárias para feedback imediato do sistema."

    componentItem: [
        Item {
            anchors.fill: parent
            
            DS.ToastManager {
                id: toastManager
                position: posSelect.model[posSelect.currentIndex]
            }

            Column {
                anchors.centerIn: parent
                spacing: DS.Theme.spacing.lg
                
                Row {
                    spacing: DS.Theme.spacing.md
                    DS.Button { text: "Sucesso"; variant: "primary"; onClicked: toastManager.success("Operação concluída com sucesso!") }
                    DS.Button { text: "Erro"; variant: "danger"; onClicked: toastManager.error("Ocorreu um erro ao processar.") }
                }
                
                Row {
                    spacing: DS.Theme.spacing.md
                    DS.Button { text: "Aviso"; variant: "secondary"; onClicked: toastManager.warning("Atenção aos detalhes.") }
                    DS.Button { text: "Info"; variant: "outline"; onClicked: toastManager.info("Novas atualizações disponíveis.") }
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: posSelect
            label: "Posição"
            model: ["top-right", "top-left", "bottom-right", "bottom-left"]
            currentIndex: 0
        }
    ]
}
