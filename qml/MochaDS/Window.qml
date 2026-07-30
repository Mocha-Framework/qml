import QtQuick 2.15
import QtQuick.Window 2.15
import MochaDS

Window {
    id: root

    default property alias content: contentContainer.data

    property string titleText: ""
    property string caption: ""
    property string icon: ""
    property string themeMode: "catppuccin"
    property string flavor: Theme.flavor
    property bool showCaption: true
    property bool resizable: true
    property real captionHeight: 44
    property real handleSize: 6

    property color captionBackground: Theme.colors.mantle
    property color captionTextColor: Theme.colors.text
    property color buttonHover: Theme.colors.surface0
    property color buttonCloseHover: Theme.colors.red
    property color borderColor: Theme.colors.surface1

    property int minimumWidth: 400
    property int minimumHeight: 300

    signal minimized()
    signal maximized()
    signal restored()
    signal closed()

    flags: Qt.Window | Qt.FramelessWindowHint
    color: Theme.colors.background

    // font.family: Theme.typography.family
    // font.pixelSize: Theme.typography.sizeMd

    onThemeModeChanged: Theme.useSystemTheme = (themeMode === "system")
    onFlavorChanged: {
        if (Theme.flavor !== flavor) Theme.flavor = flavor
    }

    Component.onCompleted: {
        Theme.useSystemTheme = (themeMode === "system")
    }

    Connections {
        target: Theme
        ignoreUnknownSignals: true
        function onFlavorChanged() {
            if (root.flavor !== Theme.flavor) root.flavor = Theme.flavor
        }
    }

    onClosing: root.closed()

    // ----- Maximized state -----
    property bool __maximized: false
    property rect __savedGeometry: Qt.rect(0, 0, 800, 600)
    property int __edge: 0
    property real __sx: 0
    property real __sy: 0
    property real __sw: 0
    property real __sh: 0
    property real __mx: 0
    property real __my: 0

    // ----- 1px border outline -----
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.color: root.borderColor
        border.width: 1
        z: 9999
    }

    // ----- Main layout -----
    Column {
        anchors.fill: parent
        spacing: 0

        // Caption bar
        Item {
            id: captionBar
            width: parent.width
            height: root.showCaption ? root.captionHeight : 0
            visible: root.showCaption
            z: 9998

            Rectangle {
                anchors.fill: parent
                color: root.captionBackground
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 1
                color: root.borderColor
            }

            // Window move — native system drag (zero lag)
            MouseArea {
                id: moveArea
                anchors.fill: parent
                enabled: root.showCaption && !root.__maximized
                acceptedButtons: Qt.LeftButton
                onPressed: {
                    if (typeof root.startSystemMove === "function") {
                        root.startSystemMove()
                    }
                }
            }

            // Icon
            LucideIcon {
                x: Theme.spacing.lg
                anchors.verticalCenter: parent.verticalCenter
                name: root.icon
                size: 18
                color: root.captionTextColor
                visible: root.icon !== ""
            }

            // Title
            Text {
                id: titleLabel
                anchors.centerIn: parent
                text: root.titleText
                font.family: Theme.typography.familyMedium
                font.pixelSize: Theme.typography.sizeMd
                color: root.captionTextColor
                elide: Text.ElideRight
            }

            // Window controls
            Row {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.sm
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.spacing.xs

                // Minimize
                Item {
                    id: minimizeBtn
                    width: 36
                    height: 36

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.geometry.radiusSm
                        color: mMin.containsMouse ? root.buttonHover : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        LucideIcon {
                            anchors.centerIn: parent; name: "minus"; size: 16; color: root.captionTextColor
                        }
                    }
                    MouseArea {
                        id: mMin; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            root.visibility = Window.Minimized
                            root.minimized()
                        }
                    }
                }

                // Maximize / Restore
                Item {
                    id: maxBtn
                    width: 36
                    height: 36

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.geometry.radiusSm
                        color: mMax.containsMouse ? root.buttonHover : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        LucideIcon {
                            anchors.centerIn: parent
                            name: root.__maximized ? "minimize-2" : "maximize-2"
                            size: 16
                            color: root.captionTextColor
                        }
                    }
                    MouseArea {
                        id: mMax; anchors.fill: parent; hoverEnabled: true
                        onClicked: toggleMaximized()
                    }
                }

                // Close
                Item {
                    id: closeBtn
                    width: 36
                    height: 36

                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.geometry.radiusSm
                        color: mClose.containsMouse ? root.buttonCloseHover : "transparent"
                        Behavior on color { ColorAnimation { duration: 100 } }
                        LucideIcon {
                            anchors.centerIn: parent; name: "x"; size: 16
                            color: mClose.containsMouse ? Theme.colors.base : root.captionTextColor
                        }
                    }
                    MouseArea {
                        id: mClose; anchors.fill: parent; hoverEnabled: true
                        onClicked: root.close()
                    }
                }
            }

            // Double-click to toggle maximize
            MouseArea {
                anchors.fill: parent
                anchors.rightMargin: 120
                enabled: root.showCaption && root.resizable
                acceptedButtons: Qt.LeftButton
                onDoubleClicked: toggleMaximized()
            }
        }

        // Content
        Item {
            id: contentContainer
            width: parent.width
            height: parent.height - captionBar.height
            clip: true
        }
    }

    // ----- Resize handles -----
    MouseArea {
        id: resizeTL
        x: 0; y: 0
        width: root.handleSize * 3; height: root.handleSize * 3
        enabled: root.resizable && !root.__maximized
        cursorShape: Qt.SizeFDiagCursor

        onPressed: function(m) { __edge = 5; __sx = root.x; __sy = root.y; __sw = root.width; __sh = root.height; __mx = m.screenX; __my = m.screenY }
        onPositionChanged: function(m) { if (!pressed) return; doResize(m, 5) }
        onReleased: __edge = 0
    }

    MouseArea {
        id: resizeTR
        x: parent.width - root.handleSize * 3; y: 0
        width: root.handleSize * 3; height: root.handleSize * 3
        enabled: root.resizable && !root.__maximized
        cursorShape: Qt.SizeBDiagCursor

        onPressed: function(m) { __edge = 6; __sx = root.x; __sy = root.y; __sw = root.width; __sh = root.height; __mx = m.screenX; __my = m.screenY }
        onPositionChanged: function(m) { if (!pressed) return; doResize(m, 6) }
        onReleased: __edge = 0
    }

    MouseArea {
        id: resizeBL
        x: 0; y: parent.height - root.handleSize * 3
        width: root.handleSize * 3; height: root.handleSize * 3
        enabled: root.resizable && !root.__maximized
        cursorShape: Qt.SizeBDiagCursor

        onPressed: function(m) { __edge = 7; __sx = root.x; __sy = root.y; __sw = root.width; __sh = root.height; __mx = m.screenX; __my = m.screenY }
        onPositionChanged: function(m) { if (!pressed) return; doResize(m, 7) }
        onReleased: __edge = 0
    }

    MouseArea {
        id: resizeBR
        x: parent.width - root.handleSize * 3; y: parent.height - root.handleSize * 3
        width: root.handleSize * 3; height: root.handleSize * 3
        enabled: root.resizable && !root.__maximized
        cursorShape: Qt.SizeFDiagCursor

        onPressed: function(m) { __edge = 8; __sx = root.x; __sy = root.y; __sw = root.width; __sh = root.height; __mx = m.screenX; __my = m.screenY }
        onPositionChanged: function(m) { if (!pressed) return; doResize(m, 8) }
        onReleased: __edge = 0
    }

    MouseArea {
        id: resizeLeft
        x: 0; y: root.handleSize * 3
        width: root.handleSize; height: parent.height - root.handleSize * 6
        enabled: root.resizable && !root.__maximized
        cursorShape: Qt.SizeHorCursor

        onPressed: function(m) { __edge = 1; __sx = root.x; __sy = root.y; __sw = root.width; __sh = root.height; __mx = m.screenX; __my = m.screenY }
        onPositionChanged: function(m) { if (!pressed) return; doResize(m, 1) }
        onReleased: __edge = 0
    }

    MouseArea {
        id: resizeRight
        x: parent.width - root.handleSize; y: root.handleSize * 3
        width: root.handleSize; height: parent.height - root.handleSize * 6
        enabled: root.resizable && !root.__maximized
        cursorShape: Qt.SizeHorCursor

        onPressed: function(m) { __edge = 2; __sx = root.x; __sy = root.y; __sw = root.width; __sh = root.height; __mx = m.screenX; __my = m.screenY }
        onPositionChanged: function(m) { if (!pressed) return; doResize(m, 2) }
        onReleased: __edge = 0
    }

    MouseArea {
        id: resizeTop
        x: root.handleSize * 3; y: 0
        width: parent.width - root.handleSize * 6; height: root.handleSize
        enabled: root.resizable && !root.__maximized
        cursorShape: Qt.SizeVerCursor

        onPressed: function(m) { __edge = 3; __sx = root.x; __sy = root.y; __sw = root.width; __sh = root.height; __mx = m.screenX; __my = m.screenY }
        onPositionChanged: function(m) { if (!pressed) return; doResize(m, 3) }
        onReleased: __edge = 0
    }

    MouseArea {
        id: resizeBottom
        x: root.handleSize * 3; y: parent.height - root.handleSize
        width: parent.width - root.handleSize * 6; height: root.handleSize
        enabled: root.resizable && !root.__maximized
        cursorShape: Qt.SizeVerCursor

        onPressed: function(m) { __edge = 4; __sx = root.x; __sy = root.y; __sw = root.width; __sh = root.height; __mx = m.screenX; __my = m.screenY }
        onPositionChanged: function(m) { if (!pressed) return; doResize(m, 4) }
        onReleased: __edge = 0
    }

    // ----- Helpers -----

    function doResize(m, edge) {
        var dx = m.screenX - __mx
        var dy = m.screenY - __my
        var newX = root.x
        var newY = root.y
        var newW = root.width
        var newH = root.height

        if (edge === 1 || edge === 5 || edge === 7) {
            newX = __sx + dx
            newW = __sw - dx
            if (newW < root.minimumWidth) {
                newX = __sx + __sw - root.minimumWidth
                newW = root.minimumWidth
            }
        }
        if (edge === 2 || edge === 6 || edge === 8) {
            newW = __sw + dx
            if (newW < root.minimumWidth) newW = root.minimumWidth
        }
        if (edge === 3 || edge === 5 || edge === 6) {
            newY = __sy + dy
            newH = __sh - dy
            if (newH < root.minimumHeight) {
                newY = __sy + __sh - root.minimumHeight
                newH = root.minimumHeight
            }
        }
        if (edge === 4 || edge === 7 || edge === 8) {
            newH = __sh + dy
            if (newH < root.minimumHeight) newH = root.minimumHeight
        }

        root.x = newX
        root.y = newY
        root.width = newW
        root.height = newH
    }

    function toggleMaximized() {
        if (!root.resizable) return
        if (root.__maximized) {
            root.restored()
            root.__maximized = false
            root.x = __savedGeometry.x
            root.y = __savedGeometry.y
            root.width = __savedGeometry.width
            root.height = __savedGeometry.height
        } else {
            root.maximized()
            __savedGeometry = Qt.rect(root.x, root.y, root.width, root.height)
            root.__maximized = true
            root.x = 0
            root.y = 0
            if (typeof Screen !== "undefined") {
                root.width = Screen.desktopAvailableWidth
                root.height = Screen.desktopAvailableHeight
            } else {
                root.width = 1280
                root.height = 800
            }
        }
    }

    function minimize() {
        root.visibility = Window.Minimized
        root.minimized()
    }
}
