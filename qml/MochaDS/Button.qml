import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // The text label of the button
    property string text: ""

    // Variant style: "primary" | "secondary" | "danger" | "success" | "warning" | "info" | "outline" | "tonal" | "ghost" | "filled"
    property string variant: "primary"

    // Theme Accent Color: "rosewater" | "flamingo" | "pink" | "mauve" | "red" | "maroon" | "peach" | "yellow" | "green" | "teal" | "sky" | "sapphire" | "blue" | "lavender"
    property string color: "mauve"

    // Size of the button: "sm" | "md" | "lg"
    property string size: "md"

    // Shape style: "square" | "rounded" | "pill"
    property string shape: "rounded"

    // If true, disables mouse interaction and reduces opacity
    property bool disabled: false

    // If true, displays a spinning loader and disables interaction
    property bool isLoading: false
    property alias loading: root.isLoading

    // Icon configuration (mirrors React properties, falling back to older 'icon' and 'iconRight')
    property string leftIcon: ""
    property string rightIcon: ""
    property string icon: ""
    property bool iconRight: false

    // Style override properties
    property real customRadius: -1
    property color customColor: "transparent"
    property color customTextColor: "transparent"

    // Default property alias to allow custom content injection
    default property alias customContent: customContentContainer.data

    // ==========================================
    // Signals
    // ==========================================
    signal clicked()

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================

    readonly property string actualVariant: {
        if (variant === "primary" || variant === "danger" || variant === "success" || variant === "warning" || variant === "info" || variant === "secondary") {
            return "filled"
        }
        return variant // filled, tonal, outline, ghost
    }

    readonly property string actualColor: {
        if (variant === "primary") return "primary"
        if (variant === "danger") return "red"
        if (variant === "success") return "green"
        if (variant === "warning") return "yellow"
        if (variant === "info") return "sky"
        if (variant === "secondary") return "surface0"
        return color
    }

    readonly property string finalLeftIcon: leftIcon !== "" ? leftIcon : (!iconRight ? icon : "")
    readonly property string finalRightIcon: rightIcon !== "" ? rightIcon : (iconRight ? icon : "")

    // Size tokens mapping
    readonly property real currentHeight: {
        if (size === "sm") return 32
        if (size === "lg") return 48
        return 40 // "md"
    }

    readonly property real currentPadding: {
        if (size === "sm") return Theme.spacing.md // 12px
        if (size === "lg") return Theme.spacing.xl // 24px
        return Theme.spacing.lg // 16px (md)
    }

    readonly property real currentFontSize: {
        if (size === "sm") return Theme.typography.sizeSm // 12px
        if (size === "lg") return Theme.typography.sizeLg // 16px
        return Theme.typography.sizeMd // 14px (md)
    }

    readonly property real currentIconSize: {
        if (size === "sm") return 14
        if (size === "lg") return 20
        return 18 // md
    }

    readonly property real defaultRadius: {
        if (shape === "square") return 0
        if (shape === "pill") return 9999
        // rounded (default)
        if (size === "sm") return Theme.geometry.radiusSm
        if (size === "lg") return Theme.geometry.radiusLg
        return Theme.geometry.radiusMd
    }

    readonly property real finalRadius: customRadius >= 0 ? customRadius : defaultRadius

    // Color Helpers
    readonly property bool hasCustomColor: customColor !== undefined && customColor !== null && customColor.toString() !== "#00000000" && customColor.toString() !== "transparent"
    readonly property bool hasCustomTextColor: customTextColor !== undefined && customTextColor !== null && customTextColor.toString() !== "#00000000" && customTextColor.toString() !== "transparent"

    readonly property color baseAccentColor: {
        if (hasCustomColor) return customColor
        if (actualColor === "surface0") return Theme.colors.surface0
        var stdColor = Theme.colors[actualColor]
        if (stdColor !== undefined) return stdColor
        return Theme.colors.primary // fallback mauve
    }

    readonly property bool isSolidVariant: actualVariant === "filled"

    // Background color based on variant and mouse state
    readonly property color finalBackgroundColor: {
        if (isSolidVariant) {
            if (actualColor === "surface0") {
                // For old secondary style surface0 background
                if (mouseArea.pressed)       return Theme.colors.surface2
                if (mouseArea.containsMouse) return Theme.colors.surface1
                return Theme.colors.surface0
            }
            if (mouseArea.pressed)       return Qt.darker(baseAccentColor, 1.1)
            if (mouseArea.containsMouse) return Qt.lighter(baseAccentColor, 1.05)
            return baseAccentColor
        }
        if (actualVariant === "outline") {
            if (mouseArea.pressed)       return Qt.rgba(baseAccentColor.r, baseAccentColor.g, baseAccentColor.b, 0.20)
            if (mouseArea.containsMouse) return Qt.rgba(baseAccentColor.r, baseAccentColor.g, baseAccentColor.b, 0.10)
            return "transparent"
        }
        if (actualVariant === "tonal") {
            if (mouseArea.pressed)       return Qt.rgba(baseAccentColor.r, baseAccentColor.g, baseAccentColor.b, 0.35)
            if (mouseArea.containsMouse) return Qt.rgba(baseAccentColor.r, baseAccentColor.g, baseAccentColor.b, 0.25)
            return Qt.rgba(baseAccentColor.r, baseAccentColor.g, baseAccentColor.b, 0.15)
        }
        if (actualVariant === "ghost") {
            if (mouseArea.pressed)       return Theme.colors.surface1
            if (mouseArea.containsMouse) return Theme.colors.surface0
            return "transparent"
        }
        return baseAccentColor
    }

    // Border color and width
    readonly property color finalBorderColor: {
        if (actualVariant === "outline") return baseAccentColor
        return "transparent"
    }

    readonly property real finalBorderWidth: {
        if (actualVariant === "outline") return Theme.geometry.borderSm
        return 0
    }

    // Text and Icon color
    readonly property color finalTextColor: {
        if (hasCustomTextColor) return customTextColor

        if (isSolidVariant) {
            // For surface0 (old secondary variant), text color should be text color, not crust
            if (actualColor === "surface0") return Theme.colors.text
            return Theme.colors.crust
        }

        // outline & tonal: use the accent color as text
        if (actualVariant === "outline" || actualVariant === "tonal") return baseAccentColor

        if (actualVariant === "ghost") return Theme.colors.text

        return Theme.colors.text
    }

    readonly property color rippleColor: {
        if (isSolidVariant) {
            return Qt.rgba(finalTextColor.r, finalTextColor.g, finalTextColor.b, 0.22)
        }
        return Qt.rgba(baseAccentColor.r, baseAccentColor.g, baseAccentColor.b, 0.18)
    }

    // Layout Dimensions
    implicitWidth: {
        var contentWidth = 0;
        if (customContentContainer.children.length > 0) {
            for (var i = 0; i < customContentContainer.children.length; i++) {
                contentWidth = Math.max(contentWidth, customContentContainer.children[i].width);
            }
        } else {
            contentWidth = defaultContentLayout.implicitWidth;
        }
        return contentWidth + currentPadding * 2;
    }
    implicitHeight: currentHeight
    width: implicitWidth
    height: implicitHeight

    // ==========================================
    // Visual Tree
    // ==========================================

    // Cozy micro-animation scale & opacity
    transformOrigin: Item.Center
    scale: root.disabled ? 1.0 : (mouseArea.pressed ? 0.97 : (mouseArea.containsMouse ? 1.02 : 1.0))
    opacity: root.disabled ? 0.5 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutBack }
    }

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    // Background Panel
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: root.finalBackgroundColor
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: root.finalBorderWidth

        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        Behavior on border.color {
            ColorAnimation { duration: 150 }
        }
    }

    // Default Content Layout (Icon + Text)
    Row {
        id: defaultContentLayout
        anchors.centerIn: parent
        spacing: Theme.spacing.sm
        visible: customContentContainer.children.length === 0

        // Left Icon Container
        Item {
            width: root.isLoading ? currentIconSize : (root.finalLeftIcon !== "" ? currentIconSize : 0)
            height: currentIconSize
            visible: root.isLoading || root.finalLeftIcon !== ""
            anchors.verticalCenter: parent.verticalCenter

            // Loader Spinner
            CozySpinner {
                size: root.currentIconSize
                color: root.finalTextColor
                visible: root.isLoading
                anchors.centerIn: parent
            }

            // Normal Left Icon
            LucideIcon {
                name: root.finalLeftIcon
                size: root.currentIconSize
                color: root.finalTextColor
                visible: !root.isLoading && root.finalLeftIcon !== ""
                anchors.centerIn: parent
            }
        }

        // Label Text
        Text {
            text: root.text
            font.family: Theme.typography.familyMedium
            font.pixelSize: root.currentFontSize
            color: root.finalTextColor
            anchors.verticalCenter: parent.verticalCenter
            visible: root.text !== ""
            antialiasing: true
        }

        // Right Icon Container
        Item {
            width: root.finalRightIcon !== "" ? currentIconSize : 0
            height: currentIconSize
            visible: root.finalRightIcon !== ""
            anchors.verticalCenter: parent.verticalCenter

            // Normal Right Icon
            LucideIcon {
                name: root.finalRightIcon
                size: root.currentIconSize
                color: root.finalTextColor
                visible: root.finalRightIcon !== ""
                anchors.centerIn: parent
            }
        }
    }

    // Custom Content Slot
    Item {
        id: customContentContainer
        anchors.centerIn: parent
        visible: children.length > 0
    }

    // Click ripple effect
    Item {
        id: rippleWrapper
        anchors.fill: parent
        clip: true
        visible: backgroundRect.visible

        Rectangle {
            id: ripple
            width: 0
            height: 0
            radius: width / 2
            color: root.rippleColor
            opacity: 0

            ParallelAnimation {
                id: rippleAnim

                NumberAnimation {
                    target: ripple
                    property: "width"
                    from: 0
                    to: Math.sqrt(root.width * root.width + root.height * root.height) * 2
                    duration: 500
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: ripple
                    property: "height"
                    from: 0
                    to: Math.sqrt(root.width * root.width + root.height * root.height) * 2
                    duration: 500
                    easing.type: Easing.OutQuad
                }

                NumberAnimation {
                    target: ripple
                    property: "opacity"
                    from: 0.5
                    to: 0
                    duration: 500
                    easing.type: Easing.InQuad
                }
            }
        }
    }

    // Mouse Interaction Area
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled && !root.isLoading
        onClicked: function(mouse) {
            var maxDim = Math.sqrt(root.width * root.width + root.height * root.height) * 2
            ripple.x = mouse.x - maxDim / 2
            ripple.y = mouse.y - maxDim / 2
            ripple.width = 0
            ripple.height = 0
            ripple.opacity = 0.5
            rippleAnim.start()
            root.clicked()
        }
    }

    // Accessibility
    Accessible.role: Accessible.Button
    Accessible.name: root.text
    Accessible.description: root.text + " button"
    activeFocusOnTab: !root.disabled && !root.isLoading

    // Keyboard support
    Keys.onReturnPressed: if (!root.disabled && !root.isLoading) root.clicked()
    Keys.onSpacePressed: if (!root.disabled && !root.isLoading) root.clicked()

    // Focus ring overlay
    FocusRing {
        target: root
        active: root.activeFocus && !root.disabled
    }
}
