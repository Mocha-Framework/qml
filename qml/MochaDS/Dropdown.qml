import QtQuick 2.15

// Dropdown — Contextual action menu that opens near a trigger item.
//
// Usage:
//   Dropdown {
//       id: myMenu
//       items: [
//           { label: "Editar",    icon: "pencil" },
//           { label: "Duplicar",  icon: "copy" },
//           { separator: true },
//           { label: "Excluir",   icon: "trash-2", variant: "danger" }
//       ]
//       onItemSelected: function(item) { console.log(item.label) }
//   }
//   Button {
//       text: "Opções"
//       onClicked: myMenu.toggle(this)
//   }
Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    property var    items: []
    property string placement: "bottom-start" // "bottom-start"|"bottom-end"|"top-start"|"top-end"
    property real   minWidth: 180
    property bool   isOpen: false
    property bool   disabled: false
    property string _actualPlacement: placement

    signal itemSelected(var item)

    function toggle(triggerItem) { if (!root.disabled) { isOpen ? _close() : _open(triggerItem) } }
    function open(triggerItem)   { if (!root.disabled) { _open(triggerItem) } }
    function close()             { _close() }

    // ==========================================
    // Internal
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

        // Smart flip logic: check if there is room below
        var windowItem = root.parent;
        var winHeight = windowItem ? windowItem.height : 600;
        var panelH = _itemsColumn.implicitHeight + Theme.spacing.sm * 2 + 2;
        var spaceBelow = winHeight - (_ty + _th);
        var spaceAbove = _ty;

        var activePlacement = placement;
        if (placement.indexOf("bottom") === 0) {
            if (spaceBelow < panelH + 10 && spaceAbove > spaceBelow) {
                activePlacement = placement.replace("bottom", "top");
            }
        } else if (placement.indexOf("top") === 0) {
            if (spaceAbove < panelH + 10 && spaceBelow > spaceAbove) {
                activePlacement = placement.replace("top", "bottom");
            }
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
        if (_actualPlacement === "bottom-end" || _actualPlacement === "top-end")
            return _tx + _tw - _panel.width;
        return _tx;
    }
    property real _panelY: {
        if (_actualPlacement === "top-start" || _actualPlacement === "top-end")
            return _ty - _panel.height - 4;
        return _ty + _th + 4;
    }

    // ==========================================
    // Full-screen backdrop (closes on outside click)
    // ==========================================
    MouseArea {
        id: _backdrop
        width:  root.parent ? root.parent.width  : 0
        height: root.parent ? root.parent.height : 0
        visible: root.isOpen
        z: 9998
        onClicked: root._close()
    }

    // ==========================================
    // Panel
    // ==========================================
    Rectangle {
        id: _panel
        x: root._panelX
        y: root._panelY
        z: 9999
        visible: root.isOpen

        width:  Math.max(root.minWidth,
                         _itemsColumn.implicitWidth + Theme.spacing.sm * 2 + 2)
        height: _itemsColumn.implicitHeight + Theme.spacing.sm * 2 + 2

        color:  Theme.colors.mantle
        border.color: Theme.colors.surface1
        border.width: Theme.geometry.borderSm
        radius: Theme.geometry.radiusMd
        clip: true

        layer.enabled: true

        // Drop shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            radius: parent.radius + 2
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.3)
            border.width: 3
            z: -1
        }

        // Open/close animation
        opacity: root.isOpen ? 1 : 0
        scale:   root.isOpen ? 1 : 0.94
        transformOrigin: {
            switch (root._actualPlacement) {
            case "bottom-end": return Item.TopRight;
            case "top-start":  return Item.BottomLeft;
            case "top-end":    return Item.BottomRight;
            default:           return Item.TopLeft; // bottom-start
            }
        }

        Behavior on opacity { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on scale   { NumberAnimation { duration: 150; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }

        Column {
            id: _itemsColumn
            x: Theme.spacing.sm
            y: Theme.spacing.sm + 1
            width: _panel.width - Theme.spacing.sm * 2 - 2
            spacing: 1

            Repeater {
                model: root.items
                delegate: Loader {
                    id: _delegateLoader
                    width: _itemsColumn.width
                    property var rowData: modelData
                    sourceComponent: modelData.separator === true
                                     ? _separatorComponent
                                     : _menuItemComponent
                }
            }
        }
    }

    // ==========================================
    // Separator component
    // ==========================================
    Component {
        id: _separatorComponent
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.colors.surface1
            opacity: 0.7
        }
    }

    // ==========================================
    // Menu item component
    // ==========================================
    Component {
        id: _menuItemComponent

        Rectangle {
            id: _itemRect
            property var rowData: parent ? parent.rowData : null
            property bool isDanger:   rowData && rowData.variant === "danger"
            property bool isDisabled: rowData && rowData.disabled === true

            width:  parent ? parent.width : 0
            height: 36
            radius: Theme.geometry.radiusSm

            color: {
                if (isDisabled) return "transparent";
                if (_hover.containsMouse) {
                    return isDanger
                        ? Qt.rgba(Theme.colors.red.r, Theme.colors.red.g, Theme.colors.red.b, 0.15)
                        : Theme.colors.surface0;
                }
                return "transparent";
            }

            Behavior on color { ColorAnimation { duration: 100 } }

            // Icon
            LucideIcon {
                id: _icon
                name: _itemRect.rowData ? (_itemRect.rowData.icon || "") : ""
                size: 14
                color: _itemRect.isDisabled ? Theme.colors.overlay0
                     : _itemRect.isDanger   ? Theme.colors.red
                     : Theme.colors.subtext1
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacing.sm
                visible: _itemRect.rowData && _itemRect.rowData.icon

                Behavior on color { ColorAnimation { duration: 100 } }
            }

            // Label
            Text {
                id: _label
                text: _itemRect.rowData ? (_itemRect.rowData.label || "") : ""
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: _itemRect.isDisabled ? Theme.colors.overlay0
                     : _itemRect.isDanger   ? Theme.colors.red
                     : Theme.colors.text
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: _icon.visible ? _icon.right : parent.left
                anchors.leftMargin: _icon.visible ? Theme.spacing.sm : Theme.spacing.sm
                antialiasing: true

                Behavior on color { ColorAnimation { duration: 100 } }
            }

            // Shortcut hint (right-aligned)
            Text {
                id: _shortcut
                text: _itemRect.rowData ? (_itemRect.rowData.shortcut || "") : ""
                font.family: Theme.typography.family
                font.pixelSize: 11
                color: Theme.colors.overlay0
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.sm
                visible: text !== ""
                antialiasing: true
            }

            // Hover/click area
            MouseArea {
                id: _hover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: _itemRect.isDisabled ? Qt.ArrowCursor : Qt.PointingHandCursor
                enabled: !_itemRect.isDisabled

                onClicked: {
                    if (!_itemRect.rowData) return;
                    root.itemSelected(_itemRect.rowData);
                    if (!(_itemRect.rowData.keepOpen === true)) root._close();
                }
            }
        }
    }
}
