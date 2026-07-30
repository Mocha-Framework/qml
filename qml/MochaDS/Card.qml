import QtQuick 2.15

Item {
    // ==========================================
    // Public API (Properties)
    // ==========================================
    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    // ==========================================
    // Micro-animation (clickable mode)
    // ==========================================
    // ==========================================
    // Visual Tree
    // ==========================================

    id: root

    // Title of the card header (used in default header)
    property string title: ""
    // Subtitle of the card header (used in default header)
    property string subtitle: ""
    // Icon name for the card header (used in default header)
    property string icon: ""
    // Variant style: "default" | "accent" | "tonal" | "outline" | "filled"
    property string variant: "default"
    // Accent line position: "left" | "top" | "none"
    property string accentPosition: "left"
    // When true, the card responds to hover/press with micro-animations
    property bool clickable: false
    // Spacing padding inside the card body
    property real padding: Theme.spacing.lg
    // Visual customizations (Overrides)
    property string backgroundColor: ""
    property real customRadius: -1
    property color customColor: "transparent"
    property color customAccentColor: "transparent"
    property color customTextColor: "transparent"
    // Separator visibility switches
    property bool headerSeparator: true
    property bool footerSeparator: true
    // Slots
    property list<Item> header
    property list<Item> footer
    // Default property to catch children inside the body
    default property alias content: bodyContainer.data
    readonly property real finalRadius: customRadius >= 0 ? customRadius : Theme.geometry.radiusMd
    readonly property bool hasCustomColor: customColor.toString() !== "#00000000" && customColor.toString() !== "transparent"
    readonly property bool hasCustomAccentColor: customAccentColor.toString() !== "#00000000" && customAccentColor.toString() !== "transparent"
    readonly property bool hasCustomTextColor: customTextColor.toString() !== "#00000000" && customTextColor.toString() !== "transparent"
    readonly property bool isColored: {
        if (variant !== "filled")
            return false;

        var coloredList = ["mauve", "lavender", "blue", "sapphire", "sky", "teal", "green", "yellow", "peach", "maroon", "red", "pink", "flamingo", "rosewater"];
        return coloredList.indexOf(backgroundColor) !== -1 || hasCustomColor;
    }
    readonly property color finalBackgroundColor: {
        if (variant === "filled") {
            if (hasCustomColor)
                return customColor;

            var themeColor = Theme.colors[backgroundColor];
            if (themeColor !== undefined)
                return themeColor;

            return Theme.colors.primary; // fallback mauve
        }
        if (variant === "tonal")
            return Theme.colors.surface0;

        if (variant === "outline")
            return "transparent";

        return Theme.colors.base; // default, accent
    }
    readonly property color finalBorderColor: {
        if (variant === "outline")
            return hasCustomAccentColor ? customAccentColor : Theme.colors.surface1;

        return "transparent";
    }
    readonly property real finalBorderWidth: {
        if (variant === "outline")
            return Theme.geometry.borderSm;

        return 0;
    }
    readonly property color finalAccentColor: {
        if (hasCustomAccentColor)
            return customAccentColor;

        if (isColored)
            return finalTextColor;

        return Theme.colors.primary; // Mauve
    }
    readonly property color finalTextColor: {
        if (hasCustomTextColor)
            return customTextColor;

        if (isColored)
            return Theme.colors.crust;

        return Theme.colors.text;
    }
    readonly property real naturalHeight: headerWrapper.height + (headerWrapper.visible && root.headerSeparator ? 1 : 0) + bodyWrapper.height + (footerWrapper.visible && root.footerSeparator ? 1 : 0) + footerWrapper.height + mainLayoutColumn.anchors.topMargin

    signal clicked()

    // Dynamic Sizing
    implicitWidth: 350
    implicitHeight: naturalHeight
    width: implicitWidth
    height: implicitHeight
    scale: root.clickable ? (cardMouse.pressed ? 0.985 : (cardMouse.containsMouse ? 1.015 : 1)) : 1

    // Invisible hover overlay (brightens background on hover)
    Rectangle {
        anchors.fill: parent
        radius: root.finalRadius
        color: "white"
        opacity: root.clickable && cardMouse.containsMouse ? 0.04 : 0
        z: 1

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }

        }

    }

    // Click handler (only active when clickable)
    MouseArea {
        id: cardMouse

        anchors.fill: parent
        hoverEnabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        enabled: root.clickable
        z: 2
        onClicked: root.clicked()
        // Let child mouse events pass through (e.g. buttons inside the card)
        propagateComposedEvents: true
        onPressed: function(mouse) {
            mouse.accepted = false;
        }
    }

    // Background Rect
    Rectangle {
        id: bgRect

        anchors.fill: parent
        color: root.finalBackgroundColor
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: root.finalBorderWidth
        clip: true // Crucial to clip custom/accent lines at rounded corners

        // Accent indicator line (visible in accent variant)
        Rectangle {
            id: accentIndicator

            color: root.finalAccentColor
            visible: root.variant === "accent" && root.accentPosition !== "none"
            // Geometry based on position
            width: root.accentPosition === "left" ? 4 : parent.width
            height: root.accentPosition === "top" ? 4 : parent.height
            anchors.left: parent.left
            anchors.top: parent.top
        }

        // Layout Stacking
        Column {
            id: mainLayoutColumn

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            // Shift layout margins so contents do not overlap with top/left accent lines
            anchors.leftMargin: (root.variant === "accent" && root.accentPosition === "left") ? 4 : 0
            anchors.topMargin: (root.variant === "accent" && root.accentPosition === "top") ? 4 : 0

            // 1. Header Block
            Item {
                id: headerWrapper

                width: parent.width
                height: root.header.length > 0 ? customHeaderContainer.childrenRect.height : (root.title !== "" ? (defaultHeaderRow.implicitHeight + Theme.spacing.md * 2) : 0)
                visible: root.header.length > 0 || root.title !== ""

                // Custom Header Slot
                Item {
                    id: customHeaderContainer

                    width: parent.width
                    height: childrenRect.height
                    visible: root.header.length > 0
                    Component.onCompleted: {
                        for (var i = 0; i < root.header.length; i++) {
                            root.header[i].parent = customHeaderContainer;
                        }
                    }
                }

                // Default Header Layout
                Item {
                    id: defaultHeaderContainer

                    anchors.fill: parent
                    visible: root.header.length === 0

                    Row {
                        id: defaultHeaderRow

                        spacing: Theme.spacing.md
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacing.lg
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing.lg

                        LucideIcon {
                            name: root.icon
                            size: 24
                            color: root.finalAccentColor
                            visible: root.icon !== ""
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Column {
                            spacing: Theme.spacing.xs
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                text: root.title
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeLg
                                color: root.finalTextColor
                                visible: root.title !== ""
                                antialiasing: true
                            }

                            Text {
                                text: root.subtitle
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeSm
                                color: root.isColored ? Qt.rgba(root.finalTextColor.r, root.finalTextColor.g, root.finalTextColor.b, 0.7) : Theme.colors.subtext0
                                visible: root.subtitle !== ""
                                antialiasing: true
                            }

                        }

                    }

                }

            }

            // Header Separator Line
            Rectangle {
                width: parent.width
                height: 1
                color: root.isColored ? Qt.rgba(root.finalTextColor.r, root.finalTextColor.g, root.finalTextColor.b, 0.15) : Theme.colors.surface0
                visible: headerWrapper.visible && root.headerSeparator
            }

            // 2. Body Block
            Item {
                id: bodyWrapper

                width: parent.width
                height: bodyContainer.height + root.padding * 2

                Item {
                    id: bodyContainer

                    x: root.padding
                    y: root.padding
                    width: parent.width - root.padding * 2
                    height: childrenRect.height
                }

            }

            // Pushes footer to the bottom of the card if card height is larger than content
            Item {
                id: fillSpacer

                width: parent.width
                height: Math.max(0, root.height - root.naturalHeight)
            }

            // Footer Separator Line
            Rectangle {
                id: footerSeparator

                width: parent.width
                height: 1
                color: root.isColored ? Qt.rgba(root.finalTextColor.r, root.finalTextColor.g, root.finalTextColor.b, 0.15) : Theme.colors.surface0
                visible: footerWrapper.visible && root.footerSeparator
            }

            // 3. Footer Block
            Item {
                id: footerWrapper

                width: parent.width
                height: root.footer.length > 0 ? (customFooterContainer.childrenRect.height + Theme.spacing.md * 2) : 0
                visible: root.footer.length > 0

                Item {
                    id: customFooterContainer

                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.lg
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.lg
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.md
                    height: childrenRect.height
                    Component.onCompleted: {
                        for (var i = 0; i < root.footer.length; i++) {
                            root.footer[i].parent = customFooterContainer;
                        }
                    }
                }

            }

        }

    }

    Behavior on scale {
        NumberAnimation {
            duration: 130
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }

    }

}
