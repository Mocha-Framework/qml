import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Box"
    description: "Container tipo div com padding/margin CSS-like e variants."

    componentItem: [
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width - 40, 500)
            height: Math.min(parent.height - 40, 200)
            color: DS.Theme.colors.crust
            radius: DS.Theme.geometry.radiusMd
            border.color: DS.Theme.colors.surface0
            border.width: 1

            DS.Box {
                anchors.centerIn: parent
                p: padSelect.model[padSelect.currentIndex]
                m: marginSelect.model[marginSelect.currentIndex]
                variant: variantSelect.model[variantSelect.currentIndex]
                colorName: colorSelect.model[colorSelect.currentIndex]

                Text {
                    text: "Box content"
                    color: {
                        if (pg.variantSelect.model[pg.variantSelect.currentIndex] === "filled")
                            return DS.Theme.colors.crust
                        return DS.Theme.colors.text
                    }
                    font.family: DS.Theme.typography.familyMedium
                    anchors.centerIn: parent
                }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: padSelect
            label: "padding (p)"
            model: ["none", "xs", "sm", "md", "lg", "xl"]
            currentIndex: 3
        },
        PlaygroundCtrlSelect {
            id: marginSelect
            label: "margin (m)"
            model: ["none", "xs", "sm", "md", "lg", "xl"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: variantSelect
            label: "variant"
            model: ["default", "surface", "elevated", "outline"]
            currentIndex: 1
        },
        PlaygroundCtrlSelect {
            id: colorSelect
            label: "colorName"
            model: ["", "mauve", "blue", "green", "surface0", "mantle"]
            currentIndex: 0
        }
    ]
}
