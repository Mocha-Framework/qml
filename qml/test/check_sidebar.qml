import QtQuick 2.15
import QtQuick.Layouts 1.15
import ".."

Item {
    id: root
    width: 1280
    height: 720

    Rectangle {
        anchors.fill: parent
        color: Theme.colors.base
    }

    Row {
        anchors.fill: parent
        anchors.margins: Theme.spacing.lg
        spacing: Theme.spacing.xl

        // Column 1: Control Panel
        Column {
            width: 300
            height: parent.height
            spacing: Theme.spacing.lg

            Text {
                text: "Sidebar Test Dashboard"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeH2
                color: Theme.colors.text
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // Controls for Sidebar 1
            Column {
                spacing: Theme.spacing.sm
                width: parent.width

                Text {
                    text: "Sidebar Controls (Left):"
                    font.family: Theme.typography.familyMedium
                    font.pixelSize: Theme.typography.sizeLg
                    color: Theme.colors.text
                }

                Button {
                    text: "Toggle Collapse Left"
                    width: parent.width
                    onClicked: leftSidebar.isCollapsed = !leftSidebar.isCollapsed
                }

                Button {
                    text: "Toggle Hover Expand (Left)"
                    width: parent.width
                    onClicked: leftSidebar.expandOnHover = !leftSidebar.expandOnHover
                }

                Text {
                    text: "Left Sidebar info:"
                    font.family: Theme.typography.family
                    color: Theme.colors.subtext1
                }
                Text {
                    text: "Collapsed: " + leftSidebar.isCollapsed + " | Hover Expand: " + leftSidebar.expandOnHover
                    font.family: Theme.typography.family
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.subtext0
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // Controls for Sidebar 2 (Floated)
            Column {
                spacing: Theme.spacing.sm
                width: parent.width

                Text {
                    text: "Floated Sidebar Controls (Right):"
                    font.family: Theme.typography.familyMedium
                    font.pixelSize: Theme.typography.sizeLg
                    color: Theme.colors.text
                }

                Button {
                    text: "Toggle Collapse Right"
                    width: parent.width
                    onClicked: rightSidebar.isCollapsed = !rightSidebar.isCollapsed
                }

                Button {
                    text: "Toggle Hover Expand (Right)"
                    width: parent.width
                    onClicked: rightSidebar.expandOnHover = !rightSidebar.expandOnHover
                }
            }
        }

        // Column 2: Fixed Sidebar (Fixed variant)
        Item {
            width: leftSidebar.width
            height: parent.height
            // Let the layout flow know how much width we occupy logically.
            // When hovered/expanded, Sidebar's width remains collapsedWidth, but visual width expands.
            // Let's bind width to the sidebar width.
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

            Sidebar {
                id: leftSidebar
                anchors.fill: parent
                variant: "fixed"
                isCollapsed: false
                expandOnHover: true

                property string activeItem: "dashboard"

                SidebarHeader {
                    title: "Mocha Desktop"
                    subtitle: "v1.0.0"
                    logoIcon: "coffee"
                }

                SidebarSection {
                    SidebarItem {
                        label: "Dashboard"
                        icon: "layout"
                        isActive: leftSidebar.activeItem === "dashboard"
                        onClicked: leftSidebar.activeItem = "dashboard"
                    }
                    SidebarItem {
                        label: "Analytics"
                        icon: "bar-chart-2"
                        isActive: leftSidebar.activeItem === "analytics"
                        onClicked: leftSidebar.activeItem = "analytics"
                    }
                    SidebarItem {
                        label: "Orders"
                        icon: "shopping-bag"
                        isActive: leftSidebar.activeItem === "orders"
                        onClicked: leftSidebar.activeItem = "orders"
                    }
                    SidebarItem {
                        label: "Customers"
                        icon: "users"
                        isActive: leftSidebar.activeItem === "customers"
                        onClicked: leftSidebar.activeItem = "customers"
                    }
                    SidebarItem {
                        label: "Inventory"
                        icon: "box"
                        isActive: leftSidebar.activeItem === "inventory"
                        onClicked: leftSidebar.activeItem = "inventory"
                    }
                    SidebarItem {
                        label: "Settings"
                        icon: "settings"
                        isActive: leftSidebar.activeItem === "settings"
                        onClicked: leftSidebar.activeItem = "settings"
                    }
                }

                SidebarFooter {
                    username: "John Doe"
                    email: "john@mocha.org"
                    avatarIcon: "user"
                }
            }
        }

        // Column 3: Floated Sidebar (Floated variant with overflow scrolling)
        Item {
            width: rightSidebar.width
            height: parent.height
            Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.InOutQuad } }

            Sidebar {
                id: rightSidebar
                anchors.fill: parent
                variant: "floated"
                isCollapsed: true
                expandOnHover: true

                property string activeItem: "home"

                SidebarHeader {
                    title: "Design System"
                    subtitle: "QML Theme"
                    logoIcon: "palette"
                }

                // A section with many items to test vertical scrolling and scrollbar overflow prevention
                SidebarSection {
                    SidebarItem {
                        label: "Home"
                        icon: "home"
                        isActive: rightSidebar.activeItem === "home"
                        onClicked: rightSidebar.activeItem = "home"
                    }
                    SidebarItem {
                        label: "Buttons"
                        icon: "square"
                        isActive: rightSidebar.activeItem === "buttons"
                        onClicked: rightSidebar.activeItem = "buttons"
                    }
                    SidebarItem {
                        label: "Cards"
                        icon: "credit-card"
                        isActive: rightSidebar.activeItem === "cards"
                        onClicked: rightSidebar.activeItem = "cards"
                    }
                    SidebarItem {
                        label: "Dialogs"
                        icon: "alert-circle"
                        isActive: rightSidebar.activeItem === "dialogs"
                        onClicked: rightSidebar.activeItem = "dialogs"
                    }
                    SidebarItem {
                        label: "Charts"
                        icon: "activity"
                        isActive: rightSidebar.activeItem === "charts"
                        onClicked: rightSidebar.activeItem = "charts"
                    }
                    SidebarItem {
                        label: "Dropdowns"
                        icon: "chevron-down"
                        isActive: rightSidebar.activeItem === "dropdowns"
                        onClicked: rightSidebar.activeItem = "dropdowns"
                    }
                    SidebarItem {
                        label: "Inputs"
                        icon: "edit-3"
                        isActive: rightSidebar.activeItem === "inputs"
                        onClicked: rightSidebar.activeItem = "inputs"
                    }
                    SidebarItem {
                        label: "Tables"
                        icon: "grid"
                        isActive: rightSidebar.activeItem === "tables"
                        onClicked: rightSidebar.activeItem = "tables"
                    }
                    SidebarItem {
                        label: "Notifications"
                        icon: "bell"
                        isActive: rightSidebar.activeItem === "notifications"
                        onClicked: rightSidebar.activeItem = "notifications"
                    }
                    SidebarItem {
                        label: "Extra Item 1"
                        icon: "plus"
                    }
                    SidebarItem {
                        label: "Extra Item 2"
                        icon: "plus"
                    }
                    SidebarItem {
                        label: "Extra Item 3"
                        icon: "plus"
                    }
                }

                SidebarFooter {
                    username: "Jane Smith"
                    email: "jane@mocha.org"
                    avatarIcon: "smile"
                }
            }
        }
    }
}
