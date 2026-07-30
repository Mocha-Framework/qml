import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    readonly property bool isSidebarHeader: true

    // Optional default properties
    property string title: ""
    property string subtitle: ""
    property string logoIcon: "" // Name of the LucideIcon

    // Default container for custom components
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

        // Bottom border divider
        Rectangle {
            width: parent.width
            height: 1
            color: Theme.colors.surface0
            anchors.bottom: parent.bottom
        }
    }

    // Default Layout (if title/logo properties are provided)
    Row {
        id: defaultLayout
        anchors.fill: parent
        anchors.leftMargin: Theme.spacing.md
        anchors.rightMargin: Theme.spacing.md
        spacing: Theme.spacing.sm
        visible: root.title !== "" || root.logoIcon !== ""

        // Logo Icon
        LucideIcon {
            id: logo
            name: root.logoIcon
            size: 24
            color: Theme.colors.primary
            anchors.verticalCenter: parent.verticalCenter
            visible: root.logoIcon !== ""
        }

        // Text block (fades out when collapsed)
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            
            opacity: root.isExpanded ? 1.0 : 0.0
            visible: opacity > 0.0

            Behavior on opacity {
                NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
            }

            Text {
                text: root.title
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeLg
                color: Theme.colors.text
                antialiasing: true
            }

            Text {
                text: root.subtitle
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeXs
                color: Theme.colors.subtext0
                visible: root.subtitle !== ""
                antialiasing: true
            }
        }
    }

    // Custom Container (if custom children are added)
    Item {
        id: customContainer
        anchors.fill: parent
        anchors.margins: Theme.spacing.md
        visible: !defaultLayout.visible
    }
}
