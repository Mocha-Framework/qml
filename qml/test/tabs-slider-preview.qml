import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Window {
    id: window
    width: 700
    height: 540
    visible: true
    title: "MochaDS — Tabs + Slider (paridade web)"
    color: "#1e1e2e"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        Text {
            text: "═ Tabs (com painéis de conteúdo)"
            color: "#cba6f7"
            font.pixelSize: 18
            font.bold: true
        }

        // ── Tabs variant "line" ──
        Rectangle {
            id: lineCard
            Layout.fillWidth: true
            height: lineInner.implicitHeight + 24
            color: "#313244"
            radius: 12
            border.width: 1
            border.color: "#45475a"
            clip: true

            Column {
                id: lineInner
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "variant: \"line\" — currentIndex alterna o conteúdo abaixo"
                    color: "#a6adc8"
                    font.pixelSize: 11
                }

                Item {
                    id: lineTabs
                    width: parent.width
                    height: lineBar.height + lineContent.implicitHeight + 12
                    property int currentIndex: 0
                    readonly property real activeTabX: lineBar.children[lineTabs.currentIndex].x
                    readonly property real activeTabW: lineBar.children[lineTabs.currentIndex].width

                    Row {
                        id: lineBar
                        spacing: 0

                        Repeater {
                            model: ["Design", "Código", "Deploy"]

                            Item {
                                width: 120
                                height: 36
                                property bool isActive: index === lineTabs.currentIndex

                                Text {
                                    text: modelData
                                    anchors.centerIn: parent
                                    font.pixelSize: 13
                                    font.weight: parent.isActive ? Font.Bold : Font.Normal
                                    color: parent.isActive ? "#cba6f7" : "#6c7086"
                                }

                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.leftMargin: 12
                                    anchors.rightMargin: 12
                                    height: 2
                                    radius: 1
                                    color: "#cba6f7"
                                    opacity: parent.isActive ? 1 : 0

                                    Behavior on opacity {
                                        NumberAnimation { duration: 200 }
                                    }
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        lineTabs.currentIndex = index
                                        lineContent.currentIndex = index
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        id: lineContent
                        anchors.top: lineBar.bottom
                        anchors.topMargin: 12
                        anchors.left: parent.left
                        anchors.leftMargin: lineTabs.activeTabX + 12
                        anchors.right: parent.right
                        implicitHeight: 44
                        property int currentIndex: 0

                        Text {
                            visible: lineContent.currentIndex === 0
                            text: "🎨  Painel Design — cores, tipografia, tokens..."
                            color: "#cdd6f4"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            font.pixelSize: 13
                        }
                        Text {
                            visible: lineContent.currentIndex === 1
                            text: "💻  Painel Código — snippets, exemplos de API..."
                            color: "#cdd6f4"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            font.pixelSize: 13
                        }
                        Text {
                            visible: lineContent.currentIndex === 2
                            text: "🚀  Painel Deploy — configs de build, CI/CD..."
                            color: "#cdd6f4"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }

        // ── Tabs variant "pill" ──
        Rectangle {
            id: pillCard
            Layout.fillWidth: true
            height: pillInner.implicitHeight + 24
            color: "#313244"
            radius: 12
            border.width: 1
            border.color: "#45475a"
            clip: true

            Column {
                id: pillInner
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Text {
                    text: "variant: \"pill\" — selected item ganha background preenchido"
                    color: "#a6adc8"
                    font.pixelSize: 11
                }

                Item {
                    id: pillTabs
                    width: parent.width
                    height: pillBar.height + pillContent.implicitHeight + 12
                    property int currentIndex: 0
                    readonly property real activeTabX: pillBar.children[pillTabs.currentIndex].x

                    Row {
                        id: pillBar
                        spacing: 4

                        Repeater {
                            model: ["📊 Analytics", "📂 Reports", "⚙️ Settings"]

                            Rectangle {
                                width: 120
                                height: 34
                                radius: 17
                                property bool isActive: index === pillTabs.currentIndex
                                color: isActive ? "#cba6f7" : "transparent"

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }

                                Text {
                                    text: modelData
                                    anchors.centerIn: parent
                                    font.pixelSize: 13
                                    font.weight: parent.isActive ? Font.Bold : Font.Normal
                                    color: parent.isActive ? "#1e1e2e" : "#6c7086"
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        pillTabs.currentIndex = index
                                        pillContent.currentIndex = index
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        id: pillContent
                        anchors.top: pillBar.bottom
                        anchors.topMargin: 12
                        anchors.left: parent.left
                        anchors.leftMargin: pillTabs.activeTabX
                        anchors.right: parent.right
                        implicitHeight: 44
                        property int currentIndex: 0

                        Text {
                            visible: pillContent.currentIndex === 0
                            text: "📊  Analytics Dashboard"
                            color: "#cdd6f4"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            font.pixelSize: 13
                        }
                        Text {
                            visible: pillContent.currentIndex === 1
                            text: "📂  Reports Archive"
                            color: "#cdd6f4"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            font.pixelSize: 13
                        }
                        Text {
                            visible: pillContent.currentIndex === 2
                            text: "⚙️  Settings Panel"
                            color: "#cdd6f4"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            font.pixelSize: 13
                        }
                    }
                }
            }
        }

        // ═══════════════ SLIDER DEMO ═══════════════

        Text {
            text: "═ Slider (single-value, paridade web)"
            color: "#cba6f7"
            font.pixelSize: 18
            font.bold: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // ── sm ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                color: "#313244"
                radius: 8
                border.width: 1
                border.color: "#45475a"
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        text: "size: sm — green"
                        color: "#a6adc8"
                        font.pixelSize: 10
                    }

                    Rectangle {
                        width: parent.width
                        height: 26
                        color: "transparent"

                        property real sliderVal: 30

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 36
                            height: 4
                            radius: 2
                            color: "#585b70"
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(8, (parent.parent.width - 36) * (parent.sliderVal / 100))
                            height: 4
                            radius: 2
                            color: "#a6e3a1"
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 14
                            height: 14
                            radius: 7
                            color: "#a6e3a1"
                            border.width: 2
                            border.color: "#ffffff"
                            x: (parent.parent.width - 36) * (parent.sliderVal / 100) - 7
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            function updateVal(mx) {
                                var ratio = Math.max(0, Math.min(1, mx / width))
                                parent.sliderVal = Math.round(ratio * 100)
                            }
                            onPositionChanged: updateVal(mouse.x)
                            onPressed: updateVal(mouse.x)
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: Math.round(parent.sliderVal).toString()
                            font.pixelSize: 12
                            font.bold: true
                            color: "#a6e3a1"
                            width: 30
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            // ── md ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                color: "#313244"
                radius: 8
                border.width: 1
                border.color: "#45475a"
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        text: "size: md — mauve"
                        color: "#a6adc8"
                        font.pixelSize: 10
                    }

                    Rectangle {
                        width: parent.width
                        height: 26
                        color: "transparent"

                        property real sliderVal: 65

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 36
                            height: 6
                            radius: 3
                            color: "#585b70"
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(10, (parent.parent.width - 36) * (parent.sliderVal / 100))
                            height: 6
                            radius: 3
                            color: "#cba6f7"
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 18
                            height: 18
                            radius: 9
                            color: "#cba6f7"
                            border.width: 2
                            border.color: "#ffffff"
                            x: (parent.parent.width - 36) * (parent.sliderVal / 100) - 9
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            function updateVal(mx) {
                                var ratio = Math.max(0, Math.min(1, mx / width))
                                parent.sliderVal = Math.round(ratio * 100)
                            }
                            onPositionChanged: updateVal(mouse.x)
                            onPressed: updateVal(mouse.x)
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: Math.round(parent.sliderVal).toString()
                            font.pixelSize: 13
                            font.bold: true
                            color: "#cba6f7"
                            width: 30
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }

            // ── lg ──
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 68
                color: "#313244"
                radius: 8
                border.width: 1
                border.color: "#45475a"
                clip: true

                Column {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 4

                    Text {
                        text: "size: lg — blue"
                        color: "#a6adc8"
                        font.pixelSize: 10
                    }

                    Rectangle {
                        width: parent.width
                        height: 26
                        color: "transparent"

                        property real sliderVal: 85

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 42
                            height: 8
                            radius: 4
                            color: "#585b70"
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(12, (parent.parent.width - 42) * (parent.sliderVal / 100))
                            height: 8
                            radius: 4
                            color: "#89b4fa"
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 22
                            height: 22
                            radius: 11
                            color: "#89b4fa"
                            border.width: 2
                            border.color: "#ffffff"
                            x: (parent.parent.width - 42) * (parent.sliderVal / 100) - 11
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            function updateVal(mx) {
                                var ratio = Math.max(0, Math.min(1, mx / width))
                                parent.sliderVal = Math.round(ratio * 100)
                            }
                            onPositionChanged: updateVal(mouse.x)
                            onPressed: updateVal(mouse.x)
                        }

                        Text {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            text: Math.round(parent.sliderVal).toString()
                            font.pixelSize: 14
                            font.bold: true
                            color: "#89b4fa"
                            width: 36
                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: "Tabs com painéis de conteúdo  •  Slider single-value (paridade React/Vue/Angular)"
            color: "#585b70"
            font.pixelSize: 10
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
