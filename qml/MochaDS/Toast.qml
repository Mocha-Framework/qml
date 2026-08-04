import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property string title: ""
    property string message: ""
    property string type: "info" // "info" | "success" | "warning" | "error"
    property int duration: 3000  // Auto-dismiss timeout (ms)
    property bool showClose: true

    // ── Mobile gesture opt-ins (see meta/mobile-gestures.md §6.6) ──────
    // Horizontal swipe to dismiss the toast (alternative to the X button).
    property bool swipeToDismiss: true

    // Trigger a haptic on appear for warning/error toasts.
    property bool hapticOnAppear: true

    // Signals
    signal dismissed()

    // =============================q=============
    // Internal States & Helpers
    // ==========================================
    property int remainingTime: duration

    readonly property color accentColor: {
        if (type === "success") return Theme.colors.green;
        if (type === "error") return Theme.colors.danger;
        if (type === "warning") return Theme.colors.yellow;
        return Theme.colors.info;
    }

    readonly property string typeIcon: {
        if (type === "success") return "check-circle";
        if (type === "error") return "alert-circle";
        if (type === "warning") return "alert-triangle";
        return "info";
    }

    // Layout Dimensions
    width: 320
    height: bgRect.implicitHeight
    implicitWidth: width
    implicitHeight: height

    // Start invisible for entry animation
    opacity: 0.0
    scale: hoverHandler.hovered ? 1.01 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
    }

    // ==========================================
    // Visual Tree
    // ==========================================
    Rectangle {
        id: bgRect
        width: parent.width
        implicitHeight: contentLayout.implicitHeight + Theme.spacing.md * 2
        color: Theme.colors.base
        radius: Theme.geometry.radiusMd
        border.color: Theme.colors.surface1
        border.width: Theme.geometry.borderSm

        clip: true

        // Subtle shadow layer for card depth
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: parent.radius
            border.color: Qt.rgba(0, 0, 0, 0.15)
            border.width: 1
            z: -1
        }

        // Horizontal Row content
        Row {
            id: contentLayout
            width: parent.width - Theme.spacing.md * 2
            anchors.centerIn: parent
            spacing: Theme.spacing.md

            // Left Type Icon
            LucideIcon {
                name: root.typeIcon
                size: 20
                color: root.accentColor
                anchors.verticalCenter: parent.verticalCenter
            }

            // Center Text Column
            Column {
                width: parent.width - 20 - 16 - (Theme.spacing.md * 2) // fits icon + close button
                spacing: Theme.spacing.xs
                anchors.verticalCenter: parent.verticalCenter

                // Toast Title
                Text {
                    text: {
                        if (root.title !== "") return root.title;
                        if (root.type === "success") return "Sucesso";
                        if (root.type === "error") return "Erro";
                        if (root.type === "warning") return "Atenção";
                        return "Informação";
                    }
                    font.family: Theme.typography.familyBold
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.subtext1
                    visible: text !== ""
                    width: parent.width
                    elide: Text.ElideRight
                    antialiasing: true
                }

                // Toast Message
                Text {
                    text: root.message
                    font.family: Theme.typography.family
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.text
                    width: parent.width
                    wrapMode: Text.WordWrap
                    antialiasing: true
                }
            }

            // Right Close Button
            LucideIcon {
                id: closeIcon
                name: "x"
                size: 16
                color: closeMouseArea.containsMouse ? Theme.colors.text : Theme.colors.overlay0
                visible: root.showClose
                anchors.verticalCenter: parent.verticalCenter
                scale: closeMouseArea.pressed ? 0.92 : (closeMouseArea.containsMouse ? 1.08 : 1.0)

                Behavior on color { ColorAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                MouseArea {
                    id: closeMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.dismiss()
                }
            }
        }

        // Floating progress indicator track
        Rectangle {
            id: progressTrack
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottomMargin: 6
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            height: 4
            color: Theme.colors.surface1
            radius: 2
            clip: true

            Rectangle {
                id: progressBar
                height: parent.height
                color: root.accentColor
                width: parent.width * (root.remainingTime / root.duration)
                anchors.left: parent.left
                anchors.top: parent.top
                radius: 2
                
                Behavior on width {
                    NumberAnimation { duration: 80; easing.type: Easing.Linear }
                }
            }
        }
    }

    // Hover handler to pause timer and progress countdown
    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            countdownTimer.running = !hovered
        }
    }

    // ==========================================
    // Timers & Animations
    // ==========================================
    
    // Countdown clock (ticking every 50ms)
    Timer {
        id: countdownTimer
        interval: 50
        repeat: true
        running: true
        onTriggered: {
            root.remainingTime -= 50;
            if (root.remainingTime <= 0) {
                running = false;
                root.dismiss();
            }
        }
    }

    // ── Mobile: swipe-to-dismiss ──────────────────────────────────────
    SwipeGesture {
        anchors.fill: bgRect
        enabled: root.swipeToDismiss && MediaQuery.isTouchDevice
        threshold: 40
        velocityThreshold: 400
        axis: Qt.Horizontal
        enabledDirections: ["left", "right"]

        onSwiped: (direction, velocity) => {
            if (MediaQuery.isTouchDevice) MediaQuery.haptic("impactLight")
            // Animate bgRect out in the swipe direction, then dismiss.
            exitAnimX.targetValue = direction === "left" ? -bgRect.width - 40 : bgRect.width + 40
            root.dismiss()
        }
    }

    // Visual transitions
    Component.onCompleted: {
        bgRect.x = 120; // slide in from right offset
        entryAnim.start();
        // Mobile: haptic on appear for warning/error toasts.
        if (root.hapticOnAppear && MediaQuery.isTouchDevice && root.opacity > 0) {
            if (root.type === "error")   MediaQuery.haptic("notificationError")
            else if (root.type === "warning") MediaQuery.haptic("notificationWarning")
            else if (root.type === "success") MediaQuery.haptic("notificationSuccess")
        }
    }

    ParallelAnimation {
        id: entryAnim
        NumberAnimation { target: bgRect; property: "x"; to: 0; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { target: root; property: "opacity"; from: 0.0; to: 1.0; duration: 250 }
    }

    // Trigger graceful slide-out exit
    function dismiss() {
        countdownTimer.running = false;
        exitAnim.start();
    }

    ParallelAnimation {
        id: exitAnim
        NumberAnimation { id: exitAnimX; target: bgRect; property: "x"; to: 350; duration: 220; easing.type: Easing.InCubic }
        NumberAnimation { target: root; property: "opacity"; to: 0.0; duration: 220 }
        onStopped: {
            root.dismissed(); // notify manager to destroy
        }
    }
}
