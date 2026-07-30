import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // Header title text
    property string title: ""

    // Optional Lucide icon to display on the left of the header
    property string icon: ""

    // Expansion state of the accordion
    property bool expanded: false

    // Variant style: "default" | "outline" | "tonal" | "split" | "filled"
    property string variant: "default"

    // If true, clicking the header toggles expansion
    property bool interactive: true

    // Accent Color: "rosewater" | "flamingo" | "pink" | "mauve" | "red" | "maroon" | "peach" | "yellow" | "green" | "teal" | "sky" | "sapphire" | "blue" | "lavender"
    property string accentColor: "mauve"

    // Visual customizations (Overrides)
    property string backgroundColor: ""
    property real customRadius: -1
    property color customColor: "transparent"
    property color customAccentColor: "transparent"
    property color customTextColor: "transparent"

    // Default content slot for children elements
    default property alias content: contentContainer.data

    // ==========================================
    // Signals
    // ==========================================
    signal toggled(bool isExpanded)

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property real finalRadius: customRadius >= 0 ? customRadius : Theme.geometry.radiusMd

    readonly property bool hasCustomColor: customColor.toString() !== "#00000000" && customColor.toString() !== "transparent"
    readonly property bool hasCustomAccentColor: customAccentColor.toString() !== "#00000000" && customAccentColor.toString() !== "transparent"
    readonly property bool hasCustomTextColor: customTextColor.toString() !== "#00000000" && customTextColor.toString() !== "transparent"

    readonly property bool isColored: {
        if (variant !== "filled") return false
        var coloredList = ["mauve", "lavender", "blue", "sapphire", "sky", "teal", "green", "yellow", "peach", "maroon", "red", "pink", "flamingo", "rosewater"]
        return coloredList.indexOf(backgroundColor) !== -1 || hasCustomColor
    }

    readonly property color finalBackgroundColor: {
        if (variant === "filled") {
            if (hasCustomColor) return customColor
            var themeColor = Theme.colors[backgroundColor]
            if (themeColor !== undefined) return themeColor
            return Theme.colors.primary // default mauve
        }
        if (variant === "tonal") return Theme.colors.surface0
        if (variant === "outline") return "transparent"
        return Theme.colors.base // default
    }

    readonly property color finalBorderColor: {
        if (variant === "outline") return hasCustomAccentColor ? customAccentColor : Theme.colors.surface1
        return "transparent"
    }

    readonly property real finalBorderWidth: {
        if (variant === "outline") return Theme.geometry.borderSm
        return 0
    }

    readonly property color finalAccentColor: {
        if (hasCustomAccentColor) return customAccentColor
        if (isColored) return finalTextColor
        var stdColor = Theme.colors[accentColor]
        if (stdColor !== undefined) return stdColor
        return Theme.colors.primary // Mauve
    }

    readonly property color finalTextColor: {
        if (hasCustomTextColor) return customTextColor
        if (isColored) return Theme.colors.crust
        return Theme.colors.text
    }
    readonly property real triggerScale: {
        if (!interactive) return 1.0
        if (headerMouseArea.pressed) return 0.988
        if (headerMouseArea.containsMouse) return 1.01
        return 1.0
    }

    // Dynamic Sizing
    implicitWidth: 320
    implicitHeight: headerWrapper.height + contentClipContainer.height
    width: implicitWidth
    height: implicitHeight
    activeFocusOnTab: interactive

    Keys.onReturnPressed: {
        if (!root.interactive) return;
        root.expanded = !root.expanded;
        root.toggled(root.expanded);
    }
    Keys.onSpacePressed: {
        if (!root.interactive) return;
        root.expanded = !root.expanded;
        root.toggled(root.expanded);
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Background Container
    Rectangle {
        id: bgPanel
        anchors.fill: parent
        color: root.finalBackgroundColor
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: root.finalBorderWidth
        clip: true

        Behavior on color { ColorAnimation { duration: 150 } }

        // Stack header, separator, and expandable content vertical layout
        Column {
            width: parent.width

            // 1. Header Bar
            Item {
                id: headerWrapper
                width: parent.width
                height: 48
                scale: root.triggerScale
                transformOrigin: Item.Center

                Behavior on scale {
                    NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
                }

                Rectangle {
                    anchors.fill: parent
                    color: root.isColored
                           ? Qt.rgba(root.finalTextColor.r, root.finalTextColor.g, root.finalTextColor.b, 0.08)
                           : Theme.colors.surface0
                    opacity: headerMouseArea.containsMouse ? 1.0 : 0.0
                    // Match parent radius so hover highlight respects rounded corners.
                    // Without this, the hover rect renders as a sharp rectangle and
                    // overflows the bgPanel's rounded corners visibly.
                    radius: root.finalRadius

                    Behavior on opacity { NumberAnimation { duration: 120 } }
                }

                // Header content row
                Row {
                    id: headerRow
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.lg
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.lg
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.md

                    // Optional Left Icon
                    LucideIcon {
                        name: root.icon
                        size: 20
                        color: root.finalAccentColor
                        visible: root.icon !== ""
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    // Title Text
                    Text {
                        text: root.title
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: root.finalTextColor
                        width: parent.width - (root.icon !== "" ? 36 : 0) - 24
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        antialiasing: true
                    }
                }

                // Interactive Chevron Icon on the right
                LucideIcon {
                    id: chevronIcon
                    name: "chevron-down"
                    size: 18
                    color: root.isColored ? root.finalTextColor : Theme.colors.overlay1
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.lg
                    anchors.verticalCenter: parent.verticalCenter

                    // Smooth chevron rotation
                    rotation: root.expanded ? 180 : 0
                    Behavior on rotation {
                        NumberAnimation { duration: 200; easing.type: Easing.OutQuad }
                    }
                }

                // Header click area to toggle expansion
                MouseArea {
                    id: headerMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: root.interactive
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.expanded = !root.expanded;
                        root.toggled(root.expanded);
                    }
                }
            }

            // 2. Separator line (visible only when expanded)
            Rectangle {
                id: separatorLine
                width: parent.width
                height: 1
                color: root.isColored ? Qt.rgba(root.finalTextColor.r, root.finalTextColor.g, root.finalTextColor.b, 0.15) : Theme.colors.surface1
                visible: root.expanded && contentClipContainer.height > 0
            }

            // 3. Expandable content clip container (prevents binding loops)
            Rectangle {
                id: contentClipContainer
                width: parent.width
                // When expanded, height corresponds to child height plus inner margins
                height: root.expanded ? (contentContainer.childrenRect.height + Theme.spacing.lg * 2) : 0
                clip: true
                color: "transparent"
                opacity: root.expanded ? 1.0 : 0.0

                // Smooth expansion height animation
                Behavior on height {
                    NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                }

                // Inner content layout
                Item {
                    id: contentContainer
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.lg
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.lg
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    height: childrenRect.height
                }
            }
        }
    }

    FocusRing {
        target: root
        active: root.activeFocus && root.interactive
    }
}
