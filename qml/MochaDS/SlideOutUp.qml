import QtQuick 2.15

Item {
    id: root

    property int duration: 350
    property int delay: 0
    property real offset: 20
    property bool trigger: true

    default property alias data: container.data

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    transform: Translate {
        id: slideTransform
        y: 0

        Behavior on y {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.InCubic
            }
        }
    }

    Item {
        id: container
        anchors.fill: parent
    }

    onTriggerChanged: {
        if (trigger) slideTransform.y = 0
        else slideOut()
    }

    function slideOut() {
        if (delay > 0) {
            slideTimer.restart()
        } else {
            slideTransform.y = -root.offset
        }
    }

    Timer {
        id: slideTimer
        interval: root.delay
        repeat: false
        onTriggered: slideTransform.y = -root.offset
    }
}
