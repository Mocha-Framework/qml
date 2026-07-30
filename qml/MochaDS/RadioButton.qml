import QtQuick 2.15

Item {
    id: root

    property string label: ""
    property string value: ""
    property string size: "md"
    property bool checked: false
    property bool disabled: false

    signal clicked()

    readonly property real radioSize: size === "sm" ? 14 : (size === "lg" ? 22 : 18)
    readonly property real fontSize: size === "sm" ? Theme.typography.sizeXs : (size === "lg" ? Theme.typography.sizeMd : Theme.typography.sizeSm)

    implicitWidth: radioRow.implicitWidth
    implicitHeight: Math.max(radioSize, radioLabel.implicitHeight)
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.5 : 1.0

    Row {
        id: radioRow
        spacing: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            width: root.radioSize
            height: root.radioSize
            radius: root.radioSize / 2
            color: "transparent"
            border.color: root.checked ? Theme.colors.primary : Theme.colors.surface2
            border.width: root.checked ? 5 : Theme.geometry.borderMd
            anchors.verticalCenter: parent.verticalCenter

            Behavior on border.color { ColorAnimation { duration: 150 } }
            Behavior on border.width { NumberAnimation { duration: 100 } }
        }

        Text {
            id: radioLabel
            text: root.label
            font.family: Theme.typography.family
            font.pixelSize: root.fontSize
            color: root.disabled ? Theme.colors.overlay0 : Theme.colors.text
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: root.disabled ? Qt.ArrowCursor : Qt.PointingHandCursor
        enabled: !root.disabled
        onClicked: {
            if (!root.checked) {
                root.clicked()
            }
        }
    }
}
