import QtQuick 2.15

Item {
    id: root

    property int duration: 350
    property int delay: 0
    property real fromScale: 0.8
    property bool trigger: true

    property bool triggerOnVisibility: false
    property real visibilityThreshold: 0.3

    default property alias data: container.data

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    opacity: 0
    scale: root.fromScale

    Behavior on opacity {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutQuad
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutBack
        }
    }

    transformOrigin: Item.Center

    Item {
        id: container
        anchors.fill: parent
    }

    onTriggerChanged: {
        if (trigger) zoomIn()
        else { root.opacity = 0; root.scale = root.fromScale }
        if (!trigger && triggerOnVisibility) startVisibilityCheck()
    }

    function zoomIn() {
        visibilityTimer.stop()
        if (delay > 0) {
            zoomTimer.restart()
        } else {
            root.opacity = 1
            root.scale = 1
        }
    }

    function startVisibilityCheck() {
        if (!triggerOnVisibility) return
        visibilityTimer.start()
    }

    function checkVisibility() {
        if (!parent || root.trigger) return
        var pos = mapToItem(parent, 0, 0)
        if (pos.y + root.height * root.visibilityThreshold < parent.height && pos.y + root.height > 0) {
            root.trigger = true
        }
    }

    Timer {
        id: visibilityTimer
        interval: 150
        repeat: true
        onTriggered: checkVisibility()
    }

    Timer {
        id: zoomTimer
        interval: root.delay
        repeat: false
        onTriggered: {
            root.opacity = 1
            root.scale = 1
        }
    }

    Component.onCompleted: {
        if (triggerOnVisibility) {
            Qt.callLater(startVisibilityCheck)
        } else if (trigger) {
            Qt.callLater(zoomIn)
        }
    }
}
