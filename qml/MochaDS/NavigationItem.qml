import QtQuick 2.15

Item {
    id: root

    // Identifier for NavigationBar child logic
    readonly property bool isNavigationItem: true

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property string iconName: ""
    property string label: ""

    // ==========================================
    // Internal state & parent resolution
    // ==========================================
    readonly property Item navigationBar: {
        var p = parent;
        while (p && !p.isNavigationBar) {
            p = p.parent;
        }
        return p;
    }

    readonly property int index: navigationBar ? navigationBar.itemsList.indexOf(this) : -1
    readonly property bool isActive: navigationBar ? navigationBar.currentIndex === index : false
    readonly property string variant: navigationBar ? navigationBar.variant : "standard"
    readonly property color highlightColor: navigationBar ? navigationBar.highlightColor : Theme.colors.primary
    readonly property color hoverColor: Qt.rgba(highlightColor.r, highlightColor.g, highlightColor.b, 0.12)
    property real expandingProgress: (variant === "expanding" && isActive) ? 1.0 : 0.0

    // Popout animation offset
    readonly property real activeY: (variant === "floating" && isActive) ? -28 : 0

    // ==========================================
    // Lifecycle
    // ==========================================
    Component.onCompleted: {
        if (navigationBar) {
            navigationBar.registerItem(this);
        }
    }

    Component.onDestruction: {
        if (navigationBar) {
            navigationBar.unregisterItem(this);
        }
    }

    // ==========================================
    // Dimensions
    // ==========================================
    implicitHeight: navigationBar ? (navigationBar.variant === "labeled" ? 56 : 40) : 40
    
    // Dynamic width driven by reveal progress for expanding variant
    width: {
        if (variant === "expanding") {
            return 40 + (horizontalText.implicitWidth * expandingProgress) + (12 * expandingProgress)
        } else if (variant === "labeled") {
            return 72
        } else {
            return 40
        }
    }
    height: implicitHeight

    Behavior on expandingProgress {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    // Cozy scale micro-animation on hover + press
    scale: mouseArea.pressed ? 0.97 : (mouseArea.containsMouse ? 1.01 : 1.0)
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    activeFocusOnTab: index >= 0

    Keys.onReturnPressed: {
        if (navigationBar && root.index >= 0) {
            navigationBar.currentIndex = root.index;
        }
    }
    Keys.onSpacePressed: {
        if (navigationBar && root.index >= 0) {
            navigationBar.currentIndex = root.index;
        }
    }

    Accessible.role: Accessible.Button
    Accessible.name: root.label

    // ==========================================
    // Visual Tree
    // ==========================================

    // 1. Horizontal Layout Container (standard, floating, expanding)
    Item {
        id: horizontalLayoutContainer
        anchors.fill: parent
        visible: root.variant !== "labeled"

        // Active container shifts up on Y (no anchors so Y animation works!)
        Item {
            id: activeContainer
            width: parent.width
            height: parent.height
            x: 0
            y: root.activeY
            
            Behavior on y {
                SpringAnimation { spring: 3.2; damping: 0.55 }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: root.variant === "labeled" ? 2 : 0
                radius: height / 2
                color: root.hoverColor
                opacity: !root.isActive && mouseArea.containsMouse ? 1.0 : 0.0

                Behavior on opacity { NumberAnimation { duration: 120 } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            // Row containing the icon and the text
            Row {
                id: rowLayout
                anchors.centerIn: parent
                spacing: root.variant === "expanding" ? 8 * root.expandingProgress : 0
                
                Behavior on spacing {
                    NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                }

                LucideIcon {
                    id: horizontalIcon
                    name: root.iconName
                    size: 24
                    color: root.isActive 
                        ? Theme.colors.base 
                        : (mouseArea.containsMouse ? Theme.colors.text : Theme.colors.subtext0)
                    anchors.verticalCenter: parent.verticalCenter
                    
                    Behavior on color { ColorAnimation { duration: 200 } }
                }

                Text {
                    id: horizontalText
                    text: root.label
                    font.family: Theme.typography.familyMedium
                    font.pixelSize: Theme.typography.sizeMd
                    color: Theme.colors.base
                    
                    width: root.variant === "expanding" ? implicitWidth * root.expandingProgress : 0
                    clip: true
                    opacity: root.variant === "expanding" ? root.expandingProgress : 0.0
                    scale: root.variant === "expanding" ? (0.94 + (0.06 * root.expandingProgress)) : 1.0
                    transformOrigin: Item.Left
                    
                    Behavior on width {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }
                    Behavior on opacity {
                        NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                    }

                    anchors.verticalCenter: parent.verticalCenter
                    antialiasing: true
                }
            }
        }

        // Active label for floating variant fading in at the bottom
        Text {
            text: root.label
            font.family: Theme.typography.familyMedium
            font.pixelSize: 10
            color: root.highlightColor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: (root.variant === "floating" && root.isActive) ? 1.0 : 0.0
            
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }

    // 2. Vertical Layout Container (labeled)
    Item {
        id: verticalLayoutContainer
        anchors.fill: parent
        visible: root.variant === "labeled"

        Item {
            id: verticalIconWrapper
            width: 40
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            y: root.isActive ? 4 : 8

            Behavior on y {
                SpringAnimation { spring: 3; damping: 0.6 }
            }

            LucideIcon {
                id: verticalIcon
                name: root.iconName
                size: 24
                color: root.isActive 
                    ? Theme.colors.base 
                    : (mouseArea.containsMouse ? Theme.colors.text : Theme.colors.subtext0)
                anchors.centerIn: parent
                
                Behavior on color { ColorAnimation { duration: 200 } }
            }
        }

        Text {
            id: verticalText
            text: root.label
            font.family: Theme.typography.familyMedium
            font.pixelSize: 10
            y: root.isActive ? 42 : 48
            opacity: root.isActive ? 1.0 : 0.0
            
            color: root.isActive 
                ? root.highlightColor 
                : (mouseArea.containsMouse ? Theme.colors.text : Theme.colors.subtext0)
            anchors.horizontalCenter: parent.horizontalCenter
            antialiasing: true
            
            Behavior on y {
                SpringAnimation { spring: 3; damping: 0.6 }
            }
            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }
        }
    }

    // ==========================================
    // Mouse Area
    // ==========================================
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (navigationBar) {
                navigationBar.currentIndex = root.index;
            }
        }
    }

    FocusRing {
        target: root
        active: root.activeFocus
    }
}
