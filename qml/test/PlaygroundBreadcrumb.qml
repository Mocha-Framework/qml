import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Breadcrumb"
    description: "Navegação hierárquica com separadores entre itens."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent

            DS.Breadcrumb {
                items: [
                    { label: "Home", onClicked: function() { pg.showToast("Home") } },
                    { label: "Produtos", onClicked: function() { pg.showToast("Produtos") } },
                    { label: "Categoria", onClicked: function() { pg.showToast("Categoria") } },
                    { label: "Item Atual" }
                ]
                size: sizeSelect.model[sizeSelect.currentIndex]
            }

            DS.Breadcrumb {
                separator: "slash"
                items: [
                    { label: "docs", onClicked: function() { pg.showToast("docs") } },
                    { label: "api", onClicked: function() { pg.showToast("api") } },
                    { label: "v2" }
                ]
                size: sizeSelect.model[sizeSelect.currentIndex]
            }

            DS.Breadcrumb {
                separator: "arrow-right"
                items: [
                    { label: "Início", onClicked: function() { pg.showToast("Início") } },
                    { label: "Configurações" }
                ]
                size: sizeSelect.model[sizeSelect.currentIndex]
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md"]
            currentIndex: 0
        }
    ]

    function showToast(label) {
        print("Breadcrumb clicked: " + label);
    }
}
