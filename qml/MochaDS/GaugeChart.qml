import QtQuick 2.15

Item {
    id: chartRoot

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property real value: 0.0     // 0.0 to 1.0
    property string label: ""
    property string unit: "%"
    property color color: Theme.colors.green
    property bool animated: true

    property real drawProgress: animated ? 0.0 : value
    Behavior on drawProgress { NumberAnimation { duration: 1200; easing.type: Easing.OutQuart } }

    Component.onCompleted: if (animated) drawProgress = value
    onValueChanged: if (animated) drawProgress = value; else drawProgress = value
    onDrawProgressChanged: chartCanvas.requestPaint()
    onColorChanged: chartCanvas.requestPaint()

    implicitWidth: 200
    implicitHeight: 200
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
            anchors.topMargin: 10
            anchors.bottomMargin: 30 // space for bottom label
            anchors.leftMargin: 20
            anchors.rightMargin: 20
            antialiasing: true

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                var centerX = width / 2
                var centerY = height / 2
                var radius = Math.min(width, height) / 2 - 5
                var startAngle = Math.PI * 0.75
                var endAngle = Math.PI * 2.25
                var totalAngle = endAngle - startAngle

                // 1. Background Track
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                ctx.strokeStyle = Theme.colors.surface0
                ctx.lineWidth = 12
                ctx.lineCap = "round"
                ctx.stroke()

                // 2. Progress Fill
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, startAngle, startAngle + totalAngle * chartRoot.drawProgress)
                
                var grad = ctx.createLinearGradient(0, height, width, 0)
                grad.addColorStop(0, chartRoot.color)
                grad.addColorStop(1, Qt.lighter(chartRoot.color, 1.2))
                
                ctx.strokeStyle = grad
                ctx.lineWidth = 12
                ctx.lineCap = "round"
                ctx.stroke()
            }
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
        }

        // Percentage Value (Centered in Donut)
        Text {
            text: Math.round(chartRoot.drawProgress * 100) + chartRoot.unit
            font.family: Theme.typography.familyBold
            font.pixelSize: 32
            color: Theme.colors.text
            anchors.centerIn: chartCanvas
            antialiasing: true
        }

        // Legend Label (Bottom)
        Text {
            id: legendLabel
            text: chartRoot.label
            font.family: Theme.typography.family
            font.pixelSize: 11
            color: Theme.colors.subtext1
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacing.sm
            anchors.horizontalCenter: parent.horizontalCenter
            visible: chartRoot.label !== ""
            antialiasing: true
        }
    }
}
