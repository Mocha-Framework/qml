import QtQuick 2.15

Item {
    id: root

    property color color: Theme ? Theme.colors.primary : "#8839ef"
    property real pulseMin: 0.3
    property real pulseMax: 1.0
    property int duration: 1500

    default property alias data: content.data

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: glow
        anchors.fill: parent
        anchors.margins: -4
        radius: content.radius + 4 || Theme.geometry.radiusMd + 4
        color: "transparent"
        border.color: root.color
        border.width: 2
        opacity: root.pulseMin

        Behavior on opacity {
            NumberAnimation { duration: root.duration * 0.5; easing.type: Easing.InOutSine }
        }

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: true

            NumberAnimation {
                from: root.pulseMin
                to: root.pulseMax
                duration: root.duration * 0.5
                easing.type: Easing.InOutSine
            }

            NumberAnimation {
                from: root.pulseMax
                to: root.pulseMin
                duration: root.duration * 0.5
                easing.type: Easing.InOutSine
            }
        }

        Rectangle {
            id: glowInner
            anchors.fill: parent
            anchors.margins: 4
            radius: parent.radius - 4
            color: "transparent"
            border.color: Qt.rgba(root.color.r, root.color.g, root.color.b, 0.4)
            border.width: 1
            opacity: root.pulseMin

            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: true

                NumberAnimation {
                    from: root.pulseMin * 0.6
                    to: root.pulseMax * 0.6
                    duration: root.duration * 0.5
                    easing.type: Easing.InOutSine
                }

                NumberAnimation {
                    from: root.pulseMax * 0.6
                    to: root.pulseMin * 0.6
                    duration: root.duration * 0.5
                    easing.type: Easing.InOutSine
                }
            }
        }
    }

    Item {
        id: content
        anchors.fill: parent
    }
}
