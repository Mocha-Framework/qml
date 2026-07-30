import QtQuick 2.15

Item {
    id: chartRoot

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property var chartData: []
    property var colors: [
        Theme.colors.primary, Theme.colors.secondary, Theme.colors.success,
        Theme.colors.warning, Theme.colors.danger, Theme.colors.peach,
        Theme.colors.teal, Theme.colors.mauve
    ]
    property real maxValue: -1
    property int gridLines: 4
    property bool animated: true

    readonly property real computedMaxValue: {
        if (maxValue > 0) return maxValue
        if (!chartData || chartData.length === 0) return 100
        var max = 0
        for (var i = 0; i < chartData.length; i++) {
            if (chartData[i].value > max) max = chartData[i].value
        }
        return max === 0 ? 100 : max * 1.1
    }

    function formatYLabel(index) {
        var increment = computedMaxValue / Math.max(1, gridLines)
        var val = computedMaxValue - (index * increment)
        if (val >= 1000) return (val / 1000).toFixed(1) + "k"
        return val.toFixed(0)
    }

    implicitWidth: 400
    implicitHeight: 250
    width: implicitWidth
    height: implicitHeight

    // 1. Y-Axis Labels
    Item {
        x: 0; y: 0; width: 40; height: parent ? parent.height - 24 : 0
        Repeater {
            model: chartRoot.gridLines + 1
            delegate: Text {
                text: chartRoot.formatYLabel(index)
                font.family: Theme.typography.family; font.pixelSize: 11; color: Theme.colors.overlay0
                x: parent.width - width - 8; y: (parent.height / Math.max(1, chartRoot.gridLines)) * index - height / 2; antialiasing: true
            }
        }
    }

    // 2. Main Chart Container
    Rectangle {
        id: gridContainer
        x: 40; y: 0; width: parent ? parent.width - 40 : 0; height: parent ? parent.height - 24 : 0
        color: Theme.colors.mantle; radius: Theme.geometry.radiusMd; border.color: Theme.colors.surface0; border.width: Theme.geometry.borderSm; clip: true

        Repeater {
            model: chartRoot.gridLines + 1
            delegate: Rectangle {
                width: parent.width; height: 1; color: Theme.colors.surface1; opacity: 0.15
                y: (parent.height / Math.max(1, chartRoot.gridLines)) * index; visible: index > 0 && index < chartRoot.gridLines
            }
        }

        Row {
            id: barsRow
            anchors.fill: parent; anchors.margins: 12; anchors.topMargin: 20; spacing: 8
            Repeater {
                model: chartRoot.chartData
                delegate: Item {
                    width: (barsRow.width - (Math.max(0, chartRoot.chartData.length - 1)) * barsRow.spacing) / Math.max(1, chartRoot.chartData.length)
                    height: parent.height
                    readonly property real targetHeight: (modelData.value / Math.max(1, chartRoot.computedMaxValue)) * height
                    property real animatedHeight: 0
                    Rectangle {
                        width: Math.min(48, parent.width * 0.8); height: Math.max(4, chartRoot.animated ? animatedHeight : targetHeight); radius: 4; anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.lighter(chartRoot.colors[index % chartRoot.colors.length], 1.1) }
                            GradientStop { position: 1.0; color: chartRoot.colors[index % chartRoot.colors.length] }
                        }
                        Rectangle { width: parent.width; height: parent.radius; color: chartRoot.colors[index % chartRoot.colors.length]; anchors.bottom: parent.bottom; visible: parent.height > parent.radius }
                        MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true }
                        ChartTooltip { 
                            showTooltip: ma.containsMouse
                            title: modelData.label
                            items: [{
                                color: chartRoot.colors[index % chartRoot.colors.length],
                                label: "Valor",
                                value: modelData.value
                            }]
                            placement: "top" 
                        }
                    }
                    Component.onCompleted: if (chartRoot.animated) animatedHeight = targetHeight
                    onTargetHeightChanged: if (chartRoot.animated) animatedHeight = targetHeight
                    Behavior on animatedHeight { NumberAnimation { duration: 800; easing.type: Easing.OutQuart } }
                }
            }
        }
    }

    // 3. X-Axis Labels
    Row {
        x: 40; y: gridContainer.height + 4; width: gridContainer.width; height: 20
        Repeater {
            model: chartRoot.chartData
            delegate: Text {
                width: parent.width / Math.max(1, chartRoot.chartData.length); text: modelData.label; font.family: Theme.typography.family; font.pixelSize: 11; color: Theme.colors.subtext1; horizontalAlignment: Text.AlignHCenter; elide: Text.ElideRight; antialiasing: true
            }
        }
    }
}
