import QtQuick 2.15
import QtQuick.Window 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    
    // Array of objects: [{ value: "val", label: "Label" }] or strings: ["val1", "val2"]
    property var options: []
    
    property var selectedValue: null
    property string selectedLabel: ""
    property string placeholder: "Selecione uma opção..."
    property bool disabled: false
    property string size: "md" // "sm" | "md" | "lg"
    
    // Validation status: "normal" | "success" | "error"
    property string status: "normal"

    // Form validation
    property string errorText: ""
    property bool isInvalid: errorText.length > 0

    // Expand state
    property bool expanded: false

    // Smart flip: true when popup should open upward
    property bool openUpward: false

    // Max dropdown height (used for flip calculation)
    readonly property int maxDropdownHeight: 220

    // Style overrides
    property real customRadius: -1
    property color customBorderColor: "transparent"
    property color customBackgroundColor: "transparent"

    // Signals
    signal valueChanged(var val)

    // ==========================================
    // Raise z-index when expanded to draw over siblings
    // ==========================================
    z: expanded ? 100 : 0

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property real currentHeight: {
        if (size === "sm") return 32
        if (size === "lg") return 48
        return 40 // "md"
    }

    readonly property real currentPadding: {
        if (size === "sm") return Theme.spacing.sm // 8px
        if (size === "lg") return Theme.spacing.lg // 16px
        return Theme.spacing.md // 12px (md)
    }

    readonly property real currentFontSize: {
        if (size === "sm") return Theme.typography.sizeSm // 12px
        if (size === "lg") return Theme.typography.sizeLg // 16px
        return Theme.typography.sizeMd // 14px (md)
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
        if (isInvalid) return Theme.colors.danger
        if (customBorderColor.toString() !== "#00000000" && customBorderColor.toString() !== "transparent") {
            return customBorderColor
        }
        if (status === "success") return Theme.colors.success
        if (status === "error") return Theme.colors.danger
        if (expanded) return Theme.colors.primary
        if (mouseArea.containsMouse) return Theme.colors.overlay0
        return Theme.colors.surface1
    }

    // Format options as consistent JS objects: { value: X, label: Y }
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

    // Layout Dimensions
    implicitWidth: 280
    implicitHeight: currentHeight + (isInvalid ? 20 : 0)

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Accessibility
    Accessible.role: Accessible.ComboBox
    Accessible.name: placeholder
    activeFocusOnTab: !disabled

    FocusRing {
        target: root
        active: root.activeFocus && !root.disabled
    }

    // Error text label
    Text {
        id: errorLabel
        y: currentHeight + 2
        text: root.errorText
        font.family: Theme.typography.family
        font.pixelSize: Theme.typography.sizeXs
        color: Theme.colors.danger
        visible: root.isInvalid
        height: 16
        anchors.left: parent.left
        anchors.leftMargin: 2
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Outer box panel
    Rectangle {
        id: triggerBox
        y: 0
        width: parent.width
        height: currentHeight
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

    // Trigger content (Text + Chevron)
    Row {
        id: triggerLayout
        anchors.fill: parent
        anchors.leftMargin: root.currentPadding
        anchors.rightMargin: root.currentPadding
        spacing: Theme.spacing.sm

        // Text Display
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

        // Chevron Arrow Icon
        LucideIcon {
            id: chevronIcon
            name: "chevron-down"
            size: root.currentHeight * 0.4
            color: root.disabled ? Theme.colors.overlay0 : (root.expanded ? Theme.colors.primary : Theme.colors.subtext0)
            anchors.verticalCenter: parent.verticalCenter
            
            // Chevron rotation micro-animation
            rotation: root.expanded ? 180 : 0
            Behavior on rotation {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    // Dropdown toggle click area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        onClicked: root.toggleDropdown()
    }

    // Dropdown list container (drawn relative to the parent)
    Rectangle {
        id: dropdownContainer
        x: 0
        // Flip: open above trigger when there's not enough space below
        y: root.openUpward
           ? -(dropdownContainer.height + Theme.spacing.xs)
           : (root.height + Theme.spacing.xs)
        width: root.width
        
        // Animated expansion height
        height: root.expanded ? Math.min(220, optionsListView.contentHeight + Theme.spacing.xs * 2) : 0
        visible: height > 0
        clip: true
        z: 99999 // Draw above everything
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

        // Dropdown Items List
        ListView {
            id: optionsListView
            anchors.fill: parent
            anchors.margins: Theme.spacing.xs
            model: root.formattedOptions
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            delegate: Rectangle {
                id: delegateRect
                width: optionsListView.width
                height: root.currentHeight - 4
                radius: Theme.geometry.radiusSm
                color: {
                    var isSelected = (modelData.value === root.selectedValue);
                    var isHighlighted = (index === optionsListView.currentIndex);
                    if (isSelected) {
                        return (delegateMouseArea.containsMouse || isHighlighted)
                            ? Qt.rgba(Theme.colors.primary.r, Theme.colors.primary.g, Theme.colors.primary.b, 0.25)
                            : Qt.rgba(Theme.colors.primary.r, Theme.colors.primary.g, Theme.colors.primary.b, 0.15);
                    }
                    return (delegateMouseArea.containsMouse || isHighlighted) ? Theme.colors.surface0 : "transparent";
                }
                scale: delegateMouseArea.pressed ? 0.985 : (delegateMouseArea.containsMouse ? 1.01 : 1.0)

                Text {
                    text: modelData.label
                    font.family: Theme.typography.family
                    font.pixelSize: root.currentFontSize
                    color: modelData.value === root.selectedValue ? Theme.colors.primary : Theme.colors.text
                    anchors.fill: parent
                    anchors.leftMargin: root.currentPadding - 4
                    anchors.rightMargin: root.currentPadding - 4
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                    antialiasing: true
                }

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                MouseArea {
                    id: delegateMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.selectedValue = modelData.value;
                        root.selectedLabel = modelData.label;
                        root.valueChanged(modelData.value);
                        root.expanded = false;
                    }
                }
            }
        }

        // Custom lightweight scrollbar binding to ListView visibleArea
        Rectangle {
            id: customScrollbar
            anchors.right: parent.right
            anchors.rightMargin: 2
            y: optionsListView.visibleArea.yPosition * optionsListView.height
            width: 4
            height: optionsListView.visibleArea.heightRatio * optionsListView.height
            color: Theme.colors.surface2
            radius: 2
            opacity: 0.6
            visible: optionsListView.visibleArea.heightRatio < 1.0
        }
    }

    // ==========================================
    // Click outside catcher
    // ==========================================
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
                // Click is inside dropdownContainer, propagate the press
                mouse.accepted = false;
            } else {
                // Click is outside, we accept the press to receive clicked event
                mouse.accepted = true;
            }
        }

        onClicked: {
            var clickPos = mapToItem(dropdownContainer, mouse.x, mouse.y);
            if (clickPos.x >= 0 && clickPos.x <= dropdownContainer.width &&
                clickPos.y >= 0 && clickPos.y <= dropdownContainer.height) {
                // Click is inside dropdownContainer, propagate
                mouse.accepted = false;
            } else {
                root.expanded = false;
            }
        }
    }

    Component.onCompleted: {
        // Find top-level root element and reparent click catcher to it
        var rootItem = root;
        while (rootItem.parent) {
            rootItem = rootItem.parent;
        }
        outsideClickCatcher.parent = rootItem;
        outsideClickCatcher.anchors.fill = rootItem;
        updateLabelFromValue();

        // Connect to parent Flickable content changes to close on scroll
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
            var selectedIdx = -1
            for (var i = 0; i < root.formattedOptions.length; i++) {
                if (root.formattedOptions[i].value === root.selectedValue) {
                    selectedIdx = i
                    break
                }
            }
            optionsListView.currentIndex = selectedIdx >= 0 ? selectedIdx : 0
            optionsListView.positionViewAtIndex(optionsListView.currentIndex, ListView.Contain)
        } else {
            restoreDropdown();
        }
    }

    // Window size change detector
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


    // Sync external selected value changes
    onSelectedValueChanged: {
        updateLabelFromValue();
    }

    onOptionsChanged: {
        updateLabelFromValue();
    }

    function updateLabelFromValue() {
        if (root.selectedValue === null || root.selectedValue === undefined) {
            root.selectedLabel = "";
            return;
        }
        
        var opts = root.formattedOptions;
        if (!opts) {
            root.selectedLabel = String(root.selectedValue);
            return;
        }
        for (var i = 0; i < opts.length; i++) {
            if (opts[i] && opts[i].value === root.selectedValue) {
                root.selectedLabel = opts[i].label;
                return;
            }
        }
        // Fallback to string representation if not found in options
        root.selectedLabel = String(root.selectedValue);
    }

    function toggleDropdown() {
        if (root.disabled) return;
        if (!root.expanded) {
            var windowItem = root;
            while (windowItem.parent !== null) windowItem = windowItem.parent;
            var posInWindow = root.mapToItem(windowItem, 0, 0);
            var spaceBelow = windowItem.height - (posInWindow.y + root.height);
            root.openUpward = spaceBelow < (root.maxDropdownHeight + Theme.spacing.md);
        }
        root.expanded = !root.expanded;
    }

    function selectIndex(index) {
        if (index >= 0 && index < root.formattedOptions.length) {
            var item = root.formattedOptions[index]
            root.selectedValue = item.value;
            root.selectedLabel = item.label;
            root.valueChanged(item.value);
            root.expanded = false;
        }
    }



    Keys.onSpacePressed: toggleDropdown()
    Keys.onReturnPressed: {
        if (root.expanded) {
            selectIndex(optionsListView.currentIndex)
        } else {
            toggleDropdown()
        }
    }
    Keys.onEscapePressed: {
        if (root.expanded) {
            root.expanded = false;
        }
    }
    Keys.onDownPressed: {
        if (!root.expanded) {
            toggleDropdown()
        } else {
            if (optionsListView.currentIndex < optionsListView.count - 1) {
                optionsListView.currentIndex++
            }
        }
    }
    Keys.onUpPressed: {
        if (root.expanded) {
            if (optionsListView.currentIndex > 0) {
                optionsListView.currentIndex--
            }
        }
    }
}
