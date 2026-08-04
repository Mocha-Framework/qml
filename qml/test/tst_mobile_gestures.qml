import QtQuick 2.15
import QtTest
import "../MochaDS" as DS

TestCase {
    name: "GestureMixinsInstantiation"

    function test_swipe_gesture_exists() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/SwipeGesture.qml"))
        compare(component.status, Component.Ready, "SwipeGesture.qml should load")
        var g = component.createObject(null, { enabledDirections: ["left", "right"], threshold: 40 })
        verify(g !== null, "SwipeGesture should instantiate")
        compare(g.enabledDirections.length, 2, "swipe should have 2 enabled directions")
        compare(g.threshold, 40)
        g.destroy()
    }

    function test_longpress_gesture_exists() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/LongPressGesture.qml"))
        compare(component.status, Component.Ready)
        var g = component.createObject(null, { duration: 600, hapticOnTrigger: false })
        verify(g !== null)
        compare(g.duration, 600)
        compare(g.hapticOnTrigger, false)
        g.destroy()
    }

    function test_pinch_gesture_exists() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/PinchGesture.qml"))
        compare(component.status, Component.Ready)
        var g = component.createObject(null, { minScale: 0.5, maxScale: 5.0 })
        verify(g !== null)
        compare(g.minScale, 0.5)
        compare(g.maxScale, 5.0)
        g.destroy()
    }

    function test_edge_swipe_gesture_exists() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/EdgeSwipeGesture.qml"))
        compare(component.status, Component.Ready)
        var g = component.createObject(null, { edge: "left", bandSize: 20 })
        verify(g !== null)
        compare(g.edge, "left")
        compare(g.bandSize, 20)
        g.destroy()
    }

    function test_pull_to_refresh_gesture_exists() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/PullToRefreshGesture.qml"))
        compare(component.status, Component.Ready)
        var g = component.createObject(null, { threshold: 100 })
        verify(g !== null)
        compare(g.threshold, 100)
        g.destroy()
    }

    function test_drawer_swipe_properties() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/Drawer.qml"))
        compare(component.status, Component.Ready)
        var drawer = component.createObject(null)
        verify(drawer !== null)
        compare(drawer.swipeToClose, true)
        compare(drawer.edgeSwipeToOpen, false)
        drawer.destroy()
    }

    function test_toast_mobile_properties() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/Toast.qml"))
        compare(component.status, Component.Ready)
        var toast = component.createObject(null, { duration: 500 })
        verify(toast !== null)
        compare(toast.swipeToDismiss, true)
        compare(toast.hapticOnAppear, true)
        toast.destroy()
    }

    function test_button_haptic_property() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/Button.qml"))
        compare(component.status, Component.Ready)
        var btn = component.createObject(null)
        verify(btn !== null)
        compare(btn.hapticOnTap, true)
        btn.destroy()
    }

    function test_modal_swipe_properties() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/Modal.qml"))
        compare(component.status, Component.Ready)
        var modal = component.createObject(null)
        verify(modal !== null)
        compare(modal.swipeToDismiss, true)
        modal.destroy()
    }

    function test_hero_carousel_swipe() {
        var component = Qt.createComponent(Qt.resolvedUrl("../MochaDS/HeroCarousel.qml"))
        compare(component.status, Component.Ready)
        var carousel = component.createObject(null, {
            model: [{ title: "A" }],
            swipeToNavigate: true,
            pinchToZoom: true,
            autoAdvanceInterval: 0
        })
        verify(carousel !== null)
        compare(carousel.swipeToNavigate, true)
        compare(carousel.pinchToZoom, true)
        carousel.destroy()
    }
}