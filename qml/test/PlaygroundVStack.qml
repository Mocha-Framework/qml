import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "VStack"
    description: "Layout vertical flexível (Flexbox column). justify-content + align-items."

    componentItem: [
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width - 40, 400)
            height: Math.min(parent.height - 40, 200)
            color: DS.Theme.colors.mantle
            radius: DS.Theme.geometry.radiusMd
            border.color: DS.Theme.colors.surface1
            border.width: 1

            DS.VStack {
                anchors.fill: parent
                anchors.margins: DS.Theme.spacing.md
                justifyContent: justifySelect.model[justifySelect.currentIndex]
                alignItems: alignSelect.model[alignSelect.currentIndex]
                spacing: spacingSlider.value

                Rectangle { width: 80; height: 24; radius: 4; color: DS.Theme.colors.green }
                Rectangle { width: 60; height: 24; radius: 4; color: DS.Theme.colors.teal }
                Rectangle { width: 100; height: 24; radius: 4; color: DS.Theme.colors.sapphire }
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: justifySelect
            label: "justifyContent"
            model: ["start", "center", "end", "between", "around", "evenly"]
            currentIndex: 0
        },
        PlaygroundCtrlSelect {
            id: alignSelect
            label: "alignItems"
            model: ["start", "center", "end", "stretch"]
            currentIndex: 2
        },
        PlaygroundCtrlSlider {
            id: spacingSlider
            label: "spacing"
            from: 0; to: 32; value: 12
        }
    ]
}
