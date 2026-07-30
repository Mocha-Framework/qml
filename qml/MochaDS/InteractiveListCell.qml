import QtQuick 2.15

Item {
    // ==========================================
    // Visual Tree
    // ==========================================

    id: root

    // ==========================================
    // Public API
    // ==========================================
    property Component rowContent
    property bool isSelected: false
    // Explicitly passed model context from CozyList delegate
    property var cellModelData: null
    property int cellIndex: -1
    // Styling overrides
    property color backgroundColor: "transparent"
    property color hoverColor: Qt.rgba(Theme.colors.surface0.r, Theme.colors.surface0.g, Theme.colors.surface0.b, 0.4)
    property color pressedColor: Qt.rgba(Theme.colors.surface0.r, Theme.colors.surface0.g, Theme.colors.surface0.b, 0.8)
    property color borderColor: "transparent"
    property color hoverBorderColor: Qt.rgba(Theme.colors.surface1.r, Theme.colors.surface1.g, Theme.colors.surface1.b, 0.5)
    property real radius: Theme.geometry.radiusMd
    property real borderWidth: Theme.geometry.borderSm
    // Margins around the Loader content inside the pill
    property real paddingHorizontal: Theme.spacing.md
    property real paddingVertical: Theme.spacing.sm

    signal clicked()

    // Dimensions
    implicitHeight: Math.max(48, contentLoader.implicitHeight + (paddingVertical * 2))
    width: parent ? parent.width : 300
    // Cozy scale micro-animation on press + hover
    scale: mouseArea.pressed ? 0.985 : (mouseArea.containsMouse ? 1.005 : 1)
    activeFocusOnTab: true
    Keys.onReturnPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()
    Accessible.role: Accessible.Button
    Accessible.name: "Interactive list cell"

    // Pill background & border container
    Rectangle {
        id: bgPanel

        anchors.fill: parent
        radius: root.radius
        color: {
            if (mouseArea.pressed)
                return root.pressedColor;

            if (mouseArea.containsMouse)
                return root.hoverColor;

            if (root.isSelected)
                return Theme.colors.surface0;

            return root.backgroundColor;
        }
        border.color: {
            if (mouseArea.containsMouse || root.isSelected)
                return root.hoverBorderColor;

            return root.borderColor;
        }
        border.width: root.borderWidth

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }

        }

    }

    // Hover & Click Area
    MouseArea {
        id: mouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked();
        }
    }

    // Loader for custom visual structure (rowContent)
    Loader {
        // Propagate list cell context explicitly to Loader children if needed,
        // though Qt Quick's Loader automatically delegates context

        id: contentLoader

        // Expose modelData, model, and index to the loaded component
        property var modelData: root.cellModelData
        property var model: root.cellModelData
        property int index: root.cellIndex

        anchors.fill: parent
        anchors.leftMargin: root.paddingHorizontal
        anchors.rightMargin: root.paddingHorizontal
        anchors.topMargin: root.paddingVertical
        anchors.bottomMargin: root.paddingVertical
        sourceComponent: root.rowContent
    }

    FocusRing {
        target: root
        active: root.activeFocus
    }

    Behavior on scale {
        NumberAnimation {
            duration: 120
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }

    }

}
