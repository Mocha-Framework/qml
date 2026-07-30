import QtQuick 2.15

Item {
    id: root

    property var model: null
    property Component delegate: null

    property string animation: "fade"
    property int duration: 300
    property int perItemDelay: 60
    property bool trigger: true
    property real offset: 20
    property real fromScale: 0.8

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    clip: true

    property int _revealedCount: 0

    onTriggerChanged: {
        if (trigger) startReveal()
    }

    Component.onCompleted: {
        if (trigger) Qt.callLater(startReveal)
    }

    function startReveal() {
        _revealedCount = 0
        if (repeater.count === 0) return
        revealTimer.repeat = true
        revealTimer.interval = root.perItemDelay
        revealTimer.start()
    }

    Timer {
        id: revealTimer
        repeat: false
        onTriggered: {
            if (_revealedCount < repeater.count) {
                _revealedCount++
            } else {
                revealTimer.stop()
            }
        }
    }

    Component {
        id: wrapperComponent

        Item {
            id: wrapperItem
            width: wrapperLoader.implicitWidth
            height: wrapperLoader.implicitHeight

            property int itemIndex: index

            opacity: root.trigger ? (root._revealedCount > itemIndex ? 1 : 0) : 1
            scale: root.trigger ? (root._revealedCount > itemIndex ? 1 : root.fromScale) : 1

            transform: Translate {
                id: wrapperSlide
                y: root.trigger ? (root._revealedCount > itemIndex ? 0 : root.offset) : 0

                Behavior on y {
                    NumberAnimation { duration: root.duration; easing.type: Easing.OutCubic }
                }
            }

            Behavior on opacity {
                NumberAnimation { duration: root.duration; easing.type: Easing.OutQuad }
            }

            Behavior on scale {
                NumberAnimation { duration: root.duration; easing.type: Easing.OutBack }
            }

            Loader {
                id: wrapperLoader
                sourceComponent: root.delegate

                onLoaded: {
                    item.modelData = modelData
                    item.index = index
                }
            }
        }
    }

    Column {
        id: container
        anchors.left: parent.left
        anchors.right: parent.right

        Repeater {
            id: repeater
            model: root.model
            delegate: wrapperComponent
        }
    }
}
