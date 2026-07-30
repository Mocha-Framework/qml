import QtQuick 2.15

Item {
    id: root

    property var items: []
    property string separator: "chevron-right"
    property string size: "sm"

    readonly property real fontSize: size === "sm" ? Theme.typography.sizeSm : Theme.typography.sizeMd

    implicitWidth: breadRow.implicitWidth
    implicitHeight: breadRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Row {
        id: breadRow
        spacing: Theme.spacing.sm

        Repeater {
            model: root.items

            delegate: Row {
                spacing: Theme.spacing.sm

                Text {
                    text: modelData.label
                    font.family: index === root.items.length - 1 ? Theme.typography.familyBold : Theme.typography.family
                    font.pixelSize: root.fontSize
                    color: index === root.items.length - 1 ? Theme.colors.text : Theme.colors.primary
                    anchors.verticalCenter: parent.verticalCenter
                    antialiasing: true

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: index === root.items.length - 1 ? Qt.ArrowCursor : Qt.PointingHandCursor
                        hoverEnabled: true
                        enabled: typeof modelData.onClicked === "function" && index < root.items.length - 1
                        onClicked: {
                            if (typeof modelData.onClicked === "function") {
                                modelData.onClicked();
                            }
                        }
                    }
                }

                LucideIcon {
                    name: root.separator
                    size: root.fontSize
                    color: Theme.colors.overlay0
                    visible: index < root.items.length - 1
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }
}
