import QtQuick 2.15

Item {
    // ==========================================
    // Visual Tree
    // ==========================================

    id: root

    // ==========================================
    // Public API
    // ==========================================
    property string icon: ""
    property string label: ""
    property bool isActive: false
    property bool expanded: false
    // Default container for nested items (allows accordion hierarchy)
    default property alias subContent: subColumn.data
    // Find parent Sidebar
    readonly property Item sidebar: {
        var p = parent;
        while (p && !p.hasOwnProperty("isFullyExpanded"))
            p = p.parent;

        return p;
    }
    readonly property bool isExpanded: sidebar ? sidebar.isFullyExpanded : true
    readonly property bool hasChildren: subColumn.children.length > 0

    signal clicked()

    // Layout
    implicitWidth: 200
    // Dynamic height based on expansion state and child items
    implicitHeight: 44 + (root.hasChildren && root.expanded ? subContainer.height : 0)
    width: parent ? parent.width : implicitWidth
    height: implicitHeight
    activeFocusOnTab: true
    Keys.onReturnPressed: {
        if (root.hasChildren)
            root.expanded = !root.expanded;

        root.clicked();
    }
    Keys.onSpacePressed: {
        if (root.hasChildren)
            root.expanded = !root.expanded;

        root.clicked();
    }

    Column {
        id: mainLayout

        anchors.fill: parent

        // Parent Interactive Item
        Item {
            id: headerRow

            width: parent.width
            height: 44
            // Cozy spring micro-animation
            scale: clickArea.pressed ? 0.96 : (hoverHandler.hovered ? 1.02 : 1)
            transformOrigin: Item.Center

            MouseArea {
                id: clickArea

                anchors.fill: parent
                hoverEnabled: false
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.hasChildren)
                        root.expanded = !root.expanded;

                    root.clicked();
                }
            }

            HoverHandler {
                id: hoverHandler
            }

            // Background Panel
            Rectangle {
                id: bgPanel

                anchors.fill: parent
                radius: Theme.geometry.radiusMd
                // Active: surface0 solid (100% opacity)
                // Hover: surface0 50% opacity
                // Idle: transparent
                color: Theme.colors.surface0
                opacity: root.isActive ? 1 : (hoverHandler.hovered ? 0.5 : 0)

                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            // Icon (LucideIcon wrapper)
            LucideIcon {
                id: iconItem

                name: root.icon
                size: 20
                color: root.isActive ? Theme.colors.mauve : Theme.colors.text
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: root.isExpanded ? Theme.spacing.md : (parent.width - size) / 2

                Behavior on anchors.leftMargin {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            // Label Text
            Text {
                id: labelItem

                text: root.label
                font.family: Theme.typography.family
                font.weight: root.isActive ? Font.DemiBold : Font.Normal
                font.pixelSize: Theme.typography.sizeMd
                color: root.isActive ? Theme.colors.mauve : Theme.colors.text
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: iconItem.right
                anchors.leftMargin: Theme.spacing.md
                // Fade in/out text smoothly
                opacity: root.isExpanded ? 1 : 0
                visible: opacity > 0
                antialiasing: true

                Behavior on opacity {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            // Chevron Indicator (only if it has sub-items and sidebar is expanded)
            LucideIcon {
                id: chevronItem

                name: "chevron-right"
                size: 16
                color: root.isActive ? Theme.colors.mauve : Theme.colors.subtext1
                rotation: root.expanded ? 90 : 0
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.md
                visible: root.hasChildren && root.isExpanded

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

                Behavior on rotation {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }

                }

            }

            Behavior on scale {
                NumberAnimation {
                    duration: 120
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.5
                }

            }
            // Hover & Click Area

        }

        // Nested Sub-items Container
        Item {
            id: subContainer

            width: parent.width
            height: root.expanded ? subColumn.implicitHeight : 0
            clip: true

            Column {
                id: subColumn

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: root.isExpanded ? Theme.spacing.lg : 0
                spacing: Theme.spacing.xs

                Behavior on anchors.leftMargin {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }

                }

            }

            // Smooth expansion/collapse animation
            Behavior on height {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }

            }

        }

    }

    FocusRing {
        target: root
        active: root.activeFocus
    }

    // Smooth height transitions for accordion behavior
    Behavior on height {
        NumberAnimation {
            duration: 250
            easing.type: Easing.InOutQuad
        }

    }

}
