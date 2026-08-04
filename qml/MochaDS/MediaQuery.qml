pragma Singleton
import QtQuick 2.15

Item {
    id: root

    property real windowWidth: 0
    property real windowHeight: 0

    // ── Breakpoints (existing) ───────────────────────────────────────────
    readonly property bool isXs: windowWidth < breakpoints.sm
    readonly property bool isSm: windowWidth >= breakpoints.sm && windowWidth < breakpoints.md
    readonly property bool isMd: windowWidth >= breakpoints.md && windowWidth < breakpoints.lg
    readonly property bool isLg: windowWidth >= breakpoints.lg && windowWidth < breakpoints.xl
    readonly property bool isXl: windowWidth >= breakpoints.xl

    readonly property bool isMobile: windowWidth < breakpoints.md
    readonly property bool isTablet: windowWidth >= breakpoints.md && windowWidth < breakpoints.lg
    readonly property bool isDesktop: windowWidth >= breakpoints.lg

    readonly property string activeBreakpoint: {
        if (isXs) return "xs"
        if (isSm) return "sm"
        if (isMd) return "md"
        if (isLg) return "lg"
        return "xl"
    }

    // ── Pointer / motion / safe-area / keyboard ──────────────────────────
    // Mutable defaults — overridden by Component.onCompleted when the C++
    // NativeBridge singleton is available (mocha-native binary loaded).
    // When running standalone (qmlscene), the safe defaults stay active.
    property bool   isTouchDevice: false
    property bool   isCoarsePointer: isTouchDevice
    property bool   prefersReducedMotion: false
    property real   pixelRatio: 1.0
    property int    keyboardHeight: 0
    property var    safeAreaInsets: ({ top: 0, right: 0, bottom: 0, left: 0 })

    // ── Haptics helper ───────────────────────────────────────────────────
    function haptic(style) {
        if (_bridgeAvailable) NativeBridge.haptic(style)
    }

    // ── Config ───────────────────────────────────────────────────────────
    property QtObject breakpoints: Theme.breakpoints

    function watch(item) {
        if (!item) return
        root.windowWidth = Qt.binding(function() { return item.width })
        root.windowHeight = Qt.binding(function() { return item.height })
    }

    // ── Bridge re-init ───────────────────────────────────────────────────
    // When mocha-native is loaded, the C++ qmlRegisterSingletonType call
    // happens BEFORE QML parsing, so NativeBridge is in scope here.
    property bool _bridgeAvailable: false

    Component.onCompleted: {
        if (typeof(NativeBridge) !== "undefined" && NativeBridge !== null) {
            _bridgeAvailable = true
            root.isTouchDevice           = Qt.binding(function() { return NativeBridge.isTouchDevice })
            root.isCoarsePointer         = Qt.binding(function() { return NativeBridge.isTouchDevice })
            root.prefersReducedMotion    = Qt.binding(function() { return NativeBridge.prefersReducedMotion })
            root.pixelRatio              = Qt.binding(function() { return NativeBridge.pixelRatio })
            root.keyboardHeight          = Qt.binding(function() { return NativeBridge.keyboardHeight })
            root.safeAreaInsets          = Qt.binding(function() { return NativeBridge.safeAreaInsets })
        }
    }
}