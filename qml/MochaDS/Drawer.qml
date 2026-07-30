import QtQuick 2.15
import QtQuick.Window 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // Control visibility and trigger open/close slide animations
    property bool open: false

    // Header Title
    property string title: ""

    // Header Subtitle/Description
    property string subtitle: ""

    // Drawer placement: "right" | "left" | "top" | "bottom"
    property string position: "right"

    // Drawer width (for left/right) or height (for top/bottom)
    property real size: 360

    // Configuration flags
    property bool closeOnBackdropClick: true
    property bool closeOnEscape: true
    property bool showCloseButton: true
    property bool usePortal: true

    // Style overrides
    property real customRadius: -1

    // Slots
    default property alias content: customContentContainer.data
    property alias footer: footerContainer.data

    // ==========================================
    // Signals
    // ==========================================
    signal opened()
    signal closed()

    // ==========================================
    // Internal Properties & Calculations
    // ==========================================
    readonly property real finalWidth: (position === "top" || position === "bottom") ? root.width : size
    readonly property real finalHeight: (position === "left" || position === "right") ? root.height : size

    readonly property real defaultRadius: Theme.geometry.radiusLg
    readonly property real finalRadius: customRadius >= 0 ? customRadius : defaultRadius

    readonly property real headerHeight: headerSection.visible ? headerSection.height + Theme.spacing.md : 0
    readonly property real footerHeight: footerSection.visible ? footerSection.height + Theme.spacing.md : 0

    // ==========================================
    // Lifecycle & Portal Mechanism
    // ==========================================
    Component.onCompleted: {
        if (usePortal) {
            hoistToRoot();
        }
    }

    function hoistToRoot() {
        var rootItem = null;
        var nextParent = parent;
        while (nextParent) {
            rootItem = nextParent;
            nextParent = nextParent.parent;
        }

        if (rootItem && rootItem !== parent) {
            root.parent = rootItem;
            // Clear current anchors if any and fill the rootItem
            root.anchors.fill = undefined;
            root.anchors.fill = rootItem;
        }
    }

    // Dynamic stacking: increment z-index to be on top of all siblings
    function bringToFront() {
        root.z = Theme.getNextMaxZ();
    }

    onOpenChanged: {
        if (open) {
            bringToFront();
            root.forceActiveFocus();
        }
    }

    // Keyboard handling
    focus: true
    Keys.onPressed: {
        if (open && closeOnEscape && event.key === Qt.Key_Escape) {
            event.accepted = true;
            root.open = false;
        }
    }

    // Layout configuration
    anchors.fill: parent
    visible: false
    opacity: 0.0

    // ==========================================
    // States and Cozy Transitions
    // ==========================================
    state: "closed"

    states: [
        State {
            name: "open"
            when: root.open
            PropertyChanges { target: root; opacity: 1.0 }
            PropertyChanges { target: backdrop; opacity: 0.7 }
            PropertyChanges { target: drawerContainer; opacity: 1.0 }
            PropertyChanges {
                target: drawerContainer
                x: {
                    if (position === "right") return root.width - drawerContainer.width;
                    if (position === "left") return 0;
                    return 0; // top/bottom
                }
                y: {
                    if (position === "bottom") return root.height - drawerContainer.height;
                    if (position === "top") return 0;
                    return 0; // left/right
                }
            }
        },
        State {
            name: "closed"
            when: !root.open
            PropertyChanges { target: root; opacity: 0.0 }
            PropertyChanges { target: backdrop; opacity: 0.0 }
            PropertyChanges { target: drawerContainer; opacity: 0.94 }
            PropertyChanges {
                target: drawerContainer
                x: {
                    if (position === "right") return root.width;
                    if (position === "left") return -drawerContainer.width;
                    return 0;
                }
                y: {
                    if (position === "bottom") return root.height;
                    if (position === "top") return -drawerContainer.height;
                    return 0;
                }
            }
        }
    ]

    transitions: [
        Transition {
            from: "closed"; to: "open"
            SequentialAnimation {
                PropertyAction { target: root; property: "visible"; value: true }
                ParallelAnimation {
                    NumberAnimation { target: root; property: "opacity"; duration: 150; easing.type: Easing.OutQuad }
                    NumberAnimation { target: backdrop; property: "opacity"; duration: 200; easing.type: Easing.OutQuad }
                    NumberAnimation { target: drawerContainer; property: "opacity"; duration: 180; easing.type: Easing.OutQuad }
                    NumberAnimation { target: drawerContainer; properties: "x,y"; duration: 250; easing.type: Easing.OutCubic }
                }
                ScriptAction { script: root.opened() }
            }
        },
        Transition {
            from: "open"; to: "closed"
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation { target: root; property: "opacity"; duration: 200; easing.type: Easing.InQuad }
                    NumberAnimation { target: backdrop; property: "opacity"; duration: 200; easing.type: Easing.InQuad }
                    NumberAnimation { target: drawerContainer; property: "opacity"; duration: 160; easing.type: Easing.InQuad }
                    NumberAnimation { target: drawerContainer; properties: "x,y"; duration: 220; easing.type: Easing.InCubic }
                }
                PropertyAction { target: root; property: "visible"; value: false }
                ScriptAction { script: root.closed() }
            }
        }
    ]

    // ==========================================
    // Visual Tree
    // ==========================================

    // Backdrop overlay
    Rectangle {
        id: backdrop
        anchors.fill: parent
        color: "#0a0a0f"
        opacity: 0.0

        Behavior on color { ColorAnimation { duration: 150 } }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.AllButtons
            onPressed: {
                root.bringToFront();
            }
            onClicked: {
                if (root.closeOnBackdropClick) {
                    root.open = false;
                }
            }
            onWheel: {
                // Intercept and accept wheel events to prevent scrolling the background Flickable
                wheel.accepted = true;
            }
        }
    }

    // Drawer Sliding Content Card
    Rectangle {
        id: drawerContainer
        width: root.finalWidth
        height: root.finalHeight
        color: Theme.colors.base
        radius: root.finalRadius
        border.color: Theme.colors.surface1
        border.width: Theme.geometry.borderSm
        clip: true
        opacity: 0.94

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // Block mouse click propagation to backdrop
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onPressed: {
                root.bringToFront();
            }
            onClicked: { /* consume event */ }
        }

        // Header Section
        Item {
            id: headerSection
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.xl
            height: (root.title !== "" || root.subtitle !== "" || root.showCloseButton) ? Math.max(headerColumn.implicitHeight, root.showCloseButton ? 32 : 0) : 0
            visible: height > 0
            opacity: root.open ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: 140 } }

            Column {
                id: headerColumn
                anchors.left: parent.left
                anchors.right: root.showCloseButton ? closeButton.left : parent.right
                anchors.rightMargin: root.showCloseButton ? Theme.spacing.md : 0
                spacing: Theme.spacing.xs

                Text {
                    text: root.title
                    width: parent.width
                    font.family: Theme.typography.familyBold
                    font.pixelSize: Theme.typography.sizeH2
                    color: Theme.colors.text
                    wrapMode: Text.WordWrap
                    antialiasing: true
                }

                Text {
                    text: root.subtitle
                    width: parent.width
                    font.family: Theme.typography.family
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.subtext0
                    wrapMode: Text.WordWrap
                    visible: root.subtitle !== ""
                    antialiasing: true
                }
            }

            // Close X Button
            Button {
                id: closeButton
                anchors.right: parent.right
                anchors.top: parent.top
                variant: "ghost"
                size: "sm"
                icon: "x"
                customRadius: Theme.geometry.radiusPill
                visible: root.showCloseButton
                onClicked: root.open = false
            }
        }

        // Header Divider
        Rectangle {
            id: headerDivider
            anchors.top: headerSection.bottom
            anchors.topMargin: Theme.spacing.md
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.geometry.borderSm
            color: Theme.colors.surface0
            visible: headerSection.visible && bodyFlickable.visible
        }

        // Footer Section
        Item {
            id: footerSection
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: Theme.spacing.xl
            height: footerContainer.implicitHeight
            visible: height > 0
            opacity: root.open ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: 140 } }

            Column {
                id: footerContainer
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing: Theme.spacing.md

                onChildrenChanged: {
                    for (var i = 0; i < children.length; i++) {
                        var child = children[i];
                        if (child && (child.width === 0 || child.width === child.implicitWidth || child.width === undefined)) {
                            child.width = Qt.binding(function() { return footerContainer.width; });
                        }
                    }
                }
            }
        }

        // Footer Divider
        Rectangle {
            id: footerDivider
            anchors.bottom: footerSection.top
            anchors.bottomMargin: Theme.spacing.md
            anchors.left: parent.left
            anchors.right: parent.right
            height: Theme.geometry.borderSm
            color: Theme.colors.surface0
            visible: footerSection.visible && bodyFlickable.visible
        }

        // Body Content (Flickable)
        Flickable {
            id: bodyFlickable
            anchors.top: headerDivider.visible ? headerDivider.bottom : headerSection.bottom
            anchors.topMargin: headerDivider.visible ? Theme.spacing.md : Theme.spacing.xl
            anchors.bottom: footerDivider.visible ? footerDivider.top : footerSection.top
            anchors.bottomMargin: footerDivider.visible ? Theme.spacing.md : Theme.spacing.xl
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.spacing.xl
            anchors.rightMargin: Theme.spacing.xl
            contentWidth: width
            contentHeight: customContentContainer.implicitHeight
            clip: true
            opacity: root.open ? 1.0 : 0.0

            Behavior on opacity { NumberAnimation { duration: 140 } }

            Item {
                id: customContentContainer
                width: parent.width

                implicitHeight: {
                    var h = 0;
                    for (var i = 0; i < children.length; i++) {
                        var child = children[i];
                        if (child.visible) {
                            var ch = child.implicitHeight > 0 ? child.implicitHeight : child.height;
                            h = Math.max(h, child.y + ch);
                        }
                    }
                    return h;
                }
            }
        }

        // Cozy Custom Scrollbar
        Rectangle {
            id: scrollbarTrack
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.xs
            anchors.top: bodyFlickable.top
            anchors.bottom: bodyFlickable.bottom
            width: 4
            radius: 2
            color: Theme.colors.surface0
            opacity: bodyFlickable.visibleArea.heightRatio < 1.0 ? 0.3 : 0.0

            Behavior on opacity { NumberAnimation { duration: 150 } }

            Rectangle {
                id: scrollbarThumb
                width: parent.width
                height: Math.max(24, parent.height * bodyFlickable.visibleArea.heightRatio)
                y: parent.height * bodyFlickable.visibleArea.yPosition
                radius: parent.radius
                color: Theme.colors.primary
            }
        }
    }
}
