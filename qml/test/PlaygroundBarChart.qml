import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "BarChart"
    description: "Gráfico de barras para visualização de dados comparativos."

    property var data: [
        { label: "Jan", value: 400 },
        { label: "Fev", value: 300 },
        { label: "Mar", value: 600 },
        { label: "Abr", value: 800 },
        { label: "Mai", value: 500 },
        { label: "Jun", value: 700 }
    ]

    componentItem: [
        DS.BarChart {
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
