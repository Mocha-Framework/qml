import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    readonly property bool isSidebarSection: true

    // Layout spacing between items
    property real spacing: Theme.spacing.xs

    // Default container for list of SidebarItems
    default property alias content: itemColumn.data

    // Fill parent area (assigned by Sidebar parent)
    anchors.fill: parent

    // ==========================================
    // Visual Tree
    // ==========================================

    Flickable {
        id: flickable
        anchors.fill: parent
        // Leave minor margins for scrollbar and breathing room
        anchors.leftMargin: Theme.spacing.sm
        anchors.rightMargin: Theme.spacing.sm
        anchors.topMargin: Theme.spacing.sm
        anchors.bottomMargin: Theme.spacing.sm

        contentWidth: width
        contentHeight: itemColumn.implicitHeight
        clip: true
        
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: itemColumn
            // Restrict layout width to the viewport width to prevent horizontal overflow
            width: parent.width
            spacing: root.spacing
        }
    }

    // ScrollBar overlay (appears on scroll or hover if overflow exists)
    ScrollBar {
        flickable: flickable
        orientation: "vertical"
        thickness: 4
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        // Ensure scrollbar has high z-index and doesn't push elements
        z: 5
    }
}
