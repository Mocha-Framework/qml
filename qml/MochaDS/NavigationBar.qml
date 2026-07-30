import QtQuick 2.15

Item {
    id: root

    // Identifier for NavigationItem parent resolution
    readonly property bool isNavigationBar: true

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property string variant: "standard" // "standard" | "floating" | "expanding" | "labeled"
    property int currentIndex: 0
    property color highlightColor: Theme.colors.primary
    property bool darkMode: true

    // Exposed internal row container for items
    readonly property alias itemsRow: itemsRow

    // Internal list of registered items
    property var itemsList: []

    readonly property Item activeItem: {
        if (currentIndex >= 0 && currentIndex < itemsList.length) {
            return itemsList[currentIndex];
        }
        return null;
    }

    // Default property alias to direct child items inside the Row layout
    default property alias content: itemsRow.data

    // ==========================================
    // Layout Dimensions
    // ==========================================
    readonly property real rowSpacing: {
        if (variant === "labeled") return 12;
        if (variant === "expanding") return 14;
        return 20;
    }
    readonly property real chromeShadowOpacity: root.variant === "floating" ? 1.0 : 0.78
    readonly property int chromeAnimDuration: root.variant === "expanding" ? 220 : 180

    implicitHeight: variant === "labeled" ? 72 : 56
    implicitWidth: itemsRow.implicitWidth + 24 // 12px padding on each side
    width: implicitWidth
    height: implicitHeight

    Behavior on width {
        NumberAnimation { duration: root.chromeAnimDuration; easing.type: Easing.OutCubic }
    }

    // ==========================================
    // Registration & Lifecycle
    // ==========================================
    function registerItem(item) {
        updateItemsList();
    }
    function unregisterItem(item) {
        updateItemsList();
    }
    function updateItemsList() {
        var list = [];
        for (var i = 0; i < itemsRow.children.length; i++) {
            var child = itemsRow.children[i];
            if (child && child.isNavigationItem) {
                list.push(child);
            }
        }
        itemsList = list;
    }

    // ==========================================
    // Visual Tree
    // ==========================================
    
    // Multi-layered cozy drop shadow
    Item {
        id: shadowStack
        anchors.fill: bgRect
        z: -1
        opacity: root.chromeShadowOpacity

        Behavior on opacity {
            NumberAnimation { duration: 160; easing.type: Easing.OutCubic }
        }
        
        // Layer 1: Close shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: parent.radius + 1
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.12)
            border.width: 1
            y: 2
        }
        
        // Layer 2: Medium diffuse shadow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -3
            radius: parent.radius + 3
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 2
            y: 4
        }
        
        // Layer 3: Soft outer glow
        Rectangle {
            anchors.fill: parent
            anchors.margins: -6
            radius: parent.radius + 6
            color: "transparent"
            border.color: Qt.rgba(0, 0, 0, 0.04)
            border.width: 3
            y: 6
        }
    }

    // Main background pill container
    Rectangle {
        id: bgRect
        anchors.fill: parent
        color: darkMode ? Theme.colors.crust : Theme.colors.base
        radius: height / 2
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        clip: false // Allow active indicator to float out

        Behavior on color { ColorAnimation { duration: 200 } }
        Behavior on border.color { ColorAnimation { duration: 200 } }

        // Sliding Active Indicator
        Rectangle {
            id: indicator
            visible: activeItem !== null
            
            // Dimensions
            height: {
                if (!activeItem) return 0;
                if (root.variant === "labeled") return 40;
                return activeItem.height;
            }
            width: {
                if (!activeItem) return 0;
                if (root.variant === "labeled") return 40;
                return activeItem.width;
            }
            radius: height / 2
            color: root.highlightColor
            
            // Position
            x: {
                if (!activeItem) return 0;
                if (root.variant === "labeled") {
                    return itemsRow.x + activeItem.x + 16; // center in 72px item
                }
                return itemsRow.x + activeItem.x;
            }
            y: {
                if (!activeItem) return 0;
                if (root.variant === "labeled") {
                    return itemsRow.y + activeItem.y + 4;
                }
                return itemsRow.y + activeItem.y + activeItem.activeY;
            }
            
            // Premium smooth spring animations
            Behavior on x {
                NumberAnimation { duration: root.chromeAnimDuration; easing.type: Easing.OutCubic }
            }
            Behavior on width {
                NumberAnimation { duration: root.chromeAnimDuration; easing.type: Easing.OutCubic }
            }
            Behavior on y {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
            Behavior on height {
                NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
            }
            
            // Nested shadow stack for floating indicator
            Item {
                anchors.fill: parent
                z: -1
                visible: root.variant === "floating"
                
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -1
                    radius: parent.radius + 1
                    color: "transparent"
                    border.color: Qt.rgba(0, 0, 0, 0.15)
                    border.width: 1
                    y: 2
                }
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: -3
                    radius: parent.radius + 3
                    color: "transparent"
                    border.color: Qt.rgba(0, 0, 0, 0.08)
                    border.width: 2
                    y: 4
                }
            }
        }

        // Row holding individual items
        Row {
            id: itemsRow
            anchors.centerIn: parent
            spacing: root.rowSpacing
        }
    }
}
