import QtQuick 2.15

Item {
    id: root

    property bool checked: false
    property bool disabled: false
    property string size: "md"
    property string label: ""

    signal toggled(bool checked)

    readonly property real trackWidth: size === "sm" ? 36 : (size === "lg" ? 56 : 44)
    readonly property real trackHeight: size === "sm" ? 20 : (size === "lg" ? 32 : 24)
    readonly property real thumbSize: trackHeight - 6
    readonly property real fontSize: size === "sm" ? Theme.typography.sizeXs : (size === "lg" ? Theme.typography.sizeMd : Theme.typography.sizeSm)

    implicitWidth: switchRow.implicitWidth
    implicitHeight: trackHeight
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.5 : 1.0

    Row {
        id: switchRow
        spacing: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: track
            width: root.trackWidth
            height: root.trackHeight
            radius: root.trackHeight / 2
            color: root.checked ? Theme.colors.primary : Theme.colors.surface0
            border.color: root.checked ? Theme.colors.primary : Theme.colors.surface2
            border.width: 1
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Rectangle {
                id: thumb
                width: root.thumbSize
                height: root.thumbSize
                radius: root.thumbSize / 2
                color: Theme.isDark ? (root.checked ? Theme.colors.crust : Theme.colors.text) : "#ffffff"
                x: root.checked ? root.trackWidth - root.thumbSize - 3 : 3
                anchors.verticalCenter: parent.verticalCenter

                Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
            }
        }

        Text {
            text: root.label
            font.family: Theme.typography.family
            font.pixelSize: root.fontSize
            color: root.disabled ? Theme.colors.overlay0 : Theme.colors.text
            anchors.verticalCenter: parent.verticalCenter
            visible: root.label !== ""
            antialiasing: true
        }
    }

    // Accessibility
    Accessible.role: Accessible.Button
    Accessible.name: root.label
    Accessible.checked: root.checked
    activeFocusOnTab: !root.disabled

    Keys.onReturnPressed: toggle()
    Keys.onSpacePressed: toggle()

    function toggle() {
        if (root.disabled) return
        root.checked = !root.checked;
        root.toggled(root.checked);
    }

    FocusRing {
        target: root
        active: root.activeFocus && !root.disabled
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.disabled
        onClicked: root.toggle()
    }
}
