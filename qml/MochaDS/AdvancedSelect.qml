import QtQuick 2.15
import QtQuick.Window 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property var options: [] // Array of objects: [{ value: "val", label: "Label" }] or strings: ["A", "B"]
    property var selectedValues: [] // Selected values array (JS array)
    property string placeholder: "Selecione..."
    property bool disabled: false
    property bool searchable: true
    property bool multiple: true
    property string size: "md" // "sm" | "md" | "lg"
    property string status: "normal" // "normal" | "success" | "error"

    // Smart flip: true when popup should open upward
    property bool expanded: false
    property bool openUpward: false
    readonly property int maxDropdownHeight: 280

    // Style overrides
    property real customRadius: -1
    property color customBorderColor: "transparent"
    property color customBackgroundColor: "transparent"

    // Signals
    signal selectionChanged(var vals)

    // ==========================================
    // Internal States and Formatting
    // ==========================================
    property string searchQuery: ""
    
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

    readonly property real finalRadius: customRadius >= 0 ? customRadius : defaultRadius
    readonly property real triggerScale: {
        if (disabled) return 1.0
        if (mouseArea.pressed) return 0.985
        if (expanded || mouseArea.containsMouse) return 1.01
        return 1.0
    }

    readonly property color finalBackgroundColor: {
        if (disabled) return Theme.colors.crust
        if (customBackgroundColor.toString() !== "#00000000" && customBackgroundColor.toString() !== "transparent") {
            return customBackgroundColor
        }
        return Theme.colors.mantle
    }

    readonly property color finalBorderColor: {
        if (disabled) return Theme.colors.surface0
        if (customBorderColor.toString() !== "#00000000" && customBorderColor.toString() !== "transparent") {
            return customBorderColor
        }
        if (status === "success") return Theme.colors.success
        if (status === "error") return Theme.colors.danger
        if (expanded) return Theme.colors.primary
        if (mouseArea.containsMouse) return Theme.colors.overlay0
        return Theme.colors.surface1
    }

    // Format options consistently: { value: X, label: Y }
    readonly property var formattedOptions: {
        var result = [];
        if (!options) return result;
        for (var i = 0; i < options.length; i++) {
            var opt = options[i];
            if (typeof opt === 'object' && opt !== null) {
                result.push({ value: opt.value, label: opt.label !== undefined ? opt.label : String(opt.value) });
            } else {
                result.push({ value: opt, label: String(opt) });
            }
        }
        return result;
    }

    // Filter options based on query
    readonly property var filteredOptions: {
        var result = [];
        var opts = formattedOptions;
        var query = searchQuery.trim().toLowerCase();
        if (query === "") return opts;
        for (var i = 0; i < opts.length; i++) {
            if (opts[i].label.toLowerCase().indexOf(query) !== -1) {
                result.push(opts[i]);
            }
        }
        return result;
    }

    // Helper to check if a value is selected
    function isSelected(val) {
        if (!selectedValues) return false;
        return selectedValues.indexOf(val) !== -1;
    }

    // Helper to toggle selection
    function toggleValue(val, label) {
        var arr = Array.prototype.slice.call(selectedValues || []);
        var idx = arr.indexOf(val);
        if (multiple) {
            if (idx === -1) {
                arr.push(val);
            } else {
                arr.splice(idx, 1);
            }
        } else {
            arr = [val];
            expanded = false;
        }
        selectedValues = arr;
        selectionChanged(arr);
    }

    // Remove single selection
    function removeValue(val) {
        var arr = Array.prototype.slice.call(selectedValues || []);
        var idx = arr.indexOf(val);
        if (idx !== -1) {
            arr.splice(idx, 1);
            selectedValues = arr;
            selectionChanged(arr);
        }
    }

    // Map selected values to labels for display
    readonly property var selectedItems: {
        var result = [];
        var vals = selectedValues || [];
        var opts = formattedOptions;
        for (var i = 0; i < vals.length; i++) {
            var val = vals[i];
            var found = false;
            for (var j = 0; j < opts.length; j++) {
                if (opts[j].value === val) {
                    result.push(opts[j]);
                    found = true;
                    break;
                }
            }
            if (!found) {
                result.push({ value: val, label: String(val) });
            }
        }
        return result;
    }

    z: expanded ? 100 : 0

    // Layout Dimensions
    implicitWidth: 320
    implicitHeight: currentHeight
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }
    activeFocusOnTab: !disabled

    FocusRing {
        target: root
        active: root.activeFocus && !root.disabled
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Outer panel box
    Rectangle {
        id: triggerBox
        anchors.fill: parent
        color: root.finalBackgroundColor
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: root.expanded ? Theme.geometry.borderMd : Theme.geometry.borderSm
        scale: root.triggerScale
        transformOrigin: Item.Center

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on scale { NumberAnimation { duration: 110; easing.type: Easing.OutCubic } }
    }

    // Content container inside the select box
    Row {
        id: triggerLayout
        anchors.fill: parent
        anchors.leftMargin: root.currentPadding
        anchors.rightMargin: root.currentPadding
        spacing: Theme.spacing.sm

        // Selected Badges Flow / Placeholder
        Item {
            height: parent.height
            width: parent.width - chevronIcon.width - parent.spacing

            // Placeholder when nothing selected
            Text {
                text: root.placeholder
                font.family: Theme.typography.family
                font.pixelSize: root.currentFontSize
                color: Theme.colors.overlay0
                visible: root.selectedValues.length === 0
                anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight
                width: parent.width
                antialiasing: true
            }

            // Flow of Badges for Multi-select
            Flickable {
                anchors.fill: parent
                contentWidth: flowLayout.implicitWidth
                contentHeight: parent.height
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                visible: root.selectedValues.length > 0

                Row {
                    id: flowLayout
                    spacing: Theme.spacing.xs
                    height: parent.height
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: root.selectedItems
                        delegate: Rectangle {
                            height: parent.height - 8
                            anchors.verticalCenter: parent.verticalCenter
                            color: Theme.colors.surface0
                            radius: Theme.geometry.radiusSm
                            border.color: Theme.colors.surface1
                            border.width: Theme.geometry.borderSm
                            scale: tagCloseMouse.pressed ? 0.97 : (tagCloseMouse.containsMouse ? 1.02 : 1.0)

                            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacing.xs
                                anchors.rightMargin: Theme.spacing.xs
                                spacing: 4

                                Text {
                                    text: modelData.label
                                    font.family: Theme.typography.family
                                    font.pixelSize: root.currentFontSize - 2
                                    color: Theme.colors.text
                                    anchors.verticalCenter: parent.verticalCenter
                                    elide: Text.ElideRight
                                    antialiasing: true
                                }

                                LucideIcon {
                                    name: "x"
                                    size: 12
                                    color: tagCloseMouse.containsMouse ? Theme.colors.red : Theme.colors.overlay1
                                    anchors.verticalCenter: parent.verticalCenter
                                    visible: !root.disabled
                                    scale: tagCloseMouse.pressed ? 0.9 : (tagCloseMouse.containsMouse ? 1.08 : 1.0)

                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                                    MouseArea {
                                        id: tagCloseMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onClicked: {
                                            root.removeValue(modelData.value);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Chevron arrow
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

    // Toggle dropdown overlay trigger MouseArea
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        // Avoid blocking badge/tag close click events
        onPressed: {
            var hitTag = false;
            if (root.selectedValues.length > 0) {
                // If clicked close to badge x coordinates, let tag handle it
                var relativeX = mouse.x - root.currentPadding;
                if (relativeX < flowLayout.implicitWidth) {
                    hitTag = true;
                }
            }
            if (hitTag) {
                mouse.accepted = false;
            } else {
                mouse.accepted = true;
            }
        }
        onClicked: {
            if (!root.expanded) {
                // Smart flip detection
                var windowItem = root;
                while (windowItem.parent !== null) windowItem = windowItem.parent;
                var posInWindow = root.mapToItem(windowItem, 0, 0);
                var spaceBelow = windowItem.height - (posInWindow.y + root.height);
                root.openUpward = spaceBelow < (root.maxDropdownHeight + Theme.spacing.md);
            }
            root.searchQuery = "";
            root.expanded = !root.expanded;
        }
    }

    // Dropdown Panel overlay
    Rectangle {
        id: dropdownContainer
        x: 0
        y: root.openUpward
           ? -(dropdownContainer.height + Theme.spacing.xs)
           : (root.height + Theme.spacing.xs)
        width: root.width
        height: root.expanded ? Math.min(root.maxDropdownHeight, listColumn.implicitHeight + Theme.spacing.sm * 2 + 2) : 0
        visible: height > 0
        clip: true
        z: 99999
        opacity: root.expanded ? 1.0 : 0.0
        scale: root.expanded ? 1.0 : 0.98
        transformOrigin: root.openUpward ? Item.Bottom : Item.Top

        color: Theme.colors.mantle
        border.color: Theme.colors.surface1
        border.width: Theme.geometry.borderSm
        radius: Theme.geometry.radiusMd

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }
        Behavior on opacity {
            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
        }
        Behavior on scale {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Column {
            id: listColumn
            width: parent.width - Theme.spacing.xs * 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.spacing.xs
            spacing: Theme.spacing.xs

            // Search Bar Input Field
            Rectangle {
                width: parent.width
                height: root.searchable ? 32 : 0
                visible: root.searchable
                color: Theme.colors.crust
                radius: Theme.geometry.radiusSm
                border.color: searchInput.activeFocus ? Theme.colors.primary : Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Behavior on border.color { ColorAnimation { duration: 120 } }

                Row {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.xs
                    spacing: Theme.spacing.xs

                    LucideIcon {
                        name: "search"
                        size: 14
                        color: Theme.colors.overlay1
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    TextInput {
                        id: searchInput
                        width: parent.width - 24
                        height: parent.height
                        font.family: Theme.typography.family
                        font.pixelSize: root.currentFontSize - 2
                        color: Theme.colors.text
                        verticalAlignment: Text.AlignVCenter
                        clip: true
                        text: root.searchQuery
                        onTextChanged: root.searchQuery = text

                        Text {
                            text: "Pesquisar..."
                            font.family: parent.font.family
                            font.pixelSize: parent.font.pixelSize
                            color: Theme.colors.overlay0
                            visible: parent.text === "" && !parent.activeFocus
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }

            // Options List
            ListView {
                id: optionsListView
                width: parent.width
                height: Math.min(200, contentHeight)
                model: root.filteredOptions
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                delegate: Rectangle {
                    id: delegateRect
                    width: optionsListView.width
                    height: root.currentHeight - 4
                    radius: Theme.geometry.radiusSm
                    color: {
                        if (root.isSelected(modelData.value)) {
                            return delegateMouseArea.containsMouse ? Qt.rgba(Theme.colors.primary.r, Theme.colors.primary.g, Theme.colors.primary.b, 0.25) : Qt.rgba(Theme.colors.primary.r, Theme.colors.primary.g, Theme.colors.primary.b, 0.15);
                        }
                        return delegateMouseArea.containsMouse ? Theme.colors.surface0 : "transparent";
                    }
                    scale: delegateMouseArea.pressed ? 0.985 : (delegateMouseArea.containsMouse ? 1.01 : 1.0)

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: root.currentPadding - 4
                        anchors.rightMargin: root.currentPadding - 4
                        spacing: Theme.spacing.sm

                        // Checkbox for multiple selection
                        Rectangle {
                            width: 14
                            height: 14
                            radius: 3
                            color: root.isSelected(modelData.value) ? Theme.colors.primary : "transparent"
                            border.color: root.isSelected(modelData.value) ? Theme.colors.primary : Theme.colors.surface2
                            border.width: 1
                            anchors.verticalCenter: parent.verticalCenter
                            visible: root.multiple

                            LucideIcon {
                                name: "check"
                                size: 10
                                color: Theme.colors.base
                                anchors.centerIn: parent
                                visible: root.isSelected(modelData.value)
                            }
                        }

                        Text {
                            text: modelData.label
                            font.family: Theme.typography.family
                            font.pixelSize: root.currentFontSize
                            color: root.isSelected(modelData.value) ? Theme.colors.primary : Theme.colors.text
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 20
                            elide: Text.ElideRight
                            antialiasing: true
                        }
                    }

                    Behavior on color { ColorAnimation { duration: 120 } }
                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                    MouseArea {
                        id: delegateMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.toggleValue(modelData.value, modelData.label);
                        }
                    }
                }
            }
        }
    }

    // Click outside catcher
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
        // Hoist click catcher
        var rootItem = root;
        while (rootItem.parent !== null) {
            rootItem = rootItem.parent;
        }
        outsideClickCatcher.parent = rootItem;
        outsideClickCatcher.anchors.fill = rootItem;

        // Close on scroll of parent Flickable
        var p = root.parent;
        while (p) {
            if (p.hasOwnProperty("flickableDirection") || p.hasOwnProperty("contentY")) {
                p.contentYChanged.connect(function() { root.expanded = false; });
                p.contentXChanged.connect(function() { root.expanded = false; });
            }
            p = p.parent;
        }
    }

    onExpandedChanged: {
        if (expanded) {
            hoistDropdown();
            if (searchable) {
                searchInput.forceActiveFocus();
            }
        } else {
            restoreDropdown();
        }
    }

    Connections {
        target: root.Window.window
        enabled: target !== null
        function onWidthChanged() { root.expanded = false; }
        function onHeightChanged() { root.expanded = false; }
    }

    function hoistDropdown() {
        var rootItem = root;
        while (rootItem.parent !== null) {
            rootItem = rootItem.parent;
        }
        if (rootItem && rootItem !== root) {
            dropdownContainer.parent = rootItem;
            dropdownContainer.x = Qt.binding(function() {
                var pos = root.mapToItem(dropdownContainer.parent, 0, 0);
                return pos.x;
            });
            dropdownContainer.y = Qt.binding(function() {
                var pos = root.mapToItem(dropdownContainer.parent, 0, 0);
                return root.openUpward
                    ? (pos.y - dropdownContainer.height - Theme.spacing.xs)
                    : (pos.y + root.height + Theme.spacing.xs);
            });
            dropdownContainer.width = root.width;
            var nextZ = Theme.getNextMaxZ();
            dropdownContainer.z = nextZ;
            outsideClickCatcher.z = nextZ - 1;
        }
    }

    function restoreDropdown() {
        dropdownContainer.parent = root;
        dropdownContainer.x = 0;
        dropdownContainer.y = Qt.binding(function() {
            return root.openUpward
               ? -(dropdownContainer.height + Theme.spacing.xs)
               : (root.height + Theme.spacing.xs);
        });
        dropdownContainer.width = root.width;
    }
}
