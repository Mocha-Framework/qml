import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "EmptyState"
    description: "Estado vazio reutilizável para listas e tabelas sem dados."

    componentItem: [
        Row {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent

            DS.EmptyState {
                icon: iconSelect.model[iconSelect.currentIndex]
                title: titleField.text
                description: descField.text
                size: sizeSelect.model[sizeSelect.currentIndex]
            }
        }
    ]

    controls: [
        PlaygroundCtrlTextField {
            id: titleField
            label: "Título"
            text: "Nenhum resultado encontrado"
        },
        PlaygroundCtrlTextField {
            id: descField
            label: "Descrição"
            text: "Tente ajustar os filtros ou realizar uma nova busca."
        },
        PlaygroundCtrlSelect {
            id: iconSelect
            label: "Ícone"
            model: ["inbox", "search", "file-text", "folder-open", "mail"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        }
    ]
}
