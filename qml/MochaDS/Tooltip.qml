import QtQuick 2.15

Item {
    id: root

    property string text: ""
    property string placement: "top"
    property int    delay: 500
    property real   maxWidth: 240

    property var  _origParent: null
    property bool _hovered: false

    on_HoveredChanged: {
        if (_hovered) {
            _delayTimer.restart();
        } else {
            _delayTimer.stop();
            _bubble.opacity = 0;
            _bubble.scale = 0.96;
        }
    }

    Component.onCompleted: {
        _origParent = parent;

        var r = parent;
        while (r.parent) r = r.parent;

        _hoverTrackerComponent.createObject(_origParent);

        root.parent = r;
    }

    Component {
        id: _hoverTrackerComponent
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: root._hovered = true
            onExited:  root._hovered = false
        }
    }

    Timer {
        id: _delayTimer
        interval: root.delay
        onTriggered: {
            if (!root._origParent || root.text === "") return;
            var pos = root._origParent.mapToItem(root.parent, 0, 0);
            root._positionBubble(pos.x, pos.y,
                                 root._origParent.width,
                                 root._origParent.height);
            var nextZ = Theme.getNextMaxZ();
            root.z = nextZ;
            _bubble.z = nextZ;
            _bubble.scale = 1.0;
            _bubble.opacity = 1;
        }
    }

    function _positionBubble(tx, ty, tw, th) {
        var margin = 10;
        var winWidth = root.parent ? root.parent.width : 800;
        var winHeight = root.parent ? root.parent.height : 600;

        function getBubbleDimensions(p) {
            var rectW = Math.min(_label.implicitWidth + Theme.spacing.md * 2, root.maxWidth);
            var rectH = _label.implicitHeight + Theme.spacing.sm * 2 + 2;
            var caretW = (p === "top" || p === "bottom") ? 12 : 7;
            var caretH = (p === "top" || p === "bottom") ? 7  : 12;
            return {
                w: rectW + caretW * (p === "left" || p === "right" ? 1 : 0),
                h: rectH + caretH * (p === "top"  || p === "bottom" ? 1 : 0)
            };
        }

        var activePlacement = placement;
        var dims = getBubbleDimensions(activePlacement);

        if (placement === "top") {
            if (ty - dims.h - margin < 0 && ty + th + margin + getBubbleDimensions("bottom").h <= winHeight) {
                activePlacement = "bottom";
            }
        } else if (placement === "bottom") {
            if (ty + th + margin + dims.h > winHeight && ty - getBubbleDimensions("top").h - margin >= 0) {
                activePlacement = "top";
            }
        } else if (placement === "left") {
            if (tx - dims.w - margin < 0 && tx + tw + margin + getBubbleDimensions("right").w <= winWidth) {
                activePlacement = "right";
            }
        } else if (placement === "right") {
            if (tx + tw + margin + dims.w > winWidth && tx - getBubbleDimensions("left").w - margin >= 0) {
                activePlacement = "left";
            }
        }

        _actualPlacement = activePlacement;
        dims = getBubbleDimensions(_actualPlacement);
        var bw = dims.w;
        var bh = dims.h;

        switch (_actualPlacement) {
        case "bottom":
            _bubble.x = Math.max(4, Math.min(winWidth - bw - 4, tx + tw / 2 - bw / 2));
            _bubble.y = ty + th + margin;
            break;
        case "left":
            _bubble.x = tx - bw - margin;
            _bubble.y = Math.max(4, Math.min(winHeight - bh - 4, ty + th / 2 - bh / 2));
            break;
        case "right":
            _bubble.x = tx + tw + margin;
            _bubble.y = Math.max(4, Math.min(winHeight - bh - 4, ty + th / 2 - bh / 2));
            break;
        default:
            _bubble.x = Math.max(4, Math.min(winWidth - bw - 4, tx + tw / 2 - bw / 2));
            _bubble.y = ty - bh - margin;
            break;
        }
    }

    property string _actualPlacement: placement

    Item {
        id: _bubble
        opacity: 0
        scale: 0.96
        z: 9999

        Behavior on opacity { NumberAnimation { duration: 130; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        width:  _bubbleRect.width  + _caretItem.width  * (root._actualPlacement === "left" || root._actualPlacement === "right" ? 1 : 0)
        height: _bubbleRect.height + _caretItem.height * (root._actualPlacement === "top"  || root._actualPlacement === "bottom" ? 1 : 0)

        Rectangle {
            anchors.fill: _bubbleRect
            anchors.margins: -1
            radius: _bubbleRect.radius + 1
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.25)
            border.width: 2
            z: -1
        }

        Rectangle {
            id: _bubbleRect
            x: root._actualPlacement === "right" ? _caretItem.width : 0
            y: root._actualPlacement === "bottom" ? _caretItem.height : 0
            width: Math.min(_label.implicitWidth + Theme.spacing.md * 2, root.maxWidth)
            height: _label.implicitHeight + Theme.spacing.sm * 2 + 2
            color: Theme.colors.overlay0
            border.color: Theme.colors.surface2
            border.width: Theme.geometry.borderSm
            radius: Theme.geometry.radiusSm

            Text {
                id: _label
                text: root.text
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.text
                anchors.centerIn: parent
                width: Math.min(implicitWidth, root.maxWidth - Theme.spacing.md * 2)
                wrapMode: Text.WordWrap
                antialiasing: true
            }
        }

        Item {
            id: _caretItem
            width:  (root._actualPlacement === "top" || root._actualPlacement === "bottom") ? 12 : 7
            height: (root._actualPlacement === "top" || root._actualPlacement === "bottom") ? 7  : 12

            x: {
                switch (root._actualPlacement) {
                case "left":   return _bubbleRect.x - width;
                case "right":  return 0;
                default:       return _bubbleRect.x + _bubbleRect.width / 2 - width / 2;
                }
            }
            y: {
                switch (root._actualPlacement) {
                case "top":    return _bubbleRect.y + _bubbleRect.height;
                case "bottom": return 0;
                default:       return _bubbleRect.y + _bubbleRect.height / 2 - height / 2;
                }
            }

            clip: true
            Item {
                property real sz: 9
                width: sz; height: sz
                rotation: {
                    switch (root._actualPlacement) {
                    case "bottom": return 225;
                    case "left":   return 315;
                    case "right":  return 135;
                    default:       return 45;
                    }
                }
                x: (parent.width - sz) / 2
                y: (parent.height - sz) / 2
                transformOrigin: Item.Center

                Rectangle {
                    anchors.fill: parent
                    color: Theme.colors.overlay0
                    border.color: Theme.colors.surface2
                    border.width: Theme.geometry.borderSm
                    radius: 2
                }
            }
        }
    }
}
