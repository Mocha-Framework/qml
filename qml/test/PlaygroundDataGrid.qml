import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Rectangle {
    width: 960
    height: 740
    color: DS.Theme.colors.base

    ColumnLayout {
        anchors { fill: parent; margins: 24 }
        spacing: DS.Theme.spacing.md

        RowLayout {
            Layout.fillWidth: true
            spacing: DS.Theme.spacing.md

            DS.Button {
                text: dsGrid.sortable ? "Sort ON" : "Sort OFF"
                variant: "primary"
                onClicked: dsGrid.sortable = !dsGrid.sortable
            }

            DS.Button {
                text: "Reset"
                variant: "ghost"
                onClicked: dsGrid.model = _makeItems()
            }

            DS.Badge {
                text: "Cols: " + dsGrid.cols
                variant: "ghost"
            }

            Item { Layout.fillWidth: true }
        }

        DS.DataGrid {
            id: dsGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            columnsMd: 2
            columnsSm: 1
            gap: "md"
            pad: 8
            aspectRatio: 1.2
            sortable: false

            model: _makeItems()

            delegate: delegateContent
        }
    }

    property Component delegateContent: Component {
        Item {

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width * 0.86
                height: parent.height * 0.86
                radius: DS.Theme.geometry.radiusMd
                color: modelData ? Qt.hsva(modelData.hue, 0.45, 0.85, 1.0) : "#333"
                border.color: modelData ? Qt.hsva(modelData.hue, 0.45, 0.65, 1.0) : "#555"

                Column {
                    anchors.centerIn: parent
                    spacing: 10

                    Text {
                        text: "#" + (modelIndex + 1)
                        font.family: DS.Theme.typography.familyBold
                        font.pixelSize: 28
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.7
                    }

                    DS.LucideIcon {
                        name: _iconFor(modelIndex)
                        size: 24
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                        opacity: 0.9
                    }

                    Text {
                        text: modelData ? modelData.name : "?"
                        font.family: DS.Theme.typography.familyBold
                        font.pixelSize: DS.Theme.typography.sizeSm
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }

    function _iconFor(idx) {
        var icons = ["coffee", "droplets", "wind", "sun", "moon", "zap", "flame", "snowflake", "globe", "star"]
        return icons[idx % icons.length]
    }

    function _makeItems() {
        return [
            { name: "Mocha",     hue: 0.78 },
            { name: "Macchiato", hue: 0.66 },
            { name: "Frappé",    hue: 0.54 },
            { name: "Latte",     hue: 0.42 },
            { name: "Vercel",    hue: 0.30 },
            { name: "Espresso",  hue: 0.18 },
            { name: "Cappuccino",hue: 0.06 },
            { name: "Dark Roast",hue: 0.94 },
            { name: "Colombian", hue: 0.88 },
            { name: "Ethiopian", hue: 0.82 }
        ]
    }
}
