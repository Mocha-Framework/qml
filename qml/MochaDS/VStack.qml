import QtQuick 2.15

Item {
    id: root

    // ═══════════════════════════════════════════════════
    // Spacing & Direction
    // ═══════════════════════════════════════════════════
    property real spacing: Theme.spacing.md
    property real spacingX: -1                     // -1 = inherit from spacing
    property real spacingY: -1                     // -1 = inherit from spacing
    property string justifyContent: "start"        // start | center | end | between | around | evenly
    property string alignItems: "stretch"          // start | center | end | stretch
    property bool wrap: false
    property bool reverse: false

    // ═══════════════════════════════════════════════════
    // Wrap-specific
    // ═══════════════════════════════════════════════════
    property string alignContent: "start"          // start | center | end | between | around | evenly | stretch

    // ═══════════════════════════════════════════════════
    // Content
    // ═══════════════════════════════════════════════════
    default property alias data: childrenContainer.data

    // ── Resolved spacing ──
    readonly property real gapX: spacingX >= 0 ? spacingX : spacing
    readonly property real gapY: spacingY >= 0 ? spacingY : spacing

    implicitWidth: 0
    implicitHeight: 0
    width: implicitWidth
    height: implicitHeight

    // ═══════════════════════════════════════════════════
    // Layout engine
    // ═══════════════════════════════════════════════════

    onWidthChanged: Qt.callLater(relayout)
    onHeightChanged: Qt.callLater(relayout)
    onJustifyContentChanged: Qt.callLater(relayout)
    onAlignItemsChanged: Qt.callLater(relayout)
    onAlignContentChanged: Qt.callLater(relayout)
    onSpacingChanged: Qt.callLater(relayout)
    onSpacingXChanged: Qt.callLater(relayout)
    onSpacingYChanged: Qt.callLater(relayout)
    onWrapChanged: Qt.callLater(relayout)
    onReverseChanged: Qt.callLater(relayout)

    Component.onCompleted: Qt.callLater(relayout)

    Item {
        id: childrenContainer
        anchors.fill: parent
        onChildrenChanged: Qt.callLater(root.relayout)
    }

    function _visibleChildren() {
        var items = []
        for (var i = 0; i < childrenContainer.children.length; i++) {
            var c = childrenContainer.children[i]
            if (c.visible) items.push(c)
        }
        if (reverse) items.reverse()
        return items
    }

    function _childWidth(c) {
        return c.implicitWidth || c.width || 0
    }

    function _childHeight(c) {
        return c.implicitHeight || c.height || 0
    }

    function _childFlexGrow(c) {
        if (c.flexGrow !== undefined && c.flexGrow > 0) return c.flexGrow
        return 0
    }

    function _childFillX(c) {
        return c.fillX !== undefined ? c.fillX : (c.fill !== undefined ? c.fill : false)
    }

    function _childFillY(c) {
        return c.fillY !== undefined ? c.fillY : (c.fill !== undefined ? c.fill : false)
    }

    function _childAlignSelf(c, fallback) {
        if (c.alignSelf !== undefined && c.alignSelf !== "") return c.alignSelf
        return fallback
    }

    function _childMinH(c) {
        if (c.minHeight !== undefined && c.minHeight > 0) return c.minHeight
        return 0
    }

    function _childMaxH(c) {
        if (c.maxHeight !== undefined && c.maxHeight > 0) return c.maxHeight
        return Infinity
    }

    function _applyAlignSelf(c, colWidth, align) {
        var iw = _childWidth(c)
        var alignSelf = _childAlignSelf(c, align)
        switch (alignSelf) {
            case "center":
                c.x = (colWidth - iw) / 2
                break
            case "end":
                c.x = colWidth - iw
                break
            case "start":
                c.x = 0
                break
            case "stretch":
                c.x = 0
                c.width = colWidth
                break
            default:
                c.x = 0
                break
        }
    }

    function relayout() {
        var items = _visibleChildren()
        var n = items.length
        if (n === 0) { implicitWidth = 0; implicitHeight = 0; return }

        var available = root.height > 0 ? root.height : 1000000
        var gX = gapX
        var gY = gapY

        if (!wrap) {
            // ── Single column layout ──
            var totalIH = 0
            var totalFlexGrow = 0
            var fillYCount = 0

            for (var i = 0; i < n; i++) {
                var c = items[i]
                if (_childFillY(c)) {
                    fillYCount++
                } else if (_childFlexGrow(c) > 0) {
                    totalFlexGrow += _childFlexGrow(c)
                    totalIH += _childHeight(c)
                } else {
                    totalIH += _childHeight(c)
                }
            }

            var totalGap = (n - 1) * gY
            var flexGrowSpace = 0
            var perFill = 0

            if (fillYCount > 0) {
                var remainingForFill = Math.max(0, available - totalIH - totalGap)
                perFill = remainingForFill / fillYCount
            } else if (totalFlexGrow > 0) {
                var baseAllocated = totalIH + totalGap
                flexGrowSpace = Math.max(0, available - baseAllocated)
            }

            var freeSpace = Math.max(0, available - totalIH - totalGap)
            if (fillYCount > 0) {
                freeSpace = Math.max(0, available - totalIH - totalGap - fillYCount * perFill)
            }

            var betweenExtra = 0
            var startY = 0

            switch (justifyContent) {
                case "center": startY = freeSpace / 2; break
                case "end": startY = freeSpace; break
                case "between":
                    if (n > 1) betweenExtra = freeSpace / (n - 1); break
                case "around":
                    var g = freeSpace / n; betweenExtra = g; startY = g / 2; break
                case "evenly":
                    var g2 = freeSpace / (n + 1); betweenExtra = g2; startY = g2; break
            }

            var currentY = startY
            var maxW = 0

            for (var j = 0; j < n; j++) {
                var ci = items[j]
                ci.y = currentY

                var ch = _childHeight(ci)
                if (_childFillY(ci)) {
                    ch = perFill > 0 ? perFill : Math.max(0, available - totalIH - totalGap) / Math.max(1, fillYCount)
                } else if (totalFlexGrow > 0 && _childFlexGrow(ci) > 0) {
                    ch += flexGrowSpace * (_childFlexGrow(ci) / totalFlexGrow)
                }
                ch = Math.max(_childMinH(ci), Math.min(ch, _childMaxH(ci)))
                ci.height = ch

                var cw = _childWidth(ci)
                if (_childFillX(ci)) cw = root.width
                ci.width = cw

                _applyAlignSelf(ci, root.width, alignItems)

                if (cw > maxW) maxW = cw
                currentY += ch + gY + betweenExtra
            }

            implicitWidth = maxW
            implicitHeight = currentY - betweenExtra - gY
            root.width = implicitWidth
            root.height = implicitHeight

        } else {
            // ── Wrap into columns ──
            var cols = []
            var col = []
            var colH = 0

            for (var k = 0; k < n; k++) {
                var wk = items[k]
                var itemH = _childHeight(wk)
                if (_childFillY(wk)) itemH = available

                if (col.length > 0 && colH + gY + itemH > available) {
                    cols.push(col)
                    col = []
                    colH = 0
                }
                col.push(wk)
                colH += (col.length > 1 ? gY : 0) + itemH
            }
            if (col.length > 0) cols.push(col)

            var colWidths = []

            for (var r = 0; r < cols.length; r++) {
                var colItems = cols[r]
                var cn = colItems.length

                var cTotalH = 0
                for (var ci = 0; ci < cn; ci++) {
                    var cc = colItems[ci]
                    if (_childFillY(cc)) cTotalH += available
                    else cTotalH += _childHeight(cc)
                }
                var cGaps = (cn - 1) * gY
                var cFree = Math.max(0, available - cTotalH - cGaps)

                var cBetweenExtra = 0
                var cStartY = 0

                switch (justifyContent) {
                    case "center": cStartY = cFree / 2; break
                    case "end": cStartY = cFree; break
                    case "between":
                        if (cn > 1) cBetweenExtra = cFree / (cn - 1); break
                    case "around":
                        var cg = cFree / cn; cBetweenExtra = cg; cStartY = cg / 2; break
                    case "evenly":
                        var cg2 = cFree / (cn + 1); cBetweenExtra = cg2; cStartY = cg2; break
                }

                var cCurY = cStartY
                var cMaxW = 0

                for (var cj = 0; cj < cn; cj++) {
                    var cci = colItems[cj]
                    cci.y = cCurY

                    var ch_ = _childHeight(cci)
                    if (_childFillY(cci)) ch_ = available
                    cci.height = ch_

                    var cw_ = _childWidth(cci)
                    if (_childFillX(cci)) cw_ = _maxColWidth(colWidths)
                    if (cw_ > cMaxW) cMaxW = cw_
                    cci.width = cw_

                    cCurY += ch_ + gY + cBetweenExtra
                }

                // Apply per-item alignSelf within the column
                for (var ca = 0; ca < cn; ca++) {
                    var cci2 = colItems[ca]
                    _applyAlignSelf(cci2, cMaxW, alignItems)
                }

                colWidths.push(cMaxW)
            }

            // alignContent — horizontal distribution of columns
            var totalColGaps = (cols.length - 1) * gX
            var totalColW = 0
            for (var tw = 0; tw < colWidths.length; tw++) totalColW += colWidths[tw]
            var contentFree = Math.max(0, root.width - totalColW - totalColGaps)
            var colStartX = 0
            var colBetweenExtra = 0

            switch (alignContent) {
                case "center": colStartX = contentFree / 2; break
                case "end": colStartX = contentFree; break
                case "around":
                    var ag = contentFree / cols.length; colBetweenExtra = ag; colStartX = ag / 2; break
                case "evenly":
                    var ag2 = contentFree / (cols.length + 1); colBetweenExtra = ag2; colStartX = ag2; break
                case "between":
                    if (cols.length > 1) colBetweenExtra = contentFree / (cols.length - 1); break
                case "stretch":
                    if (contentFree > 0 && cols.length > 0) {
                        var stretchExtra = contentFree / cols.length
                        for (var sr = 0; sr < colWidths.length; sr++) colWidths[sr] += stretchExtra
                        totalColW += contentFree
                    }
                    break
            }

            var curX = colStartX
            for (var lr = 0; lr < cols.length; lr++) {
                var lcolItems = cols[lr]
                for (var lj = 0; lj < lcolItems.length; lj++) {
                    lcolItems[lj].x = curX
                }
                curX += colWidths[lr] + gX + colBetweenExtra
            }

            // implicit sizing
            var maxColH = 0
            for (var mh = 0; mh < cols.length; mh++) {
                var cItems = cols[mh]
                var cTotal = 0
                for (var mi = 0; mi < cItems.length; mi++) {
                    cTotal += cItems[mi].height
                }
                cTotal += (Math.max(0, cItems.length - 1)) * gY
                if (cTotal > maxColH) maxColH = cTotal
            }
            implicitWidth = totalColW + totalColGaps
            implicitHeight = maxColH
            root.width = implicitWidth
            root.height = implicitHeight
        }
    }

    function _maxColWidth(widths) {
        var m = 0
        for (var i = 0; i < widths.length; i++) {
            if (widths[i] > m) m = widths[i]
        }
        return m
    }
}
