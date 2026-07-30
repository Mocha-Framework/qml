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
    property string alignItems: "center"           // start | center | end | stretch
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

    // Dummy initial values — replaced by relayout
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

    function _childMinW(c) {
        if (c.minWidth !== undefined && c.minWidth > 0) return c.minWidth
        return 0
    }

    function _childMaxW(c) {
        if (c.maxWidth !== undefined && c.maxWidth > 0) return c.maxWidth
        return Infinity
    }

    function _applyAlignSelf(c, rowHeight, align) {
        var ih = _childHeight(c)
        var alignSelf = _childAlignSelf(c, align)
        switch (alignSelf) {
            case "center":
                c.y = (rowHeight - ih) / 2
                break
            case "end":
                c.y = rowHeight - ih
                break
            case "start":
                c.y = 0
                break
            case "stretch":
                c.y = 0
                c.height = rowHeight
                break
            default:
                c.y = 0
                break
        }
    }

    function relayout() {
        var items = _visibleChildren()
        var n = items.length
        if (n === 0) { implicitWidth = 0; implicitHeight = 0; return }

        var available = root.width > 0 ? root.width : 1000000
        var gX = gapX
        var gY = gapY

        if (!wrap) {
            // ── Single row layout ──
            var totalIW = 0
            var totalFlexGrow = 0
            var fillXCount = 0

            for (var i = 0; i < n; i++) {
                var c = items[i]
                if (_childFillX(c)) {
                    fillXCount++
                } else if (_childFlexGrow(c) > 0) {
                    totalFlexGrow += _childFlexGrow(c)
                    totalIW += _childWidth(c)
                } else {
                    totalIW += _childWidth(c)
                }
            }

            var totalGap = (n - 1) * gX
            var flexGrowSpace = 0
            var baseAllocated = totalIW + totalGap

            // FillX items take remaining space equally
            if (fillXCount > 0) {
                var remainingForFill = Math.max(0, available - totalIW - totalGap)
                var perFill = remainingForFill / fillXCount
                // Recalc base to account for fillX allocation
                baseAllocated = totalIW + fillXCount * perFill + totalGap
                if (totalFlexGrow > 0) {
                    baseAllocated = totalIW + totalGap
                    flexGrowSpace = Math.max(0, available - baseAllocated - fillXCount * perFill)
                }
            } else if (totalFlexGrow > 0) {
                flexGrowSpace = Math.max(0, available - baseAllocated)
            }

            var freeSpace = Math.max(0, available - baseAllocated)
            if (totalFlexGrow <= 0 && fillXCount === 0) freeSpace = flexGrowSpace

            var betweenExtra = 0
            var startX = 0

            switch (justifyContent) {
                case "center": startX = freeSpace / 2; break
                case "end": startX = freeSpace; break
                case "between":
                    if (n > 1) betweenExtra = freeSpace / (n - 1); break
                case "around":
                    var g = freeSpace / n; betweenExtra = g; startX = g / 2; break
                case "evenly":
                    var g2 = freeSpace / (n + 1); betweenExtra = g2; startX = g2; break
            }

            var currentX = startX
            var maxH = 0

            for (var j = 0; j < n; j++) {
                var ci = items[j]
                ci.x = currentX

                var cw = _childWidth(ci)
                if (_childFillX(ci)) {
                    cw = perFill !== undefined ? perFill : Math.max(0, available - totalIW - totalGap) / fillXCount
                } else if (totalFlexGrow > 0 && _childFlexGrow(ci) > 0) {
                    cw += flexGrowSpace * (_childFlexGrow(ci) / totalFlexGrow)
                }
                cw = Math.max(_childMinW(ci), Math.min(cw, _childMaxW(ci)))
                ci.width = cw

                var ch = _childHeight(ci)
                if (_childFillY(ci)) ch = root.height
                ci.height = ch

                _applyAlignSelf(ci, root.height, alignItems)

                if (ch > maxH) maxH = ch
                currentX += cw + gX + betweenExtra
            }

            implicitWidth = currentX - betweenExtra - gX
            implicitHeight = maxH
            root.width = implicitWidth
            root.height = implicitHeight

        } else {
            // ── Wrap layout ──
            var rows = []
            var row = []
            var rowW = 0

            for (var k = 0; k < n; k++) {
                var wk = items[k]
                var itemW = _childWidth(wk)
                if (_childFillX(wk)) itemW = available

                if (row.length > 0 && rowW + gX + itemW > available) {
                    rows.push(row)
                    row = []
                    rowW = 0
                }
                row.push(wk)
                rowW += (row.length > 1 ? gX : 0) + itemW
            }
            if (row.length > 0) rows.push(row)

            var rowHeights = []
            var totalRowH = 0

            for (var r = 0; r < rows.length; r++) {
                var rowItems = rows[r]
                var rn = rowItems.length

                var rTotalW = 0
                for (var ri = 0; ri < rn; ri++) {
                    var rc = rowItems[ri]
                    if (_childFillX(rc)) rTotalW += available
                    else rTotalW += _childWidth(rc)
                }
                var rGaps = (rn - 1) * gX
                var rFree = Math.max(0, available - rTotalW - rGaps)

                var rBetweenExtra = 0
                var rStartX = 0

                switch (justifyContent) {
                    case "center": rStartX = rFree / 2; break
                    case "end": rStartX = rFree; break
                    case "between":
                        if (rn > 1) rBetweenExtra = rFree / (rn - 1); break
                    case "around":
                        var rg = rFree / rn; rBetweenExtra = rg; rStartX = rg / 2; break
                    case "evenly":
                        var rg2 = rFree / (rn + 1); rBetweenExtra = rg2; rStartX = rg2; break
                }

                var rCurX = rStartX
                var rMaxH = 0

                for (var rj = 0; rj < rn; rj++) {
                    var rci = rowItems[rj]
                    rci.x = rCurX

                    var rw = _childWidth(rci)
                    if (_childFillX(rci)) rw = available
                    rci.width = rw

                    var rh = _childHeight(rci)
                    if (_childFillY(rci)) rh = _maxRowHeight(rowHeights)
                    rci.height = rh

                    if (rh > rMaxH) rMaxH = rh
                    rCurX += rw + gX + rBetweenExtra
                }

                // Apply per-item alignSelf within the row
                for (var ra = 0; ra < rn; ra++) {
                    var rci2 = rowItems[ra]
                    _applyAlignSelf(rci2, rMaxH, alignItems)
                }

                rowHeights.push(rMaxH)
                totalRowH += rMaxH
            }

            // alignContent — vertical distribution of rows
            var totalRowGaps = (rows.length - 1) * gY
            var contentFree = Math.max(0, root.height - totalRowH - totalRowGaps)
            var rowStartY = 0
            var rowBetweenExtra = 0

            switch (alignContent) {
                case "center": rowStartY = contentFree / 2; break
                case "end": rowStartY = contentFree; break
                case "around":
                    var ag = contentFree / rows.length; rowBetweenExtra = ag; rowStartY = ag / 2; break
                case "evenly":
                    var ag2 = contentFree / (rows.length + 1); rowBetweenExtra = ag2; rowStartY = ag2; break
                case "between":
                    if (rows.length > 1) rowBetweenExtra = contentFree / (rows.length - 1); break
                case "stretch":
                    if (contentFree > 0 && rows.length > 0) {
                        var stretchExtra = contentFree / rows.length
                        for (var sr = 0; sr < rowHeights.length; sr++) {
                            rowHeights[sr] += stretchExtra
                        }
                        totalRowH += contentFree
                    }
                    break
            }

            var curY = rowStartY
            for (var lr = 0; lr < rows.length; lr++) {
                var lrowItems = rows[lr]
                for (var lj = 0; lj < lrowItems.length; lj++) {
                    lrowItems[lj].y = curY
                }
                curY += rowHeights[lr] + gY + rowBetweenExtra
            }

            // implicit sizing for wrap mode
            var maxRowW = 0
            for (var mw = 0; mw < rows.length; mw++) {
                var rItems = rows[mw]
                var rTotal = 0
                for (var mi = 0; mi < rItems.length; mi++) {
                    rTotal += rItems[mi].width
                }
                rTotal += (Math.max(0, rItems.length - 1)) * gX
                if (rTotal > maxRowW) maxRowW = rTotal
            }
            implicitWidth = maxRowW
            implicitHeight = totalRowH + totalRowGaps
            root.width = implicitWidth
            root.height = implicitHeight
        }
    }

    function _maxRowHeight(heights) {
        var m = 0
        for (var i = 0; i < heights.length; i++) {
            if (heights[i] > m) m = heights[i]
        }
        return m
    }
}
