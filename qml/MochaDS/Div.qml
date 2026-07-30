import QtQuick 2.15

Item {
    id: root

    // ═══════════════════════════════════════════════════
    // Show / Animate
    // ═══════════════════════════════════════════════════
    property bool show: true
    property bool animate: false

    property string animateIn: "fade"
    property string animateOut: "fade"

    property int durationIn: 300
    property int durationOut: 250

    property real easingInEasing: Easing.OutQuad
    property real easingOutEasing: Easing.InQuad

    property real enterOffset: 24
    property real exitOffset: 24

    property real enterScale: 0.95
    property real exitScale: 0.95

    readonly property bool isAnimating: animate ? (show ? enterSeq.running : exitSeq.running) : false

    // ═══════════════════════════════════════════════════
    // Spacing (Box model)
    // ═══════════════════════════════════════════════════
    property var p: undefined
    property var px: undefined
    property var py: undefined
    property var pt: undefined
    property var pr: undefined
    property var pb: undefined
    property var pl: undefined

    property var m: undefined
    property var mx: undefined
    property var my: undefined
    property var mt: undefined
    property var mr: undefined
    property var mb: undefined
    property var ml: undefined

    // ═══════════════════════════════════════════════════
    // Visual
    // ═══════════════════════════════════════════════════
    property string variant: "default"        // default | surface | elevated | outline
    property string colorName: ""             // token override for bg color

    property var radius: undefined            // shorthand: "sm"|"md"|"lg"|"pill"|"none" or number
    property real customRadius: -1            // fallback (-1 = use variant default)
    property string shadow: "none"            // none | sm | md | lg

    // ═══════════════════════════════════════════════════
    // Layout — replaces anchors.*
    // ═══════════════════════════════════════════════════
    property bool fill: false                 // → anchors.fill: parent
    property bool fillX: false                // → anchors.left + right: parent
    property bool fillY: false                // → anchors.top + bottom: parent
    property string alignSelf: ""             // start | center | end | stretch (consumed by parent stack)

    // ═══════════════════════════════════════════════════
    // Flex — consumed by HStack / VStack
    // ═══════════════════════════════════════════════════
    property real flexGrow: 0
    property real flexShrink: 1

    // ═══════════════════════════════════════════════════
    // Sizing
    // ═══════════════════════════════════════════════════
    property real width_: -1                   // explicit width override (-1 = auto)
    property real height_: -1                  // explicit height override (-1 = auto)
    property real minWidth: 0
    property real maxWidth: 0
    property real minHeight: 0
    property real maxHeight: 0

    // ═══════════════════════════════════════════════════
    // Stack / Flex
    // ═══════════════════════════════════════════════════
    property string alignItems: ""             // start | center | end | stretch (self-layout shortcut)

    // ═══════════════════════════════════════════════════
    // Stacking / Overflow
    // ═══════════════════════════════════════════════════
    property int zIndex: -1                   // -1 = use default
    property string overflow: "visible"       // visible | hidden | scroll | auto

    // ═══════════════════════════════════════════════════
    // Interactive
    // ═══════════════════════════════════════════════════
    property bool clickable: false
    signal clicked()

    // ═══════════════════════════════════════════════════
    // Content
    // ═══════════════════════════════════════════════════
    default property alias data: contentArea.data

    // ═══════════════════════════════════════════════════
    // Spacing helpers
    // ═══════════════════════════════════════════════════
    function resolveSpacing(val) {
        if (val === undefined || val === null) return 0
        if (typeof val === "number") return val
        if (val === "xs") return Theme.spacing.xs
        if (val === "sm") return Theme.spacing.sm
        if (val === "md") return Theme.spacing.md
        if (val === "lg") return Theme.spacing.lg
        if (val === "xl") return Theme.spacing.xl
        if (val === "xxl") return Theme.spacing.xxl
        return 0
    }

    readonly property real finalPt: pt !== undefined ? resolveSpacing(pt) : (py !== undefined ? resolveSpacing(py) : resolveSpacing(p))
    readonly property real finalPr: pr !== undefined ? resolveSpacing(pr) : (px !== undefined ? resolveSpacing(px) : resolveSpacing(p))
    readonly property real finalPb: pb !== undefined ? resolveSpacing(pb) : (py !== undefined ? resolveSpacing(py) : resolveSpacing(p))
    readonly property real finalPl: pl !== undefined ? resolveSpacing(pl) : (px !== undefined ? resolveSpacing(px) : resolveSpacing(p))

    readonly property real finalMt: mt !== undefined ? resolveSpacing(mt) : (my !== undefined ? resolveSpacing(my) : resolveSpacing(m))
    readonly property real finalMr: mr !== undefined ? resolveSpacing(mr) : (mx !== undefined ? resolveSpacing(mx) : resolveSpacing(m))
    readonly property real finalMb: mb !== undefined ? resolveSpacing(mb) : (my !== undefined ? resolveSpacing(my) : resolveSpacing(m))
    readonly property real finalMl: ml !== undefined ? resolveSpacing(ml) : (mx !== undefined ? resolveSpacing(mx) : resolveSpacing(m))

    readonly property real finalRadius: {
        var v = _resolveRadius()
        if (v >= 0) return v
        if (customRadius >= 0) return customRadius
        return Theme.geometry.radiusMd
    }

    function _resolveRadius() {
        if (radius === undefined || radius === null) return -1
        if (typeof radius === "number") return radius
        if (radius === "none") return 0
        if (radius === "sm") return Theme.geometry.radiusSm
        if (radius === "md") return Theme.geometry.radiusMd
        if (radius === "lg") return Theme.geometry.radiusLg
        if (radius === "pill") return Theme.geometry.radiusPill
        return -1
    }

    readonly property string finalOverflow: overflow

    // ═══════════════════════════════════════════════════
    // Layout — fill-aware sizing
    // ═══════════════════════════════════════════════════

    implicitWidth: _calcImplicitW()
    implicitHeight: _calcImplicitH()

    function _calcImplicitW() {
        return contentArea.implicitWidth + finalPl + finalPr + finalMl + finalMr
    }

    function _calcImplicitH() {
        return contentArea.implicitHeight + finalPt + finalPb + finalMt + finalMb
    }

    width: {
        if (width_ >= 0) return width_
        var baseW = _calcImplicitW()
        if (fill || fillX) baseW = parent ? parent.width : baseW
        if (minWidth > 0) baseW = Math.max(baseW, minWidth)
        if (maxWidth > 0) baseW = Math.min(baseW, maxWidth)
        return baseW
    }

    height: {
        if (height_ >= 0) return height_
        var baseH = _calcImplicitH()
        if (fill || fillY) baseH = parent ? parent.height : baseH
        if (minHeight > 0) baseH = Math.max(baseH, minHeight)
        if (maxHeight > 0) baseH = Math.min(baseH, maxHeight)
        return baseH
    }

    z: zIndex >= 0 ? zIndex : 0

    visible: animate ? true : show
    clip: {
        if (finalOverflow === "hidden") return true
        if (finalOverflow === "scroll") return true
        if (finalOverflow === "auto") return contentArea.implicitHeight > root.height || contentArea.implicitWidth > root.width
        return animate
    }

    opacity: animate ? (show ? 1 : 0) : 1
    scale: animate ? (show ? 1 : exitScale) : 1
    transformOrigin: Item.Center

    // ═══════════════════════════════════════════════════
    // States
    // ═══════════════════════════════════════════════════
    states: [
        State {
            name: "shown"
            when: root.animate && root.show
            PropertyChanges { target: root; opacity: 1 }
            PropertyChanges { target: root; scale: 1 }
            PropertyChanges { target: rootTranslate; y: 0 }
            PropertyChanges { target: rootTranslate; x: 0 }
        },
        State {
            name: "hidden"
            when: root.animate && !root.show
            PropertyChanges { target: root; opacity: 0 }
            PropertyChanges { target: root; scale: root.exitScale }
            PropertyChanges { target: rootTranslate; y: _exitY() }
            PropertyChanges { target: rootTranslate; x: _exitX() }
        }
    ]

    // ═══════════════════════════════════════════════════
    // Transitions
    // ═══════════════════════════════════════════════════
    transitions: [
        Transition {
            from: "hidden"
            to: "shown"

            SequentialAnimation {
                id: enterSeq

                ScriptAction { script: _prepareEnter() }

                ParallelAnimation {
                    NumberAnimation {
                        target: root; property: "opacity"
                        duration: root.durationIn; easing.type: root.easingInEasing
                    }
                    NumberAnimation {
                        target: root; property: "scale"
                        duration: _useScale(root.animateIn) ? root.durationIn : 0
                        easing.type: root.easingInEasing
                    }
                    NumberAnimation {
                        target: rootTranslate; property: "y"
                        duration: _useSlideY(root.animateIn) ? root.durationIn : 0
                        easing.type: root.easingInEasing
                    }
                    NumberAnimation {
                        target: rootTranslate; property: "x"
                        duration: _useSlideX(root.animateIn) ? root.durationIn : 0
                        easing.type: root.easingInEasing
                    }
                }
            }
        },
        Transition {
            from: "shown"
            to: "hidden"

            SequentialAnimation {
                id: exitSeq

                ParallelAnimation {
                    NumberAnimation {
                        target: root; property: "opacity"
                        duration: root.durationOut; easing.type: root.easingOutEasing
                    }
                    NumberAnimation {
                        target: root; property: "scale"
                        duration: _useScale(root.animateOut) ? root.durationOut : 0
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation {
                        target: rootTranslate; property: "y"
                        duration: _useSlideY(root.animateOut) ? root.durationOut : 0
                        easing.type: Easing.InCubic
                    }
                    NumberAnimation {
                        target: rootTranslate; property: "x"
                        duration: _useSlideX(root.animateOut) ? root.durationOut : 0
                        easing.type: Easing.InCubic
                    }
                }
            }
        }
    ]

    // ═══════════════════════════════════════════════════
    // Transform
    // ═══════════════════════════════════════════════════
    transform: Translate {
        id: rootTranslate
        x: 0; y: 0
    }

    // ═══════════════════════════════════════════════════
    // Shadow layer
    // ═══════════════════════════════════════════════════
    Rectangle {
        id: shadowRect
        x: root.finalMl + _shadowOffset(); y: root.finalMt + _shadowOffset()
        width: root.width - root.finalMl - root.finalMr
        height: root.height - root.finalMt - root.finalMb
        radius: root.finalRadius
        color: _shadowColor()
        visible: root.shadow !== "none" && root.shadow !== ""
        z: -1
    }

    function _shadowOffset() {
        switch (shadow) {
            case "sm": return 2
            case "md": return 4
            case "lg": return 8
            default: return 0
        }
    }

    function _shadowColor() {
        // approximate box-shadow with a semi-transparent dark rect
        switch (shadow) {
            case "sm": return Qt.rgba(0, 0, 0, 0.10)
            case "md": return Qt.rgba(0, 0, 0, 0.15)
            case "lg": return Qt.rgba(0, 0, 0, 0.22)
            default: return "transparent"
        }
    }

    // ═══════════════════════════════════════════════════
    // Background + Content
    // ═══════════════════════════════════════════════════
    Rectangle {
        id: backgroundRect
        x: root.finalMl; y: root.finalMt
        width: root.width - root.finalMl - root.finalMr
        height: root.height - root.finalMt - root.finalMb

        color: {
            if (root.colorName && Theme.colors[root.colorName]) return Theme.colors[root.colorName]
            if (root.variant === "surface") return Theme.colors.surface0
            if (root.variant === "elevated") return Theme.colors.mantle
            return "transparent"
        }
        radius: root.finalRadius
        border.color: root.variant === "outline" ? Theme.colors.surface1 : "transparent"
        border.width: root.variant === "outline" ? Theme.geometry.borderSm : 0

        Item {
            id: contentArea
            x: root.finalPl; y: root.finalPt
            width: parent.width - root.finalPl - root.finalPr
            height: parent.height - root.finalPt - root.finalPb
        }
    }

    // ═══════════════════════════════════════════════════
    // Interactive — clickable overlay
    // ═══════════════════════════════════════════════════
    MouseArea {
        id: interactiveArea
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        z: 100
        onClicked: root.clicked()
    }

    // ═══════════════════════════════════════════════════
    // Animation helpers
    // ═══════════════════════════════════════════════════
    function _useSlideY(type) {
        return type === "slide-up" || type === "slide-down" || type === "all"
    }

    function _useSlideX(type) {
        return type === "slide-left" || type === "slide-right" || type === "all"
    }

    function _useScale(type) {
        return type === "zoom" || type === "bounce" || type === "all"
    }

    function _enterY() {
        if (animateIn === "slide-up") return enterOffset
        if (animateIn === "slide-down") return -enterOffset
        if (animateIn === "all") return enterOffset
        return 0
    }

    function _enterX() {
        if (animateIn === "slide-left") return enterOffset
        if (animateIn === "slide-right") return -enterOffset
        return 0
    }

    function _exitY() {
        if (animateOut === "slide-up") return exitOffset
        if (animateOut === "slide-down") return -exitOffset
        if (animateOut === "all") return exitOffset
        return 0
    }

    function _exitX() {
        if (animateOut === "slide-left") return exitOffset
        if (animateOut === "slide-right") return -exitOffset
        return 0
    }

    function _prepareEnter() {
        rootTranslate.y = _enterY()
        rootTranslate.x = _enterX()
        if (_useScale(animateIn) || _useScale(animateOut)) {
            root.scale = enterScale
        }
    }
}
