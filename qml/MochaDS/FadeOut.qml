import QtQuick 2.15

Item {
    id: root

    property int duration: 300
    property int delay: 0
    property bool trigger: true

    default property alias data: container.data

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    opacity: 1

    Behavior on opacity {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.InQuad
        }
    }

    Item {
        id: container
        anchors.fill: parent
    }

    onTriggerChanged: {
        if (trigger) root.opacity = 1
        else fadeOut()
    }

    function fadeOut() {
        if (delay > 0) {
            fadeTimer.restart()
        } else {
            root.opacity = 0
        }
    }

    Timer {
        id: fadeTimer
        interval: root.delay
        repeat: false
        onTriggered: root.opacity = 0
    }
}
