import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // The flickable or view to control
    property Flickable flickable: null

    // "vertical" | "horizontal"
    property string orientation: "vertical"

    // If true, the scrollbar is always visible. Otherwise only on hover/scroll.
    property bool permanent: false

    // Custom thickness of the scrollbar thumb
    property real thickness: 6

    // ==========================================
    // Internal Logic
    // ==========================================

    readonly property bool isVertical: orientation === "vertical"
    readonly property real margin: 4
    
    // Calculate size and position based on flickable's visibleArea
    readonly property real thumbSize: {
        if (!flickable) return 0
        var ratio = isVertical ? flickable.visibleArea.heightRatio : flickable.visibleArea.widthRatio
        var avail = (isVertical ? root.height : root.width) - margin * 2
        return Math.max(20, avail * ratio)
    }

    readonly property real thumbPos: {
        if (!flickable) return 0
        var pos = isVertical ? flickable.visibleArea.yPosition : flickable.visibleArea.xPosition
        var avail = (isVertical ? root.height : root.width) - margin * 2
        return margin + avail * pos
    }

    // Visibility management
    readonly property bool shouldShow: permanent || flickMouseArea.containsMouse || thumbMouseArea.containsMouse || (flickable && flickable.moving)
    
    opacity: shouldShow ? 1.0 : 0.0
    Behavior on opacity { NumberAnimation { duration: 250 } }

    implicitWidth: isVertical ? thickness + margin * 2 : 100
    implicitHeight: isVertical ? 100 : thickness + margin * 2
    width: implicitWidth
    height: implicitHeight

    // Track (faint reference so the thumb position is clear)
    Rectangle {
        anchors.fill: parent
        color: Theme.colors.overlay0
        opacity: thumbMouseArea.containsMouse ? 0.15 : 0.06
        radius: root.thickness / 2
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    // Thumb
    Rectangle {
        id: thumb
        x: isVertical ? margin : thumbPos
        y: isVertical ? thumbPos : margin
        width: isVertical ? root.thickness : thumbSize
        height: isVertical ? thumbSize : root.thickness
        radius: root.thickness / 2
        color: (thumbMouseArea.pressed || flickable.moving) ? Theme.colors.primary : (thumbMouseArea.containsMouse ? Theme.colors.overlay1 : Theme.colors.overlay0)
        
        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            id: thumbMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            drag.target: thumb
            drag.axis: root.isVertical ? Drag.YAxis : Drag.XAxis
            drag.minimumY: margin
            drag.maximumY: root.height - thumb.height - margin
            drag.minimumX: margin
            drag.maximumX: root.width - thumb.width - margin

            onPositionChanged: {
                if (drag.active) {
                    var avail = (root.isVertical ? root.height : root.width) - margin * 2 - (root.isVertical ? thumb.height : thumb.width)
                    var rel = ((root.isVertical ? thumb.y : thumb.x) - margin) / avail
                    if (root.isVertical) flickable.contentY = rel * (flickable.contentHeight - flickable.height)
                    else flickable.contentX = rel * (flickable.contentWidth - flickable.width)
                }
            }
        }
    }

    // Connect to flickable mouse area to detect activity
    MouseArea {
        id: flickMouseArea
        parent: flickable ? flickable : root
        anchors.fill: parent
        propagateComposedEvents: true
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        enabled: flickable !== null
    }
}
