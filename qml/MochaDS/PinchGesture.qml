// ── PinchGesture.qml ──────────────────────────────────────────────────────
// Reusable pinch (zoom) detector. Wraps a PinchHandler and emits a clean
// scale/center stream with min/max clamping.
//
// Usage:
//   PinchGesture {
//       anchors.fill: parent
//       minScale: 1.0
//       maxScale: 4.0
//       onPinchUpdated: (scale, center, rotation) => { ... }
//       onPinchFinished: (scale, center) => { ... }
//   }
//
// See meta/mobile-gestures.md §5.3.

import QtQuick 2.15

Item {
    id: root

    // ── Public API ───────────────────────────────────────────────────────
    property real minScale: 1.0
    property real maxScale: 4.0
    property bool hapticOnBounds: true
    property bool respectReducedMotion: true

    // Currently exposed scale (clamped). Read this from your own delegate
    // to drive the visual zoom (`scale: root.currentScale`).
    property real currentScale: 1.0
    property real baseScale: 1.0

    // ── Signals ──────────────────────────────────────────────────────────
    signal pinchStarted()
    signal pinchUpdated(real scale, point center, real rotation)
    signal pinchFinished(real scale, point center)

    // ── Internal ─────────────────────────────────────────────────────────
    property bool _hapticOnMax: false
    property bool _hapticOnMin: false

    PinchHandler {
        id: pinchHandler
        enabled: root.enabled
        target: null
        minimumScale: 0.5
        maximumScale: 10.0   // we clamp to minScale/maxScale ourselves

        onActiveChanged: {
            if (active) {
                root.baseScale = root.currentScale
                root.pinchStarted()
                root._hapticOnMax = false
                root._hapticOnMin = false
                if (root.hapticOnBounds && MediaQuery.isTouchDevice) {
                    MediaQuery.haptic("selection")
                }
            } else {
                root.pinchFinished(root.currentScale, centroid.position)
            }
        }

        onScaleChanged: {
            var s = root.baseScale * scale
            if (s < root.minScale) s = root.minScale
            if (s > root.maxScale) s = root.maxScale
            root.currentScale = s

            // Haptic when hitting bounds (only at the moment of crossing)
            if (root.hapticOnBounds && MediaQuery.isTouchDevice) {
                if (s >= root.maxScale && !root._hapticOnMax) {
                    root._hapticOnMax = true
                    MediaQuery.haptic("impactLight")
                } else if (s < root.maxScale) {
                    root._hapticOnMax = false
                }
                if (s <= root.minScale && !root._hapticOnMin) {
                    root._hapticOnMin = true
                    MediaQuery.haptic("impactLight")
                } else if (s > root.minScale) {
                    root._hapticOnMin = false
                }
            }

            root.pinchUpdated(s, centroid.position, rotation)
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: false
    }
}