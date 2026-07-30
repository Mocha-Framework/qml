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
    property bool animated: true
    property real donutRatio: 0.0 // 0.0 = Pie, 0.5+ = Donut

    // Animation progress
    property real drawProgress: animated ? 0.0 : 1.0
    Behavior on drawProgress { NumberAnimation { duration: 1000; easing.type: Easing.OutQuart } }

    property int hoverIndex: -1
    readonly property var hoveredItem: hoverIndex >= 0 && hoverIndex < chartData.length ? chartData[hoverIndex] : null

    onChartDataChanged: { hoverIndex = -1; chartCanvas.requestPaint() }
    onDrawProgressChanged: chartCanvas.requestPaint()
    onDonutRatioChanged: chartCanvas.requestPaint()

    Component.onCompleted: if (animated) drawProgress = 1.0

    implicitWidth: 300
    implicitHeight: 300
    width: implicitWidth
    height: implicitHeight

    // ------------------------------------------
    // 1. Chart Container
    // ------------------------------------------
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
            anchors.margins: 20
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                
                if (!chartRoot.chartData || chartRoot.chartData.length === 0) return

                var centerX = width / 2
                var centerY = height / 2
                var radius = Math.min(width, height) / 2
                var innerRadius = radius * chartRoot.donutRatio

                var total = 0
                for (var i = 0; i < chartRoot.chartData.length; i++) {
                    total += chartRoot.chartData[i].value
                }
                if (total === 0) return

                var startAngle = -Math.PI / 2 // Start from top
                
                for (var j = 0; j < chartRoot.chartData.length; j++) {
                    var sliceAngle = (chartRoot.chartData[j].value / total) * Math.PI * 2 * chartRoot.drawProgress
                    var endAngle = startAngle + sliceAngle

                    // Draw Slice
                    ctx.beginPath()
                    ctx.moveTo(centerX, centerY)
                    ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                    ctx.lineTo(centerX, centerY)
                    ctx.closePath()

                    // Gradient for the slice
                    var grad = ctx.createRadialGradient(centerX, centerY, innerRadius, centerX, centerY, radius)
                    var c = chartRoot.colors[j % chartRoot.colors.length]
                    grad.addColorStop(0, c)
                    grad.addColorStop(1, Qt.darker(c, 1.1))
                    
                    ctx.fillStyle = grad
                    ctx.fill()

                    // Stroke/Gap between slices
                    ctx.strokeStyle = Theme.colors.mantle
                    ctx.lineWidth = 2
                    ctx.stroke()

                    startAngle = endAngle
                }

                // If it's a donut, clear the center
                if (chartRoot.donutRatio > 0) {
                    ctx.globalCompositeOperation = "destination-out"
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, innerRadius, 0, Math.PI * 2)
                    ctx.fill()
                    ctx.globalCompositeOperation = "source-over"
                    
                    // Draw inner border for donut
                    ctx.beginPath()
                    ctx.arc(centerX, centerY, innerRadius, 0, Math.PI * 2)
                    ctx.strokeStyle = Theme.colors.surface0
                    ctx.lineWidth = 1
                    ctx.stroke()
                }
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        // ------------------------------------------
        // 2. Interaction & Hover
        // ------------------------------------------
        MouseArea {
            id: mouseArea
            anchors.fill: chartCanvas
            anchors.margins: 20
            hoverEnabled: true
            acceptedButtons: Qt.NoButton

            onPositionChanged: {
                var centerX = width / 2
                var centerY = height / 2
                var dx = mouseX - centerX
                var dy = mouseY - centerY
                var dist = Math.sqrt(dx*dx + dy*dy)
                var radius = Math.min(width, height) / 2
                
                if (dist > radius || dist < radius * chartRoot.donutRatio) {
                    chartRoot.hoverIndex = -1
                    return
                }

                var angle = Math.atan2(dy, dx) + Math.PI / 2
                if (angle < 0) angle += Math.PI * 2

                var total = 0
                for (var i = 0; i < chartRoot.chartData.length; i++) total += chartRoot.chartData[i].value
                
                var currentAngle = 0
                for (var j = 0; j < chartRoot.chartData.length; j++) {
                    var sliceAngle = (chartRoot.chartData[j].value / total) * Math.PI * 2
                    if (angle >= currentAngle && angle < currentAngle + sliceAngle) {
                        chartRoot.hoverIndex = j
                        return
                    }
                    currentAngle += sliceAngle
                }
            }
            onExited: chartRoot.hoverIndex = -1
        }

        // Center Text for Donut
        Column {
            anchors.centerIn: parent
            visible: chartRoot.donutRatio > 0.4
            spacing: -2
            Text {
                text: chartRoot.hoveredItem ? chartRoot.hoveredItem.value : ""
                font.family: Theme.typography.familyBold
                font.pixelSize: 24
                color: Theme.colors.text
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: chartRoot.hoveredItem ? chartRoot.hoveredItem.label : "Total"
                font.family: Theme.typography.family
                font.pixelSize: 12
                color: Theme.colors.subtext1
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // Tooltip for Pie mode
        ChartTooltip {
            showTooltip: chartRoot.hoverIndex >= 0 && chartRoot.donutRatio < 0.4
            title: chartRoot.hoveredItem ? chartRoot.hoveredItem.label : ""
            items: chartRoot.hoveredItem ? [{
                color: chartRoot.colors[chartRoot.hoverIndex % chartRoot.colors.length],
                label: "Valor",
                value: chartRoot.hoveredItem.value
            }] : []
            placement: "top"
        }
    }
}
