import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property color selectedColor: Theme.colors.mauve
    property string placeholder: "Selecione uma cor..."
    property bool disabled: false
    property string size: "md"

    // Popover expanded state
    property bool expanded: false

    // Smart flip: true when popup should open upward
    property bool openUpward: false

    // Fixed popup height (used for flip calculation)
    readonly property int popupHeight: 200

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

    z: expanded ? 100 : 0

    implicitWidth: 280
    implicitHeight: currentHeight
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Preset color palette (Catppuccin Mocha Accents)
    readonly property var colorPresets: [
        { name: "Lavender", value: Theme.colors.lavender },
        { name: "Blue", value: Theme.colors.blue },
        { name: "Sapphire", value: Theme.colors.sapphire },
        { name: "Sky", value: Theme.colors.sky },
        { name: "Teal", value: Theme.colors.teal },
        { name: "Green", value: Theme.colors.green },
        { name: "Yellow", value: Theme.colors.yellow },
        { name: "Peach", value: Theme.colors.peach },
        { name: "Maroon", value: Theme.colors.maroon },
        { name: "Red", value: Theme.colors.red },
        { name: "Mauve", value: Theme.colors.mauve },
        { name: "Pink", value: Theme.colors.pink },
        { name: "Flamingo", value: Theme.colors.flamingo },
        { name: "Rosewater", value: Theme.colors.rosewater }
    ]

    // Outer box panel
    Rectangle {
        id: triggerBox
        anchors.fill: parent
        color: disabled ? Theme.colors.crust : Theme.colors.mantle
        radius: root.size === "sm" ? Theme.geometry.radiusSm : (root.size === "lg" ? Theme.geometry.radiusLg : Theme.geometry.radiusMd)
        border.color: disabled ? Theme.colors.surface0 : (expanded ? Theme.colors.primary : (mouseArea.containsMouse ? Theme.colors.overlay0 : Theme.colors.surface1))
        border.width: expanded ? Theme.geometry.borderMd : Theme.geometry.borderSm

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

        // Color Preview Circle
        Rectangle {
            width: root.currentHeight * 0.45
            height: width
            radius: width / 2
            color: root.selectedColor
            border.color: Theme.colors.surface2
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.selectedColor.toString().toUpperCase()
            font.family: Theme.typography.family
            font.pixelSize: root.currentFontSize
            color: root.disabled ? Theme.colors.overlay0 : Theme.colors.text
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 32 - parent.spacing * 2
            elide: Text.ElideRight
            antialiasing: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        onClicked: {
            if (!expanded) {
                // Initialize input value to hex text
                hexInputField.text = root.selectedColor.toString().toUpperCase();
                hexInputField.status = "normal";

                // Smart flip: detect if there is room below
                var windowItem = root;
                while (windowItem.parent !== null) windowItem = windowItem.parent;
                var posInWindow = root.mapToItem(windowItem, 0, 0);
                var spaceBelow = windowItem.height - (posInWindow.y + root.height);
                root.openUpward = spaceBelow < (root.popupHeight + Theme.spacing.md);
            }
            root.expanded = !root.expanded;
        }
    }

    // Popover Container
    Rectangle {
        id: popupContainer
        x: 0
        // Flip: open above trigger when there's not enough space below
        y: root.openUpward
           ? -(popupContainer.height + Theme.spacing.xs)
           : (root.height + Theme.spacing.xs)
        width: 260
        height: root.expanded ? root.popupHeight : 0
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

        Column {
            width: parent.width - Theme.spacing.md * 2
            anchors.centerIn: parent
            spacing: Theme.spacing.md

            // Preset Swatches Header
            Text {
                text: "Paleta Cozy"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.overlay1
            }

            // Grid of Presets
            Grid {
                columns: 7
                spacing: Theme.spacing.sm
                width: parent.width

                Repeater {
                    model: root.colorPresets
                    delegate: Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: modelData.value
                        border.color: (root.selectedColor === modelData.value) ? Theme.colors.text : Theme.colors.surface1
                        border.width: (root.selectedColor === modelData.value) ? 2 : 1

                        scale: swatchMouse.containsMouse ? 1.15 : 1.0
                        Behavior on scale { NumberAnimation { duration: 100 } }

                        MouseArea {
                            id: swatchMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.selectedColor = modelData.value;
                                hexInputField.text = modelData.value.toString().toUpperCase();
                                hexInputField.status = "normal";
                                root.expanded = false; // close on selection
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // Custom HEX input row using project TextField
            Row {
                width: parent.width
                spacing: Theme.spacing.sm
                z: 100

                Text {
                    text: "HEX:"
                    font.family: Theme.typography.familyMedium
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.subtext1
                    anchors.verticalCenter: parent.verticalCenter
                }

                TextField {
                    id: hexInputField
                    width: parent.width - 40
                    anchors.verticalCenter: parent.verticalCenter
                    size: "sm"
                    text: root.selectedColor.toString().toUpperCase()
                    placeholder: "#FFFFFF"
                    
                    onTextChanged: {
                        var str = text.trim();
                        // Validate hex input regex
                        if (str.match(/^#[0-9A-F]{6}$/i) || str.match(/^#[0-9A-F]{3}$/i)) {
                            root.selectedColor = str;
                            hexInputField.status = "success";
                        } else {
                            hexInputField.status = "error";
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

    Component.onCompleted: {
        // Find top-level root element and reparent click catcher to it
        var rootItem = root;
        while (rootItem.parent !== null) {
            rootItem = rootItem.parent;
        }
        outsideClickCatcher.parent = rootItem;
        outsideClickCatcher.anchors.fill = rootItem;
    }
}
