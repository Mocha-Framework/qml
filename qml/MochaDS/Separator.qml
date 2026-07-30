import QtQuick 2.15

Item {
    id: root

    property string orientation: "horizontal"
    property string variant: "default"
    property real thickness: 1
    property real margin: 0

    implicitWidth: orientation === "vertical" ? thickness : 100
    implicitHeight: orientation === "horizontal" ? thickness : 40
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        anchors.centerIn: parent
        width: root.orientation === "horizontal" ? parent.width - root.margin * 2 : root.thickness
        height: root.orientation === "vertical" ? parent.height - root.margin * 2 : root.thickness
        radius: root.thickness / 2
        color: {
            if (root.variant === "accent") return Theme.colors.primary;
            if (root.variant === "subtle") return Theme.colors.surface0;
            return Theme.colors.surface1;
        }
    }
}
