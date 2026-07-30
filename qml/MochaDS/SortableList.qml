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
                            var pos = delegateRoot.mapToItem(root, centroid.position.x, centroid.position.y)
                            dragGhost.x = pos.x - dragGhost.width / 2
                            dragGhost.y = pos.y - dragGhost.height / 2
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
                        }
                    }

                    onTranslationChanged: {
                        if (active) {
                            var pos = delegateRoot.mapToItem(root, centroid.position.x, centroid.position.y)
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
        visible: root.isDragging
        width: 8; height: 8
        Drag.keys: root.sortable ? [root.dragKey] : []
        Drag.active: false
        Drag.source: dragGhost
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
    }
}
