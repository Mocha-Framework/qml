import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    readonly property bool isSidebarFooter: true

    // Optional default profile properties
    property string username: ""
    property string email: ""
    property string avatarIcon: "user"

    // Default container for custom footer items
    default property alias content: customContainer.data

    // Find parent Sidebar
    readonly property Item sidebar: {
        var p = parent;
        while (p && !p.hasOwnProperty("isFullyExpanded")) {
            p = p.parent;
        }
        return p;
    }

    readonly property bool isExpanded: sidebar ? sidebar.isFullyExpanded : true

    // Layout
    implicitWidth: 260
    implicitHeight: 72
    width: parent ? parent.width : implicitWidth
    height: implicitHeight

    // Background & Divider
    Rectangle {
        anchors.fill: parent
        color: "transparent"

        // Top border divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.colors.surface0
            anchors.top: parent.top
        }
    }

    // Default Profile Layout (shown if username is specified)
    Row {
        id: defaultProfileLayout
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.md
        anchors.rightMargin: Theme.spacing.md
        spacing: Theme.spacing.sm
        visible: root.username !== ""

        // Avatar wrapper
        Rectangle {
            width: 36
            height: 36
            radius: 18
            color: Theme.colors.surface0
            anchors.verticalCenter: parent.verticalCenter

            LucideIcon {
                name: root.avatarIcon
                size: 18
                color: Theme.colors.subtext1
                anchors.centerIn: parent
            }
        }

        // Profile Details (fades out when collapsed)
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            
            opacity: root.isExpanded ? 1.0 : 0.0
            visible: opacity > 0.0

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            Text {
                text: root.username
                font.family: Theme.typography.familyMedium
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.text
                antialiasing: true
            }

            Text {
                text: root.email
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeXs
                color: Theme.colors.subtext0
                visible: root.email !== ""
                antialiasing: true
            }
        }
    }

    // Custom Container (if custom children are added)
    Item {
        id: customContainer
        anchors.fill: parent
        anchors.margins: Theme.spacing.md
        visible: !defaultProfileLayout.visible
    }
}
