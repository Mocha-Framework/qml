import QtQuick 2.15
import QtQuick.Window 2.15

Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    property string colorValue: "#CBA6F7"
    property bool inline: false
    property bool disabled: false
    signal colorChanged(string newHex)

    // Popover state
    property bool expanded: false
    property bool openUpward: false
    readonly property int popupHeight: 210

    // ==========================================
    // Internal States
    // ==========================================
    property real currentHue: 0.8
    property real currentSaturation: 0.33
    property real currentValue: 0.97
    property bool _updating: false

    implicitWidth: 280
    implicitHeight: inline ? 290 : 40
    width: implicitWidth
    height: implicitHeight

    // ==========================================
    // Helpers (HSV <-> Hex Conversion)
    // ==========================================
    function hsvToHex(h, s, v) {
        var r, g, b;
        var i = Math.floor(h * 6);
        var f = h * 6 - i;
        var p = v * (1 - s);
        var q = v * (1 - f * s);
        var t = v * (1 - (1 - f) * s);
        switch (i % 6) {
            case 0: r = v; g = t; b = p; break;
            case 1: r = q; g = v; b = p; break;
            case 2: r = p; g = v; b = t; break;
            case 3: r = p; g = q; b = v; break;
            case 4: r = t; g = p; b = v; break;
            case 5: r = v; g = p; b = q; break;
        }
        var rHex = Math.round(r * 255).toString(16).padStart(2, '0').toUpperCase();
        var gHex = Math.round(g * 255).toString(16).padStart(2, '0').toUpperCase();
        var bHex = Math.round(b * 255).toString(16).padStart(2, '0').toUpperCase();
        return "#" + rHex + gHex + bHex;
    }

    function hexToHsv(hex) {
        var cleanHex = hex.trim();
        if (cleanHex.startsWith("#")) {
            cleanHex = cleanHex.slice(1);
        }
        if (cleanHex.length === 3) {
            cleanHex = cleanHex[0] + cleanHex[0] + cleanHex[1] + cleanHex[1] + cleanHex[2] + cleanHex[2];
        }
        if (cleanHex.length !== 6) {
            return null;
        }
        var r = parseInt(cleanHex.slice(0, 2), 16) / 255;
        var g = parseInt(cleanHex.slice(2, 4), 16) / 255;
        var b = parseInt(cleanHex.slice(4, 6), 16) / 255;

        var max = Math.max(r, g, b), min = Math.min(r, g, b);
        var h, s, v = max;

        var d = max - min;
        s = max === 0 ? 0 : d / max;

        if (max === min) {
            h = 0; // achromatic
        } else {
            switch (max) {
                case r: h = (g - b) / d + (g < b ? 6 : 0); break;
                case g: h = (b - r) / d + 2; break;
                case b: h = (r - g) / d + 4; break;
            }
            h /= 6;
        }
        return { h: h, s: s, v: v };
    }

    function updateColorValue() {
        if (_updating) return;
        _updating = true;
        var hex = hsvToHex(currentHue, currentSaturation, currentValue);
        colorValue = hex;
        colorChanged(hex);
        _updating = false;
    }

    onColorValueChanged: {
        if (typeof inlineInput !== "undefined" && inlineInput && inlineInput.text.toUpperCase() !== colorValue.toUpperCase()) {
            inlineInput.text = colorValue.toUpperCase();
        }
        if (typeof overlayInput !== "undefined" && overlayInput && overlayInput.text.toUpperCase() !== colorValue.toUpperCase()) {
            overlayInput.text = colorValue.toUpperCase();
        }
        if (_updating) return;
        var hsv = hexToHsv(colorValue);
        if (hsv !== null) {
            _updating = true;
            currentHue = hsv.h;
            currentSaturation = hsv.s;
            currentValue = hsv.v;
            _updating = false;
        }
    }

    Component.onCompleted: {
        var hsv = hexToHsv(colorValue);
        if (hsv !== null) {
            _updating = true;
            currentHue = hsv.h;
            currentSaturation = hsv.s;
            currentValue = hsv.v;
            _updating = false;
        }

        // Reparent click catcher
        var rootItem = root;
        while (rootItem.parent !== null) {
            rootItem = rootItem.parent;
        }
        outsideClickCatcher.parent = rootItem;
        outsideClickCatcher.anchors.fill = rootItem;

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
            hoistPopup();
        } else {
            restorePopup();
        }
    }

    // Window size change detector
    Connections {
        target: root.Window.window
        enabled: target !== null
        function onWidthChanged() { root.expanded = false; }
        function onHeightChanged() { root.expanded = false; }
    }

    function hoistPopup() {
        var rootItem = root;
        while (rootItem.parent !== null) {
            rootItem = rootItem.parent;
        }
        if (rootItem && rootItem !== root) {
            popupContainer.parent = rootItem;
            popupContainer.x = Qt.binding(function() {
                var pos = root.mapToItem(popupContainer.parent, 0, 0);
                return pos.x;
            });
            popupContainer.y = Qt.binding(function() {
                var pos = root.mapToItem(popupContainer.parent, 0, 0);
                return root.openUpward
                    ? (pos.y - popupContainer.height - Theme.spacing.xs)
                    : (pos.y + root.height + Theme.spacing.xs);
            });
            var nextZ = Theme.getNextMaxZ();
            popupContainer.z = nextZ;
            outsideClickCatcher.z = nextZ - 1;
        }
    }

    function restorePopup() {
        popupContainer.parent = root;
        popupContainer.x = 0;
        popupContainer.y = Qt.binding(function() {
            return root.openUpward
               ? -root.popupHeight - Theme.spacing.xs
               : root.height + Theme.spacing.xs;
        });
    }

    // Toggle popover visibility & positioning
    function togglePopover() {
        if (root.disabled) return;
        if (!root.expanded) {
            // Recalculate if we open upward or downward
            var windowItem = root;
            while (windowItem.parent !== null) windowItem = windowItem.parent;
            var posInWindow = root.mapToItem(windowItem, 0, 0);
            var spaceBelow = windowItem.height - (posInWindow.y + root.height);
            root.openUpward = spaceBelow < (root.popupHeight + Theme.spacing.md);
        }
        root.expanded = !root.expanded;
    }

    // ==========================================
    // Visual Tree - INLINE MODE
    // ==========================================
    Rectangle {
        id: inlinePanel
        anchors.fill: parent
        visible: root.inline
        color: Theme.colors.mantle
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        radius: Theme.geometry.radiusLg

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacing.md
            spacing: Theme.spacing.md

            // SV Square
            Rectangle {
                id: inlineSvSquare
                width: parent.width
                height: 160
                radius: Theme.geometry.radiusMd
                clip: true
                color: Qt.hsva(root.currentHue, 1, 1, 1)

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#FFFFFF" }
                        GradientStop { position: 1.0; color: "#00FFFFFF" }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "#00000000" }
                        GradientStop { position: 1.0; color: "#FF000000" }
                    }
                }

                Item {
                    id: inlineSvThumb
                    x: root.currentSaturation * parent.width - width / 2
                    y: (1.0 - root.currentValue) * parent.height - height / 2
                    width: 18
                    height: 18
                    z: 10

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.color: "#FFFFFF"
                        border.width: 2.5
                        Rectangle { anchors.fill: parent; anchors.margins: -1; radius: width / 2; color: "transparent"; border.color: "#22000000"; border.width: 1; z: -1 }
                        Rectangle { anchors.fill: parent; anchors.margins: 2; radius: width / 2; color: "transparent"; border.color: "#44000000"; border.width: 1; z: -1 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    function updatePosition(mouse) {
                        var s = Math.max(0.0, Math.min(1.0, mouse.x / inlineSvSquare.width));
                        var v = Math.max(0.0, Math.min(1.0, 1.0 - (mouse.y / inlineSvSquare.height)));
                        root.currentSaturation = s;
                        root.currentValue = v;
                        root.updateColorValue();
                    }
                    onPressed: updatePosition(mouse)
                    onPositionChanged: updatePosition(mouse)
                }
            }

            // Hue Slider
            Rectangle {
                id: inlineHueSlider
                width: parent.width
                height: 14
                radius: Theme.geometry.radiusPill

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.00; color: "#FF0000" }
                    GradientStop { position: 0.17; color: "#FFFF00" }
                    GradientStop { position: 0.33; color: "#00FF00" }
                    GradientStop { position: 0.50; color: "#00FFFF" }
                    GradientStop { position: 0.67; color: "#0000FF" }
                    GradientStop { position: 0.83; color: "#FF00FF" }
                    GradientStop { position: 1.00; color: "#FF0000" }
                }

                Rectangle {
                    x: root.currentHue * parent.width - width / 2
                    y: (parent.height - height) / 2
                    width: 10
                    height: parent.height + 6
                    radius: 4
                    color: "#FFFFFF"
                    border.color: "#11111b"
                    border.width: 1.5
                    Rectangle { anchors.fill: parent; anchors.margins: -1; radius: parent.radius + 1; color: "transparent"; border.color: "#33000000"; border.width: 1; z: -1 }
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    function updateHue(mouse) {
                        var h = Math.max(0.0, Math.min(1.0, mouse.x / inlineHueSlider.width));
                        root.currentHue = h;
                        root.updateColorValue();
                    }
                    onPressed: updateHue(mouse)
                    onPositionChanged: updateHue(mouse)
                }
            }

            // Hex input row
            Row {
                width: parent.width
                height: 36
                spacing: Theme.spacing.sm

                Rectangle {
                    width: 44
                    height: parent.height
                    radius: Theme.geometry.radiusSm
                    color: root.colorValue
                    border.color: Theme.colors.surface0
                    border.width: Theme.geometry.borderSm
                }

                TextField {
                    id: inlineInput
                    width: parent.width - 44 - parent.spacing
                    height: parent.height
                    size: "sm"
                    text: root.colorValue
                    placeholder: "#FFFFFF"

                    onTextChanged: {
                        var str = text.trim();
                        if (str.match(/^#[0-9A-F]{6}$/i) || str.match(/^#[0-9A-F]{3}$/i)) {
                            inlineInput.status = "normal";
                            var hsv = root.hexToHsv(str);
                            if (hsv !== null) {
                                root._updating = true;
                                root.currentHue = hsv.h;
                                root.currentSaturation = hsv.s;
                                root.currentValue = hsv.v;
                                root.colorValue = str.toUpperCase();
                                root.colorChanged(str.toUpperCase());
                                root._updating = false;
                            }
                        } else {
                            inlineInput.status = "error";
                        }
                    }
                }
            }
        }
    }

    // ==========================================
    // Visual Tree - OVERLAY MODE
    // ==========================================
    Rectangle {
        id: triggerBox
        anchors.fill: parent
        visible: !root.inline
        color: root.disabled ? Theme.colors.crust : Theme.colors.mantle
        radius: Theme.geometry.radiusMd
        border.color: root.disabled ? Theme.colors.surface0 : (root.expanded ? Theme.colors.primary : (triggerMouse.containsMouse ? Theme.colors.overlay0 : Theme.colors.surface1))
        border.width: root.expanded ? Theme.geometry.borderMd : Theme.geometry.borderSm

        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.sm
            anchors.rightMargin: Theme.spacing.sm
            spacing: Theme.spacing.sm

            // Color widget preview + Mouse click logic to open overlay
            Rectangle {
                width: 24
                height: 24
                radius: width / 2
                color: root.colorValue
                border.color: Theme.colors.surface2
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.togglePopover()
                }
            }

            // Direct Hex editing TextInput
            TextInput {
                id: overlayInput
                width: parent.width - 24 - 24 - Theme.spacing.sm * 2
                height: parent.height
                verticalAlignment: Text.AlignVCenter
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: root.disabled ? Theme.colors.overlay0 : Theme.colors.text
                selectionColor: Theme.colors.surface2
                selectedTextColor: Theme.colors.text
                enabled: !root.disabled
                text: root.colorValue.toUpperCase()
                antialiasing: true

                onTextChanged: {
                    var str = text.trim();
                    if (str.match(/^#[0-9A-F]{6}$/i) || str.match(/^#[0-9A-F]{3}$/i)) {
                        var hsv = root.hexToHsv(str);
                        if (hsv !== null) {
                            root._updating = true;
                            root.currentHue = hsv.h;
                            root.currentSaturation = hsv.s;
                            root.currentValue = hsv.v;
                            root.colorValue = str.toUpperCase();
                            root.colorChanged(str.toUpperCase());
                            root._updating = false;
                        }
                    }
                }
            }

            // Dropdown Chevron
            LucideIcon {
                name: "chevron-down"
                size: 16
                color: triggerMouse.containsMouse ? Theme.colors.primary : Theme.colors.subtext0
                anchors.verticalCenter: parent.verticalCenter
                rotation: root.expanded ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: 150 } }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.togglePopover()
                }
            }
        }

        MouseArea {
            id: triggerMouse
            anchors.fill: parent
            z: -1
            hoverEnabled: true
            onClicked: root.togglePopover()
        }
    }

    // Popover overlay panel
    Rectangle {
        id: popupContainer
        visible: !root.inline && root.expanded
        x: 0
        y: root.openUpward ? -root.popupHeight - Theme.spacing.xs : root.height + Theme.spacing.xs
        width: 280
        height: root.popupHeight
        color: Theme.colors.mantle
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        radius: Theme.geometry.radiusLg
        z: 99999

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacing.md
            spacing: Theme.spacing.md

            // SV Square
            Rectangle {
                id: overlaySvSquare
                width: parent.width
                height: 140
                radius: Theme.geometry.radiusMd
                clip: true
                color: Qt.hsva(root.currentHue, 1, 1, 1)

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#FFFFFF" }
                        GradientStop { position: 1.0; color: "#00FFFFFF" }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop { position: 0.0; color: "#00000000" }
                        GradientStop { position: 1.0; color: "#FF000000" }
                    }
                }

                Item {
                    x: root.currentSaturation * parent.width - width / 2
                    y: (1.0 - root.currentValue) * parent.height - height / 2
                    width: 18
                    height: 18
                    z: 10

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: "transparent"
                        border.color: "#FFFFFF"
                        border.width: 2.5
                        Rectangle { anchors.fill: parent; anchors.margins: -1; radius: width / 2; color: "transparent"; border.color: "#22000000"; border.width: 1; z: -1 }
                        Rectangle { anchors.fill: parent; anchors.margins: 2; radius: width / 2; color: "transparent"; border.color: "#44000000"; border.width: 1; z: -1 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    function updatePosition(mouse) {
                        var s = Math.max(0.0, Math.min(1.0, mouse.x / overlaySvSquare.width));
                        var v = Math.max(0.0, Math.min(1.0, 1.0 - (mouse.y / overlaySvSquare.height)));
                        root.currentSaturation = s;
                        root.currentValue = v;
                        root.updateColorValue();
                    }
                    onPressed: updatePosition(mouse)
                    onPositionChanged: updatePosition(mouse)
                }
            }

            // Hue Slider
            Rectangle {
                id: overlayHueSlider
                width: parent.width
                height: 14
                radius: Theme.geometry.radiusPill

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.00; color: "#FF0000" }
                    GradientStop { position: 0.17; color: "#FFFF00" }
                    GradientStop { position: 0.33; color: "#00FF00" }
                    GradientStop { position: 0.50; color: "#00FFFF" }
                    GradientStop { position: 0.67; color: "#0000FF" }
                    GradientStop { position: 0.83; color: "#FF00FF" }
                    GradientStop { position: 1.00; color: "#FF0000" }
                }

                Rectangle {
                    x: root.currentHue * parent.width - width / 2
                    y: (parent.height - height) / 2
                    width: 10
                    height: parent.height + 6
                    radius: 4
                    color: "#FFFFFF"
                    border.color: "#11111b"
                    border.width: 1.5
                    Rectangle { anchors.fill: parent; anchors.margins: -1; radius: parent.radius + 1; color: "transparent"; border.color: "#33000000"; border.width: 1; z: -1 }
                }

                MouseArea {
                    anchors.fill: parent
                    preventStealing: true
                    function updateHue(mouse) {
                        var h = Math.max(0.0, Math.min(1.0, mouse.x / overlayHueSlider.width));
                        root.currentHue = h;
                        root.updateColorValue();
                    }
                    onPressed: updateHue(mouse)
                    onPositionChanged: updateHue(mouse)
                }
            }
        }
    }

    // Click outside catcher
    MouseArea {
        id: outsideClickCatcher
        enabled: !root.inline && root.expanded
        z: 99998
        hoverEnabled: false
        propagateComposedEvents: true

        onPressed: {
            var clickPos = mapToItem(popupContainer, mouse.x, mouse.y);
            if (clickPos.x >= 0 && clickPos.x <= popupContainer.width &&
                clickPos.y >= 0 && clickPos.y <= popupContainer.height) {
                mouse.accepted = false;
            } else {
                mouse.accepted = true;
            }
        }

        onClicked: {
            var clickPos = mapToItem(popupContainer, mouse.x, mouse.y);
            if (clickPos.x >= 0 && clickPos.x <= popupContainer.width &&
                clickPos.y >= 0 && clickPos.y <= popupContainer.height) {
                mouse.accepted = false;
            } else {
                root.expanded = false;
            }
        }
    }
}
