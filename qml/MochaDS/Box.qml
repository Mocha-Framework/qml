import QtQuick 2.15

Item {
    id: root

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

    property string variant: "default"
    property string colorName: ""

    default property alias content: contentArea.data

    function resolveSpacing(val) {
        if (val === undefined || val === null) return 0;
        if (typeof val === "number") return val;
        if (val === "xs") return Theme.spacing.xs;
        if (val === "sm") return Theme.spacing.sm;
        if (val === "md") return Theme.spacing.md;
        if (val === "lg") return Theme.spacing.lg;
        if (val === "xl") return Theme.spacing.xl;
        if (val === "xxl") return Theme.spacing.xxl;
        if (val === "none") return 0;
        return 0;
    }

    readonly property real finalPt: pt !== undefined ? resolveSpacing(pt) : (py !== undefined ? resolveSpacing(py) : (p !== undefined ? resolveSpacing(p) : 0))
    readonly property real finalPr: pr !== undefined ? resolveSpacing(pr) : (px !== undefined ? resolveSpacing(px) : (p !== undefined ? resolveSpacing(p) : 0))
    readonly property real finalPb: pb !== undefined ? resolveSpacing(pb) : (py !== undefined ? resolveSpacing(py) : (p !== undefined ? resolveSpacing(p) : 0))
    readonly property real finalPl: pl !== undefined ? resolveSpacing(pl) : (px !== undefined ? resolveSpacing(px) : (p !== undefined ? resolveSpacing(p) : 0))

    readonly property real finalMt: mt !== undefined ? resolveSpacing(mt) : (my !== undefined ? resolveSpacing(my) : (m !== undefined ? resolveSpacing(m) : 0))
    readonly property real finalMr: mr !== undefined ? resolveSpacing(mr) : (mx !== undefined ? resolveSpacing(mx) : (m !== undefined ? resolveSpacing(m) : 0))
    readonly property real finalMb: mb !== undefined ? resolveSpacing(mb) : (my !== undefined ? resolveSpacing(my) : (m !== undefined ? resolveSpacing(m) : 0))
    readonly property real finalMl: ml !== undefined ? resolveSpacing(ml) : (mx !== undefined ? resolveSpacing(mx) : (m !== undefined ? resolveSpacing(m) : 0))

    // Background — positioned AFTER margins so margin space stays transparent
    Rectangle {
        id: backgroundRect
        x: root.finalMl
        y: root.finalMt
        width: root.width - root.finalMl - root.finalMr
        height: root.height - root.finalMt - root.finalMb

        color: {
            if (root.colorName && Theme.colors[root.colorName]) return Theme.colors[root.colorName];
            if (root.variant === "surface") return Theme.colors.surface0;
            if (root.variant === "elevated") return Theme.colors.mantle;
            return "transparent";
        }
        radius: Theme.geometry.radiusMd
        border.color: root.variant === "outline" ? Theme.colors.surface1 : "transparent"
        border.width: root.variant === "outline" ? Theme.geometry.borderSm : 0

        // Content area inside background — offset by padding
        Item {
            id: contentArea
            x: root.finalPl
            y: root.finalPt
            width: parent.width - root.finalPl - root.finalPr
            height: parent.height - root.finalPt - root.finalPb
        }
    }

    implicitWidth: contentArea.implicitWidth + finalPl + finalPr + finalMl + finalMr
    implicitHeight: contentArea.implicitHeight + finalPt + finalPb + finalMt + finalMb
}
