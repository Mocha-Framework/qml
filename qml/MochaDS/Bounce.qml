import QtQuick 2.15

Item {
    id: root

    property int duration: 600
    property int delay: 0
    property real fromScale: 0.5
    property bool trigger: true

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
            easing.type: Easing.OutBounce
        }
    }

    transformOrigin: Item.Center

    Item {
        id: container
        anchors.fill: parent
    }

    onTriggerChanged: {
        if (trigger) bounceIn()
        else { root.opacity = 0; root.scale = root.fromScale }
    }

    function bounceIn() {
        if (delay > 0) {
            bounceTimer.restart()
        } else {
            root.opacity = 1
            root.scale = 1
        }
    }

    Timer {
        id: bounceTimer
        interval: root.delay
        repeat: false
        onTriggered: {
            root.opacity = 1
            root.scale = 1
        }
    }

    Component.onCompleted: {
        if (trigger) Qt.callLater(bounceIn)
    }
}
