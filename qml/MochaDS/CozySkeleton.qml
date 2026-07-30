import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    property string variant: "rectangle" // "rectangle" | "circle"
    property real radius: variant === "circle" ? Math.min(width, height) / 2 : Theme.geometry.radiusSm
    
    // Layout Dimensions
    implicitWidth: 100
    implicitHeight: 20
    width: implicitWidth
    height: implicitHeight

    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: Theme.colors.surface0
        radius: root.radius
        clip: true

        Rectangle {
            id: shimmerBar
            width: parent.width * 1.5 + 100
            height: parent.height * 3 + 100
            anchors.verticalCenter: parent.verticalCenter
            rotation: 25

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.35; color: "transparent" }
                GradientStop { position: 0.5; color: Theme.colors.surface1 }
                GradientStop { position: 0.65; color: "transparent" }
                GradientStop { position: 1.0; color: "transparent" }
            }

            NumberAnimation on x {
                from: -shimmerBar.width / 2 - 50
                to: root.width + 50
                duration: 1500
                loops: Animation.Infinite
                running: root.visible && root.width > 0 && root.height > 0
            }
        }
    }
}
