import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    
    // Total number of steps in the wizard
    property int totalSteps: 4

    // Current active step (1-based index: 1 to totalSteps)
    property int currentStep: 1

    // Variant style: "primary" | "secondary" | "success" | "warning" | "danger" | "info"
    property string variant: "primary"

    // If true, shows animated stripes on the active step
    property bool showStripes: true

    // If true, pulses the active step opacity to indicate activity
    property bool animateCurrent: true

    // Custom spacing between steps (defaults to theme spacing Sm / 8px)
    property real spacing: Theme.spacing.xs

    // Overrides
    property color customColor: "transparent"
    property real customRadius: -1

    // ==========================================
    // Layout Dimensions
    // ==========================================
    implicitWidth: 200
    implicitHeight: 8
    width: implicitWidth
    height: implicitHeight

    // ==========================================
    // Colors & Styles mapping
    // ==========================================
    readonly property color baseAccentColor: {
        if (customColor.toString() !== "#00000000" && customColor.toString() !== "transparent") {
            return customColor
        }
        if (variant === "secondary") return Theme.colors.secondary
        if (variant === "success")   return Theme.colors.success
        if (variant === "warning")   return Theme.colors.warning
        if (variant === "danger")    return Theme.colors.danger
        if (variant === "info")      return Theme.colors.info
        return Theme.colors.primary // primary (mauve)
    }

    // ==========================================
    // Visual Elements
    // ==========================================
    RowLayout {
        anchors.fill: parent
        spacing: root.spacing

        Repeater {
            model: Math.max(1, root.totalSteps)

            delegate: Rectangle {
                id: pillRect
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: root.customRadius >= 0 ? root.customRadius : height / 2
                clip: true

                // States flags
                readonly property bool isCompleted: index < (root.currentStep - 1)
                readonly property bool isActive: index === (root.currentStep - 1)
                readonly property bool isPending: index > (root.currentStep - 1)

                // Smooth color transition on step change
                color: {
                    if (isCompleted || isActive) {
                        return root.baseAccentColor
                    }
                    return Theme.colors.surface1 // recessed pending color
                }

                Behavior on color {
                    ColorAnimation { duration: 300 }
                }

                // Stripe overlay on the active step
                StripedFill {
                    id: stripes
                    anchors.fill: parent
                    color1: root.baseAccentColor
                    // Slightly distinct stripe color
                    color2: Qt.rgba(1.0, 1.0, 1.0, 0.15)
                    visible: pillRect.isActive && root.showStripes
                }

                // Pulse animation on the active step's opacity
                SequentialAnimation {
                    id: pulseAnimation
                    running: pillRect.isActive && root.animateCurrent
                    loops: Animation.Infinite
                    alwaysRunToEnd: false

                    NumberAnimation {
                        target: pillRect
                        property: "opacity"
                        from: 0.8
                        to: 1.0
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        target: pillRect
                        property: "opacity"
                        from: 1.0
                        to: 0.8
                        duration: 800
                        easing.type: Easing.InOutQuad
                    }

                    onStopped: pillRect.opacity = 1.0
                }

                // Reset opacity immediately when step transitions away
                onIsActiveChanged: {
                    if (!isActive) {
                        pillRect.opacity = 1.0
                    }
                }
            }
        }
    }
}
