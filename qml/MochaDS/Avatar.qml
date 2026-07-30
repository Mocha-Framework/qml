import QtQuick 2.15

Item {
    id: root

    property string src: ""
    property string name: ""
    property string size: "md"
    property string shape: "circle"
    property string variant: "default"
    property bool showStatus: false
    property bool isOnline: false
    property string statusColor: ""

    readonly property real avatarSize: {
        if (size === "sm") return 32;
        if (size === "lg") return 56;
        if (size === "xl") return 80;
        return 40;
    }

    implicitWidth: avatarSize
    implicitHeight: avatarSize
    width: implicitWidth
    height: implicitHeight

    HoverHandler {
        id: hoverHandler
    }

    scale: hoverHandler.hovered ? 1.06 : 1.0
    z: hoverHandler.hovered ? 2 : 1
    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

    Rectangle {
        anchors.fill: parent
        radius: shape === "circle" ? avatarSize / 2 : Theme.geometry.radiusMd
        color: {
            if (variant === "accent") return Theme.colors.primary;
            if (variant === "tonal") return Theme.colors.surface0;
            return Theme.colors.mantle;
        }
        clip: true

        Image {
            anchors.fill: parent
            source: root.src
            fillMode: Image.PreserveAspectCrop
            visible: root.src !== ""
        }

        Text {
            text: {
                var parts = root.name.split(" ");
                if (parts.length >= 2) return parts[0][0] + parts[parts.length - 1][0];
                if (parts.length === 1 && parts[0].length >= 1) return parts[0][0];
                return "?";
            }
            font.family: Theme.typography.familyBold
            font.pixelSize: avatarSize * 0.4
            color: root.variant === "accent" ? Theme.colors.crust : Theme.colors.text
            anchors.centerIn: parent
            visible: root.src === ""
            antialiasing: true
        }
    }

    Rectangle {
        width: avatarSize * 0.28
        height: avatarSize * 0.28
        radius: width / 2
        color: root.statusColor !== "" ? root.statusColor : (root.isOnline ? Theme.colors.success : Theme.colors.overlay1)
        border.color: Theme.colors.base
        border.width: 2
        visible: root.showStatus
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: -1
        anchors.bottomMargin: -1
    }
}
