import QtQuick 2.15

Item {
    id: root

    property var items: []
    property bool open: false
    property real offsetX: 0
    property real offsetY: 0

    signal closed()

    visible: false
    width: 200
    implicitHeight: menuColumn.implicitHeight + Theme.spacing.sm * 2
    height: implicitHeight

    z: Theme.getNextMaxZ()

    onOpenChanged: {
        if (open) {
            root.visible = true;
            root.z = Theme.getNextMaxZ();
        }
    }

    function showAt(x, y) {
        root.x = Math.min(x, parent ? parent.width - root.width : x);
        root.y = Math.min(y, parent ? parent.height - root.height : y);
        root.open = true;
    }

    function dismiss() {
        root.open = false;
        root.visible = false;
        root.closed();
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.mantle
        radius: Theme.geometry.radiusMd
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm

        MouseArea {
            anchors.fill: parent
        }
    }

    Column {
        id: menuColumn
        width: parent.width
        anchors.top: parent.top
        anchors.topMargin: Theme.spacing.sm
        spacing: 0

        Repeater {
            model: root.items

            delegate: Item {
                width: parent.width
                height: modelData.separator ? 9 : 36

                Rectangle {
                    width: parent.width - Theme.spacing.md * 2
                    height: 1
                    color: Theme.colors.surface0
                    anchors.centerIn: parent
                    visible: modelData.separator === true
                }

                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.sm
                    anchors.rightMargin: Theme.spacing.sm
                    radius: Theme.geometry.radiusSm
                    color: menuItemMouse.containsMouse ? Theme.colors.surface0 : "transparent"
                    visible: !modelData.separator

                    Behavior on color { ColorAnimation { duration: 100 } }

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacing.md
                        anchors.rightMargin: Theme.spacing.md
                        spacing: Theme.spacing.md

                        LucideIcon {
                            name: modelData.icon || ""
                            size: 16
                            color: Theme.colors.subtext0
                            visible: modelData.icon !== undefined && modelData.icon !== ""
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.label || ""
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.text
                            anchors.verticalCenter: parent.verticalCenter
                            antialiasing: true
                        }

                        Item { width: 1; height: 1 }

                        Text {
                            text: modelData.shortcut || ""
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeXs
                            color: Theme.colors.overlay1
                            anchors.verticalCenter: parent.verticalCenter
                            visible: modelData.shortcut !== undefined && modelData.shortcut !== ""
                            antialiasing: true
                        }
                    }

                    MouseArea {
                        id: menuItemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof modelData.onClicked === "function") {
                                modelData.onClicked();
                            }
                            root.dismiss();
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: _dismissOverlay
        color: "transparent"
        visible: root.open
        z: 9998

        Component.onCompleted: {
            var r = root;
            while (r.parent) r = r.parent;
            _dismissOverlay.parent = r;
            _dismissOverlay.anchors.fill = r;
            _dismissOverlay.z = Theme.getNextMaxZ() - 1;
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.dismiss()
        }
    }
}
