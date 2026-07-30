import QtQuick 2.15
import QtQml.Models

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // Array of tab items: e.g., ["Tab A", "Tab B"] or [{ id: "t1", label: "Tab A", icon: "settings" }]
    property var model: []

    // Index of the active tab
    property int currentIndex: 0

    // Variant style: "line" | "pill" | "segmented" | "card"
    property string variant: "line"

    // Visual customizations (Overrides)
    property color customAccentColor: "transparent"
    property color customTextColor: "transparent"

    // ==========================================
    // Signals
    // ==========================================
    signal tabSelected(int index, string tabId)
    signal tabsReordered(int fromIndex, int toIndex)

    property bool sortable: false

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property bool hasCustomAccentColor: customAccentColor.toString() !== "#00000000" && customAccentColor.toString() !== "transparent"
    readonly property bool hasCustomTextColor: customTextColor.toString() !== "#00000000" && customTextColor.toString() !== "transparent"

    readonly property color finalAccentColor: hasCustomAccentColor ? customAccentColor : Theme.colors.primary
    readonly property color finalTextColor: hasCustomTextColor ? customTextColor : Theme.colors.text

    // Segmented tab width helper
    readonly property real segmentedTabWidth: model && model.length > 0 ? (width / model.length) : 0

    // Helper functions to resolve tab item details
    function getLabel(item, index) {
        if (item === undefined || item === null) return "";
        if (typeof item === "string") return item;
        return item.label || "";
    }

    function getId(item, index) {
        if (item === undefined || item === null) return String(index);
        if (typeof item === "string") return item;
        return item.id !== undefined ? String(item.id) : String(index);
    }

    function getIcon(item) {
        if (item === undefined || item === null) return "";
        if (typeof item === "object") {
            return item.icon || "";
        }
        return "";
    }

    // Reference to current active tab visual item
    readonly property Item currentTabItem: (tabRow && currentIndex >= 0 && currentIndex < tabRow.children.length) ? tabRow.children[currentIndex] : null

    // Layout Dimensions
    implicitHeight: 40
    implicitWidth: 300
    width: implicitWidth
    height: implicitHeight

    // Scroll active tab into view when changed
    onCurrentIndexChanged: {
        if (tabRow && tabRow.currentIndex !== currentIndex) {
            tabRow.currentIndex = currentIndex;
        }
    }
    
    onModelChanged: {
        // When the model is completely replaced, ListView resets its internal currentIndex to 0 asynchronously.
        // We must wait for the event loop to finish rebuilding before forcing the index back.
        Qt.callLater(function() {
            if (tabRow && tabRow.currentIndex !== root.currentIndex) {
                tabRow.currentIndex = root.currentIndex;
            }
        });
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Segmented Container Background (unified track behind segmented tabs)
    Rectangle {
        id: segmentedBg
        anchors.fill: parent
        color: Theme.colors.mantle
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        radius: Theme.geometry.radiusMd
        visible: root.variant === "segmented"
        z: 0

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // 2. Track Line (visible only in line variant)
    Rectangle {
        id: trackLine
        width: parent.width
        height: 1
        anchors.bottom: parent.bottom
        color: Theme.colors.surface0
        visible: root.variant === "line"
        z: 0
    }

    // 3. Tabs ListView
    ListView {
        id: tabRow
        anchors.fill: parent
        anchors.margins: root.variant === "segmented" ? 4 : 0
        orientation: ListView.Horizontal
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        spacing: root.variant === "card" ? Theme.spacing.sm : 0
        z: 1
        
        highlightFollowsCurrentItem: true
        highlightMoveDuration: 200
        
        highlight: Item {
            z: -1
            Rectangle {
                width: parent.width
                
                y: {
                    if (root.variant === "line") return tabRow.height - 3;
                    if (root.variant === "segmented") return 0;
                    return Theme.spacing.xs; // "pill"
                }
                height: {
                    if (root.variant === "line") return 3;
                    if (root.variant === "segmented") return tabRow.height;
                    return tabRow.height - (Theme.spacing.xs * 2); // "pill"
                }
                radius: {
                    if (root.variant === "line") return 0;
                    if (root.variant === "segmented") return Theme.geometry.radiusMd - 2;
                    return Theme.geometry.radiusPill; // "pill"
                }
                
                color: {
                    if (root.variant === "segmented") return Theme.colors.surface0;
                    return root.finalAccentColor;
                }
                border.color: root.variant === "segmented" ? Theme.colors.surface1 : "transparent"
                border.width: root.variant === "segmented" ? Theme.geometry.borderSm : 0
                visible: root.variant !== "card"

                Behavior on y { NumberAnimation { duration: 150 } }
                Behavior on height { NumberAnimation { duration: 150 } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        model: DelegateModel {
            id: visualModel
            model: root.model

                    delegate: Item {
                        id: tabItem
                        height: tabRow.height
                        
                        // Calculate width dynamically or equally for segmented control
                        width: {
                            if (root.variant === "segmented" && tabRow.count > 0) {
                                return tabRow.width / tabRow.count;
                            }
                            return tabContent.implicitWidth + Theme.spacing.lg * 2;
                        }

                        property var _model: typeof model !== "undefined" ? model : null
                        property var _modelData: typeof modelData !== "undefined" ? modelData : null
                        property int _index: typeof index !== "undefined" ? index : 0
                        property int _visualIndex: typeof DelegateModel !== "undefined" && DelegateModel.itemsIndex !== undefined ? DelegateModel.itemsIndex : _index

                        readonly property bool isActive: root.currentIndex === _index
                        readonly property bool isHovered: hoverHandler.hovered
                        readonly property bool isPressed: tapHandler.pressed
                        property bool held: false
                        
                        transformOrigin: Item.Center
                        scale: held ? 1.05 : (isPressed ? 0.985 : (isHovered && !isActive ? 1.01 : 1.0))
                        opacity: held ? 0.8 : 1.0
                        z: held ? 100 : 0

                        Behavior on scale {
                            NumberAnimation { duration: 110; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            id: hoverBg
                            anchors.fill: parent
                            anchors.margins: root.variant === "line" ? Theme.spacing.xs : 2
                            radius: root.variant === "line" ? Theme.geometry.radiusSm : Theme.geometry.radiusMd
                            visible: root.variant !== "card"
                            color: {
                                if (root.variant === "segmented") {
                                    return Theme.colors.surface0
                                }
                                return Qt.rgba(root.finalAccentColor.r, root.finalAccentColor.g, root.finalAccentColor.b, 0.10)
                            }
                            opacity: tabItem.isActive ? 0.0 : (tabItem.isHovered ? (tabItem.isPressed ? 0.9 : 1.0) : 0.0)
                            z: 0

                            Behavior on opacity { NumberAnimation { duration: 120 } }
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        // Card variant background
                        Rectangle {
                            id: cardBg
                            anchors.fill: parent
                            visible: root.variant === "card"
                            color: {
                                if (tabItem.isActive) return Theme.colors.base
                                if (tabItem.isHovered) return Theme.colors.surface0
                                return Theme.colors.mantle
                            }
                            border.color: tabItem.isActive ? root.finalAccentColor : Theme.colors.surface0
                            border.width: Theme.geometry.borderSm
                            radius: Theme.geometry.radiusMd

                            Behavior on color { ColorAnimation { duration: 150 } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }
                        }

                        Row {
                            id: tabContent
                            spacing: Theme.spacing.sm
                            anchors.centerIn: parent

                            // Optional Left Icon
                            LucideIcon {
                                name: root.getIcon(modelData)
                                size: 16
                                color: {
                                    if (tabItem.isActive) {
                                        if (root.variant === "pill") return Theme.colors.crust;
                                        if (root.variant === "segmented") return Theme.colors.text;
                                        return root.finalAccentColor;
                                    }
                                    return tabItem.isHovered ? root.finalTextColor : Theme.colors.subtext0;
                                }
                                visible: name !== ""
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }

                            // Tab Label Text
                            Text {
                                text: root.getLabel(_modelData, _index)
                                font.family: tabItem.isActive ? Theme.typography.familyBold : Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: {
                                    if (tabItem.isActive) {
                                        if (root.variant === "pill") return Theme.colors.crust;
                                        if (root.variant === "segmented") return Theme.colors.text;
                                        return root.finalAccentColor;
                                    }
                                    return tabItem.isHovered ? root.finalTextColor : Theme.colors.subtext0;
                                }
                                anchors.verticalCenter: parent.verticalCenter
                                antialiasing: true
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                        }

                        HoverHandler {
                            id: hoverHandler
                        }

                        TapHandler {
                            id: tapHandler
                            onTapped: {
                                root.currentIndex = _index;
                                root.tabSelected(_index, root.getId(_modelData, _index));
                            }
                        }

                        DragHandler {
                            id: dragHandler
                            target: null
                            enabled: root.sortable
                            dragThreshold: 8
                            acceptedButtons: Qt.LeftButton
                            cursorShape: active ? Qt.ClosedHandCursor : Qt.PointingHandCursor

                            onActiveChanged: {
                                if (active) {
                                    tabItem.held = true;
                                    dragGhost.__startIndex = tabItem._visualIndex;
                                    dragGhost.Drag.active = true;
                                } else {
                                    tabItem.held = false;
                                    dragGhost.Drag.active = false;
                                    dragGhost.x = 0;
                                    dragGhost.y = 0;
                                    if (dragGhost.__startIndex !== -1 && dragGhost.__startIndex !== tabItem._visualIndex) {
                                        var startIdx = dragGhost.__startIndex;
                                        var finalIdx = tabItem._visualIndex;
                                        // Revert the visual moves to clear DelegateModel overrides before updating data
                                        visualModel.items.move(finalIdx, startIdx);
                                        
                                        // Update currentIndex so the highlight follows the correct tab
                                        var oldCurrent = root.currentIndex;
                                        if (oldCurrent === startIdx) {
                                            root.currentIndex = finalIdx;
                                        } else if (startIdx < finalIdx && oldCurrent > startIdx && oldCurrent <= finalIdx) {
                                            root.currentIndex = oldCurrent - 1;
                                        } else if (startIdx > finalIdx && oldCurrent >= finalIdx && oldCurrent < startIdx) {
                                            root.currentIndex = oldCurrent + 1;
                                        }
                                        
                                        // Update the real data array
                                        root.tabsReordered(startIdx, finalIdx);
                                    }
                                }
                            }

                            onTranslationChanged: {
                                if (active) {
                                    var pos = tabItem.mapToItem(tabRow, centroid.position.x, centroid.position.y);
                                    dragGhost.x = pos.x - dragGhost.width / 2;
                                    dragGhost.y = pos.y - dragGhost.height / 2;
                                }
                            }
                        }

                        DropArea {
                            id: dropArea
                            anchors.fill: parent
                            keys: root.sortable ? ["mochads-sortable-tab"] : []

                            onEntered: (drag) => {
                                if (!root.sortable) return;
                                var fromIndex = drag.source.__currentIndex;
                                var toIndex = tabItem._visualIndex;
                                
                                if (fromIndex >= 0 && fromIndex !== toIndex) {
                                    visualModel.items.move(fromIndex, toIndex);
                                }
                            }
                        }

                        Item {
                            id: dragGhost
                            parent: tabRow
                            width: 10
                            height: 10
                            
                            property int __startIndex: -1
                            property int __currentIndex: tabItem._visualIndex
                            
                            Drag.keys: root.sortable ? ["mochads-sortable-tab"] : []
                            Drag.hotSpot.x: width / 2
                            Drag.hotSpot.y: height / 2
                            Drag.source: dragGhost
                        }
                    }
        }
    }
}
