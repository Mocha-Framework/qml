// ── LongPressGesture.qml ──────────────────────────────────────────────────
// Reusable long-press detector using MouseArea + Timer (compatible with
// QtQuick 2.15 – does NOT rely on PressAndHoldHandler which is Qt ≥6.4 only).
//
// See meta/mobile-gestures.md §5.2.

import QtQuick 2.15

Item {
    id: root

    // ── Public API ───────────────────────────────────────────────────────
    property int duration: 500                // ms
    property bool hapticOnTrigger: true
    property string hapticStyle: "impactMedium"

    // True while a finger is currently held inside the gesture area.
    // Gate for competing gestures (e.g. drag-to-reorder after long press).
    property bool pressed: _mouse.pressed

    // ── Signals ──────────────────────────────────────────────────────────
    signal longPressed(point localPos)
    signal pressStarted()
    signal pressCanceled()

    // ── Internal ─────────────────────────────────────────────────────────
    Timer {
        id: _holdTimer
        interval: root.duration
        repeat: false
        onTriggered: {
            if (_mouse.pressed) {
                if (root.hapticOnTrigger && MediaQuery.isTouchDevice)
                    MediaQuery.haptic(root.hapticStyle)
                root.longPressed(Qt.point(_mouse.mouseX, _mouse.mouseY))
            }
        }
    }

    MouseArea {
        id: _mouse
        anchors.fill: parent
        enabled: root.enabled

        onPressed: function(mouse) {
            root.pressStarted()
            _holdTimer.restart()
        }

        onReleased: {
            _holdTimer.stop()
        }

        onExited: {
            _holdTimer.stop()
            root.pressCanceled()
        }

        onCanceled: {
            _holdTimer.stop()
            root.pressCanceled()
        }
    }
}