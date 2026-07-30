import QtQuick 2.15

Item {
    id: root

    property real value: 0
    property real minimum: 0
    property real maximum: 100
    property real step: 1
    property bool disabled: false
    property string size: "md"

    readonly property real trackHeight: size === "sm" ? 4 : (size === "lg" ? 8 : 6)
    readonly property real thumbSize: size === "sm" ? 14 : (size === "lg" ? 22 : 18)
    readonly property real normalizedValue: {
        if (root.maximum <= root.minimum) return 0;
        return (value - minimum) / (maximum - minimum);
    }

    implicitWidth: 200
    implicitHeight: Math.max(trackHeight, thumbSize)
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.5 : 1.0

    Rectangle {
        id: track
        width: parent.width
        height: root.trackHeight
        radius: root.trackHeight / 2
        color: Theme.colors.surface1
        anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
        width: parent.width * root.normalizedValue
        height: root.trackHeight
        radius: root.trackHeight / 2
        color: Theme.colors.primary
        anchors.verticalCenter: parent.verticalCenter
        Behavior on width { NumberAnimation { duration: 50 } }
    }

    Rectangle {
        id: thumb
        width: root.thumbSize
        height: root.thumbSize
        radius: root.thumbSize / 2
        color: Theme.colors.crust
        border.color: Theme.colors.primary
        border.width: 2
        x: (parent.width - root.thumbSize) * root.normalizedValue
        anchors.verticalCenter: parent.verticalCenter

        Behavior on x { NumberAnimation { duration: 50 } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.disabled
        onPositionChanged: {
            if (pressed) {
                var ratio = Math.max(0, Math.min(1, mouse.x / width));
                var raw = root.minimum + ratio * (root.maximum - root.minimum);
                root.value = Math.round(raw / root.step) * root.step;
                root.valueChanged(root.value);
            }
        }
        onClicked: {
            var ratio = Math.max(0, Math.min(1, mouse.x / width));
            var raw = root.minimum + ratio * (root.maximum - root.minimum);
            root.value = Math.round(raw / root.step) * root.step;
            root.valueChanged(root.value);
        }
    }
}
