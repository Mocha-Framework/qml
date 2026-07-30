import QtQuick 2.15

Item {
    id: chartRoot

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property var chartData: []
    property color lineColor: Theme.colors.primary
    property bool fillArea: true
    property real maxValue: -1
    property int gridLines: 4
    property bool smooth: true
    property bool animated: true

    // Internal Calculations
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

    property real drawProgress: animated ? 0.0 : 1.0
    Behavior on drawProgress { NumberAnimation { duration: 1000; easing.type: Easing.OutQuart } }

    property int hoverIndex: -1
    readonly property var hoveredItem: hoverIndex >= 0 && hoverIndex < chartData.length ? chartData[hoverIndex] : null

    onChartDataChanged: { hoverIndex = -1; chartCanvas.requestPaint() }
    onLineColorChanged: chartCanvas.requestPaint()
    onComputedMaxValueChanged: chartCanvas.requestPaint()
    onDrawProgressChanged: chartCanvas.requestPaint()
    onFillAreaChanged: chartCanvas.requestPaint()
    onSmoothChanged: chartCanvas.requestPaint()

    Component.onCompleted: if (animated) drawProgress = 1.0

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

    // 2. Chart Grid & Canvas
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

        Canvas {
            id: chartCanvas; anchors.fill: parent; antialiasing: true
            onPaint: {
                var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height); ctx.beginPath()
                if (!chartRoot.chartData || chartRoot.chartData.length < 2) return
                var w = width; var h = height; var len = chartRoot.chartData.length; var px = 20; var py = 20; var cw = w - px * 2; var ch = h - py * 2
                var points = []
                for (var i = 0; i < len; i++) {
                    var x = px + (i * (cw / (len - 1)))
                    var y = h - py - ((chartRoot.chartData[i].value / chartRoot.computedMaxValue) * ch) * chartRoot.drawProgress
                    points.push({ x: x, y: y })
                }
                if (chartRoot.fillArea && points.length > 0) {
                    ctx.beginPath(); ctx.moveTo(points[0].x, h - py)
                    if (chartRoot.smooth) {
                        ctx.lineTo(points[0].x, points[0].y)
                        for (var j = 0; j < points.length - 1; j++) {
                            var p0 = points[j], p1 = points[j+1]
                            ctx.bezierCurveTo(p0.x + (p1.x - p0.x)/2, p0.y, p0.x + (p1.x - p0.x)/2, p1.y, p1.x, p1.y)
                        }
                        ctx.lineTo(points[len-1].x, h - py)
                    } else {
                        for (var k = 0; k < len; k++) ctx.lineTo(points[k].x, points[k].y)
                        ctx.lineTo(points[len-1].x, h - py)
                    }
                    ctx.closePath(); var grad = ctx.createLinearGradient(0, py, 0, h - py); var c = chartRoot.lineColor
                    grad.addColorStop(0, "rgba(" + Math.round(c.r*255) + "," + Math.round(c.g*255) + "," + Math.round(c.b*255) + ",0.3)")
                    grad.addColorStop(1, "rgba(" + Math.round(c.r*255) + "," + Math.round(c.g*255) + "," + Math.round(c.b*255) + ",0.0)")
                    ctx.fillStyle = grad; ctx.fill()
                }
                ctx.beginPath(); ctx.moveTo(points[0].x, points[0].y)
                if (chartRoot.smooth) {
                    for (var m = 0; m < len - 1; m++) {
                        var pt0 = points[m], pt1 = points[m+1]
                        ctx.bezierCurveTo(pt0.x + (pt1.x - pt0.x)/2, pt0.y, pt0.x + (pt1.x - pt0.x)/2, pt1.y, pt1.x, pt1.y)
                    }
                } else {
                    for (var n = 1; n < len; n++) ctx.lineTo(points[n].x, points[n].y)
                }
                ctx.strokeStyle = chartRoot.lineColor; ctx.lineWidth = 3; ctx.lineCap = "round"; ctx.lineJoin = "round"; ctx.stroke()
            }
        }

        MouseArea {
            id: ha; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton
            onPositionChanged: {
                if (!chartRoot.chartData || chartRoot.chartData.length < 2) return
                var idx = Math.max(0, Math.min(chartRoot.chartData.length - 1, Math.round((mouseX - 20) / ((width - 40) / (chartRoot.chartData.length - 1)))))
                chartRoot.hoverIndex = idx
            }
            onExited: chartRoot.hoverIndex = -1
        }

        Rectangle {
            id: hd; width: 12; height: 12; radius: 6; color: chartRoot.lineColor; border.color: "white"; border.width: 2
            visible: chartRoot.hoverIndex >= 0 && chartRoot.drawProgress === 1.0
            x: chartRoot.hoverIndex < 0 ? 0 : 20 + (chartRoot.hoverIndex * ((parent.width - 40) / (chartRoot.chartData.length - 1))) - 6
            y: chartRoot.hoverIndex < 0 ? 0 : parent.height - 20 - (chartRoot.chartData[chartRoot.hoverIndex].value / chartRoot.computedMaxValue) * (parent.height - 40) - 6
            Behavior on x { NumberAnimation { duration: 80 } }
            Behavior on y { NumberAnimation { duration: 80 } }
            ChartTooltip {
                showTooltip: chartRoot.hoverIndex >= 0
                title: chartRoot.hoveredItem ? chartRoot.hoveredItem.label : ""
                items: chartRoot.hoveredItem ? [{
                    color: chartRoot.lineColor,
                    label: "Valor",
                    value: chartRoot.hoveredItem.value
                }] : []
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
