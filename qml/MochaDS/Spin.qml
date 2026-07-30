import QtQuick 2.15

Item {
    id: root

    property int duration: 500
    property int delay: 0
    property real fromRotation: -180
    property bool trigger: true

    default property alias data: container.data

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    opacity: 0
    rotation: root.fromRotation

    Behavior on opacity {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutQuad
        }
    }

    Behavior on rotation {
        NumberAnimation {
            duration: root.duration
            easing.type: Easing.OutCubic
        }
    }

    transformOrigin: Item.Center

    Item {
        id: container
        anchors.fill: parent
    }

    onTriggerChanged: {
        if (trigger) spinIn()
        else { root.opacity = 0; root.rotation = root.fromRotation }
    }

    function spinIn() {
        if (delay > 0) {
            spinTimer.restart()
        } else {
            root.opacity = 1
            root.rotation = 0
        }
    }

    Timer {
        id: spinTimer
        interval: root.delay
        repeat: false
        onTriggered: {
            root.opacity = 1
            root.rotation = 0
        }
    }

    Component.onCompleted: {
        if (trigger) Qt.callLater(spinIn)
    }
}
