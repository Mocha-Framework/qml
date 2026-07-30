import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    property real size: 24
    property color color: Theme.colors.primary
    property bool overlay: false
    property string label: ""
    property color overlayColor: Qt.rgba(Theme.colors.crust.r, Theme.colors.crust.g, Theme.colors.crust.b, 0.85)

    // Set implicit sizes for layout integration when not in overlay mode
    implicitWidth: overlay ? parent.width : size
    implicitHeight: overlay ? parent.height : size
    width: overlay ? undefined : size
    height: overlay ? undefined : size

    // Manage stacking index dynamically when overlay is toggled on/off
    z: overlay ? 99999 : 1

    // 1. Normal (inline) mode spinner icon
    LucideIcon {
        id: spinnerIcon
        name: "loader-2"
        size: root.size
        color: root.color
        anchors.centerIn: parent
        visible: !root.overlay

        RotationAnimator {
            target: spinnerIcon
            from: 0
            to: 360
            duration: 1000
            loops: Animation.Infinite
            running: root.visible && !root.overlay && root.width > 0 && root.height > 0
        }
    }

    // 2. Fullscreen overlay mode components
    Rectangle {
        id: overlayBg
        visible: root.overlay
        width: (parent && parent.parent) ? parent.parent.width : (parent ? parent.width : 0)
        height: (parent && parent.parent) ? parent.parent.height : (parent ? parent.height : 0)
        x: (parent && parent.parent) ? -parent.x : 0
        y: (parent && parent.parent) ? -parent.y : 0
        color: root.overlayColor
        z: root.z

        // Intercept mouse clicks to block background actions
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.spacing.md

            LucideIcon {
                id: overlaySpinnerIcon
                name: "loader-2"
                size: 48 // Larger for full-screen impact
                color: root.color
                anchors.horizontalCenter: parent.horizontalCenter

                RotationAnimator {
                    target: overlaySpinnerIcon
                    from: 0
                    to: 360
                    duration: 1000
                    loops: Animation.Infinite
                    running: root.visible && root.overlay
                }
            }

            Text {
                text: root.label
                color: Theme.colors.text
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                visible: root.label !== ""
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
