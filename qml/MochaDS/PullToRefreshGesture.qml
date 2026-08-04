// ── PullToRefreshGesture.qml ──────────────────────────────────────────────
// Attach to a Flickable to detect overscroll at the top and emit a refresh
// signal when the user pulls past `threshold`.
//
// Strategy: we observe the Flickable's `contentY` via a Timer poll. When
// contentY goes negative (overscroll at the top), we track the maximum
// overscroll. When contentY returns to >= 0 (user released), we check whether
// the max overscroll crossed `threshold` and fire `refresh()`.
//
// This avoids injecting a DragHandler into the Flickable's contentItem
// (which is impossible because PointerHandlers can't be reparented into
// arbitrary Items at runtime). Instead we piggyback on the Flickable's
// built-in bouncing overscroll.
//
// Usage:
//   Flickable {
//       id: list
//       ...
//       PullToRefreshGesture {
//           target: list
//           threshold: 80
//           onRefresh: doRefresh()
//       }
//   }
//
// See meta/mobile-gestures.md §5.5.

import QtQuick 2.15

Item {
    id: root

    // ── Public API ───────────────────────────────────────────────────────
    property Flickable target: null
    property real threshold: 80
    property bool hapticOnTrigger: true

    // Set to true while refresh is in-flight; the gesture won't fire again
    // until the consumer resets it to false.
    property bool refreshing: false

    // ── Signals ──────────────────────────────────────────────────────────
    signal refresh()
    // 0..1+; values above 1 mean the user has pulled past the threshold
    // without releasing.
    signal progressChanged(real progress)

    // ── Internal state ───────────────────────────────────────────────────
    property real __maxOverscroll: 0
    property bool __dragging: false

    // Poll the Flickable 16 times/sec while dragging. Cheap.
    Timer {
        id: pollTimer
        interval: 60
        repeat: true
        running: root.target !== null && root.enabled && !root.refreshing

        onTriggered: {
            if (!root.target || root.refreshing) return
            var cy = root.target.contentY

            if (cy < 0) {
                // Overscroll at the top — user is pulling down.
                __dragging = true
                if (-cy > __maxOverscroll) __maxOverscroll = -cy
                root.progressChanged(Math.max(0, __maxOverscroll / root.threshold))
            } else if (__dragging && cy >= 0) {
                // User released. Commit if we crossed the threshold.
                if (__maxOverscroll >= root.threshold) {
                    root.refreshing = true
                    if (root.hapticOnTrigger && MediaQuery.isTouchDevice) {
                        MediaQuery.haptic("impactMedium")
                    }
                    root.refresh()
                }
                __dragging = false
                __maxOverscroll = 0
                root.progressChanged(0)
            } else if (cy >= 0) {
                // Idle at the top.
                __maxOverscroll = 0
            }
        }
    }

    // Also watch `moving` property — when it transitions from true to
    // false and we were dragging, it's the end of a flick gesture.
    Connections {
        target: root.target
        ignoreUnknownSignals: true
        enabled: root.target !== null
        function onMovingChanged() {
            if (!root.target) return
            if (!root.target.moving && __dragging) {
                // Flickable stopped — flush the max overscroll.
                if (__maxOverscroll >= root.threshold && !root.refreshing) {
                    root.refreshing = true
                    if (root.hapticOnTrigger && MediaQuery.isTouchDevice) {
                        MediaQuery.haptic("impactMedium")
                    }
                    root.refresh()
                }
                __dragging = false
                __maxOverscroll = 0
                root.progressChanged(0)
            }
        }
    }
}