import QtQuick 2.15
import QtQuick.Layouts 1.15

// HoverCard — A generic floating surface triggered by hover.
//
// Usage:
//   Rectangle {
//       width: 100; height: 100; color: "blue"
//       HoverCard {
//           placement: "right"
//           contentItem: Column {
//               Text { text: "Perfil" }
//               Text { text: "Usuário ativo" }
//           }
//       }
//   }
Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    default property Component contentItem
    property string placement: "top" // "bottom", "top", "left", "right"
    property int    openDelay: 300
    property int    closeDelay: 300
    property bool   disabled: false

    property var    _origParent: null
    property bool   _triggerHovered: false
    property bool   _cardHovered: false
    property string _actualPlacement: placement
    
    readonly property bool _shouldBeOpen: (_triggerHovered || _cardHovered) && !disabled

    on_ShouldBeOpenChanged: {
        if (_shouldBeOpen) {
            _closeTimer.stop();
            if (openDelay > 0) _openTimer.restart();
            else _open();
        } else {
            _openTimer.stop();
            if (closeDelay > 0) _closeTimer.restart();
            else _close();
        }
    }

    Timer { id: _openTimer; interval: root.openDelay; onTriggered: root._open() }
    Timer { id: _closeTimer; interval: root.closeDelay; onTriggered: root._close() }

    Component.onCompleted: {
        _origParent = parent;
        var r = parent;
        while (r && r.parent) r = r.parent;
        
        _triggerTracker.createObject(_origParent);
        
        root.parent = r;
    }

    Component {
        id: _triggerTracker
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: root._triggerHovered = true
            onExited: root._triggerHovered = false
        }
    }

    // ==========================================
    // Internal State
    // ==========================================
    property real _tx: 0
    property real _ty: 0
    property real _tw: 0
    property real _th: 0
    
    function _open() {
        if (!root._origParent) return;
        var pos = root._origParent.mapToItem(root.parent, 0, 0);
        _tx = pos.x;
        _ty = pos.y;
        _tw = root._origParent.width;
        _th = root._origParent.height;

        var windowItem = root.parent;
        var winHeight = windowItem ? windowItem.height : 600;
        var winWidth = windowItem ? windowItem.width : 800;
        
        var panelH = _loader.implicitHeight + Theme.spacing.md * 2;
        var panelW = _loader.implicitWidth + Theme.spacing.md * 2;
        
        var spaceBelow = winHeight - (_ty + _th);
        var spaceAbove = _ty;
        var spaceRight = winWidth - (_tx + _tw);
        var spaceLeft = _tx;

        var activePlacement = placement;
        
        if (placement.indexOf("bottom") === 0 && spaceBelow < panelH + 10 && spaceAbove > spaceBelow) {
            activePlacement = placement.replace("bottom", "top");
        } else if (placement.indexOf("top") === 0 && spaceAbove < panelH + 10 && spaceBelow > spaceAbove) {
            activePlacement = placement.replace("top", "bottom");
        } else if (placement.indexOf("right") === 0 && spaceRight < panelW + 10 && spaceLeft > spaceRight) {
            activePlacement = placement.replace("right", "left");
        } else if (placement.indexOf("left") === 0 && spaceLeft < panelW + 10 && spaceRight > spaceLeft) {
            activePlacement = placement.replace("left", "right");
        }
        
        _actualPlacement = activePlacement;

        var nextZ = Theme.getNextMaxZ();
        root.z = nextZ;
        _panel.z = nextZ;

        _panel.opacity = 1;
        _panel.scale = 1;
    }

    function _close() {
        _panel.opacity = 0;
        _panel.scale = 0.95;
    }

    // ==========================================
    // Computed panel position
    // ==========================================
    property real _panelX: {
        var pw = _panel.width;
        if (_actualPlacement === "left") return _tx - pw - 8;
        if (_actualPlacement === "right") return _tx + _tw + 8;
        return _tx + _tw / 2 - pw / 2;
    }

    property real _panelY: {
        var ph = _panel.height;
        if (_actualPlacement === "bottom") return _ty + _th + 8;
        if (_actualPlacement === "top") return _ty - ph - 8;
        return _ty + _th / 2 - ph / 2;
    }

    // ==========================================
    // UI Elements
    // ==========================================
    Item {
        id: _panel
        x: {
            var winW = root.parent ? root.parent.width : 800;
            return Math.max(8, Math.min(winW - width - 8, root._panelX));
        }
        y: {
            var winH = root.parent ? root.parent.height : 600;
            return Math.max(8, Math.min(winH - height - 8, root._panelY));
        }
        width: _loader.implicitWidth + Theme.spacing.md * 2
        height: _loader.implicitHeight + Theme.spacing.md * 2
        opacity: 0
        scale: 0.95
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root._cardHovered = true
            onExited: root._cardHovered = false
        }

        Rectangle {
            anchors.fill: parent
            color: Theme.colors.base
            border.color: Theme.colors.surface1
            border.width: Theme.geometry.borderSm
            radius: Theme.geometry.radiusLg
            
            // Drop shadow
            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                z: -1
                color: "transparent"
                border.color: Qt.rgba(0,0,0,0.2)
                radius: parent.radius
            }

            Loader {
                id: _loader
                anchors.centerIn: parent
                sourceComponent: root.contentItem
            }
        }
    }
}
