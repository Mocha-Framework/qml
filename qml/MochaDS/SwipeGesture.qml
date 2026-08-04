// ── SwipeGesture.qml ──────────────────────────────────────────────────────
// Reusable swipe detector for any Item. Wraps a low-level DragHandler with
// threshold + velocity-based commit logic and emits typed direction signals.
//
// Usage:
//   SwipeGesture {
//       anchors.fill: parent
//       enabledDirections: ["left", "right"]
//       onSwiped: (direction, velocity) => { ... }
//   }
//
// See meta/mobile-gestures.md §5.1 for the contract.

import QtQuick 2.15

Item {
    id: root

    // ── Public API ───────────────────────────────────────────────────────
    // Subset of ["left", "right", "up", "down"]. Empty = none.
    property var enabledDirections: ["left", "right", "up", "down"]

    // Distance threshold in pixels. A commit triggers when |translation|
    // crosses this on the dominant axis.
    property real threshold: 80

    // Velocity threshold in px/sec. Commits also trigger if the gesture
    // releases with high enough velocity even if it didn't reach `threshold`.
    property real velocityThreshold: 600

    // Axis gate. Defaults to both — use Qt.Horizontal | Qt.Vertical.
    property int axis: Qt.Horizontal | Qt.Vertical

    // Suppress animating `translation` — leave it to the parent to react
    // to `swipeProgress` and snap back manually.
    property bool consumeEvents: true

    // ── Signals ──────────────────────────────────────────────────────────
    // Fired when the user releases after a committed swipe. Direction is one
    // of the strings in enabledDirections. Velocity is px/sec (signed).
    signal swiped(string direction, real velocity)

    // Fired during the drag with progress 0..1 (clamped). Useful for
    // driving drag-along animations on the parent (e.g. moving the drawer
    // along with the finger). Dominant axis only.
    signal swipeProgress(string direction, real progress)

    // Fired when a gesture was rejected (threshold not crossed, wrong
    // direction, etc.). Parent uses this to snap back.
    signal swipeCanceled()

    // ── Read-only state ──────────────────────────────────────────────────
    property bool active: dragHandler.active
    property string lastDirection: "none"
    property real lastProgress: 0.0

    // ── Internal: drag bookkeeping ───────────────────────────────────────
    DragHandler {
        id: dragHandler
        target: null
        acceptedButtons: Qt.LeftButton
        dragThreshold: 8
        enabled: root.enabled

        property real __startX: 0
        property real __startY: 0
        property real __startMs: 0

        onActiveChanged: {
            if (active) {
                __startX = translation.x
                __startY = translation.y
                __startMs = Date.now()
            } else if (root.consumeEvents) {
                _commit()
            }
        }

        onTranslationChanged: {
            if (!active) return
            var dx = translation.x - __startX
            var dy = translation.y - __startY
            var ax = Math.abs(dx)
            var ay = Math.abs(dy)

            // Honor axis gate
            if ((root.axis & Qt.Horizontal) === 0 && ax >= ay) return
            if ((root.axis & Qt.Vertical)   === 0 && ay >  ax) return

            var dir = "none"
            var prog = 0
            if (ax >= ay) {
                if (dx > 0)      { dir = "right"; prog = dx / root.threshold }
                else if (dx < 0) { dir = "left";  prog = -dx / root.threshold }
            } else {
                if (dy > 0)      { dir = "down"; prog = dy / root.threshold }
                else if (dy < 0) { dir = "up";   prog = -dy / root.threshold }
            }
            if (root.enabledDirections.indexOf(dir) < 0) return

            var clamped = Math.max(0, Math.min(1, prog))
            root.lastDirection = dir
            root.lastProgress = clamped
            root.swipeProgress(dir, clamped)
        }

        function _commit() {
            var dx = translation.x - __startX
            var dy = translation.y - __startY
            var dt = Math.max(1, Date.now() - __startMs) / 1000
            var vx = dx / dt
            var vy = dy / dt

            var ax = Math.abs(dx), ay = Math.abs(dy)
            var dir = "none"
            var v = 0

            if ((root.axis & Qt.Horizontal) !== 0 && ax >= ay) {
                if (dx >  root.threshold || vx >  root.velocityThreshold) { dir = "right"; v = vx }
                else if (-dx > root.threshold || -vx > root.velocityThreshold) { dir = "left";  v = vx }
            }
            if (dir === "none" && (root.axis & Qt.Vertical) !== 0) {
                if (dy >  root.threshold || vy >  root.velocityThreshold) { dir = "down"; v = vy }
                else if (-dy > root.threshold || -vy > root.velocityThreshold) { dir = "up";   v = vy }
            }

            if (dir !== "none" && root.enabledDirections.indexOf(dir) >= 0) {
                root.lastDirection = dir
                root.lastProgress = 0
                root.swiped(dir, v)
            } else {
                root.lastProgress = 0
                root.swipeCanceled()
            }
        }
    }

    // Make the gesture targetable by parent MouseAreas without blocking
    // them — handled by the DragHandler, this stays transparent.
    MouseArea {
        anchors.fill: parent
        enabled: false
        cursorShape: Qt.ArrowCursor
    }
}