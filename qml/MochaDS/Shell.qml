import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // Sidebar dimensions
    property real sidebarWidth: 240
    property real secondarySidebarWidth: 200
    property real headerHeight: 56
    property real footerHeight: 48

    // Visibility and State
    property bool headerVisible: true
    property bool footerVisible: footer.length > 0
    property bool sidebarVisible: true
    property alias showSidebar: root.sidebarVisible
    property bool secondarySidebarVisible: false
    property bool sidebarCollapsed: false

    // Background visibility (to avoid "double background" when using custom sidebars)
    property bool sidebarShowBackground: sidebar.length === 0
    property bool secondarySidebarShowBackground: secondarySidebar.length === 0

    // Mobile sidebar state
    property bool sidebarOpenMobile: false

    // Column settings
    property int columnCount: 1 // 0 | 1 | 2 | 3
    property real columnSpacing: Theme.spacing.lg
    property real columnRatio1: 0
    property real columnRatio2: 0
    property real columnRatio3: 0

    // Mobile Column visibility switch
    property int activeMobileColumn: 0 // 0 = col1 | 1 = col2 | 2 = col3
    property bool isReady: false

    // Breakpoint limits
    property real breakpointMd: 768
    property real breakpointLg: 1024

    // Slots
    property list<Item> header
    property list<Item> footer
    property list<Item> sidebar
    property list<Item> secondarySidebar

    property list<Item> col1
    property list<Item> col2
    property list<Item> col3

    // ==========================================
    // Responsive State Variables (Read Only)
    // ==========================================
    readonly property bool isMobile: width < breakpointMd
    readonly property bool isTablet: width >= breakpointMd && width < breakpointLg
    readonly property bool isDesktop: width >= breakpointLg

    // Dynamic Margins and Dimensions
    readonly property real targetLeftMargin: {
        var margin = 0;
        if (!isMobile) {
            if (sidebarVisible) {
                margin += (sidebarCollapsed ? 64 : sidebarWidth);
            }
            if (secondarySidebarVisible) {
                margin += secondarySidebarWidth;
            }
        }
        return margin;
    }

    // Colors
    property color backgroundColor: Theme.colors.crust

    // Layout Dimensions
    implicitWidth: 1024
    implicitHeight: 768
    width: implicitWidth
    height: implicitHeight

    // ==========================================
    // Dynamic Reparenting of Sidebar Slots
    // ==========================================
    onIsMobileChanged: {
        reparentSidebars();
    }

    Component.onCompleted: {
        reparentSidebars();
        startupTimer.start();
    }

    Timer {
        id: startupTimer
        interval: 100
        repeat: false
        onTriggered: root.isReady = true
    }

    function reparentSidebars() {
        var targetParent = isMobile ? mobileSidebarContainer : customSidebarContainer;
        for (var i = 0; i < sidebar.length; i++) {
            sidebar[i].parent = targetParent;
        }

        var secTargetParent = isMobile ? mobileSecondarySidebarContainer : customSecondarySidebarContainer;
        for (var j = 0; j < secondarySidebar.length; j++) {
            secondarySidebar[j].parent = secTargetParent;
        }
    }

    // Helper to calculate column widths on desktop
    function calculateColumnWidth(index) {
        var visibleColumns = root.columnCount;
        if (visibleColumns < 1) return 0;
        if (visibleColumns > 3) visibleColumns = 3;

        var totalSpacing = (visibleColumns - 1) * root.columnSpacing;
        var availWidth = columnsRow.width - totalSpacing;
        if (availWidth < 0) availWidth = 0;

        var ratio1 = root.columnRatio1;
        var ratio2 = root.columnRatio2;
        var ratio3 = root.columnRatio3;

        // Default to split equally if all ratios are zero
        if (ratio1 === 0 && ratio2 === 0 && ratio3 === 0) {
            return availWidth / visibleColumns;
        }

        var activeRatios = [];
        if (visibleColumns >= 1) activeRatios.push(ratio1 > 0 ? ratio1 : 1.0 / visibleColumns);
        if (visibleColumns >= 2) activeRatios.push(ratio2 > 0 ? ratio2 : 1.0 / visibleColumns);
        if (visibleColumns >= 3) activeRatios.push(ratio3 > 0 ? ratio3 : 1.0 / visibleColumns);

        var sum = 0;
        for (var i = 0; i < activeRatios.length; i++) sum += activeRatios[i];
        if (sum <= 0) sum = 1.0;

        if (index >= activeRatios.length) return 0;
        return availWidth * (activeRatios[index] / sum);
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Background base
    Rectangle {
        id: bgPanel
        anchors.fill: parent
        color: root.backgroundColor
    }

    // 1. Header Bar
    Rectangle {
        id: headerBar
        width: parent.width
        height: root.headerVisible ? root.headerHeight : 0
        visible: root.headerVisible
        color: Theme.colors.mantle
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        anchors.top: parent.top
        anchors.left: parent.left
        z: 10
        clip: true

        // Custom Header Slot Container
        Item {
            id: customHeaderContainer
            anchors.fill: parent
            visible: root.header.length > 0

            Component.onCompleted: {
                for (var i = 0; i < root.header.length; i++) {
                    root.header[i].parent = customHeaderContainer;
                }
            }
        }

        // Default Header (renders on mobile or if no header provided)
        Row {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.md
            anchors.rightMargin: Theme.spacing.md
            spacing: Theme.spacing.md
            visible: root.header.length === 0

            Button {
                icon: "menu"
                variant: "ghost"
                size: "sm"
                visible: root.isMobile && root.sidebarVisible
                anchors.verticalCenter: parent.verticalCenter
                onClicked: root.sidebarOpenMobile = !root.sidebarOpenMobile
            }

            Text {
                text: "Mocha App"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeLg
                color: Theme.colors.text
                anchors.verticalCenter: parent.verticalCenter
                antialiasing: true
            }
        }
    }

    // 2. Docked Left Sidebar (Desktop/Tablet)
    Rectangle {
        id: leftSidebarDocked
        anchors.left: parent.left
        anchors.top: headerBar.bottom
        anchors.bottom: root.footerVisible ? footerBar.top : parent.bottom
        width: root.sidebarCollapsed ? 64 : root.sidebarWidth
        color: root.sidebarShowBackground ? Theme.colors.mantle : "transparent"
        border.color: root.sidebarShowBackground ? Theme.colors.surface0 : "transparent"
        border.width: root.sidebarShowBackground ? Theme.geometry.borderSm : 0
        visible: !root.isMobile && root.sidebarVisible
        z: 5

        Behavior on width {
            NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
        }

        Item {
            id: customSidebarContainer
            anchors.fill: parent
        }
    }

    // 3. Docked Secondary Left Sidebar (Desktop/Tablet)
    Rectangle {
        id: secondarySidebarDocked
        anchors.left: leftSidebarDocked.right
        anchors.top: headerBar.bottom
        anchors.bottom: root.footerVisible ? footerBar.top : parent.bottom
        width: root.secondarySidebarWidth
        color: root.secondarySidebarShowBackground ? Theme.colors.base : "transparent"
        border.color: root.secondarySidebarShowBackground ? Theme.colors.surface0 : "transparent"
        border.width: root.secondarySidebarShowBackground ? Theme.geometry.borderSm : 0
        visible: !root.isMobile && root.secondarySidebarVisible
        z: 4

        Item {
            id: customSecondarySidebarContainer
            anchors.fill: parent
        }
    }

    // 4. Main Content Area (reactive left margin)
    Item {
        id: contentArea
        anchors.top: headerBar.bottom
        anchors.bottom: root.footerVisible ? footerBar.top : parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.targetLeftMargin

        Behavior on anchors.leftMargin {
            enabled: root.isReady
            NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
        }

        // Columns Layout
        Row {
            id: columnsRow
            anchors.fill: parent
            anchors.margins: Theme.spacing.lg
            spacing: root.columnSpacing

            // Column 1
            Item {
                id: col1Wrapper
                height: parent.height
                visible: root.isMobile ? (root.activeMobileColumn === 0 && root.columnCount >= 1) : (root.columnCount >= 1)
                width: root.isMobile ? parent.width : root.calculateColumnWidth(0)
                opacity: visible ? 1.0 : 0.0

                Behavior on opacity { NumberAnimation { duration: 200 } }

                Item {
                    id: col1Container
                    anchors.fill: parent
                    Component.onCompleted: {
                        for (var i = 0; i < root.col1.length; i++) {
                            root.col1[i].parent = col1Container;
                        }
                    }
                }
            }

            // Column 2
            Item {
                id: col2Wrapper
                height: parent.height
                visible: root.isMobile ? (root.activeMobileColumn === 1 && root.columnCount >= 2) : (root.columnCount >= 2)
                width: root.isMobile ? parent.width : root.calculateColumnWidth(1)
                opacity: visible ? 1.0 : 0.0

                Behavior on opacity { NumberAnimation { duration: 200 } }

                Item {
                    id: col2Container
                    anchors.fill: parent
                    Component.onCompleted: {
                        for (var i = 0; i < root.col2.length; i++) {
                            root.col2[i].parent = col2Container;
                        }
                    }
                }
            }

            // Column 3
            Item {
                id: col3Wrapper
                height: parent.height
                visible: root.isMobile ? (root.activeMobileColumn === 2 && root.columnCount >= 3) : (root.columnCount >= 3)
                width: root.isMobile ? parent.width : root.calculateColumnWidth(2)
                opacity: visible ? 1.0 : 0.0

                Behavior on opacity { NumberAnimation { duration: 200 } }

                Item {
                    id: col3Container
                    anchors.fill: parent
                    Component.onCompleted: {
                        for (var i = 0; i < root.col3.length; i++) {
                            root.col3[i].parent = col3Container;
                        }
                    }
                }
            }
        }
    }

    // 5. Footer Bar
    Rectangle {
        id: footerBar
        width: parent.width
        height: root.footerVisible ? root.footerHeight : 0
        visible: root.footerVisible
        color: Theme.colors.mantle
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        z: 10
        clip: true

        // Custom Footer Slot Container
        Item {
            id: customFooterContainer
            anchors.fill: parent
            visible: root.footer.length > 0

            Component.onCompleted: {
                for (var i = 0; i < root.footer.length; i++) {
                    root.footer[i].parent = customFooterContainer;
                }
            }
        }
    }

    // ==========================================
    // Mobile Overlays & Drawers
    // ==========================================

    // Backdrop shadow on mobile
    Rectangle {
        id: mobileBackdrop
        anchors.fill: parent
        color: "#80000000"
        z: 20
        opacity: (root.isMobile && root.sidebarOpenMobile) ? 1.0 : 0.0
        visible: opacity > 0.0

        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.sidebarOpenMobile = false
        }
    }

    // Slide-out Drawer Panel on mobile
    Rectangle {
        id: mobileSidebarDrawer
        width: root.sidebarWidth
        height: parent.height
        color: Theme.colors.mantle
        border.color: Theme.colors.surface0
        border.width: Theme.geometry.borderSm
        z: 21

        x: (root.isMobile && root.sidebarOpenMobile) ? 0 : -width

        Behavior on x {
            NumberAnimation { duration: 250; easing.type: Easing.OutQuad }
        }

        Column {
            anchors.fill: parent

            // Drawer Header
            Rectangle {
                width: parent.width
                height: root.headerHeight
                color: Theme.colors.mantle
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Text {
                    text: "Menu"
                    font.family: Theme.typography.familyBold
                    font.pixelSize: Theme.typography.sizeLg
                    color: Theme.colors.text
                    anchors.centerIn: parent
                }

                // Drawer Close Button
                Button {
                    icon: "x"
                    variant: "ghost"
                    size: "sm"
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.md
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: root.sidebarOpenMobile = false
                }
            }

            // Primary Mobile Sidebar slot
            Item {
                id: mobileSidebarContainer
                width: parent.width
                height: (parent.height - root.headerHeight) * 0.6
            }

            // Divider between sidebars in mobile
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
                visible: root.secondarySidebarVisible
            }

            // Secondary Mobile Sidebar slot
            Item {
                id: mobileSecondarySidebarContainer
                width: parent.width
                height: (parent.height - root.headerHeight) * 0.4
                visible: root.secondarySidebarVisible
            }
        }
    }
}
