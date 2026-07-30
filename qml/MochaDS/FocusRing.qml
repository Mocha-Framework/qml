import QtQuick 2.15

Rectangle {
    id: root

    property Item target: parent
    property color ringColor: Theme.colors.primary
    property real ringWidth: 2
    property real ringOffset: 3
    property bool active: target && target.activeFocus

    visible: root.active
    z: 9999

    x: root.target ? root.target.x - root.ringOffset : 0
    y: root.target ? root.target.y - root.ringOffset : 0
    width: root.target ? root.target.width + root.ringOffset * 2 : 0
    height: root.target ? root.target.height + root.ringOffset * 2 : 0

    radius: root.target ? (root.target.radius !== undefined ? root.target.radius + root.ringOffset : Theme.geometry.radiusMd + root.ringOffset) : Theme.geometry.radiusMd

    color: "transparent"
    border.color: root.ringColor
    border.width: root.ringWidth

    opacity: root.active ? 0.7 : 0.0

    Behavior on opacity { NumberAnimation { duration: 120 } }
}
