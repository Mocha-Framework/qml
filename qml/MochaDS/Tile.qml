import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // Title label of the tile
    property string title: ""

    // Subtext description
    property string description: ""

    // Left icon name
    property string icon: ""

    // Right icon name (defaults to "chevron-right" if interactive is true, otherwise empty)
    property string rightIcon: ""

    // Variant style: "default" | "accent" | "tonal" | "outline" | "filled"
    property string variant: "default"

    // If true, the tile is visually highlighted as active
    property bool active: false

    // If true, enables hover states, pointing hand cursor, scaling animation and click signals
    property bool interactive: true

    // Drag support (for dashboard reordering)
    property bool draggable: false
    property string dragKey: "mochads-tile"

    // Visual customizations (Overrides)
    property string backgroundColor: ""
    property real customRadius: -1
    property color customColor: "transparent"
    property color customAccentColor: "transparent"
    property color customTextColor: "transparent"

    // Default property for custom content in the center area
    default property alias customContent: customContentContainer.data

    // Custom slot for right side content (replaces default right icon)
    property list<Item> rightContent

    // ==========================================
    // Signals
    // ==========================================
    signal clicked()

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================

    readonly property real finalRadius: customRadius >= 0 ? customRadius : Theme.geometry.radiusSm

    readonly property bool hasCustomColor: customColor.toString() !== "#00000000" && customColor.toString() !== "transparent"
    readonly property bool hasCustomAccentColor: customAccentColor.toString() !== "#00000000" && customAccentColor.toString() !== "transparent"
    readonly property bool hasCustomTextColor: customTextColor.toString() !== "#00000000" && customTextColor.toString() !== "transparent"

    readonly property bool isColored: {
        if (variant !== "filled") return false
        var coloredList = ["mauve", "lavender", "blue", "sapphire", "sky", "teal", "green", "yellow", "peach", "maroon", "red", "pink", "flamingo", "rosewater"]
        return coloredList.indexOf(backgroundColor) !== -1 || hasCustomColor
    }

    // Right icon logic fallback
    readonly property string finalRightIcon: {
        if (rightIcon !== "") return rightIcon
        return interactive ? "chevron-right" : ""
    }

    readonly property color finalAccentColor: {
        if (hasCustomAccentColor) return customAccentColor
        if (isColored) return finalTextColor
        return Theme.colors.primary // Mauve
    }

    readonly property color finalTextColor: {
        if (hasCustomTextColor) return customTextColor
        if (isColored) return Theme.colors.crust
        return Theme.colors.text
    }

    // Background color based on variant and mouse interaction state
    readonly property color finalBackgroundColor: {
        if (variant === "filled") {
            if (hasCustomColor) return customColor
            var themeColor = Theme.colors[backgroundColor]
            if (themeColor !== undefined) return themeColor
            return Theme.colors.primary // default to mauve
        }

        if (variant === "tonal") {
            if (interactive && mouseArea.pressed) return Theme.colors.surface2
            if (interactive && mouseArea.containsMouse) return Theme.colors.surface1
            return Theme.colors.surface0
        }
        if (variant === "outline") {
            if (interactive && mouseArea.pressed) return Qt.rgba(finalAccentColor.r, finalAccentColor.g, finalAccentColor.b, 0.20)
            if (interactive && mouseArea.containsMouse) return Qt.rgba(finalAccentColor.r, finalAccentColor.g, finalAccentColor.b, 0.10)
            return "transparent"
        }
        // default, accent
        if (interactive && mouseArea.pressed) return Theme.colors.surface1
        if (interactive && mouseArea.containsMouse) return Theme.colors.surface0
        return Theme.colors.base
    }

    // Border properties
    readonly property color finalBorderColor: {
        if (variant === "outline") return hasCustomAccentColor ? customAccentColor : Theme.colors.surface1
        return "transparent"
    }

    readonly property real finalBorderWidth: {
        if (variant === "outline") return Theme.geometry.borderSm
        return 0
    }

    // Size Settings
    implicitWidth: 320
    implicitHeight: Math.max(56, contentRow.implicitHeight + Theme.spacing.md * 2)
    width: implicitWidth
    height: implicitHeight

    Drag.keys: root.draggable ? [root.dragKey] : []
    Drag.source: root
    Drag.hotSpot.x: root.width / 2
    Drag.hotSpot.y: root.height / 2
    Drag.active: root.draggable && dragHandler.active

    // Cozy scale and hover micro-animations
    scale: dragHandler.active ? 1.03 : (interactive ? (mouseArea.pressed ? 0.98 : (mouseArea.containsMouse ? 1.01 : 1.0)) : 1.0)
    opacity: dragHandler.active ? 0.9 : 1.0
    z: dragHandler.active ? 100 : 0

    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutBack }
    }
    Behavior on opacity {
        NumberAnimation { duration: 120 }
    }

    DragHandler {
        id: dragHandler
        enabled: root.draggable
        dragThreshold: 10
        acceptedButtons: Qt.LeftButton

        onActiveChanged: {
            if (active) {
                Drag.hotSpot.x = root.width / 2
                Drag.hotSpot.y = root.height / 2
            } else {
                Drag.drop()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -8
        radius: root.finalRadius + 8
        color: "transparent"
        visible: dragHandler.active
        z: -1

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.2)
        }
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Background panel
    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: root.finalBackgroundColor
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: root.finalBorderWidth
        clip: true

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // Left Accent indicator line (variant: accent or active)
        Rectangle {
            id: accentLine
            width: 4
            height: parent.height
            color: root.finalAccentColor
            visible: root.variant === "accent" || root.active
            anchors.left: parent.left
            anchors.top: parent.top
        }

        // Content Row
        Row {
            id: contentRow
            x: (root.variant === "accent" ? 4 : 0) + Theme.spacing.md
            y: (parent.height - height) / 2
            width: parent.width - x - Theme.spacing.md
            spacing: Theme.spacing.md

            // 1. Left Icon Container
            Item {
                id: leftIconContainer
                width: 24
                height: 24
                visible: root.icon !== ""
                anchors.verticalCenter: parent.verticalCenter

                LucideIcon {
                    name: root.icon
                    size: 24
                    color: root.finalAccentColor
                    anchors.centerIn: parent
                }
            }

            // 2. Center Text Column (takes all remaining space)
            Column {
                id: textColumn
                width: parent.width - (leftIconContainer.visible ? leftIconContainer.width + parent.spacing : 0)
                                   - (rightIconContainer.visible ? rightIconContainer.width + parent.spacing : 0)
                spacing: Theme.spacing.xs
                anchors.verticalCenter: parent.verticalCenter
                visible: customContentContainer.children.length === 0

                Text {
                    text: root.title
                    font.family: Theme.typography.familyBold
                    font.pixelSize: Theme.typography.sizeMd
                    color: root.finalTextColor
                    visible: root.title !== ""
                    elide: Text.ElideRight
                    width: parent.width
                    antialiasing: true
                }
                Text {
                    text: root.description
                    font.family: Theme.typography.family
                    font.pixelSize: Theme.typography.sizeSm
                    color: root.isColored ? Qt.rgba(root.finalTextColor.r, root.finalTextColor.g, root.finalTextColor.b, 0.7) : Theme.colors.subtext0
                    visible: root.description !== ""
                    elide: Text.ElideRight
                    width: parent.width
                    antialiasing: true
                }
            }

            // 3. Custom Content Slot
            Item {
                id: customContentContainer
                width: parent.width - (leftIconContainer.visible ? leftIconContainer.width + parent.spacing : 0)
                                   - (rightIconContainer.visible ? rightIconContainer.width + parent.spacing : 0)
                height: childrenRect.height
                anchors.verticalCenter: parent.verticalCenter
                visible: children.length > 0
            }

            // 4. Right Icon Container (Supports custom elements or fallback chevron)
            Item {
                id: rightIconContainer
                width: customRightContentContainer.visible ? customRightContentContainer.childrenRect.width : (root.finalRightIcon !== "" ? 20 : 0)
                height: customRightContentContainer.visible ? customRightContentContainer.childrenRect.height : 20
                visible: root.finalRightIcon !== "" || customRightContentContainer.visible
                anchors.verticalCenter: parent.verticalCenter

                // Custom Right Content Slot
                Item {
                    id: customRightContentContainer
                    width: childrenRect.width
                    height: childrenRect.height
                    anchors.centerIn: parent
                    visible: root.rightContent && root.rightContent.length > 0

                    Component.onCompleted: {
                        for (var i = 0; i < root.rightContent.length; i++) {
                            root.rightContent[i].parent = customRightContentContainer;
                        }
                    }
                }

                // Default chevron icon
                LucideIcon {
                    name: root.finalRightIcon
                    size: 20
                    color: root.isColored ? root.finalTextColor : Theme.colors.overlay1
                    visible: root.finalRightIcon !== "" && !customRightContentContainer.visible
                    anchors.centerIn: parent
                }
            }
        }
    }

    // Mouse Interaction Area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.interactive || root.draggable
        cursorShape: dragHandler.active ? Qt.ClosedHandCursor : (root.draggable && containsMouse ? Qt.OpenHandCursor : Qt.PointingHandCursor)

        onClicked: root.clicked()
    }
}
