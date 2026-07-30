import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property string text: ""
    
    // Variant style: "filled" | "tonal" | "outline" | "flat"
    property string variant: "filled"

    // Theme Accent Color: "rosewater" | "flamingo" | "pink" | "mauve" | "red" | "maroon" | "peach" | "yellow" | "green" | "teal" | "sky" | "sapphire" | "blue" | "lavender"
    property string color: "mauve"

    // Size of the badge: "sm" | "md" | "lg"
    property string size: "md"

    // Shape style: "square" | "rounded" | "pill"
    property string shape: "pill"
    
    // Optional Lucide icon to display on the left of the badge label
    property string icon: ""

    // If true, displays a close/dismiss button on the right
    property bool isDismissible: false

    // Backward compatibility dot indicator
    property bool showDot: false

    // Style overrides (Overrides)
    property real customRadius: -1
    property color customColor: "transparent"
    property color customTextColor: "transparent"
    property color customBgColor: "transparent"

    // ==========================================
    // Signals
    // ==========================================
    signal dismissed()

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property bool hasCustomColor: customColor !== undefined && customColor !== null && customColor.toString() !== "#00000000" && customColor.toString() !== "transparent"
    readonly property bool hasCustomTextColor: customTextColor !== undefined && customTextColor !== null && customTextColor.toString() !== "#00000000" && customTextColor.toString() !== "transparent"
    readonly property bool hasCustomBgColor: customBgColor !== undefined && customBgColor !== null && customBgColor.toString() !== "#00000000" && customBgColor.toString() !== "transparent"

    // Resolve color (e.g. mauve, green, red, etc.)
    readonly property string actualColorName: {
        if (variant === "success") return "green"
        if (variant === "warning") return "yellow"
        if (variant === "danger") return "red"
        if (variant === "info") return "sky"
        if (variant === "secondary") return "subtext0"
        return color
    }

    readonly property color resolvedColor: {
        if (hasCustomColor) return customColor;
        var stdColor = Theme.colors[actualColorName];
        if (stdColor !== undefined) return stdColor;
        return Theme.colors.primary; // primary (mauve)
    }

    readonly property color baseColor: resolvedColor

    // Resolve variant compatibility (if variant was success/danger/etc. treat as tonal/flat)
    readonly property string actualVariant: {
        if (variant === "success" || variant === "warning" || variant === "danger" || variant === "info" || variant === "secondary" || variant === "primary") {
            return "tonal" // old style was translucent/tonal
        }
        return variant // filled | tonal | outline | flat
    }

    // Background Panel Properties
    readonly property color finalBgColor: {
        if (hasCustomBgColor) return customBgColor;
        if (actualVariant === "filled") return resolvedColor;
        if (actualVariant === "tonal") return Qt.rgba(resolvedColor.r, resolvedColor.g, resolvedColor.b, 0.12);
        return "transparent";
    }

    readonly property color finalBorderColor: {
        if (actualVariant === "outline") return resolvedColor;
        if (actualVariant === "tonal") return Qt.rgba(resolvedColor.r, resolvedColor.g, resolvedColor.b, 0.2);
        return "transparent";
    }

    readonly property real finalBorderWidth: {
        if (actualVariant === "outline" || actualVariant === "tonal") return Theme.geometry.borderSm;
        return 0;
    }

    readonly property color finalTextColor: {
        if (hasCustomTextColor) return customTextColor;
        if (actualVariant === "filled") return Theme.colors.crust;
        return resolvedColor;
    }

    // Radius calculations based on shape
    readonly property real finalRadius: {
        if (customRadius >= 0) return customRadius;
        if (shape === "square") return 0;
        if (shape === "rounded") return Theme.geometry.radiusSm;
        return Theme.geometry.radiusPill;
    }

    // Size-based variables
    readonly property real currentHeight: {
        if (size === "sm") return 20;
        if (size === "lg") return 32;
        return 24; // md
    }

    readonly property real currentPadding: {
        if (size === "sm") return Theme.spacing.sm; // 8px
        if (size === "lg") return Theme.spacing.lg; // 16px
        return Theme.spacing.md; // 12px
    }

    readonly property real currentFontSize: {
        if (size === "sm") return Theme.typography.sizeXs;
        if (size === "lg") return Theme.typography.sizeMd;
        return Theme.typography.sizeSm - 1; // 11px cozy text size
    }

    readonly property real currentIconSize: {
        if (size === "sm") return 10;
        if (size === "lg") return 14;
        return 12;
    }

    // Layout Dimensions
    implicitWidth: layoutRow.implicitWidth + currentPadding * 2
    implicitHeight: currentHeight
    width: implicitWidth
    height: implicitHeight

    HoverHandler {
        id: hoverHandler
    }

    scale: hoverHandler.hovered ? 1.04 : 1.0
    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    // ==========================================
    // Visual Tree
    // ==========================================
    
    // Badge track
    Rectangle {
        anchors.fill: parent
        color: root.finalBgColor
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: root.finalBorderWidth

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // Inner contents
    Row {
        id: layoutRow
        anchors.centerIn: parent
        spacing: 6

        // Indicator dot on left (backward compatibility)
        Rectangle {
            width: 6
            height: 6
            radius: 3
            color: root.resolvedColor
            anchors.verticalCenter: parent.verticalCenter
            visible: root.showDot

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // Left Icon
        LucideIcon {
            name: root.icon
            size: root.currentIconSize
            color: root.finalTextColor
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        // Label text
        Text {
            text: root.text
            font.family: Theme.typography.familyMedium
            font.pixelSize: root.currentFontSize
            color: root.finalTextColor
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // Close / Dismiss button on right
        Item {
            width: root.isDismissible ? root.currentIconSize + 4 : 0
            height: root.currentIconSize
            visible: root.isDismissible
            anchors.verticalCenter: parent.verticalCenter

            LucideIcon {
                name: "x"
                size: root.currentIconSize
                color: root.finalTextColor
                anchors.centerIn: parent
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.dismissed();
                }
            }
        }
    }
}
