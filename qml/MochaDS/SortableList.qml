import QtQuick 2.15

Item {
    id: root

    property var model: null
    property Component delegate: null
    property real spacing: Theme.spacing.sm
    property real paddingLeft: Theme.spacing.xs
    property real paddingRight: Theme.spacing.xs
    property real paddingTop: Theme.spacing.xs
    property real paddingBottom: Theme.spacing.xs
    property string listId: ""
    property string dragKey: "mochads-sortable"
    property bool sortable: true
    property bool clip: true

    // ── Drag Ghost visual ─────────────────────────
    property bool dragGhostEnabled: true
    property real dragGhostScale: 1.04
    property real dragGhostRotation: 2.5
    property real dragGhostElevation: 8

    signal itemsReordered(int fromIndex, int toIndex)
    signal externalItemDropped(var source, int insertIndex)

    property int dragIndex: -1
    property int dragTargetIndex: -1
    property bool isDragging: false

    implicitWidth: 300
    implicitHeight: 400
    width: implicitWidth
    height: implicitHeight

    ListView {
        id: listView
        anchors.fill: parent
        anchors.leftMargin: root.paddingLeft
        anchors.rightMargin: root.paddingRight
        anchors.topMargin: root.paddingTop
        anchors.bottomMargin: root.paddingBottom
        clip: root.clip
        spacing: root.spacing
        reuseItems: false
        cacheBuffer: 0

        model: DelegateModel {
            id: visualModel
            model: root.model

            delegate: Item {
                id: delegateRoot
                width: ListView.view.width
                height: loader.implicitHeight

                // Capturamos os context properties originais
                property var _model: typeof model !== "undefined" ? model : null
                property var _modelData: typeof modelData !== "undefined" ? modelData : null
                property int _index: DelegateModel.itemsIndex

                property bool held: false

                scale: delegateRoot.held ? 1.02 : 1.0
                opacity: delegateRoot.held ? 0.35 : 1.0
                z: delegateRoot.held ? 100 : 0

                Behavior on scale {
                    NumberAnimation { duration: 120; easing.type: Easing.OutBack }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
                Behavior on y {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }

                DragHandler {
                    id: dragHandler
                    target: null
                    enabled: root.sortable
                    dragThreshold: 8
                    acceptedButtons: Qt.LeftButton
                    cursorShape: active ? Qt.ClosedHandCursor : Qt.OpenHandCursor

                    onActiveChanged: {
                        if (active) {
                            console.log("DRAG START: index", delegateRoot._index)
                            dragGhost.Drag.active = true
                            root.isDragging = true
                            delegateRoot.held = true
                            root.dragIndex = delegateRoot._index
                            root.dragTargetIndex = delegateRoot._index
                            dragGhost.__sourceListId = root.listId
                            dragGhost.__sourceIndex = delegateRoot._index
                            dragGhost.__sourceModel = delegateRoot._model
                            dragGhost.__sourceModelData = delegateRoot._modelData
                            dragGhost.__sourceWidth = delegateRoot.width
                            dragGhost.__sourceHeight = delegateRoot.height

                            // Reparent ghost to topmost ancestor so it can follow
                            // the cursor across the whole window (e.g. across columns
                            // in a Kanban). Drop matching uses Drag.keys, not hierarchy,
                            // so this is safe.
                            if (root.dragGhostEnabled) {
                                var top = root.parent
                                while (top && top.parent) top = top.parent
                                dragGhost.parent = top
                                var pos = delegateRoot.mapToItem(top, centroid.position.x, centroid.position.y)
                                dragGhost.x = pos.x - dragGhost.width / 2
                                dragGhost.y = pos.y - dragGhost.height / 2
                            } else {
                                var pos2 = delegateRoot.mapToItem(root, centroid.position.x, centroid.position.y)
                                dragGhost.x = pos2.x - dragGhost.width / 2
                                dragGhost.y = pos2.y - dragGhost.height / 2
                            }
                        } else {
                            console.log("DRAG END: from", root.dragIndex, "to", root.dragTargetIndex)
                            var fromIndex = root.dragIndex
                            var toIndex = root.dragTargetIndex
                            delegateRoot.held = false
                            root.isDragging = false

                            var dropResult = dragGhost.Drag.drop()
                            console.log("DROP RESULT:", dropResult)
                            dragGhost.Drag.active = false

                            if (toIndex >= 0 && toIndex !== fromIndex) {
                                visualModel.items.move(fromIndex, toIndex)
                                root.itemsReordered(fromIndex, toIndex)
                            }

                            root.dragIndex = -1
                            root.dragTargetIndex = -1
                            dragGhost.__sourceListId = ""
                            dragGhost.__sourceIndex = -1
                            dragGhost.__sourceModel = null
                            dragGhost.__sourceModelData = null
                            dragGhost.__sourceWidth = 0
                            dragGhost.__sourceHeight = 0
                        }
                    }

                    onTranslationChanged: {
                        if (active) {
                            var gp = dragGhost.parent
                            var pos = delegateRoot.mapToItem(gp, centroid.position.x, centroid.position.y)
                            dragGhost.x = pos.x - dragGhost.width / 2
                            dragGhost.y = pos.y - dragGhost.height / 2
                        }
                    }
                }

                Loader {
                    id: loader
                    width: parent.width
                    sourceComponent: root.delegate

                    property var model: delegateRoot._model
                    property var modelData: delegateRoot._modelData
                    property int index: delegateRoot._index
                }

                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    anchors.topMargin: -4
                    anchors.bottomMargin: -4
                    keys: root.sortable ? [root.dragKey] : []

                    onEntered: (drag) => {
                        console.log("DROP AREA ENTERED na coluna", root.listId, "item", delegateRoot._index)
                        if (!root.sortable) return
                        root.dragTargetIndex = delegateRoot._index
                    }

                    onExited: {
                        if (!root.sortable) return
                        if (root.dragTargetIndex === delegateRoot._index) {
                            root.dragTargetIndex = -1
                        }
                    }

                    onDropped: (drop) => {
                        if (!root.sortable) return
                        root.dragTargetIndex = -1
                        var source = drop.source
                        var srcId = source.__sourceListId
                        if (srcId && srcId !== root.listId) {
                            root.externalItemDropped(source, delegateRoot._index)
                        }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: Theme.colors.primary
                    opacity: dropArea.containsDrag ? 0.2 : 0
                    radius: Theme.geometry.radiusMd
                    z: 10
                    border.color: Theme.colors.primary
                    border.width: dropArea.containsDrag ? 2 : 0
                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }
                    Behavior on border.width {
                        NumberAnimation { duration: 150 }
                    }
                }
            }
        }
    }

    Item {
        id: dragGhost
        property string __sourceListId: ""
        property int __sourceIndex: -1
        property var __sourceModel: null
        property var __sourceModelData: null
        property real __sourceWidth: 0
        property real __sourceHeight: 0

        visible: root.isDragging
        enabled: false
        width: __sourceWidth
        height: __sourceHeight
        z: 9999

        Drag.keys: root.sortable ? [root.dragKey] : []
        Drag.active: root.isDragging
        Drag.source: dragGhost
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        scale: root.isDragging ? root.dragGhostScale : 1.0
        rotation: root.isDragging ? root.dragGhostRotation : 0.0
        transformOrigin: Item.Center

        Behavior on x { NumberAnimation { duration: 50; easing.type: Easing.OutQuad } }
        Behavior on y { NumberAnimation { duration: 50; easing.type: Easing.OutQuad } }
        Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
        Behavior on rotation { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        // Multi-layer shadow for "lifted" feel (mirrors Draggable.qml pattern)
        Rectangle {
            anchors.fill: parent
            anchors.margins: -root.dragGhostElevation
            radius: Theme.geometry.radiusMd + root.dragGhostElevation
            color: "transparent"
            visible: root.isDragging
            z: -2

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: Qt.rgba(0, 0, 0, 0.25)
                y: 4
                visible: root.isDragging
            }
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: parent.radius + 3
                color: Qt.rgba(0, 0, 0, 0.12)
                y: 8
                visible: root.isDragging
            }
        }

        // Visual clone of the dragged delegate
        Loader {
            id: ghostLoader
            anchors.fill: parent
            sourceComponent: root.delegate

            property var model: dragGhost.__sourceModel
            property var modelData: dragGhost.__sourceModelData
            property int index: dragGhost.__sourceIndex
        }
    }
}
