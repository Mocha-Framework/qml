import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // ── Data ───────────────────────────────────────
    property var model: null
    property Component delegate: null

    // ── Sortable ───────────────────────────────────
    property bool sortable: false
    property string sortableDragKey: "mochads-datagrid"
    readonly property int dragIndex: _dragIndex
    readonly property int dragTargetIndex: _dragTargetIndex
    property bool isDragging: false

    signal itemsReordered(int fromIndex, int toIndex)

    // ── Columns (responsive) ───────────────────────
    property int columns: 3
    property int columnsSm: -1
    property int columnsMd: -1
    property int columnsLg: -1

    readonly property int cols: {
        var w = root.width
        if (w <= 0) return 1
        if (columnsSm > 0 && w < 640) return columnsSm
        if (columnsMd > 0 && w < 768) return columnsMd
        if (columnsLg > 0 && w < 1024) return columnsLg
        return Math.max(1, columns)
    }

    // ── Sizing ─────────────────────────────────────
    property real aspectRatio: 1.0

    // ── Spacing ────────────────────────────────────
    property var gap: "md"
    property real pad: 0

    readonly property real _gapPx: _resolve(gap)
    readonly property real _padPx: pad

    // ── State ──────────────────────────────────────
    readonly property bool isEmpty: _modelCount === 0
    property bool isLoading: false
    property int skeletonCount: 6
    property string emptyStateTitle: "Nenhum item"
    property string emptyStateSubtitle: ""

    // ── Signals ────────────────────────────────────
    signal itemClicked(var modelData, int index)

    // ── Internal ───────────────────────────────────
    readonly property int _modelCount: {
        if (!model) return 0
        if (Array.isArray(model)) return model.length
        if (typeof model === "number") return model
        if (model.count !== undefined) return model.count
        if (model.length !== undefined) return model.length
        return 0
    }

    property int _dragIndex: -1
    property int _dragTargetIndex: -1
    property real _layoutHeight: 0
    implicitHeight: 0
    clip: true

    onWidthChanged: Qt.callLater(_doLayout)
    onColsChanged: Qt.callLater(_doLayout)
    on_GapPxChanged: Qt.callLater(_doLayout)
    on_PadPxChanged: Qt.callLater(_doLayout)
    onAspectRatioChanged: Qt.callLater(_doLayout)

    // ── Spacing resolver ───────────────────────────
    function _resolve(v) {
        if (typeof v === "number") return v
        if (v === "xs") return Theme.spacing.xs
        if (v === "sm") return Theme.spacing.sm
        if (v === "md") return Theme.spacing.md
        if (v === "lg") return Theme.spacing.lg
        if (v === "xl") return Theme.spacing.xl
        if (v === "xxl") return Theme.spacing.xxl
        return Theme.spacing.md
    }

    // ── Layout engine ──────────────────────────────
    function _doLayout() {
        var c = cols
        var g = _gapPx
        var p = _padPx
        var w = flick.width - 2 * p
        var total = itemRepeater.count

        if (c <= 0 || w <= 0 || total <= 0) {
            root._layoutHeight = 0
            root.implicitHeight = 0
            return
        }

        var cellW = (w - (c - 1) * g) / c
        var cellH = aspectRatio > 0 ? cellW / aspectRatio : cellW

        for (var i = 0; i < total; i++) {
            var item = itemRepeater.itemAt(i)
            if (!item) continue
            item.x = p + (i % c) * (cellW + g)
            item.y = p + Math.floor(i / c) * (cellH + g)
            item.width = cellW
            item.height = cellH
        }

        var rows = Math.ceil(total / c)
        var th = 2 * p + rows * cellH + Math.max(0, rows - 1) * g
        root._layoutHeight = th
        root.implicitHeight = th
    }

    // ── DelegateModel ──────────────────────────────
    Component {
        id: cellWrapper
        Item {
            id: cellRoot
            clip: true
            property bool held: false

            scale: held && root.sortable ? 1.05 : 1.0
            opacity: held && root.sortable ? 0.85 : 1.0
            z: held && root.sortable ? 100 : 0

            Behavior on x {
                enabled: root.sortable
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }
            Behavior on y {
                enabled: root.sortable
                NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
            }
            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 150 } }

            property int cellIndex: index
            property var cellData: typeof modelData !== "undefined" ? modelData : model

            // ── Content loader (like SortableList) ──
            Loader {
                id: loader
                anchors.fill: parent
                sourceComponent: root.delegate

                property var modelData: cellRoot.cellData
                property int modelIndex: cellRoot.cellIndex
            }

            MouseArea {
                anchors.fill: parent
                enabled: !root.sortable
                cursorShape: root.sortable ? Qt.OpenHandCursor : Qt.PointingHandCursor
                onClicked: root.itemClicked(cellRoot.cellData, cellRoot.cellIndex)
            }

            // ── Drag Handler (like SortableList) ────
            DragHandler {
                id: dragHandler
                target: null
                enabled: root.sortable
                dragThreshold: 8
                acceptedButtons: Qt.LeftButton
                cursorShape: active ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                onActiveChanged: {
                    if (active) {
                        cellRoot.held = true
                        root.isDragging = true
                        root._dragIndex = cellRoot.cellIndex
                        root._dragTargetIndex = cellRoot.cellIndex
                        dragGhost.Drag.active = true
                        dragGhost.__sourceIndex = cellRoot.cellIndex
                        dragGhost.visible = true

                        var pos = cellRoot.mapToItem(root, centroid.position.x, centroid.position.y)
                        dragGhost.x = pos.x - dragGhost.width / 2
                        dragGhost.y = pos.y - dragGhost.height / 2
                    } else {
                        cellRoot.held = false
                        var fromIndex = root._dragIndex
                        var targetIdx = root._dragTargetIndex

                        dragGhost.visible = false
                        dragGhost.Drag.drop()
                        dragGhost.Drag.active = false
                        root.isDragging = false

                        if (targetIdx >= 0 && targetIdx !== fromIndex) {
                            visualModel.items.move(fromIndex, targetIdx)
                            Qt.callLater(function() {
                                for (var j = 0; j < itemRepeater.count; j++) {
                                    var cell = itemRepeater.itemAt(j)
                                    if (!cell) continue
                                    cell.cellIndex = j
                                    if (cell.loader) cell.loader.modelIndex = j
                                }
                                _doLayout()
                                root.itemsReordered(fromIndex, targetIdx)
                            })
                        }

                        root._dragIndex = -1
                        root._dragTargetIndex = -1
                    }
                }

                onTranslationChanged: {
                    if (active) {
                        var pos = cellRoot.mapToItem(root, centroid.position.x, centroid.position.y)
                        dragGhost.x = pos.x - dragGhost.width / 2
                        dragGhost.y = pos.y - dragGhost.height / 2
                    }
                }
            }

            // ── Drop Area (like SortableList) ───────
            DropArea {
                id: dropArea
                anchors.fill: parent
                anchors.topMargin: -4
                anchors.bottomMargin: -4
                keys: root.sortable ? [root.sortableDragKey] : []

                onEntered: function(drag) {
                    if (!root.sortable) return
                    root._dragTargetIndex = cellRoot.cellIndex
                }
                onExited: {
                    if (!root.sortable) return
                    root._dragTargetIndex = -1
                }
            }

            // ── Drop highlight ──────────────────────
            Rectangle {
                anchors.fill: parent
                color: Theme.colors.primary
                opacity: root.sortable && dropArea.containsDrag ? 0.2 : 0
                border.color: Theme.colors.primary
                border.width: root.sortable && dropArea.containsDrag ? 2 : 0
                radius: Theme.geometry.radiusSm
                z: 10
                Behavior on opacity { NumberAnimation { duration: 150 } }
                Behavior on border.width { NumberAnimation { duration: 150 } }
            }
        }
    }

    DelegateModel {
        id: visualModel
        model: root.model
        delegate: cellWrapper
    }

    Item {
        id: dragGhost
        property int __sourceIndex: -1
        visible: root.isDragging
        width: 8; height: 8
        z: 9999
        Drag.keys: root.sortable ? [root.sortableDragKey] : []
        Drag.active: false
        Drag.source: dragGhost
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: width / 2
    }

    // ── Scroll ─────────────────────────────────────
    Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: root._layoutHeight
        interactive: !root.isDragging
        boundsBehavior: Flickable.StopAtBounds
        visible: !root.isEmpty && !root.isLoading && root.model !== null
        clip: true

        ScrollBar.vertical: ScrollBar {
            visible: flick.contentHeight > flick.height
        }

        Item {
            id: layoutArea
            width: flick.width
            height: Math.max(root._layoutHeight, 1)

            Repeater {
                id: itemRepeater
                model: visualModel
            }
        }
    }

    Connections {
        target: itemRepeater
        function onCountChanged() { Qt.callLater(_doLayout) }
    }

    onModelChanged: {
        visualModel.model = root.model
        Qt.callLater(_doLayout)
    }

    // ── Empty State ────────────────────────────────
    Column {
        anchors.centerIn: parent
        spacing: Theme.spacing.sm
        visible: root.isEmpty && !root.isLoading && root.model !== null
        width: Math.min(parent.width - Theme.spacing.xl * 2, 280)

        LucideIcon {
            name: "package-open"
            size: 48
            color: Theme.colors.surface2
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: root.emptyStateTitle
            font.family: Theme.typography.familyBold
            font.pixelSize: Theme.typography.sizeMd
            color: Theme.colors.subtext0
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            antialiasing: true
        }

        Text {
            text: root.emptyStateSubtitle
            font.family: Theme.typography.family
            font.pixelSize: Theme.typography.sizeSm
            color: Theme.colors.overlay0
            horizontalAlignment: Text.AlignHCenter
            width: parent.width
            visible: root.emptyStateSubtitle !== ""
            wrapMode: Text.WordWrap
            antialiasing: true
        }
    }

    // ── Skeleton Loading ───────────────────────────
    GridLayout {
        id: skeletonGrid
        anchors { left: parent.left; right: parent.right; top: parent.top }
        anchors.margins: root._padPx
        columnSpacing: root._gapPx
        rowSpacing: root._gapPx
        visible: root.isLoading
        columns: root.cols

        Repeater {
            model: root.skeletonCount
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: width / root.aspectRatio
                radius: Theme.geometry.radiusSm
                color: Theme.colors.surface0

                CozySkeleton {
                    anchors.fill: parent
                    visible: true
                }
            }
        }
    }
}
