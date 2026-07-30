import QtQuick 2.15

Item {
    id: root

    property int count: 15
    property color color: Theme ? Theme.colors.surface2 : "#cccccc"
    property real minSize: 2
    property real maxSize: 6
    property int duration: 3000
    property real spread: 100

    property bool running: true

    implicitWidth: parent ? parent.width : 200
    implicitHeight: parent ? parent.height : 200

    Component {
        id: particleComponent

        Rectangle {
            id: particle
            width: size
            height: size
            radius: size / 2
            color: root.color
            opacity: 0

            property real size: root.minSize + Math.random() * (root.maxSize - root.minSize)
            property real startX: Math.random() * root.width
            property real startY: Math.random() * root.height
            property real endX: startX + (Math.random() - 0.5) * root.spread * 2
            property real endY: startY + (Math.random() - 0.5) * root.spread * 2
            property real randomDelay: Math.random() * root.duration * 0.5
            property real randomDuration: root.duration * 0.5 + Math.random() * root.duration

            x: startX
            y: startY

            SequentialAnimation {
                running: root.running
                loops: Animation.Infinite

                PauseAnimation { duration: particle.randomDelay }

                ParallelAnimation {
                    NumberAnimation {
                        target: particle
                        property: "opacity"
                        from: 0
                        to: 0.6 + Math.random() * 0.4
                        duration: particle.randomDuration * 0.3
                    }

                    NumberAnimation {
                        target: particle
                        property: "x"
                        from: particle.startX
                        to: particle.endX
                        duration: particle.randomDuration
                        easing.type: Easing.InOutSine
                    }

                    NumberAnimation {
                        target: particle
                        property: "y"
                        from: particle.startY
                        to: particle.endY
                        duration: particle.randomDuration
                        easing.type: Easing.InOutSine
                    }
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: particle
                        property: "opacity"
                        from: 0.6 + Math.random() * 0.4
                        to: 0
                        duration: particle.randomDuration * 0.3
                    }
                }
            }
        }
    }

    Repeater {
        model: root.count
        delegate: particleComponent
    }
}
