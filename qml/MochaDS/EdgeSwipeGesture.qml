// ── EdgeSwipeGesture.qml ──────────────────────────────────────────────────
// Detects a swipe that STARTS in a band near the given screen edge. Useful
// for "swipe from the left edge to open the navigation drawer" patterns.
//
// Usage:
//   EdgeSwipeGesture {
//       anchors.fill: parent
//       edge: "left"          // "left" | "right" | "top" | "bottom"
//       bandSize: 24
//       threshold: 60
//       onEdgeSwiped: (edge, direction) => { ... }
//   }
//
// See meta/mobile-gestures.md §5.4.

import QtQuick 2.15

Item {
    id: root

    // ── Public API ───────────────────────────────────────────────────────
    property string edge: "left"           // "left" | "right" | "top" | "bottom"
    property real bandSize: 24             // px from edge that counts as "on the edge"
    property real threshold: 60            // px of travel required to commit
    property bool hapticOnTrigger: true

    // ── Signals ──────────────────────────────────────────────────────────
    // `edge` echoes `root.edge`. `direction` is "left"/"right"/"up"/"down"
    // depending on which way the swipe went from that edge.
    signal edgeSwiped(string edge, string direction)

    // ── Internal ─────────────────────────────────────────────────────────
    DragHandler {
        id: dragHandler
        target: null
        dragThreshold: 8
        acceptedButtons: Qt.LeftButton
        enabled: root.enabled

        property real __startX: 0
        property real __startY: 0
        property bool __validStart: false

        onActiveChanged: {
            if (active) {
                __startX = translation.x
                __startY = translation.y
                __validStart = _startsOnEdge(__startX, __startY)
            } else if (__validStart) {
                _commit()
                __validStart = false
            }
        }

        function _startsOnEdge(x, y) {
            if (!root.parent) return false
            var w = root.parent.width
            var h = root.parent.height
            if (root.edge === "left")   return x <= root.bandSize
            if (root.edge === "right")  return w - x <= root.bandSize
            if (root.edge === "top")    return y <= root.bandSize
            if (root.edge === "bottom") return h - y <= root.bandSize
            return false
        }

        function _commit() {
            var dx = translation.x - __startX
            var dy = translation.y - __startY
            var dir = "none"
            if (root.edge === "left") {
                if (dx > root.threshold) dir = "right"
            } else if (root.edge === "right") {
                if (-dx > root.threshold) dir = "left"
            } else if (root.edge === "top") {
                if (dy > root.threshold) dir = "down"
            } else if (root.edge === "bottom") {
                if (-dy > root.threshold) dir = "up"
            }
            if (dir !== "none") {
                if (root.hapticOnTrigger && MediaQuery.isTouchDevice) {
                    MediaQuery.haptic("impactLight")
                }
                root.edgeSwiped(root.edge, dir)
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: false
    }
}