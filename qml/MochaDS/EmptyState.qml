import QtQuick 2.15

Item {
    id: root

    property string icon: "inbox"
    property string title: "Nenhum registro encontrado"
    property string description: ""
    property string size: "md"

    readonly property real iconSize: size === "sm" ? 24 : (size === "lg" ? 56 : 40)
    readonly property real titleFontSize: size === "sm" ? Theme.typography.sizeSm : (size === "lg" ? Theme.typography.sizeLg : Theme.typography.sizeMd)

    implicitWidth: 200
    implicitHeight: contentColumn.implicitHeight + Theme.spacing.xl * 2
    width: implicitWidth
    height: implicitHeight

    Column {
        id: contentColumn
        anchors.centerIn: parent
        spacing: Theme.spacing.sm

        LucideIcon {
            name: root.icon
            size: root.iconSize
            color: Theme.colors.overlay0
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: root.title
            font.family: Theme.typography.familyMedium
            font.pixelSize: root.titleFontSize
            color: Theme.colors.overlay0
            anchors.horizontalCenter: parent.horizontalCenter
            antialiasing: true
        }

        Text {
            text: root.description
            font.family: Theme.typography.family
            font.pixelSize: Theme.typography.sizeSm
            color: Theme.colors.overlay1
            visible: root.description !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
            antialiasing: true
        }
    }
}
