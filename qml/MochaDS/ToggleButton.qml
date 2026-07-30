import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property bool checked: false
    property string label: ""
    property bool disabled: false

    // Signals
    signal toggled(bool state)

    implicitWidth: labelText.visible ? (switchTrack.width + Theme.spacing.sm + labelText.implicitWidth) : switchTrack.width
    implicitHeight: Math.max(switchTrack.height, labelText.implicitHeight)
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.5 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Visual elements layout
    Row {
        spacing: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter

        // Switch Track
        Rectangle {
            id: switchTrack
            width: 46
            height: 24
            radius: 12
            color: root.checked ? Theme.colors.primary : Theme.colors.surface1
            border.color: root.checked ? "transparent" : Theme.colors.surface2
            border.width: Theme.geometry.borderSm
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 200 } }

            // Switch Thumb
            Rectangle {
                id: switchThumb
                width: 18
                height: 18
                radius: 9
                color: Theme.isDark ? (root.checked ? Theme.colors.crust : Theme.colors.text) : "#ffffff"
                anchors.verticalCenter: parent.verticalCenter
                
                // Slide thumb animation
                x: root.checked ? (switchTrack.width - switchThumb.width - 3) : 3

                Behavior on x {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutBack
                    }
                }
            }
        }

        // Optional Label
        Text {
            id: labelText
            text: root.label
            visible: text !== ""
            font.family: Theme.typography.family
            font.pixelSize: Theme.typography.sizeMd
            color: root.disabled ? Theme.colors.overlay1 : Theme.colors.text
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
        }
    }

    // Interaction Area
    MouseArea {
        anchors.fill: parent
        enabled: !root.disabled
        hoverEnabled: true
        onClicked: {
            root.checked = !root.checked;
            root.toggled(root.checked);
        }
    }
}
