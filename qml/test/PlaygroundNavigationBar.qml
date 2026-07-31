import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "NavigationBar"
    description: "Barra de navegação inferior com itens e variantes de estilo."

    property int navIndex: 0

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent
            width: parent.width

            DS.NavigationBar {
                width: parent.width
                currentIndex: pg.navIndex
                variant: variantSelect.model[variantSelect.currentIndex]

                DS.NavigationItem { iconName: "home"; label: "Início" }
                DS.NavigationItem { iconName: "search"; label: "Buscar" }
                DS.NavigationItem { iconName: "bell"; label: "Notificações" }
                DS.NavigationItem { iconName: "user"; label: "Perfil" }
            }

            Text {
                text: "Aba selecionada: " + pg.navIndex
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["standard", "floating", "expanding", "labeled"]
            currentIndex: 0
        }
    ]
}
