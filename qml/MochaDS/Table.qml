import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // Array of column metadata objects:
    // e.g. [{ name: "id", label: "ID", width: 100, sortable: true, type: "text" }]
    // Types supported: "text" | "bold" | "subtext" | "badge" | "currency"
    property var columns: []

    // Array of data row objects
    property var rows: []

    // Array of indices currently selected
    property var selectedIndexes: []

    // Sorting
    property string sortColumn: ""
    property string sortOrder: "asc"  // "asc" | "desc"

    // Pagination
    property int  pageSize:       5
    property int  currentPage:    1
    property bool showPagination: true

    // Selection
    property bool selectable: true

    // Drag and Drop Reordering
    property bool dragToReorder: false

    // ==========================================
    // Signals
    // ==========================================
    signal selectionChanged(var indexes)
    signal sortChanged(string column, string order)
    signal rowsReordered(int fromIndex, int toIndex)
    signal editSelected(var selectedRows)
    signal downloadSelected(var selectedRows)
    signal deleteSelected(var selectedRows)

    // ==========================================
    // Internal computed properties
    // ==========================================
    readonly property int  totalRecords: rows ? rows.length : 0
    readonly property int  totalPages:   Math.ceil(totalRecords / pageSize)

    readonly property bool isSelectionIndeterminate:
        selectedIndexes.length > 0 && selectedIndexes.length < totalRecords
    readonly property bool isAllSelected:
        totalRecords > 0 && selectedIndexes.length === totalRecords

    readonly property real baseColumnsWidth: {
        var w = 0;
        if (!columns) return w;
        for (var i = 0; i < columns.length; i++) w += columns[i].width || 120;
        return w;
    }

    readonly property int  checkboxColWidth: selectable ? 44 : 0
    readonly property int  dragHandleWidth: dragToReorder ? 44 : 0

    // Total minimum content width (used for horizontal scrolling)
    readonly property real minContentWidth: dragHandleWidth + checkboxColWidth + baseColumnsWidth

    // Returns the effective rendered pixel-width for a given column
    function getColWidth(col, idx) {
        var baseW = col.width || 120;
        var avail = root.width - checkboxColWidth - dragHandleWidth;
        if (avail > baseColumnsWidth && baseColumnsWidth > 0)
            return (baseW / baseColumnsWidth) * avail;
        return baseW;
    }

    // ── Sorting ──────────────────────────────────────────────────────────────
    function getSortedRows() {
        if (!rows) return [];
        if (!sortColumn) return rows;
        var sorted = rows.slice(0);
        sorted.sort(function(a, b) {
            var valA = a[sortColumn], valB = b[sortColumn];
            if (valA === undefined || valA === null) valA = "";
            if (valB === undefined || valB === null) valB = "";

            // Brazilian currency
            if (typeof valA === "string" && valA.indexOf("R$") !== -1)
                valA = parseFloat(valA.replace("R$","").replace(/\./g,"").replace(",",".").trim());
            if (typeof valB === "string" && valB.indexOf("R$") !== -1)
                valB = parseFloat(valB.replace("R$","").replace(/\./g,"").replace(",",".").trim());

            if (!isNaN(valA) && !isNaN(valB) && typeof valA !== "string" && typeof valB !== "string")
                return sortOrder === "asc" ? valA - valB : valB - valA;

            var numA = Number(valA), numB = Number(valB);
            if (!isNaN(numA) && !isNaN(numB) && valA !== "" && valB !== "")
                return sortOrder === "asc" ? numA - numB : numB - numA;

            var strA = String(valA).toLowerCase(), strB = String(valB).toLowerCase();
            if (strA < strB) return sortOrder === "asc" ? -1 : 1;
            if (strA > strB) return sortOrder === "asc" ?  1 : -1;
            return 0;
        });
        return sorted;
    }

    readonly property var paginatedRows: {
        var sorted = getSortedRows();
        if (!showPagination) return sorted;
        var start = (currentPage - 1) * pageSize;
        var end   = Math.min(start + pageSize, totalRecords);
        return sorted.slice(start, end);
    }

    onTotalPagesChanged: {
        if (currentPage > totalPages) currentPage = Math.max(1, totalPages);
    }

    // ── Selection helpers ─────────────────────────────────────────────────────
    function toggleRowSelection(rowIndex) {
        var indexes = selectedIndexes.slice(0);
        var idx = indexes.indexOf(rowIndex);
        if (idx !== -1) indexes.splice(idx, 1);
        else indexes.push(rowIndex);
        selectedIndexes = indexes;
        root.selectionChanged(selectedIndexes);
    }

    function toggleSelectAll() {
        if (isAllSelected) {
            selectedIndexes = [];
        } else {
            var indexes = [];
            for (var i = 0; i < totalRecords; i++) indexes.push(i);
            selectedIndexes = indexes;
        }
        root.selectionChanged(selectedIndexes);
    }

    function getSelectedRowsObjects() {
        var selected = [];
        for (var i = 0; i < selectedIndexes.length; i++) {
            var idx = selectedIndexes[i];
            if (idx >= 0 && idx < rows.length) selected.push(rows[idx]);
        }
        return selected;
    }

    function handleHeaderClick(col) {
        if (!col.sortable) return;
        if (sortColumn === col.name) sortOrder = sortOrder === "asc" ? "desc" : "asc";
        else { sortColumn = col.name; sortOrder = "asc"; }
        root.sortChanged(sortColumn, sortOrder);
    }

    // ── Dimensions ────────────────────────────────────────────────────────────
    implicitWidth:  800
    implicitHeight: 450
    width:  implicitWidth
    height: implicitHeight

    // Shared horizontal scroll offset — header and body stay in sync
    property real sharedContentX: 0
    readonly property real sharedContentWidth: Math.max(root.width, root.minContentWidth)

    // ==========================================
    // Visual Tree
    // ==========================================
    Column {
        anchors.fill: parent
        spacing: 0

        // ── 1. Selection Toolbar ──────────────────────────────────────────────
        Rectangle {
            id: selectionToolbar
            width:  parent.width
            height: root.selectedIndexes.length > 0 ? 46 : 0
            color:  Theme.colors.mantle
            border.color: Theme.colors.surface1
            border.width: Theme.geometry.borderSm
            radius: Theme.geometry.radiusMd
            clip: true
            z: 10
            opacity: root.selectedIndexes.length > 0 ? 1.0 : 0.0

            Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutQuad } }
            Behavior on opacity { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

            Row {
                anchors.fill: parent
                anchors.leftMargin:  Theme.spacing.lg
                anchors.rightMargin: Theme.spacing.lg
                spacing: Theme.spacing.md

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.sm
                    LucideIcon {
                        name: "check"; size: 16; color: Theme.colors.primary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.selectedIndexes.length + " selecionados"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.text
                        anchors.verticalCenter: parent.verticalCenter
                        antialiasing: true
                    }
                }

                Item {
                    height: 1
                    width: parent.width
                           - (parent.children[0].width + parent.children[2].width
                              + Theme.spacing.lg * 2 + Theme.spacing.md)
                }

                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.sm

                    Button { variant:"ghost"; size:"sm"; icon:"edit";     customRadius:Theme.geometry.radiusPill; onClicked: root.editSelected(root.getSelectedRowsObjects()) }
                    Button { variant:"ghost"; size:"sm"; icon:"download"; customRadius:Theme.geometry.radiusPill; onClicked: root.downloadSelected(root.getSelectedRowsObjects()) }
                    Button { variant:"ghost"; size:"sm"; icon:"trash-2";  customRadius:Theme.geometry.radiusPill; onClicked: root.deleteSelected(root.getSelectedRowsObjects()) }

                    Rectangle { width:1; height:20; color:Theme.colors.surface1; anchors.verticalCenter:parent.verticalCenter }

                    Button { variant:"ghost"; size:"sm"; icon:"x"; customRadius:Theme.geometry.radiusPill; onClicked: root.selectedIndexes = [] }
                }
            }
        }

        Item { width: parent.width; height: root.selectedIndexes.length > 0 ? Theme.spacing.sm : 0 }

        // ── 2. Outer wrapper: header card + gap + body card ───────────────────
        Item {
            id: tableArea
            width: parent.width
            height: parent.height
                    - selectionToolbar.height
                    - (root.selectedIndexes.length > 0 ? Theme.spacing.sm : 0)
                    - (root.showPagination ? 50 : 0)

            // ── 2a. HEADER CARD ───────────────────────────────────────────────
            Rectangle {
                id: headerCard
                anchors.top:   parent.top
                anchors.left:  parent.left
                anchors.right: parent.right
                height: 44
                color:  Theme.colors.mantle
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm
                radius: Theme.geometry.radiusMd
                clip: true
                z: 5

                // Clip inner content to rounded corners
                Item {
                    anchors.fill: parent
                    // We shift the inner Row by sharedContentX to mirror horizontal scroll
                    Item {
                        id: headerInner
                        x: -root.sharedContentX
                        width:  root.sharedContentWidth
                        height: parent.height

                        Row {
                            anchors.fill: parent
                            spacing: 0

                            // Drag handle spacer
                            Item {
                                width:   root.dragHandleWidth
                                height:  parent.height
                                visible: root.dragToReorder
                            }

                            // Checkbox header cell
                            Item {
                                id: headerCheckboxContainer
                                width:  root.checkboxColWidth
                                height: parent.height
                                visible: root.selectable

                                Rectangle {
                                    width: 18; height: 18
                                    anchors.centerIn: parent
                                    radius: Theme.geometry.radiusSm
                                    color: (root.isAllSelected || root.isSelectionIndeterminate)
                                           ? Theme.colors.primary : "transparent"
                                    border.color: (root.isAllSelected || root.isSelectionIndeterminate)
                                                  ? Theme.colors.primary : Theme.colors.surface2
                                    border.width: (root.isAllSelected || root.isSelectionIndeterminate)
                                                  ? 0 : Theme.geometry.borderSm
                                    scale: headerCheckboxMouse.pressed ? 0.92 : (headerCheckboxMouse.containsMouse ? 1.06 : 1.0)

                                    Behavior on color { ColorAnimation { duration: 120 } }
                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                                    LucideIcon {
                                        name: root.isSelectionIndeterminate ? "minus" : "check"
                                        size: 12; color: Theme.colors.crust
                                        anchors.centerIn: parent
                                        visible: root.isAllSelected || root.isSelectionIndeterminate
                                    }
                                    MouseArea {
                                        id: headerCheckboxMouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.toggleSelectAll()
                                    }
                                }
                            }

                            // Column header cells
                            Repeater {
                                model: root.columns
                                delegate: Item {
                                    id: headerCell
                                    width:  root.getColWidth(modelData, index)
                                    height: headerCard.height
                                    readonly property bool isActiveSort: root.sortColumn === modelData.name
                                    scale: headerMouseArea.pressed ? 0.985 : 1.0

                                    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                                    Rectangle {
                                        anchors.fill: parent
                                        color: headerMouseArea.containsMouse
                                               ? Theme.colors.surface0 : "transparent"
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }

                                    // Column separator
                                    Rectangle {
                                        anchors.right:        parent.right
                                        anchors.top:          parent.top
                                        anchors.bottom:       parent.bottom
                                        anchors.topMargin:    8
                                        anchors.bottomMargin: 8
                                        width: 1
                                        color: Theme.colors.surface1
                                        visible: index < root.columns.length - 1
                                    }

                                    // Label + sort icon
                                    Row {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left:           parent.left
                                        anchors.leftMargin:     Theme.spacing.md
                                        spacing: Theme.spacing.xs

                                        Text {
                                            text: modelData.label
                                            font.family:    Theme.typography.familyBold
                                            font.pixelSize: Theme.typography.sizeSm
                                            color: headerCell.isActiveSort
                                                   ? Theme.colors.primary : Theme.colors.subtext1
                                            antialiasing: true
                                            Behavior on color { ColorAnimation { duration: 150 } }
                                        }
                                        LucideIcon {
                                            name: root.sortOrder === "asc" ? "chevron-up" : "chevron-down"
                                            size: 12; color: Theme.colors.primary
                                            visible: headerCell.isActiveSort
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }

                                    // Active sort underline
                                    Rectangle {
                                        anchors.bottom:            parent.bottom
                                        anchors.horizontalCenter:  parent.horizontalCenter
                                        width:  parent.width - Theme.spacing.md * 2
                                        height: 2
                                        color:  Theme.colors.primary
                                        visible: headerCell.isActiveSort || headerMouseArea.containsMouse
                                        opacity: headerCell.isActiveSort ? 1.0 : (headerMouseArea.containsMouse ? 0.35 : 0.0)

                                        Behavior on opacity { NumberAnimation { duration: 120 } }
                                    }

                                    MouseArea {
                                        id: headerMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        enabled:     !!modelData.sortable
                                        cursorShape: !!modelData.sortable
                                                     ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: root.handleHeaderClick(modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ── Gap between header and body ───────────────────────────────────
            readonly property int headerBodyGap: 6

            // ── 2b. BODY CARD ─────────────────────────────────────────────────
            Rectangle {
                id: bodyCard
                anchors.top:    parent.top
                anchors.topMargin: headerCard.height + parent.headerBodyGap
                anchors.left:  parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color:  Theme.colors.base
                radius: Theme.geometry.radiusMd
                clip: true

                ListView {
                    id: bodyFlickable
                    anchors.fill: parent
                    contentWidth:  root.sharedContentWidth
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    spacing: 0

                    // Keep header in sync with horizontal scroll
                    onContentXChanged: root.sharedContentX = contentX
                    
                    // Empty state as footer
                    footer: Item {
                        width:   bodyFlickable.contentWidth
                        height:  (root.paginatedRows && root.paginatedRows.length === 0) ? 120 : 0
                        visible: root.paginatedRows && root.paginatedRows.length === 0

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacing.sm

                            LucideIcon {
                                name: "inbox"; size: 32; color: Theme.colors.overlay0
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                            Text {
                                text: "Nenhum registro encontrado"
                                font.family:    Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.overlay0
                                anchors.horizontalCenter: parent.horizontalCenter
                                antialiasing: true
                            }
                        }
                    }

                    model: DelegateModel {
                        id: visualModel
                        model: root.paginatedRows

                        delegate: DropArea {
                            id: dropArea
                            width:  bodyFlickable.contentWidth
                            height: 48
                            keys: ["table-row"]

                            property int visualIndex: DelegateModel.itemsIndex

                            onEntered: function(drag) {
                                var sourceIndex = drag.source.__startIndex;
                                var targetIndex = dropArea.visualIndex;
                                if (sourceIndex !== targetIndex) {
                                    visualModel.items.move(sourceIndex, targetIndex);
                                    drag.source.__startIndex = targetIndex;
                                }
                            }

                            Rectangle {
                                id: rowRect
                                width:  parent.width
                                height: parent.height

                                readonly property var rowData: typeof modelData !== "undefined" ? modelData : null
                                readonly property int globalIndex: root.showPagination
                                    ? (root.currentPage - 1) * root.pageSize + index
                                    : index
                                readonly property bool isRowSelected:
                                    root.selectedIndexes.indexOf(globalIndex) !== -1

                                color: {
                                    if (rowRect.held) return Theme.colors.surface0;
                                    if (rowMouseArea.containsMouse) return Theme.colors.surface0;
                                    if (isRowSelected) return Qt.rgba(
                                        Theme.colors.primary.r,
                                        Theme.colors.primary.g,
                                        Theme.colors.primary.b, 0.08);
                                    return "transparent";
                                }
                                
                                property bool held: false
                                scale: held ? 1.02 : (rowMouseArea.pressed ? 0.995 : 1.0)
                                opacity: held ? 0.8 : 1.0
                                z: held ? 100 : 0

                                // Bottom separator
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left:   parent.left
                                    anchors.right:  parent.right
                                    height: 1
                                    color: Theme.colors.surface0
                                }

                                Behavior on color { ColorAnimation { duration: 120 } }
                                Behavior on scale { NumberAnimation { duration: 90; easing.type: Easing.OutCubic } }
                                Behavior on opacity { NumberAnimation { duration: 90 } }

                                Row {
                                    anchors.fill: parent
                                    spacing: 0
                                    
                                    // Drag handle cell
                                    Item {
                                        id: dragHandleContainer
                                        width:   root.dragHandleWidth
                                        height:  parent.height
                                        visible: root.dragToReorder
                                        
                                        LucideIcon {
                                            name: "grip-vertical"
                                            size: 16
                                            color: Theme.colors.overlay0
                                            anchors.centerIn: parent
                                        }
                                        
                                        MouseArea {
                                            id: dragMouseArea
                                            anchors.fill: parent
                                            cursorShape: Qt.OpenHandCursor
                                        }
                                        
                                        DragHandler {
                                            id: dragHandler
                                            target: null
                                            
                                            property int _originalIndex: -1
                                            property real _startX: 0
                                            property real _startY: 0
                                            
                                            onActiveChanged: {
                                                if (active) {
                                                    rowRect.held = true
                                                    _startX = dropArea.mapToItem(bodyFlickable.contentItem, 0, 0).x
                                                    _startY = dropArea.mapToItem(bodyFlickable.contentItem, 0, 0).y
                                                    dragGhost.x = _startX
                                                    dragGhost.y = _startY
                                                    dragGhost.visible = true
                                                    dragGhost.__startIndex = dropArea.visualIndex
                                                    _originalIndex = index // Data array index
                                                    
                                                    dragGhost.Drag.active = true
                                                } else {
                                                    rowRect.held = false
                                                    dragGhost.Drag.active = false
                                                    dragGhost.visible = false
                                                    
                                                    var finalIdx = dropArea.visualIndex;
                                                    if (_originalIndex !== finalIdx) {
                                                        visualModel.items.move(finalIdx, _originalIndex);
                                                        Qt.callLater(function() {
                                                            root.rowsReordered(_originalIndex, finalIdx);
                                                        });
                                                    }
                                                }
                                            }
                                            
                                            onTranslationChanged: {
                                                if (active) {
                                                    dragGhost.y = _startY + translation.y
                                                    dragGhost.x = _startX + translation.x
                                                }
                                            }
                                        }
                                    }


                                    // Checkbox cell
                                    Item {
                                        id: cellCheckboxContainer
                                        width:   root.checkboxColWidth
                                        height:  parent.height
                                        visible: root.selectable

                                        Rectangle {
                                            width: 18; height: 18
                                            anchors.centerIn: parent
                                            radius: Theme.geometry.radiusSm
                                            color: rowRect.isRowSelected
                                                   ? Theme.colors.primary : "transparent"
                                            border.color: rowRect.isRowSelected
                                                          ? Theme.colors.primary : Theme.colors.surface2
                                            border.width: rowRect.isRowSelected
                                                          ? 0 : Theme.geometry.borderSm
                                            scale: checkboxMouse.pressed ? 0.92 : (checkboxMouse.containsMouse ? 1.06 : 1.0)

                                            Behavior on color { ColorAnimation { duration: 120 } }
                                            Behavior on border.color { ColorAnimation { duration: 120 } }
                                            Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }

                                            LucideIcon {
                                                name: "check"; size: 12; color: Theme.colors.crust
                                                anchors.centerIn: parent
                                                visible: rowRect.isRowSelected
                                            }
                                            MouseArea {
                                                id: checkboxMouse
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    mouse.accepted = true;
                                                    root.toggleRowSelection(rowRect.globalIndex);
                                                }
                                            }
                                        }
                                    }

                                    // Data cells
                                    Repeater {
                                        model: root.columns
                                        delegate: Item {
                                            id: cellItem
                                            width:  root.getColWidth(modelData, index)
                                            height: rowRect.height

                                            // Column separator
                                            Rectangle {
                                                anchors.right:        parent.right
                                                anchors.top:          parent.top
                                                anchors.bottom:       parent.bottom
                                                anchors.topMargin:    10
                                                anchors.bottomMargin: 10
                                                width: 1
                                                color: Theme.colors.surface0
                                                visible: index < root.columns.length - 1
                                            }

                                            readonly property string cellValue: {
                                                var val = (rowRect.rowData && modelData.name)
                                                          ? rowRect.rowData[modelData.name] : "";
                                                return (val !== undefined && val !== null)
                                                       ? String(val) : "";
                                            }

                                            Loader {
                                                id: cellLoader
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left:           parent.left
                                                anchors.leftMargin:     Theme.spacing.md
                                                width: parent.width - Theme.spacing.md * 2

                                                sourceComponent: modelData.type === "badge"
                                                                 ? badgeCellComponent : textCellComponent

                                                readonly property string textValue: cellItem.cellValue
                                                readonly property bool   fontBold:  modelData.type === "bold"
                                                readonly property color  textColor: {
                                                    if (modelData.type === "subtext") return Theme.colors.subtext0;
                                                    if (modelData.type === "bold")    return Theme.colors.text;
                                                    return Theme.colors.subtext1;
                                                }
                                            }
                                        }
                                    }
                                }

                                // Row click (lower z so checkbox wins)
                                MouseArea {
                                    id: rowMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    z: -1
                                    onClicked: root.toggleRowSelection(rowRect.globalIndex)
                                }
                            } // rowRect
                        } // DropArea
                    } // DelegateModel
                    
                    // The Ghost Item for Dragging
                    Item {
                        id: dragGhost
                        width: bodyFlickable.contentWidth
                        height: 48
                        visible: false
                        z: 999
                        
                        property int __startIndex: -1
                        
                        Drag.active: false
                        Drag.keys: ["table-row"]
                        Drag.hotSpot.x: width / 2
                        Drag.hotSpot.y: height / 2
                        
                        Rectangle {
                            anchors.fill: parent
                            color: Theme.colors.surface0
                            radius: Theme.geometry.radiusSm
                            border.color: Theme.colors.primary
                            border.width: 1
                            opacity: 0.9
                            
                            Row {
                                anchors.fill: parent
                                anchors.leftMargin: Theme.spacing.sm
                                spacing: Theme.spacing.md
                                
                                LucideIcon {
                                    name: "grip-vertical"
                                    size: 16
                                    color: Theme.colors.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                                Text {
                                    text: "Arrastando linha..."
                                    font.family: Theme.typography.family
                                    font.pixelSize: Theme.typography.sizeMd
                                    color: Theme.colors.text
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                } // ListView
            }
        }

        // Space above footer
        Item { width: parent.width; height: root.showPagination ? Theme.spacing.md : 0 }

        // ── 3. Footer (Pagination) ────────────────────────────────────────────
        Rectangle {
            width:   parent.width
            height:  34
            color:   "transparent"
            visible: root.showPagination

            Row {
                id: footerLeftRow
                anchors.left:           parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.md

                ItemsPerPage {
                    pageSize: root.pageSize
                    options: [5, 10, 20, 50]
                    anchors.verticalCenter: parent.verticalCenter
                    onPageSizeChanged: root.pageSize = pageSize
                }

                Text {
                    text: "Total de registros: " + root.totalRecords
                    font.family:    Theme.typography.family
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.subtext0
                    anchors.verticalCenter: parent.verticalCenter
                    antialiasing: true
                }
            }

            Paginator {
                currentPage: root.currentPage
                totalPages:  root.totalPages
                anchors.right:          parent.right
                anchors.verticalCenter: parent.verticalCenter
                onPageChanged: root.currentPage = page
            }
        }
    }

    // ==========================================
    // Cell Component Templates
    // ==========================================
    Component {
        id: textCellComponent
        Text {
            text:           parent ? parent.textValue : ""
            font.family:    (parent && parent.fontBold) ? Theme.typography.familyBold : Theme.typography.family
            font.pixelSize: Theme.typography.sizeMd
            color:          (parent && parent.textColor) ? parent.textColor : Theme.colors.text
            elide: Text.ElideRight
            width: parent ? parent.width : 0
            antialiasing: true
        }
    }

    Component {
        id: badgeCellComponent
        Badge {
            text: parent ? parent.textValue : ""
            variant: {
                var v = String(text).toLowerCase();
                if (v === "ativo"    || v === "active"   || v === "sucesso")   return "success";
                if (v === "pendente" || v === "pending")                       return "warning";
                if (v === "inativo"  || v === "inactive" || v === "cancelado") return "danger";
                return "primary";
            }
        }
    }
}
