import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "HStack"
    description: "Layout horizontal flexível (Flexbox row). justify-content + align-items."

    componentItem: [
        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width - 40, 500)
            height: 80
            color: DS.Theme.colors.mantle
            radius: DS.Theme.geometry.radiusMd
            border.color: DS.Theme.colors.surface1
            border.width: 1

            DS.HStack {
                anchors.fill: parent
                anchors.margins: DS.Theme.spacing.md
                justifyContent: justifySelect.model[justifySelect.currentIndex]
                alignItems: alignSelect.model[alignSelect.currentIndex]
                spacing: spacingSlider.value

                Rectangle { width: 50; height: 28; radius: 4; color: DS.Theme.colors.mauve }
                Rectangle { width: 50; height: 28; radius: 4; color: DS.Theme.colors.blue }
                Rectangle { width: 50; height: 28; radius: 4; color: DS.Theme.colors.green }
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
            currentIndex: 1
        },
        PlaygroundCtrlSlider {
            id: spacingSlider
            label: "spacing"
            from: 0; to: 32; value: 12
        }
    ]
}
