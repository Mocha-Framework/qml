import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property bool mobile: false
    property bool multiline: true
    property int gap: 3
    property string align: "start"      // "start" | "center" | "end" | "space-between" | "space-around"
    property string valign: "start"     // "start" | "center" | "end"

    // Default property to receive children
    default property alias content: root.children

    // Repeater Mode Properties (Optional - for direct loop rendering)
    property var model: null
    property Component delegate: null

    // Implicit sizing helper (updates on layout)
    implicitWidth: 600
    implicitHeight: layoutHeight
    width: implicitWidth
    height: layoutHeight

    // Breakpoint limits (synced with Shell.qml)
    readonly property real breakpointMd: 768
    readonly property real breakpointLg: 1024

    readonly property string currentScreenSize: {
        var w = root.width;
        // Search up the parent hierarchy for Window width if root width is not descriptive yet
        var p = parent;
        while (p && w <= 0) {
            if (p.width !== undefined && p.width > 0) {
                w = p.width;
            }
            p = p.parent;
        }
        if (w < breakpointMd) return "sm";
        if (w < breakpointLg) return "md";
        return "lg";
    }

    readonly property real gapPixels: {
        if (gap === 0) return 0;
        if (gap === 1) return Theme.spacing.xs;  // 4
        if (gap === 2) return Theme.spacing.sm;  // 8
        if (gap === 3) return Theme.spacing.md;  // 16
        if (gap === 4) return Theme.spacing.lg;  // 24
        if (gap === 5) return Theme.spacing.xl;  // 32
        return Theme.spacing.md;
    }

    // Internal height tracked dynamically
    property real layoutHeight: 0

    onWidthChanged: Qt.callLater(doLayout)
    onChildrenChanged: Qt.callLater(doLayout)
    onCurrentScreenSizeChanged: Qt.callLater(doLayout)
    onGapChanged: Qt.callLater(doLayout)
    onAlignChanged: Qt.callLater(doLayout)
    onValignChanged: Qt.callLater(doLayout)
    onModelChanged: Qt.callLater(doLayout)

    Component.onCompleted: Qt.callLater(doLayout)

    function requestLayout() {
        Qt.callLater(doLayout)
    }

    function doLayout() {
        var gridWidth = root.width;
        if (gridWidth <= 0) return;

        var cols = [];
        
        // Filter visual children that are GridCol elements
        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            if (child.visible && (child.hasOwnProperty("span") || child.hasOwnProperty("_resolvedSpan"))) {
                cols.push(child);
            }
        }

        if (cols.length === 0) {
            layoutHeight = 0;
            return;
        }

        // Sort by order property (lower = first)
        cols.sort(function(a, b) {
            var orderA = a.order !== undefined ? a.order : 0
            var orderB = b.order !== undefined ? b.order : 0
            return orderA - orderB
        })

        var gapPx = root.gapPixels;
        var screen = root.currentScreenSize;

        // Group columns into rows using a 12-column grid system
        var rows = [];
        var currentRow = [];
        var currentSpanSum = 0;

        for (var j = 0; j < cols.length; j++) {
            var col = cols[j];
            
            // Resolve span based on screen size
            var span = col.span !== undefined ? col.span : 12;
            if (screen === "sm" && col.sm !== undefined && col.sm > 0) span = col.sm;
            else if (screen === "md" && col.md !== undefined && col.md > 0) span = col.md;
            else if (screen === "lg" && col.lg !== undefined && col.lg > 0) span = col.lg;
            
            // In mobile mode, if mobile=false, columns stack (span=12)
            if (screen === "sm" && !root.mobile) {
                span = 12;
            }

            col._resolvedSpan = span;

            // Resolve offset
            var offset = col.offset !== undefined ? col.offset : 0;
            if (screen === "sm" && col.smOffset !== undefined && col.smOffset >= 0) offset = col.smOffset;
            else if (screen === "md" && col.mdOffset !== undefined && col.mdOffset >= 0) offset = col.mdOffset;
            else if (screen === "lg" && col.lgOffset !== undefined && col.lgOffset >= 0) offset = col.lgOffset;
            col._resolvedOffset = offset;

            var totalColCost = span + offset;

            if (root.multiline && (currentSpanSum + totalColCost > 12) && currentRow.length > 0) {
                // Wrap to next row
                rows.push(currentRow);
                currentRow = [col];
                currentSpanSum = totalColCost;
            } else {
                currentRow.push(col);
                currentSpanSum += totalColCost;
            }
        }
        if (currentRow.length > 0) {
            rows.push(currentRow);
        }

        // Calculate positions row by row
        var currentY = 0;

        for (var r = 0; r < rows.length; r++) {
            var rowCols = rows[r];
            
            var rowSpanSum = 0;
            var maxColHeight = 0;
            
            for (var c = 0; c < rowCols.length; c++) {
                var cItem = rowCols[c];
                rowSpanSum += cItem._resolvedSpan + cItem._resolvedOffset;
            }

            // Width of 1 column unit
            var numGaps = Math.max(0, rowCols.length - 1);
            var widthForCols = gridWidth - (numGaps * gapPx);
            var unitWidth = widthForCols / 12;

            // Compute sizes and find tallest column in row
            for (var c2 = 0; c2 < rowCols.length; c2++) {
                var colItem = rowCols[c2];
                colItem.width = unitWidth * colItem._resolvedSpan;
                
                var itemHeight = 0;
                if (colItem.implicitHeight > 0) {
                    itemHeight = colItem.implicitHeight;
                } else if (colItem.childrenRect.height > 0) {
                    itemHeight = colItem.childrenRect.height;
                } else {
                    itemHeight = colItem.height;
                }
                maxColHeight = Math.max(maxColHeight, itemHeight);
            }

            // Position horizontally inside row based on align
            var currentX = 0;
            var extraSpace = gridWidth - (rowSpanSum * unitWidth) - (numGaps * gapPx);
            
            var startOffset = 0;
            var spacingBetween = gapPx;

            if (align === "center") {
                startOffset = extraSpace / 2;
            } else if (align === "end") {
                startOffset = extraSpace;
            } else if (align === "space-between" && rowCols.length > 1) {
                startOffset = 0;
                spacingBetween = gapPx + (extraSpace / (rowCols.length - 1));
            } else if (align === "space-around" && rowCols.length > 0) {
                spacingBetween = gapPx + (extraSpace / rowCols.length);
                startOffset = spacingBetween / 2;
            }

            currentX = startOffset;

            for (var c3 = 0; c3 < rowCols.length; c3++) {
                var targetCol = rowCols[c3];
                
                currentX += unitWidth * targetCol._resolvedOffset;
                targetCol.x = currentX;
                targetCol.height = maxColHeight; // match tallest item in row

                // Vertical alignment inside row — alignSelf overrides grid valign
                var itemAlign = targetCol.alignSelf !== undefined && targetCol.alignSelf !== "" ? targetCol.alignSelf : valign;
                if (itemAlign === "center") {
                    targetCol.y = currentY + (maxColHeight - targetCol.height) / 2;
                } else if (itemAlign === "end") {
                    targetCol.y = currentY + (maxColHeight - targetCol.height);
                } else {
                    targetCol.y = currentY;
                }

                currentX += targetCol.width + spacingBetween;
            }

            currentY += maxColHeight + gapPx;
        }

        layoutHeight = Math.max(0, currentY - gapPx);
    }

    // Internal Repeater for loop mode
    Repeater {
        id: internalRepeater
        model: root.model
        delegate: root.delegate
        onCountChanged: Qt.callLater(root.doLayout)
    }
}
