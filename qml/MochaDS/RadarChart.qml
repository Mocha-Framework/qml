import QtQuick 2.15

Item {
    id: chartRoot

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property var chartData: [] // Array of { label: "Strength", value: 80 }
    property color color: Theme.colors.mauve
    property real maxValue: 100
    property int levels: 4
    property bool animated: true

    property real drawProgress: animated ? 0.0 : 1.0
    Behavior on drawProgress { NumberAnimation { duration: 1200; easing.type: Easing.OutQuart } }

    Component.onCompleted: if (animated) drawProgress = 1.0
    onChartDataChanged: chartCanvas.requestPaint()
    onDrawProgressChanged: chartCanvas.requestPaint()

    implicitWidth: 300
    implicitHeight: 300
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: chartArea
        anchors.fill: parent
        color: Theme.colors.mantle
        radius: Theme.geometry.radiusMd
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        clip: true

        Canvas {
            id: chartCanvas
            anchors.fill: parent
            anchors.margins: 40
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                if (!chartRoot.chartData || chartRoot.chartData.length < 3) return

                var centerX = width / 2
                var centerY = height / 2
                var radius = Math.min(width, height) / 2
                var sides = chartRoot.chartData.length

                // 1. Draw Grid Web
                ctx.strokeStyle = Theme.colors.surface1
                ctx.lineWidth = 1
                ctx.setLineDash([2, 2])
                
                for (var l = 1; l <= chartRoot.levels; l++) {
                    var r = (radius / chartRoot.levels) * l
                    ctx.beginPath()
                    for (var s = 0; l === chartRoot.levels && s < sides; s++) {
                        // Draw radial lines on the outer level
                        var angleRadial = (s * 2 * Math.PI / sides) - Math.PI / 2
                        ctx.moveTo(centerX, centerY)
                        ctx.lineTo(centerX + radius * Math.cos(angleRadial), centerY + radius * Math.sin(angleRadial))
                    }
                    ctx.stroke()

                    ctx.beginPath()
                    for (var i = 0; i <= sides; i++) {
                        var angle = (i * 2 * Math.PI / sides) - Math.PI / 2
                        var x = centerX + r * Math.cos(angle)
                        var y = centerY + r * Math.sin(angle)
                        if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y)
                    }
                    ctx.stroke()
                }
                ctx.setLineDash([]) // Reset dash

                // 2. Draw Data Shape
                var points = []
                for (var j = 0; j < sides; j++) {
                    var val = chartRoot.chartData[j].value
                    var dataR = (val / chartRoot.maxValue) * radius * chartRoot.drawProgress
                    var dataAngle = (j * 2 * Math.PI / sides) - Math.PI / 2
                    points.push({
                        x: centerX + dataR * Math.cos(dataAngle),
                        y: centerY + dataR * Math.sin(dataAngle)
                    })
                }

                ctx.beginPath()
                ctx.moveTo(points[0].x, points[0].y)
                for (var k = 1; k < points.length; k++) ctx.lineTo(points[k].x, points[k].y)
                ctx.closePath()

                var c = chartRoot.color
                ctx.fillStyle = "rgba(" + Math.round(c.r*255) + "," + Math.round(c.g*255) + "," + Math.round(c.b*255) + ",0.3)"
                ctx.fill()
                ctx.strokeStyle = c
                ctx.lineWidth = 3
                ctx.stroke()

                // 3. Data Points
                for (var p = 0; p < points.length; p++) {
                    ctx.beginPath()
                    ctx.arc(points[p].x, points[p].y, 4, 0, Math.PI * 2)
                    ctx.fillStyle = Theme.colors.text
                    ctx.fill()
                    ctx.strokeStyle = c
                    ctx.lineWidth = 2
                    ctx.stroke()
                }
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        // 4. Labels (Floating outside)
        Repeater {
            model: chartRoot.chartData
            delegate: Text {
                text: modelData.label
                font.family: Theme.typography.family; font.pixelSize: 10; color: Theme.colors.subtext1
                
                readonly property real angle: (index * 2 * Math.PI / chartRoot.chartData.length) - Math.PI / 2
                readonly property real dist: Math.min(chartArea.width, chartArea.height) / 2 - 15
                
                x: chartArea.width / 2 + dist * Math.cos(angle) - width / 2
                y: chartArea.height / 2 + dist * Math.sin(angle) - height / 2
                antialiasing: true
            }
        }
    }
}
