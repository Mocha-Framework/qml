import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    property var columns: []
    property var rows: []
    property var selectedIndexes: []

    // Sorting
    property string sortColumn: ""
    property string sortOrder: "asc"  // "asc" | "desc"

    // Selection
    property bool selectable: true

    // ==========================================
    // Signals
    // ==========================================
    signal selectionChanged(var indexes)
    signal sortChanged(string column, string order)
    signal rowToggled(var rowData, bool isExpanded)

    // ==========================================
    // Internal State
    // ==========================================
    property var flatRows: []
    property var _expandedMap: ({})

    onRowsChanged: rebuildFlatRows()
    onSortColumnChanged: rebuildFlatRows()
    onSortOrderChanged: rebuildFlatRows()

    function toggleNode(node) {
        var nodeId = node.id || node.name;
        var isExp = !!_expandedMap[nodeId];
        _expandedMap[nodeId] = !isExp;
        rebuildFlatRows();
        rowToggled(node, !isExp);
    }

    function sortNodes(nodes) {
        if (!sortColumn) return nodes;
        var sorted = nodes.slice(0);
        sorted.sort(function(a, b) {
            var valA = a[sortColumn], valB = b[sortColumn];
            if (valA === undefined || valA === null) valA = "";
            if (valB === undefined || valB === null) valB = "";

            if (typeof valA === "string" && valA.indexOf("R$") !== -1)
                valA = parseFloat(valA.replace("R$","").replace(/\./g,"").replace(",",".").trim());
            if (typeof valB === "string" && valB.indexOf("R$") !== -1)
                valB = parseFloat(valB.replace("R$","").replace(/\./g,"").replace(",",".").trim());

            if (!isNaN(valA) && !isNaN(valB) && typeof valA !== "string" && typeof valB !== "string")
                return sortOrder === "asc" ? valA - valB : valB - valA;

            var numA = Number(valA), numB = Number(valB);
            if (!isNaN(numA) && !isNaN(numB) && valA !== "" && valB !== "")
                return sortOrder === "asc" ? numA - numB : numB - numA;

            valA = String(valA).toLowerCase();
            valB = String(valB).toLowerCase();
            if (valA < valB) return sortOrder === "asc" ? -1 : 1;
            if (valA > valB) return sortOrder === "asc" ? 1 : -1;
            return 0;
        });
        return sorted;
    }

    function rebuildFlatRows() {
        var arr = [];
        
        function traverse(nodes, depth) {
            if (!nodes) return;
            var processedNodes = sortNodes(nodes);
            
            for (var i = 0; i < processedNodes.length; i++) {
                var node = processedNodes[i];
                var nodeId = node.id || node.name;
                node._treeDepth = depth;
                node._hasChildren = !!(node.children && node.children.length > 0);
                node._isExpanded = !!root._expandedMap[nodeId];
                
                arr.push(node);
                
                if (node._isExpanded && node._hasChildren) {
                    traverse(node.children, depth + 1);
                }
            }
        }
        
        traverse(root.rows, 0);
        flatRows = arr;
    }

    function toggleRowSelection(globalIndex) {
        var idx = selectedIndexes.indexOf(globalIndex);
        var newSel = selectedIndexes.slice();
        if (idx === -1) newSel.push(globalIndex);
        else newSel.splice(idx, 1);
        selectedIndexes = newSel;
        selectionChanged(selectedIndexes);
    }

    function handleHeaderClick(colData) {
        if (!colData.sortable) return;
        if (sortColumn === colData.name) {
            if (sortOrder === "asc") sortOrder = "desc";
            else { sortColumn = ""; sortOrder = "asc"; }
        } else {
            sortColumn = colData.name;
            sortOrder = "asc";
        }
        sortChanged(sortColumn, sortOrder);
    }

    // ==========================================
    // Computed Properties for Layout
    // ==========================================
    readonly property int totalRecords: flatRows.length
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

    readonly property int checkboxColWidth: selectable ? 44 : 0
    readonly property real minContentWidth: checkboxColWidth + baseColumnsWidth

    function getColWidth(col, idx) {
        var baseW = col.width || 120;
        var avail = root.width - checkboxColWidth;
        if (avail > baseColumnsWidth && baseColumnsWidth > 0)
            return (baseW / baseColumnsWidth) * avail;
        return baseW;
    }

    property real sharedContentX: 0
    property real sharedContentWidth: Math.max(root.width, minContentWidth)

    // ==========================================
    // Cell Delegates
    // ==========================================
    Component {
        id: textCellComponent
        Text {
            text: textValue
            font.family: Theme.typography.family
            font.pixelSize: Theme.typography.sizeMd
            font.bold: fontBold
            color: textColor
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            anchors.fill: parent
        }
    }

    Component {
        id: badgeCellComponent
        Item {
            anchors.fill: parent
            Badge {
                text: textValue
                anchors.verticalCenter: parent.verticalCenter
                variant: {
                    var l = textValue.toLowerCase();
                    if (l === "ativo" || l === "concluído" || l === "sucesso") return "success";
                    if (l === "pendente" || l === "em andamento" || l === "aviso") return "warning";
                    if (l === "inativo" || l === "erro" || l === "falha") return "danger";
                    return "neutral";
                }
            }
        }
    }

    // ==========================================
    // Main UI
    // ==========================================
    Item {
        anchors.fill: parent

        // ── 1. HEADER CARD ──────────────────────────────────────────────────
        Rectangle {
            id: headerCard
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            height: 48
            color:  Theme.colors.base
            radius: Theme.geometry.radiusMd
            clip: true

            Flickable {
                id: headerFlickable
                anchors.fill: parent
                contentWidth:  root.sharedContentWidth
                contentHeight: parent.height
                boundsBehavior: Flickable.StopAtBounds
                interactive: false
                contentX: root.sharedContentX

                Rectangle {
                    width:  headerFlickable.contentWidth
                    height: parent.height
                    color:  "transparent"

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width; height: 1
                        color: Theme.colors.surface0
                    }

                    Row {
                        anchors.fill: parent
                        spacing: 0

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
                                    onClicked: function(mouse) {
                                        mouse.accepted = true;
                                        if (root.isAllSelected) {
                                            root.selectedIndexes = [];
                                        } else {
                                            var all = [];
                                            for (var i = 0; i < root.totalRecords; i++) {
                                                all.push(i);
                                            }
                                            root.selectedIndexes = all;
                                        }
                                        root.selectionChanged(root.selectedIndexes);
                                    }
                                }
                            }
                        }

                        // Column headers
                        Repeater {
                            model: root.columns
                            delegate: Item {
                                width:  root.getColWidth(modelData, index)
                                height: parent.height

                                Row {
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.left:           parent.left
                                    anchors.leftMargin:     Theme.spacing.md
                                    spacing: Theme.spacing.xs

                                    Text {
                                        text: modelData.label || modelData.name
                                        font.family: Theme.typography.family
                                        font.pixelSize: Theme.typography.sizeSm
                                        font.bold: true
                                        color: Theme.colors.subtext0
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    LucideIcon {
                                        name: root.sortOrder === "asc" ? "chevron-up" : "chevron-down"
                                        size: 14
                                        color: Theme.colors.primary
                                        anchors.verticalCenter: parent.verticalCenter
                                        visible: root.sortColumn === modelData.name
                                    }
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

        // ── 2. BODY CARD ────────────────────────────────────────────────────
        Rectangle {
            id: bodyCard
            anchors.top:    headerCard.bottom
            anchors.topMargin: 6
            anchors.left:  parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color:  Theme.colors.base
            radius: Theme.geometry.radiusMd
            clip: true

            ListView {
                id: bodyListView
                anchors.fill: parent
                contentWidth:  root.sharedContentWidth
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                spacing: 0

                onContentXChanged: root.sharedContentX = contentX

                footer: Item {
                    width:   bodyListView.contentWidth
                    height:  root.flatRows.length === 0 ? 120 : 0
                    visible: root.flatRows.length === 0

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
                        }
                    }
                }

                model: root.flatRows

                delegate: Rectangle {
                    id: rowRect
                    width:  bodyListView.contentWidth
                    height: 48

                    readonly property var rowData: modelData
                    readonly property int globalIndex: index
                    readonly property bool isRowSelected:
                        root.selectedIndexes.indexOf(globalIndex) !== -1

                    color: {
                        if (rowMouseArea.containsMouse) return Theme.colors.surface0;
                        if (isRowSelected) return Qt.rgba(
                            Theme.colors.primary.r,
                            Theme.colors.primary.g,
                            Theme.colors.primary.b, 0.08);
                        return "transparent";
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        height: 1
                        color: Theme.colors.surface0
                    }

                    Behavior on color { ColorAnimation { duration: 120 } }

                    Row {
                        anchors.fill: parent
                        spacing: 0

                        // Checkbox cell
                        Item {
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
                                    onClicked: function(mouse) {
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

                                Item {
                                    anchors.fill: parent
                                    
                                    // ── Tree indentation & chevron (only in first column) ──
                                    Row {
                                        id: treeContentRow
                                        anchors.fill: parent
                                        anchors.leftMargin: Theme.spacing.md + (index === 0 ? (rowData._treeDepth || 0) * 24 : 0)
                                        spacing: Theme.spacing.xs
                                        
                                        Item {
                                            width: 20
                                            height: parent.height
                                            visible: index === 0
                                            
                                            LucideIcon {
                                                name: rowData._isExpanded ? "chevron-down" : "chevron-right"
                                                size: 16
                                                color: Theme.colors.overlay0
                                                anchors.centerIn: parent
                                                visible: rowData._hasChildren
                                                
                                                MouseArea {
                                                    anchors.fill: parent
                                                    anchors.margins: -4
                                                    cursorShape: Qt.PointingHandCursor
                                                    onClicked: function(mouse) {
                                                        mouse.accepted = true;
                                                        root.toggleNode(rowRect.rowData);
                                                    }
                                                }
                                            }
                                        }

                                        Loader {
                                            id: cellLoader
                                            width: parent.width - treeContentRow.anchors.leftMargin - (index === 0 ? 20 + treeContentRow.spacing : 0)
                                            height: parent.height

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
                        }
                    }

                    MouseArea {
                        id: rowMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        z: -1
                        onClicked: {
                            // Clicar na linha também expande/colapsa se tiver filhos
                            if (rowRect.rowData._hasChildren) {
                                root.toggleNode(rowRect.rowData);
                            } else {
                                root.toggleRowSelection(rowRect.globalIndex);
                            }
                        }
                    }
                }
            }
        }
    }
}
