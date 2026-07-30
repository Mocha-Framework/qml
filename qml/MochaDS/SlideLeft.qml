import QtQuick 2.15

Item {
    id: root

    property int duration: 400
    property int delay: 0
    property real offset: 20
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

    transform: Translate {
        id: slideTransform
        x: root.offset

        Behavior on x {
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
        if (trigger) slideIn()
        else { root.opacity = 0; slideTransform.x = root.offset }
    }

    function slideIn() {
        if (delay > 0) {
            slideTimer.restart()
        } else {
            root.opacity = 1
            slideTransform.x = 0
        }
    }

    Timer {
        id: slideTimer
        interval: root.delay
        repeat: false
        onTriggered: {
            root.opacity = 1
            slideTransform.x = 0
        }
    }

    Component.onCompleted: {
        if (trigger) Qt.callLater(slideIn)
    }
}
