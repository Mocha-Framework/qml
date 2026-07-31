import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Item {
    id: root
    
    property alias componentItem: previewContainer.data
    property alias controls: controlColumn.data
    property string title: ""
    property string description: ""
    property string codeSnippet: ""
    property string _copiedText: ""

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // Preview Area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "transparent"
                
                Row {
                    anchors.fill: parent
                    anchors.margins: DS.Theme.spacing.xl
                    spacing: DS.Theme.spacing.lg

                    Column {
                        width: parent.width - 120
                        spacing: DS.Theme.spacing.xs

                        Text {
                            text: root.title
                            font.family: DS.Theme.typography.familyBold
                            font.pixelSize: DS.Theme.typography.sizeH2
                            color: DS.Theme.colors.text
                        }
                        Text {
                            text: root.description
                            font.family: DS.Theme.typography.family
                            font.pixelSize: DS.Theme.typography.sizeMd
                            color: DS.Theme.colors.subtext0
                        }
                    }

                    // Copy Code Button
                    Rectangle {
                        width: 100
                        height: 36
                        radius: DS.Theme.geometry.radiusSm
                        color: copyMouse.containsMouse ? DS.Theme.colors.surface1 : "transparent"
                        border.color: DS.Theme.colors.surface1
                        border.width: 1
                        anchors.verticalCenter: parent.verticalCenter

                        Text {
                            text: root._copiedText !== "" ? root._copiedText : "Copiar Código"
                            font.family: DS.Theme.typography.family
                            font.pixelSize: DS.Theme.typography.sizeSm
                            color: DS.Theme.colors.text
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            id: copyMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var snippet = root.codeSnippet !== ""
                                    ? root.codeSnippet
                                    : "// Mocha-DS — " + root.title + "\n// Importe o módulo MochaDS e use o componente diretamente."
                                clipInput.text = snippet
                                clipInput.selectAll()
                                clipInput.copy()
                                root._copiedText = "Copiado!"
                                copyTimer.start()
                            }
                        }

                        Timer {
                            id: copyTimer
                            interval: 2000
                            onTriggered: root._copiedText = ""
                        }

                        TextInput {
                            id: clipInput
                            visible: false
                            text: ""
                        }
                    }
                }
            }

            Rectangle {
                id: previewContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: DS.Theme.colors.mantle
                radius: DS.Theme.geometry.radiusLg
                anchors.margins: DS.Theme.spacing.xl
                
                border.color: DS.Theme.colors.surface0
                border.width: DS.Theme.geometry.borderSm

                // The actual component will be centered here
            }
        }

        // Controls Area
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: DS.Theme.colors.base

            Rectangle {
                anchors.left: parent.left
                width: 1
                height: parent.height
                color: DS.Theme.colors.surface0
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: DS.Theme.spacing.xl
                spacing: DS.Theme.spacing.lg

                Text {
                    text: "Propriedades"
                    font.family: DS.Theme.typography.familyBold
                    font.pixelSize: DS.Theme.typography.sizeLg
                    color: DS.Theme.colors.text
                }

                ScrollView {
                    id: controlScroll
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        id: controlColumn
                        width: controlScroll.width - DS.Theme.spacing.md
                        spacing: DS.Theme.spacing.xl
                    }
                }
            }
        }
    }
}
