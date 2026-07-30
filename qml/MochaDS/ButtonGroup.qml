import QtQuick 2.15

Item {
    id: root
    
    // Identifier for ButtonGroupItem child detection
    readonly property bool isButtonGroup: true
    
    // ==========================================
    // Public API (Properties)
    // ==========================================
    property int currentIndex: 0
    property string variant: "default" // "default" | "primary"
    property bool expand: true // If true, distributes width equally among children
    
    // Exposed internal row container for items
    readonly property alias itemsRow: itemsRow
    
    // Internal list of registered items
    property var itemsList: []
    
    // Default property alias to direct child items inside the Row layout
    default property alias content: itemsRow.data
    
    // ==========================================
    // Layout Dimensions
    // ==========================================
    implicitHeight: 40
    implicitWidth: {
        if (expand) {
            return 320 // default width for expanded mode
        } else {
            var w = 8 // track left + right padding
            for (var i = 0; i < itemsList.length; i++) {
                w += itemsList[i].implicitWidth
            }
            return w
        }
    }
    width: implicitWidth
    height: implicitHeight
    
    // ==========================================
    // Registration methods
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
            if (child && child.isButtonGroupItem) {
                list.push(child);
            }
        }
        itemsList = list;
    }
    
    // Active item reference
    readonly property Item activeItem: {
        if (currentIndex >= 0 && currentIndex < itemsList.length) {
            return itemsList[currentIndex];
        }
        return null;
    }
    
    // ==========================================
    // Visual Tree
    // ==========================================
    
    // Track background
    Rectangle {
        id: track
        anchors.fill: parent
        color: Qt.rgba(Theme.colors.surface0.r, Theme.colors.surface0.g, Theme.colors.surface0.b, 0.4)
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        radius: height / 2
        
        // Sliding Active Indicator
        Rectangle {
            id: indicator
            x: activeItem ? (activeItem.x + 4) : 4
            width: activeItem ? activeItem.width : 0
            height: parent.height - 8
            y: 4
            radius: height / 2
            
            color: root.variant === "primary" ? Theme.colors.mauve : Theme.colors.surface1
            border.color: root.variant === "primary" ? "transparent" : Qt.rgba(1,1,1,0.05)
            border.width: root.variant === "primary" ? 0 : 1
            
            // Smooth sliding transition using Quad Easing (macOS feel)
            Behavior on x {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on width {
                NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
            }
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
    
    // Row of buttons
    Row {
        id: itemsRow
        anchors.fill: parent
        anchors.leftMargin: 4
        anchors.rightMargin: 4
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        spacing: 0
    }
}
