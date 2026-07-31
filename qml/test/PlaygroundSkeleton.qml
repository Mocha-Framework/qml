import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Skeleton"
    description: "Espaços reservados animados para estados de carregamento de conteúdo."

    componentItem: [
        Column {
            anchors.centerIn: parent
            spacing: DS.Theme.spacing.md
            width: 300

            Row {
                spacing: DS.Theme.spacing.md
                DS.CozySkeleton { width: 60; height: 60; radius: 30 }
                Column {
                    spacing: DS.Theme.spacing.sm
                    anchors.verticalCenter: parent.verticalCenter
                    DS.CozySkeleton { width: 180; height: 16 }
                    DS.CozySkeleton { width: 120; height: 12 }
                }
            }
            
            DS.CozySkeleton { width: parent.width; height: 100 }
        }
    ]

    controls: [
        Text {
            text: "Skeletons são animados automaticamente."
            color: DS.Theme.colors.subtext0
            font.pixelSize: DS.Theme.typography.sizeMd
            width: parent.width
            wrapMode: Text.WordWrap
        }
    ]
}
