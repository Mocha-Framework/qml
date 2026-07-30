import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    property string title: ""
    property var items: [] // Ex: [{ color: "red", label: "Income", value: "5000" }]
    property string placement: "top"
    property bool showTooltip: false

    property var _origParent: null

    onShowTooltipChanged: {
        if (showTooltip) {
            if (!root._origParent) return;
            var pos = root._origParent.mapToItem(root.parent, 0, 0);
            root._positionBubble(pos.x, pos.y, root._origParent.width, root._origParent.height);
            var nextZ = Theme.getNextMaxZ();
            root.z = nextZ;
            _bubble.z = nextZ;
            _bubble.scale = 1.0;
            _bubble.opacity = 1.0;
        } else {
            _bubble.opacity = 0;
            _bubble.scale = 0.96;
        }
    }

    Component.onCompleted: {
        _origParent = parent;
        var r = parent;
        while (r.parent) r = r.parent;
        root.parent = r;
    }

    function _positionBubble(tx, ty, tw, th) {
        var margin = 12;
        var winWidth = root.parent ? root.parent.width : 800;
        var winHeight = root.parent ? root.parent.height : 600;

        var bw = _bubbleRect.width;
        var bh = _bubbleRect.height;

        var finalX = 0;
        var finalY = 0;

        if (placement === "top") {
            finalX = tx + tw / 2 - bw / 2;
            finalY = ty - bh - margin;
            if (finalY < 0) {
                finalY = ty + th + margin;
            }
        } else if (placement === "bottom") {
            finalX = tx + tw / 2 - bw / 2;
            finalY = ty + th + margin;
        } else if (placement === "right") {
            finalX = tx + tw + margin;
            finalY = ty + th / 2 - bh / 2;
        } else if (placement === "left") {
            finalX = tx - bw - margin;
            finalY = ty + th / 2 - bh / 2;
        }

        finalX = Math.max(4, Math.min(winWidth - bw - 4, finalX));
        
        _bubble.x = finalX;
        _bubble.y = finalY;
    }

    Item {
        id: _bubble
        opacity: 0
        scale: 0.96
        
        width: _bubbleRect.width
        height: _bubbleRect.height
        
        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

        Rectangle {
            id: _bubbleRect
            width: contentLayout.implicitWidth + Theme.spacing.xl * 2
            height: contentLayout.implicitHeight + Theme.spacing.lg * 2
            color: Theme.colors.base
            border.color: Theme.colors.surface0
            border.width: Theme.geometry.borderSm
            radius: Theme.geometry.radiusMd

            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                z: -1
                color: "transparent"
                border.color: Qt.rgba(0,0,0,0.10)
                radius: parent.radius
            }

            Column {
                id: contentLayout
                anchors.centerIn: parent
                spacing: Theme.spacing.md

                Text {
                    text: root.title
                    visible: root.title !== ""
                    font.family: Theme.typography.family
                    font.pixelSize: Theme.typography.sizeSm
                    font.bold: true
                    color: Theme.colors.subtext0
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: Theme.colors.surface0
                    visible: root.title !== ""
                }

                Repeater {
                    model: root.items
                    delegate: Row {
                        spacing: Theme.spacing.sm
                        
                        Rectangle {
                            width: 10
                            height: 10
                            radius: 5
                            color: modelData.color
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        
                        Text {
                            text: modelData.label
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext1
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(80, implicitWidth)
                        }
                        
                        Text {
                            text: modelData.value
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeMd
                            font.bold: true
                            color: Theme.colors.text
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
