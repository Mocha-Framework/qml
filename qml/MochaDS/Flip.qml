import QtQuick 2.15

Item {
    id: root

    property int duration: 500
    property int delay: 0
    property bool clockwise: false
    property bool trigger: true

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

    transform: Rotation {
        id: flipRotation
        axis { x: 0; y: 1; z: 0 }
        angle: root.clockwise ? 90 : -90
        origin.x: root.width / 2
        origin.y: root.height / 2

        Behavior on angle {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.OutCubic
            }
        }
    }

    Item {
        id: container
        anchors.fill: parent
    }

    onTriggerChanged: {
        if (trigger) flipIn()
        else { root.opacity = 0; flipRotation.angle = root.clockwise ? 90 : -90 }
    }

    function flipIn() {
        if (delay > 0) {
            flipTimer.restart()
        } else {
            root.opacity = 1
            flipRotation.angle = 0
        }
    }

    Timer {
        id: flipTimer
        interval: root.delay
        repeat: false
        onTriggered: {
            root.opacity = 1
            flipRotation.angle = 0
        }
    }

    Component.onCompleted: {
        if (trigger) Qt.callLater(flipIn)
    }
}
