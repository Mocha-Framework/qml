import QtQuick 2.15
import QtQuick.Layouts 1.15


Item {
    // ==========================================
    // Visual Tree
    // ==========================================

    id: root

    // ==========================================
    // Public API
    // ==========================================
    property var model: null
    property Component rowContent
    // List visual overrides
    property real spacing: Theme.spacing.sm
    property real paddingLeft: Theme.spacing.xs
    property real paddingRight: Theme.spacing.xs
    property real paddingTop: Theme.spacing.xs
    property real paddingBottom: Theme.spacing.xs
    // Empty State System configuration
    property string emptyStateIcon: "package-open"
    property string emptyStateTitle: "Nenhum item encontrado"
    property string emptyStateSubtitle: ""
    
    // Loading State
    property bool isLoading: false

    // Sortable (Drag & Drop Reordering)
    property bool sortable: false
    property string listId: ""
    property string sortableDragKey: "mochads-sortable"
    signal itemsReordered(int fromIndex, int toIndex)
    signal itemClicked(var modelData)

    property int dragIndex: -1
    property int dragTargetIndex: -1
    property bool isDragging: false

    // Reactive empty check
    readonly property bool isEmpty: {
        if (root.model === null || root.model === undefined)
            return true;

        // Handle QML ListModels, Javascript arrays, and numeric models
        if (typeof root.model === "number")
            return root.model <= 0;

        if (typeof root.model.count === "number")
            return root.model.count === 0;

        if (typeof root.model.length === "number")
            return root.model.length === 0;

        // Fallback to ListView count check
        return listView.count === 0;
    }

    // Dimensions
    implicitWidth: 350
    implicitHeight: 400
    width: implicitWidth
    height: implicitHeight

    // The Wrapper: ListView (with optional sortable DelegateModel)
    ListView {
        id: listView

        anchors.fill: parent
        anchors.leftMargin: root.paddingLeft
        anchors.rightMargin: root.paddingRight
        anchors.topMargin: root.paddingTop
        anchors.bottomMargin: root.paddingBottom
        clip: true
        spacing: root.spacing
        visible: !root.isEmpty && !root.isLoading
        reuseItems: false

        model: DelegateModel {
            id: visualModel
            model: root.model

            delegate: Item {
                id: delegateRoot
                width: listView.width - (scrollBar.shouldShow ? scrollBar.width : 0)
                height: cellLoader.implicitHeight

                property int _index: DelegateModel.itemsIndex
                property bool held: false

                scale: delegateRoot.held ? 1.03 : 1.0
                opacity: delegateRoot.held ? 0.85 : 1.0
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

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: root.sortable
                    enabled: root.sortable
                    acceptedButtons: Qt.NoButton
                    cursorShape: delegateRoot.held ? Qt.ClosedHandCursor : (containsMouse ? Qt.OpenHandCursor : Qt.ArrowCursor)
                }

                DragHandler {
                    id: dragHandler
                    target: null
                    enabled: root.sortable
                    dragThreshold: 8
                    acceptedButtons: Qt.LeftButton

                    onActiveChanged: {
                        if (active) {
                            dragGhost.Drag.active = true
                            root.isDragging = true
                            delegateRoot.held = true
                            root.dragIndex = delegateRoot._index
                            root.dragTargetIndex = delegateRoot._index
                            dragGhost.__sourceListId = root.listId
                            dragGhost.__sourceIndex = delegateRoot._index
                            var pos = delegateRoot.mapToItem(root,
                                centroid.position.x,
                                centroid.position.y)
                            dragGhost.x = pos.x - dragGhost.width / 2
                            dragGhost.y = pos.y - dragGhost.height / 2
                        } else {
                            var fromIndex = root.dragIndex
                            var toIndex = root.dragTargetIndex
                            delegateRoot.held = false
                            root.isDragging = false
                            Drag.drop()
                            dragGhost.Drag.active = false
                            if (toIndex >= 0 && toIndex !== fromIndex) {
                                visualModel.items.move(fromIndex, toIndex)
                                root.itemsReordered(fromIndex, toIndex)
                            }
                            root.dragIndex = -1
                            root.dragTargetIndex = -1
                            dragGhost.__sourceListId = ""
                            dragGhost.__sourceIndex = -1
                        }
                    }

                    onTranslationChanged: {
                        if (active) {
                            var pos = delegateRoot.mapToItem(root,
                                centroid.position.x,
                                centroid.position.y)
                            dragGhost.x = pos.x - dragGhost.width / 2
                            dragGhost.y = pos.y - dragGhost.height / 2
                        }
                    }
                }

                InteractiveListCell {
                    id: cellLoader
                    width: parent.width
                    rowContent: root.rowContent
                    cellModelData: typeof modelData !== "undefined" ? modelData : (typeof model !== "undefined" ? model : null)
                    cellIndex: DelegateModel.itemsIndex
                    isSelected: false
                    onClicked: {
                        root.itemClicked(cellModelData)
                    }
                }

                DropArea {
                    id: dropArea
                    anchors.fill: parent
                    anchors.topMargin: -4
                    anchors.bottomMargin: -4
                    keys: root.sortable ? [root.sortableDragKey] : []

                    onEntered: {
                        if (!root.sortable) return
                        root.dragTargetIndex = delegateRoot._index
                    }

                    onExited: {
                        if (!root.sortable) return
                        if (root.dragTargetIndex === delegateRoot._index) {
                            root.dragTargetIndex = -1
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
        Drag.keys: root.sortable ? [root.sortableDragKey] : []
        Drag.active: false
        Drag.source: dragGhost
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2
    }

    // Skeleton Shimmer Loading State Layout
    ColumnLayout {
        id: skeletonLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: root.paddingLeft
        anchors.rightMargin: root.paddingRight
        anchors.topMargin: root.paddingTop
        spacing: root.spacing
        visible: root.isLoading

        Repeater {
            model: 5
            delegate: Rectangle {
                Layout.fillWidth: true
                height: 56
                color: "transparent"
                radius: Theme.geometry.radiusMd
                border.width: Theme.geometry.borderSm
                border.color: Qt.rgba(Theme.colors.surface0.r, Theme.colors.surface0.g, Theme.colors.surface0.b, 0.2)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.md
                    anchors.rightMargin: Theme.spacing.md
                    spacing: Theme.spacing.md

                    // Icon/Avatar skeleton
                    CozySkeleton {
                        variant: "circle"
                        width: 24
                        height: 24
                    }

                    // Main title skeleton text
                    ColumnLayout {
                        spacing: Theme.spacing.xs
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter

                        CozySkeleton {
                            width: 140
                            height: 14
                        }
                    }

                    // Optional accessory badge/action skeleton
                    CozySkeleton {
                        variant: "circle"
                        width: 18
                        height: 18
                    }
                }
            }
        }
    }

    // ScrollBar
    ScrollBar {
        id: scrollBar

        flickable: listView
        orientation: "vertical"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        z: 2
        visible: !root.isLoading
    }

    // Empty State System Container
    ColumnLayout {
        id: emptyStateContainer

        anchors.centerIn: parent
        width: Math.min(parent.width - Theme.spacing.xl * 2, 320)
        spacing: Theme.spacing.md
        // Reactive opacity animation
        opacity: (root.isEmpty && !root.isLoading) ? 1 : 0
        visible: opacity > 0

        // Icon (Large, Theme.colors.subtext0)
        LucideIcon {
            name: root.emptyStateIcon
            size: 48
            color: Theme.colors.subtext0
            Layout.alignment: Qt.AlignHCenter
        }

        // Titles layout
        ColumnLayout {
            spacing: Theme.spacing.xs
            Layout.fillWidth: true

            Text {
                text: root.emptyStateTitle
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeLg
                color: Theme.colors.text
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                antialiasing: true
            }

            Text {
                text: root.emptyStateSubtitle
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.subtext0
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                visible: text !== ""
                antialiasing: true
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutQuad
            }

        }

    }

}
