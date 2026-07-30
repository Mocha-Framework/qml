pragma Singleton
import QtQuick 2.15

Item {
    id: root

    property real windowWidth: 0
    property real windowHeight: 0

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

    property QtObject breakpoints: Theme.breakpoints

    function watch(item) {
        if (!item) return
        root.windowWidth = Qt.binding(function() { return item.width })
        root.windowHeight = Qt.binding(function() { return item.height })
    }
}
