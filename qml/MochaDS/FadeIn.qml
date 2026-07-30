import QtQuick 2.15

Item {
    id: root

    property int duration: 300
    property int delay: 0
    property bool trigger: true

    property bool triggerOnVisibility: false
    property real visibilityThreshold: 0.3

    default property alias data: container.data

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    opacity: 0

    Behavior on opacity {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutQuad
        }
    }

    Item {
        id: container
        anchors.fill: parent
    }

    onTriggerChanged: {
        if (trigger) fadeIn()
        else root.opacity = 0
        if (!trigger && triggerOnVisibility) startVisibilityCheck()
    }

    function fadeIn() {
        visibilityTimer.stop()
        if (delay > 0) {
            fadeTimer.restart()
        } else {
            root.opacity = 1
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
        id: fadeTimer
        interval: root.delay
        repeat: false
        onTriggered: root.opacity = 1
    }

    Component.onCompleted: {
        if (triggerOnVisibility) {
            Qt.callLater(startVisibilityCheck)
        } else if (trigger) {
            Qt.callLater(fadeIn)
        }
    }
}
