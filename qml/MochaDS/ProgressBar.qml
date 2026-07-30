import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // The current progress value (0.0 to 1.0)
    property real value: 0.0

    // Optional text label to display next to the percentage
    property string label: ""

    // Variant style: "primary" | "success" | "warning" | "danger" | "info" | "peach" | "mauve"
    property string variant: "primary"

    // If true, shows a percentage text label (and descriptive label if provided)
    property bool showLabel: false

    // If true, the bar animates with a pulse effect (busy state)
    property bool indeterminate: false

    // If true, uses a pill (rounded) shape
    property bool pill: true

    // Visual customizations
    property color customColor: "transparent"
    property real customHeight: 8

    // ==========================================
    // Internal Style Tokens
    // ==========================================

    readonly property color finalColor: {
        if (customColor.toString() !== "#00000000" && customColor.toString() !== "transparent") return customColor
        if (variant === "success") return Theme.colors.green
        if (variant === "warning") return Theme.colors.yellow
        if (variant === "danger") return Theme.colors.red
        if (variant === "info") return Theme.colors.blue
        if (variant === "peach") return Theme.colors.peach
        if (variant === "mauve") return Theme.colors.mauve
        return Theme.colors.primary // default mauve
    }

    readonly property real finalRadius: pill ? height / 2 : Theme.geometry.radiusSm

    // ==========================================
    // Layout & Dimensions
    // ==========================================
    implicitWidth: 200
    implicitHeight: showLabel ? customHeight + 20 : customHeight
    width: implicitWidth
    height: implicitHeight

    Column {
        anchors.fill: parent
        spacing: 4

        // Progress Labels Container
        Row {
            width: parent.width
            visible: root.showLabel && !root.indeterminate

            Text {
                text: root.label
                font.family: Theme.typography.family
                font.pixelSize: 11
                color: Theme.colors.subtext1
                visible: root.label !== ""
                elide: Text.ElideRight
                width: parent.width - percentageText.width - 8
            }

            Text {
                id: percentageText
                text: Math.round(root.value * 100) + "%"
                font.family: Theme.typography.familyMedium
                font.pixelSize: 11
                color: Theme.colors.subtext1
                anchors.right: parent.right
            }
        }

        // Track
        Rectangle {
            id: track
            width: parent.width
            height: root.customHeight
            color: Theme.colors.surface0
            radius: root.finalRadius
            clip: true

            // Progress Fill
            Rectangle {
                id: fill
                width: root.indeterminate ? parent.width * 0.3 : parent.width * Math.min(1.0, Math.max(0.0, root.value))
                height: parent.height
                radius: parent.radius
                
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: root.finalColor }
                    GradientStop { position: 1.0; color: Qt.lighter(root.finalColor, 1.15) }
                }

                // Animation for value changes
                Behavior on width {
                    enabled: !root.indeterminate
                    NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
                }

                // Indeterminate Animation
                SequentialAnimation on x {
                    running: root.indeterminate
                    loops: Animation.Infinite
                    NumberAnimation { from: -fill.width; to: track.width; duration: 1000; easing.type: Easing.InOutSine }
                }

                // Glossy/Glow overlay
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    opacity: 0.2
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "white" }
                        GradientStop { position: 0.5; color: "transparent" }
                        GradientStop { position: 1.0; color: "black" }
                    }
                }
            }
        }
    }
}
