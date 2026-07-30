import QtQuick 2.15

Item {
    id: root

    property string text: ""
    property string variant: "tonal"
    property string color: "mauve"
    property string size: "sm"
    property bool removable: false
    property bool selected: false
    property string icon: ""

    // Drag support
    property bool draggable: false
    property string dragKey: "mochads-tag"

    signal removed()
    signal clicked()

    readonly property real tagHeight: size === "sm" ? 26 : (size === "lg" ? 36 : 30)
    readonly property real fontSize: size === "sm" ? Theme.typography.sizeXs : Theme.typography.sizeSm
    readonly property real iconSize: size === "sm" ? 12 : 14

    readonly property color resolvedColor: {
        if (Theme.colors[color] !== undefined) return Theme.colors[color];
        return Theme.colors.primary;
    }

    readonly property color finalBg: {
        if (variant === "filled") return resolvedColor;
        return Qt.rgba(resolvedColor.r, resolvedColor.g, resolvedColor.b, 0.12);
    }

    readonly property color finalBorderColor: {
        if (variant === "outline") return resolvedColor;
        if (variant === "tonal") return Qt.rgba(resolvedColor.r, resolvedColor.g, resolvedColor.b, 0.20);
        return "transparent";
    }

    readonly property color finalTextColor: {
        if (variant === "filled") return Theme.colors.crust;
        return resolvedColor;
    }

    implicitWidth: contentRow.implicitWidth + Theme.spacing.md * 2
    implicitHeight: tagHeight
    width: implicitWidth
    height: implicitHeight

    Drag.keys: root.draggable ? [root.dragKey] : []
    Drag.source: root
    Drag.hotSpot.x: root.width / 2
    Drag.hotSpot.y: root.height / 2
    Drag.active: root.draggable && dragHandler.active

    scale: dragHandler.active ? 1.1 : (mouseArea.containsMouse && !dragHandler.active && root.draggable ? 1.05 : 1.0)
    opacity: dragHandler.active ? 0.85 : 1.0
    z: dragHandler.active ? 100 : 0

    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutBack } }
    Behavior on opacity { NumberAnimation { duration: 120 } }

    DragHandler {
        id: dragHandler
        enabled: root.draggable
        dragThreshold: 8
        acceptedButtons: Qt.LeftButton

        onActiveChanged: {
            if (active) {
                Drag.hotSpot.x = root.width / 2
                Drag.hotSpot.y = root.height / 2
            } else {
                Drag.drop()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.geometry.radiusPill
        color: root.finalBg
        border.color: root.selected ? resolvedColor : root.finalBorderColor
        border.width: root.selected ? 2 : Theme.geometry.borderSm

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -6
        radius: Theme.geometry.radiusPill + 6
        color: "transparent"
        visible: dragArea.drag.active
        z: -1

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    Row {
        id: contentRow
        anchors.centerIn: parent
        spacing: 4

        LucideIcon {
            name: root.icon
            size: root.iconSize
            color: root.finalTextColor
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            font.family: Theme.typography.familyMedium
            font.pixelSize: root.fontSize
            color: root.finalTextColor
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
        }

        LucideIcon {
            name: "x"
            size: root.iconSize
            color: root.finalTextColor
            visible: root.removable
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: root.removed()
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: dragHandler.active ? Qt.ClosedHandCursor : (root.draggable && containsMouse ? Qt.OpenHandCursor : Qt.PointingHandCursor)

        onClicked: root.clicked()
    }
}
