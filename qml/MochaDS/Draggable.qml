import QtQuick 2.15

Item {
    id: root

    default property alias content: container.data

    property string key: ""
    property var dragData: null
    property real threshold: 8
    property real dragScale: 1.05
    property real dragOpacity: 0.9
    // Subtle tilt applied to the dragged item. Gives the card a "lifted off the
    // board" feel, similar to Trello/Notion drag previews. Set to 0 to disable.
    property real dragRotation: 3.5
    property real elevation: 6
    property real radius: -1

    property bool moves: false
    property int axis: Drag.XAxis | Drag.YAxis

    signal dragStarted(var data)
    signal dragEnded(var data)
    signal clicked()

    readonly property alias active: dragHandler.active
    readonly property alias hovered: hoverHandler.hovered

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Item {
        id: container
        anchors.fill: parent

        Drag.keys: root.key ? [root.key] : []
        Drag.hotSpot.x: root.width / 2
        Drag.hotSpot.y: root.height / 2
        Drag.source: root
        Drag.active: dragHandler.active

        scale: dragHandler.active ? root.dragScale : (hoverHandler.hovered && root.enabled ? 1.02 : 1.0)
        opacity: dragHandler.active ? root.dragOpacity : 1.0
        // Subtle tilt while dragging for a "lifted" feel. Pivot at the center
        // so the rotation looks balanced (top-pivot + scale caused visual drift).
        rotation: dragHandler.active ? root.dragRotation : 0
        transformOrigin: Item.Center
        z: dragHandler.active ? 100 : 0

        Behavior on scale {
            NumberAnimation { duration: 120; easing.type: Easing.OutBack }
        }
        Behavior on opacity {
            NumberAnimation { duration: 120 }
        }
        Behavior on rotation {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: shadowRect
            anchors.fill: parent
            anchors.margins: -root.elevation
            radius: root.radius >= 0 ? root.radius + root.elevation : Theme.geometry.radiusMd + root.elevation
            color: "transparent"
            visible: dragHandler.active
            z: -1

            // Multi-layer shadow for a more pronounced "lifted" feel while dragging.
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Qt.rgba(0, 0, 0, 0.25)
                opacity: dragHandler.active ? 1.0 : 0.0
                y: 4

                Behavior on opacity { NumberAnimation { duration: 140 } }
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: parent.radius + 3
                color: Qt.rgba(0, 0, 0, 0.12)
                opacity: dragHandler.active ? 1.0 : 0.0
                y: 8

                Behavior on opacity { NumberAnimation { duration: 140 } }
            }
        }
    }

    HoverHandler {
        id: hoverHandler
        enabled: root.enabled
    }

    DragHandler {
        id: dragHandler
        target: null
        enabled: root.enabled
        dragThreshold: root.threshold
        acceptedButtons: Qt.LeftButton
        cursorShape: active ? Qt.ClosedHandCursor : Qt.OpenHandCursor

        property real __startX: 0
        property real __startY: 0
        property var __oldParent: null
        property real __oldX: 0
        property real __oldY: 0

        onActiveChanged: {
            if (active) {
                __oldParent = container.parent
                __oldX = container.x
                __oldY = container.y

                var p = root.parent
                while (p && p.parent) {
                    p = p.parent
                }
                var globalPos = container.mapToItem(p, 0, 0)
                __startX = globalPos.x
                __startY = globalPos.y

                container.anchors.fill = undefined
                container.parent = p
                container.x = globalPos.x
                container.y = globalPos.y

                root.dragStarted(root.dragData)
            } else {
                var dropResult = container.Drag.drop()

                if (root.moves) {
                    var oldParent = __oldParent
                    var globalPos = container.mapToItem(oldParent, 0, 0)
                    container.parent = root
                    container.anchors.fill = root
                    root.x = globalPos.x
                    root.y = globalPos.y
                } else {
                    container.parent = root
                    container.anchors.fill = root
                }

                root.dragEnded(root.dragData)
            }
        }

        onTranslationChanged: {
            if (active) {
                if (root.axis & Drag.XAxis)
                    container.x = __startX + translation.x
                if (root.axis & Drag.YAxis)
                    container.y = __startY + translation.y
            }
        }
    }
}
