import QtQuick 2.15

Item {
    id: root

    default property alias content: container.data

    property string key: ""
    property color accentColor: Theme.colors.primary
    property real highlightOpacity: 0.15
    property real borderOpacity: 0.4
    property real radius: Theme.geometry.radiusMd
    property bool forceHighlight: false

    signal entered(var source)
    signal exited(var source)
    signal dropped(var source)

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    readonly property alias containsDrag: dropArea.containsDrag
    readonly property alias dropArea: dropArea
    readonly property bool isActive: dropArea.containsDrag || root.forceHighlight

    DropArea {
        id: dropArea
        anchors.fill: parent
        keys: root.key ? [root.key] : []

        onEntered: (drag) => root.entered(drag.source)
        onExited: root.exited(null)
        onDropped: (drop) => root.dropped(drop.source)
    }

    Item {
        id: container
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: root.accentColor
        opacity: root.isActive ? root.highlightOpacity : 0
        radius: root.radius
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: root.accentColor
        border.width: 2
        opacity: root.isActive ? root.borderOpacity : 0
        radius: root.radius
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }
}
