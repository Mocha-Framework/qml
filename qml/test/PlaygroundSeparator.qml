import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Separator"
    description: "Linha divisória horizontal ou vertical com variantes de cor."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.xl
            anchors.centerIn: parent
            width: parent.width * 0.6

            Column {
                spacing: DS.Theme.spacing.md
                width: parent.width

                Text {
                    text: "Seção 1"
                    font.family: DS.Theme.typography.familyBold
                    color: DS.Theme.colors.text
                }
                Text {
                    text: "Conteúdo da primeira seção."
                    font.family: DS.Theme.typography.family
                    color: DS.Theme.colors.subtext0
                }
            }

            DS.Separator { width: parent.width; variant: variantSelect.model[variantSelect.currentIndex] }

            Column {
                spacing: DS.Theme.spacing.md
                width: parent.width

                Text {
                    text: "Seção 2"
                    font.family: DS.Theme.typography.familyBold
                    color: DS.Theme.colors.text
                }
                Text {
                    text: "Conteúdo da segunda seção."
                    font.family: DS.Theme.typography.family
                    color: DS.Theme.colors.subtext0
                }
            }

            DS.Separator { width: parent.width; variant: "accent" }

            Column {
                spacing: DS.Theme.spacing.md
                width: parent.width

                Text {
                    text: "Seção 3"
                    font.family: DS.Theme.typography.familyBold
                    color: DS.Theme.colors.text
                }
                Text {
                    text: "Conteúdo da terceira seção."
                    font.family: DS.Theme.typography.family
                    color: DS.Theme.colors.subtext0
                }
            }

            Row {
                spacing: DS.Theme.spacing.md
                anchors.horizontalCenter: parent.horizontalCenter
                height: 60

                Text {
                    text: "Item A"
                    font.family: DS.Theme.typography.family
                    color: DS.Theme.colors.text
                    anchors.verticalCenter: parent.verticalCenter
                }

                DS.Separator { orientation: "vertical"; height: parent.height }

                Text {
                    text: "Item B"
                    font.family: DS.Theme.typography.family
                    color: DS.Theme.colors.text
                    anchors.verticalCenter: parent.verticalCenter
                }

                DS.Separator { orientation: "vertical"; height: parent.height; variant: "accent" }

                Text {
                    text: "Item C"
                    font.family: DS.Theme.typography.family
                    color: DS.Theme.colors.text
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "Variante"
            model: ["default", "subtle", "accent"]
            currentIndex: 0
        }
    ]
}
