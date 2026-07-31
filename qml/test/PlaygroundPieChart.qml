import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "PieChart"
    description: "Visualização de dados em formato de pizza/rosca."

    componentItem: [
        DS.PieChart {
            anchors.centerIn: parent
            width: 300
            height: 300
            
            donutRatio: donutSwitch.checked ? 0.6 : 0.0
            
            chartData: [
                { label: "Mocha", value: 40 },
                { label: "Latte", value: 25 },
                { label: "Frappé", value: 20 },
                { label: "Macchiato", value: 15 }
            ]
        }
    ]

    controls: [
        PlaygroundCtrlSwitch {
            id: donutSwitch
            label: "Modo Donut (Furo)"
            checked: true
        }
    ]
}
