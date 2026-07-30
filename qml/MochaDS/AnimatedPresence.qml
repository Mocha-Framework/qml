import QtQuick 2.15

Item {
    id: root

    property bool shown: false

    property int enterDuration: 300
    property int exitDuration: 250

    property real enterOffset: 20
    property real exitOffset: 20

    property real enterFromScale: 0.92
    property real exitToScale: 0.92

    property string enterAnimation: "fade"
    property string exitAnimation: "fade"

    default property alias data: container.data

    implicitWidth: container.width
    implicitHeight: container.height
    width: implicitWidth
    height: implicitHeight
    clip: true

    visible: true
    opacity: 0

    states: [
        State {
            name: "hidden"
            when: !root.shown
            PropertyChanges { target: root; opacity: 0 }
            PropertyChanges { target: container; scale: root.exitToScale }
            PropertyChanges { target: containerSlide; y: root.exitOffset }
            PropertyChanges { target: containerFlip; angle: root.exitAnimation === "flip" ? -90 : 0 }
        },
        State {
            name: "visible"
            when: root.shown
            PropertyChanges { target: root; opacity: 1 }
            PropertyChanges { target: container; scale: 1 }
            PropertyChanges { target: containerSlide; y: 0 }
        }
    ]

    transitions: [
        Transition {
            from: "hidden"
            to: "visible"

            ParallelAnimation {
                NumberAnimation { target: root; property: "opacity"; duration: root.enterDuration; easing.type: Easing.OutQuad }

                NumberAnimation {
                    target: container; property: "scale"
                    duration: (root.enterAnimation === "zoom" || root.enterAnimation === "bounce" || root.enterAnimation === "all") ? root.enterDuration : 0
                    easing.type: root.enterAnimation === "bounce" ? Easing.OutBounce : Easing.OutBack
                }

                NumberAnimation {
                    target: containerSlide; property: "y"
                    duration: (root.enterAnimation === "slide" || root.enterAnimation === "all") ? root.enterDuration : 0
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: root; property: "rotation"
                    from: -90; to: 0
                    duration: (root.enterAnimation === "spin" || root.enterAnimation === "all") ? root.enterDuration : 0
                    easing.type: Easing.OutCubic
                }

                NumberAnimation {
                    target: containerFlip; property: "angle"
                    duration: (root.enterAnimation === "flip" || root.enterAnimation === "all") ? root.enterDuration : 0
                    easing.type: Easing.OutCubic
                }
            }
        },
        Transition {
            from: "visible"
            to: "hidden"

            ParallelAnimation {
                NumberAnimation { target: root; property: "opacity"; duration: root.exitDuration; easing.type: Easing.InQuad }

                NumberAnimation {
                    target: container; property: "scale"
                    duration: (root.exitAnimation === "zoom" || root.exitAnimation === "bounce" || root.exitAnimation === "all") ? root.exitDuration : 0
                    easing.type: Easing.InQuad
                }

                NumberAnimation {
                    target: containerSlide; property: "y"
                    duration: (root.exitAnimation === "slide" || root.exitAnimation === "all") ? root.exitDuration : 0
                    easing.type: Easing.InCubic
                }

                NumberAnimation {
                    target: containerFlip; property: "angle"
                    duration: (root.exitAnimation === "flip" || root.exitAnimation === "all") ? root.exitDuration : 0
                    easing.type: Easing.InCubic
                }
            }
        }
    ]

    transformOrigin: Item.Center

    transform: [
        Translate {
            id: containerSlide
            y: 0
        },
        Rotation {
            id: containerFlip
            origin.x: root.width / 2
            origin.y: root.height / 2
            axis { x: 1; y: 0; z: 0 }
            angle: 0
        }
    ]

    Item {
        id: container
        width: childrenRect.width
        height: childrenRect.height
    }
}
