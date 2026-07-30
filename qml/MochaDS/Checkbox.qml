import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property bool checked: false
    property string label: ""
    property bool disabled: false

    // Form validation
    property string errorText: ""
    property bool isInvalid: errorText.length > 0

    // Signals
    signal toggled(bool isChecked)

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property real boxSize: 20
    readonly property real finalRadius: Theme.geometry.radiusSm

    readonly property color boxColor: {
        if (disabled) return Theme.colors.crust
        if (checked) {
            return mouseArea.pressed ? Qt.darker(Theme.colors.primary, 1.1) : (mouseArea.containsMouse ? Qt.lighter(Theme.colors.primary, 1.05) : Theme.colors.primary)
        }
        return mouseArea.containsMouse ? Theme.colors.surface1 : Theme.colors.mantle
    }

    readonly property color borderColor: {
        if (disabled) return Theme.colors.surface0
        if (checked) return "transparent"
        if (mouseArea.containsMouse) return Theme.colors.overlay0
        return Theme.colors.surface1
    }

    readonly property color checkColor: Theme.colors.crust

    // Layout Dimensions
    implicitWidth: checkRow.implicitWidth
    implicitHeight: Math.max(boxSize, labelText.implicitHeight)
    width: implicitWidth
    height: implicitHeight

    // Cozy micro-animations
    scale: disabled ? 1.0 : (mouseArea.pressed ? 0.97 : (mouseArea.containsMouse ? 1.03 : 1.0))
    opacity: disabled ? 0.5 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 120; easing.type: Easing.OutBack }
    }

    Behavior on opacity {
        NumberAnimation { duration: 150 }
    }

    // Horizontal Row Layout
    Row {
        id: checkRow
        spacing: Theme.spacing.md
        anchors.verticalCenter: parent.verticalCenter

        // Checkbox Box Rectangle
        Rectangle {
            id: checkboxBox
            width: root.boxSize
            height: root.boxSize
            radius: root.finalRadius
            color: root.boxColor
            border.color: root.borderColor
            border.width: Theme.geometry.borderSm
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            // Checkmark Icon
            LucideIcon {
                id: checkIcon
                name: "check"
                size: 14
                color: root.checkColor
                anchors.centerIn: parent
                
                // Animate checkmark visibility scaling
                scale: root.checked ? 1.0 : 0.0
                opacity: root.checked ? 1.0 : 0.0

                Behavior on scale {
                    NumberAnimation { duration: 180; easing.type: Easing.OutBack }
                }
                Behavior on opacity {
                    NumberAnimation { duration: 120 }
                }
            }
        }

        // Label Text
        Text {
            id: labelText
            text: root.label
            font.family: Theme.typography.family
            font.pixelSize: Theme.typography.sizeMd
            color: root.disabled ? Theme.colors.overlay0 : Theme.colors.text
            visible: root.label !== ""
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    // Accessibility
    Accessible.role: Accessible.CheckBox
    Accessible.name: root.label
    Accessible.checked: root.checked
    activeFocusOnTab: !root.disabled

    // Keyboard support
    Keys.onReturnPressed: toggle()
    Keys.onSpacePressed: toggle()

    function toggle() {
        if (root.disabled) return
        root.checked = !root.checked;
        root.toggled(root.checked);
    }

    // Focus ring overlay
    FocusRing {
        target: root
        active: root.activeFocus && !root.disabled
    }

    // Entire Area mouse click interaction
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        onClicked: root.toggle()
    }
}
