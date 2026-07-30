import QtQuick 2.15
import QtQuick.Layouts 1.15

// Popover — A generic floating surface for complex content (forms, filters, etc.)
//
// Usage:
//   Popover {
//       id: myPopover
//       placement: "bottom"
//       contentItem: Column {
//           spacing: Theme.spacing.md
//           Text { text: "Filtros Rápidos"; color: Theme.colors.text; font.bold: true }
//           TextField { placeholderText: "Pesquisar..." }
//           Button { text: "Aplicar"; onClicked: myPopover.close() }
//       }
//   }
//   Button {
//       text: "Abrir"
//       onClicked: myPopover.toggle(this)
//   }
Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    default property Component contentItem
    property string placement: "bottom" // "bottom", "top", "left", "right" - can add "-start"/ "-end" support too
    property bool   isOpen: false
    property bool   disabled: false
    property string _actualPlacement: placement

    function toggle(triggerItem) { if (!root.disabled) { isOpen ? _close() : _open(triggerItem) } }
    function open(triggerItem)   { if (!root.disabled) { _open(triggerItem) } }
    function close()             { _close() }

    // ==========================================
    // Internal State
    // ==========================================
    property real _tx: 0
    property real _ty: 0
    property real _tw: 0
    property real _th: 0

    function _open(triggerItem) {
        if (!triggerItem) return;
        var pos = triggerItem.mapToItem(root.parent, 0, 0);
        _tx = pos.x;
        _ty = pos.y;
        _tw = triggerItem.width;
        _th = triggerItem.height;

        // Smart flip logic
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
        _backdrop.z = nextZ - 1;

        isOpen = true;
    }

    function _close() { isOpen = false; }

    function _windowRoot() {
        var r = root.parent;
        while (r && r.parent) r = r.parent;
        return r;
    }

    Component.onCompleted: {
        var r = _windowRoot();
        if (r) root.parent = r;
    }

    // ==========================================
    // Computed panel position
    // ==========================================
    property real _panelX: {
        var pw = _panel.width;
        if (_actualPlacement === "bottom-end" || _actualPlacement === "top-end") return _tx + _tw - pw;
        if (_actualPlacement === "bottom-start" || _actualPlacement === "top-start") return _tx;
        if (_actualPlacement === "left") return _tx - pw - 8;
        if (_actualPlacement === "right") return _tx + _tw + 8;
        // Center horizontal (bottom/top)
        return _tx + _tw / 2 - pw / 2;
    }

    property real _panelY: {
        var ph = _panel.height;
        if (_actualPlacement.indexOf("bottom") === 0) return _ty + _th + 8;
        if (_actualPlacement.indexOf("top") === 0) return _ty - ph - 8;
        // Center vertical (left/right)
        return _ty + _th / 2 - ph / 2;
    }

    // ==========================================
    // UI Elements
    // ==========================================
    MouseArea {
        id: _backdrop
        anchors.fill: parent
        visible: root.isOpen
        onClicked: root._close()
    }

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
        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.95
        visible: opacity > 0

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuart } }
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }

        Rectangle {
            anchors.fill: parent
            color: Theme.colors.mantle
            border.color: Theme.colors.surface0
            border.width: Theme.geometry.borderSm
            radius: Theme.geometry.radiusLg
            
            // Subtle shadow
            Rectangle {
                anchors.fill: parent
                anchors.margins: -1
                z: -1
                color: "transparent"
                border.color: Qt.rgba(0,0,0,0.15)
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
