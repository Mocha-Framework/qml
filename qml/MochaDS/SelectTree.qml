import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property var options: [] // [{ label: "A", value: "a", children: [...] }]
    property var selectedValue: null
    property string selectedLabel: ""
    property string placeholder: "Selecione uma opção..."
    property bool disabled: false
    property string size: "md"

    // Expand state of the dropdown
    property bool expanded: false

    // Smart flip: true when popup should open upward
    property bool openUpward: false

    // Max dropdown height (used for flip calculation)
    readonly property int maxDropdownHeight: 260

    // Internal tree expanded states
    property var expandedNodes: ({})
    property var flatList: []

    // Signals
    signal valueChanged(var val)

    z: expanded ? 100 : 0

    // Size tokens mapping
    readonly property real currentHeight: {
        if (size === "sm") return 32
        if (size === "lg") return 48
        return 40 // "md"
    }

    readonly property real currentPadding: {
        if (size === "sm") return Theme.spacing.sm
        if (size === "lg") return Theme.spacing.lg
        return Theme.spacing.md
    }

    readonly property real currentFontSize: {
        if (size === "sm") return Theme.typography.sizeSm
        if (size === "lg") return Theme.typography.sizeLg
        return Theme.typography.sizeMd
    }

    readonly property real defaultRadius: {
        if (size === "sm") return Theme.geometry.radiusSm
        if (size === "lg") return Theme.geometry.radiusLg
        return Theme.geometry.radiusMd
    }

    readonly property color finalBackgroundColor: disabled ? Theme.colors.crust : Theme.colors.mantle
    readonly property color finalBorderColor: {
        if (disabled) return Theme.colors.surface0
        if (expanded) return Theme.colors.primary
        if (mouseArea.containsMouse) return Theme.colors.overlay0
        return Theme.colors.surface1
    }

    implicitWidth: 280
    implicitHeight: currentHeight
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Outer box panel
    Rectangle {
        id: triggerBox
        anchors.fill: parent
        color: root.finalBackgroundColor
        radius: root.defaultRadius
        border.color: root.finalBorderColor
        border.width: root.expanded ? Theme.geometry.borderMd : Theme.geometry.borderSm

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // Trigger content
    Row {
        id: triggerLayout
        anchors.fill: parent
        anchors.leftMargin: root.currentPadding
        anchors.rightMargin: root.currentPadding
        spacing: Theme.spacing.sm

        Text {
            text: root.selectedLabel !== "" ? root.selectedLabel : root.placeholder
            font.family: Theme.typography.family
            font.pixelSize: root.currentFontSize
            color: root.selectedLabel !== "" ? (root.disabled ? Theme.colors.overlay0 : Theme.colors.text) : Theme.colors.overlay0
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - chevronIcon.width - parent.spacing
            elide: Text.ElideRight
            antialiasing: true

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        LucideIcon {
            id: chevronIcon
            name: "chevron-down"
            size: root.currentHeight * 0.4
            color: root.disabled ? Theme.colors.overlay0 : (root.expanded ? Theme.colors.primary : Theme.colors.subtext0)
            anchors.verticalCenter: parent.verticalCenter
            rotation: root.expanded ? 180 : 0
            Behavior on rotation {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
        }
    }

    // Toggle click area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        onClicked: {
            if (!root.expanded) {
                // Smart flip: detect if there is room below
                var windowItem = root;
                while (windowItem.parent !== null) windowItem = windowItem.parent;
                var posInWindow = root.mapToItem(windowItem, 0, 0);
                var spaceBelow = windowItem.height - (posInWindow.y + root.height);
                root.openUpward = spaceBelow < (root.maxDropdownHeight + Theme.spacing.md);
            }
            root.expanded = !root.expanded;
        }
    }

    // Dropdown list container
    Rectangle {
        id: dropdownContainer
        x: 0
        // Flip: open above trigger when there's not enough space below
        y: root.openUpward
           ? -(dropdownContainer.height + Theme.spacing.xs)
           : (root.height + Theme.spacing.xs)
        width: root.width
        height: root.expanded ? Math.min(260, treeListView.contentHeight + Theme.spacing.xs * 2) : 0
        visible: height > 0
        clip: true
        z: 99999

        color: Theme.colors.mantle
        border.color: Theme.colors.surface1
        border.width: Theme.geometry.borderSm
        radius: Theme.geometry.radiusMd

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        ListView {
            id: treeListView
            anchors.fill: parent
            anchors.margins: Theme.spacing.xs
            model: root.flatList
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            delegate: Rectangle {
                id: delegateRect
                width: treeListView.width
                height: root.currentHeight - 4
                radius: Theme.geometry.radiusSm
                color: {
                    if (modelData.value === root.selectedValue) {
                        return delegateMouseArea.containsMouse ? Qt.rgba(Theme.colors.primary.r, Theme.colors.primary.g, Theme.colors.primary.b, 0.25) : Qt.rgba(Theme.colors.primary.r, Theme.colors.primary.g, Theme.colors.primary.b, 0.15);
                    }
                    return delegateMouseArea.containsMouse ? Theme.colors.surface0 : "transparent";
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: root.currentPadding + (modelData.level * Theme.spacing.lg) - 4
                    spacing: Theme.spacing.xs

                    // Collapse/Expand Icon (only if it has children)
                    LucideIcon {
                        name: "chevron-right"
                        size: 16
                        color: Theme.colors.subtext0
                        anchors.verticalCenter: parent.verticalCenter
                        visible: modelData.hasChildren
                        rotation: modelData.expanded ? 90 : 0
                        Behavior on rotation {
                            NumberAnimation { duration: 150 }
                        }
                    }

                    // Node Icon (Folder for branches, File for leaves)
                    LucideIcon {
                        name: modelData.hasChildren ? (modelData.expanded ? "folder-open" : "folder") : "file"
                        size: 16
                        color: modelData.value === root.selectedValue ? Theme.colors.primary : Theme.colors.subtext1
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: modelData.label
                        font.family: Theme.typography.family
                        font.pixelSize: root.currentFontSize
                        color: modelData.value === root.selectedValue ? Theme.colors.primary : Theme.colors.text
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 40 // space for icons
                        elide: Text.ElideRight
                        antialiasing: true
                    }
                }

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.hasChildren) {
                            // Toggle expanded state
                            var val = modelData.value;
                            var expandedNodesCopy = root.expandedNodes;
                            expandedNodesCopy[val] = !expandedNodesCopy[val];
                            root.expandedNodes = expandedNodesCopy; // trigger change binding
                            root.rebuildFlatList();
                        } else {
                            // Select leaf node
                            root.selectedValue = modelData.value;
                            root.selectedLabel = modelData.label;
                            root.valueChanged(modelData.value);
                            root.expanded = false;
                        }
                    }
                }
            }
        }
    }

    // Click outside catcher with click propagation
    MouseArea {
        id: outsideClickCatcher
        enabled: root.expanded
        z: 99998
        hoverEnabled: false
        propagateComposedEvents: true

        onPressed: {
            var clickPos = mapToItem(dropdownContainer, mouse.x, mouse.y);
            if (clickPos.x >= 0 && clickPos.x <= dropdownContainer.width &&
                clickPos.y >= 0 && clickPos.y <= dropdownContainer.height) {
                mouse.accepted = false;
            } else {
                mouse.accepted = true;
            }
        }

        onClicked: {
            var clickPos = mapToItem(dropdownContainer, mouse.x, mouse.y);
            if (clickPos.x >= 0 && clickPos.x <= dropdownContainer.width &&
                clickPos.y >= 0 && clickPos.y <= dropdownContainer.height) {
                mouse.accepted = false;
            } else {
                root.expanded = false;
            }
        }
    }

    Component.onCompleted: {
        // Find top-level root element and reparent click catcher to it
        var rootItem = root;
        while (rootItem.parent !== null) {
            rootItem = rootItem.parent;
        }
        outsideClickCatcher.parent = rootItem;
        outsideClickCatcher.anchors.fill = rootItem;

        rebuildFlatList();
        updateLabelFromValue();
    }

    onSelectedValueChanged: {
        updateLabelFromValue();
    }

    onOptionsChanged: {
        rebuildFlatList();
        updateLabelFromValue();
    }

    function rebuildFlatList() {
        var list = [];
        
        function traverse(nodes, level, parentExpanded) {
            if (!nodes) return;
            for (var i = 0; i < nodes.length; i++) {
                var node = nodes[i];
                var nodeVal = node.value !== undefined ? node.value : node.label;
                var isExpanded = root.expandedNodes[nodeVal] === true;
                var hasKids = node.children && node.children.length > 0;
                
                if (parentExpanded) {
                    list.push({
                        "label": node.label,
                        "value": nodeVal,
                        "level": level,
                        "hasChildren": hasKids,
                        "expanded": isExpanded
                    });
                }
                
                if (hasKids) {
                    traverse(node.children, level + 1, parentExpanded && isExpanded);
                }
            }
        }
        
        traverse(root.options, 0, true);
        root.flatList = list;
    }

    function updateLabelFromValue() {
        if (root.selectedValue === null || root.selectedValue === undefined) {
            root.selectedLabel = "";
            return;
        }

        // Search recursively inside options tree
        function findLabel(nodes, val) {
            if (!nodes) return null;
            for (var i = 0; i < nodes.length; i++) {
                var node = nodes[i];
                var nodeVal = node.value !== undefined ? node.value : node.label;
                if (nodeVal === val) {
                    return node.label;
                }
                if (node.children) {
                    var lbl = findLabel(node.children, val);
                    if (lbl) return lbl;
                }
            }
            return null;
        }

        var label = findLabel(root.options, root.selectedValue);
        if (label !== null) {
            root.selectedLabel = label;
        } else {
            root.selectedLabel = String(root.selectedValue);
        }
    }
}
