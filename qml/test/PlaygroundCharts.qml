import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Charts"
    description: "Visualizações de dados variadas (Bar, Line, Radar, Gauge)."

    // ──────────────────────────────────────────
    // Reactive data properties
    // ──────────────────────────────────────────
    property var barData: [
        { label: "Jan", value: 400 },
        { label: "Fev", value: 300 },
        { label: "Mar", value: 600 },
        { label: "Abr", value: 800 }
    ]

    property var lineData: [
        { label: "Semana 1", value: 10 },
        { label: "Semana 2", value: 25 },
        { label: "Semana 3", value: 45 },
        { label: "Semana 4", value: 30 }
    ]

    property var radarData: [
        { label: "Design",    value: 80 },
        { label: "Dev",       value: 95 },
        { label: "Marketing", value: 40 },
        { label: "RH",        value: 60 }
    ]

    property real gaugeValue: 0.65

    // ──────────────────────────────────────────
    // Randomise helper
    // ──────────────────────────────────────────
    function randomBetween(min, max) {
        return Math.floor(Math.random() * (max - min + 1)) + min;
    }

    function randomiseData() {
        // Bar chart — values 50..950
        var newBar = [];
        var barLabels = ["Jan", "Fev", "Mar", "Abr"];
        for (var i = 0; i < barLabels.length; i++) {
            newBar.push({ label: barLabels[i], value: randomBetween(50, 950) });
        }
        pg.barData = newBar;

        // Line chart — values 5..50
        var newLine = [];
        var lineLabels = ["Semana 1", "Semana 2", "Semana 3", "Semana 4"];
        for (var j = 0; j < lineLabels.length; j++) {
            newLine.push({ label: lineLabels[j], value: randomBetween(5, 50) });
        }
        pg.lineData = newLine;

        // Radar chart — values 10..100
        var newRadar = [];
        var radarLabels = ["Design", "Dev", "Marketing", "RH"];
        for (var k = 0; k < radarLabels.length; k++) {
            newRadar.push({ label: radarLabels[k], value: randomBetween(10, 100) });
        }
        pg.radarData = newRadar;

        // Gauge — 0.05..1.0 in steps of 0.05
        pg.gaugeValue = randomBetween(5, 100) / 100;
    }

    componentItem: [
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl
            spacing: DS.Theme.spacing.xl

            RowLayout {
                spacing: DS.Theme.spacing.xl

                DS.BarChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    chartData: pg.barData
                }

                DS.LineChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    chartData: pg.lineData
                }
            }

            RowLayout {
                spacing: DS.Theme.spacing.xl

                DS.RadarChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    chartData: pg.radarData
                }

                DS.GaugeChart {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250
                    label: "CPU"
                    value: pg.gaugeValue
                }
            }
        }
    ]

    controls: [
        Text {
            text: "Visão geral dos componentes de visualização de dados."
            color: DS.Theme.colors.subtext0
            font.pixelSize: DS.Theme.typography.sizeMd
            wrapMode: Text.WordWrap
            width: parent ? parent.width : implicitWidth
        },

        DS.Button {
            text: "Randomizar Dados"
            icon: "shuffle"
            variant: "primary"
            width: parent ? parent.width : implicitWidth
            onClicked: pg.randomiseData()
        }
    ]
}
