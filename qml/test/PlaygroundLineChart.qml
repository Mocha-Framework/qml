import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "LineChart"
    description: "Gráfico de linhas para visualização de tendências ao longo do tempo."

    property var data: [
        { label: "Jan", value: 10 },
        { label: "Fev", value: 25 },
        { label: "Mar", value: 45 },
        { label: "Abr", value: 30 },
        { label: "Mai", value: 60 },
        { label: "Jun", value: 55 },
        { label: "Jul", value: 80 },
        { label: "Ago", value: 70 }
    ]

    componentItem: [
        DS.LineChart {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl
            chartData: pg.data
            animated: animSwitch.checked
        }
    ]

    controls: [
        PlaygroundCtrlSwitch {
            id: animSwitch
            label: "Animado"
            checked: true
        }
    ]
}
