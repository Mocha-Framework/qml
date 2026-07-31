import QtQuick 2.15
import QtQuick.Window 2.15
import MochaDS as DS

Window {
    visible: true
    width: 900
    height: 1100
    title: "Mocha-DS — Flexbox Demo"
    color: DS.Theme.colors.crust

    Column {
        anchors.fill: parent
        anchors.margins: DS.Theme.spacing.xl
        spacing: DS.Theme.spacing.xxl


        // ============================================================
        // HStack — justifyContent
        // ============================================================
        Column {
            spacing: DS.Theme.spacing.lg
            width: parent.width

            Text {
                text: "HStack | justifyContent"
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeXl
                color: DS.Theme.colors.mauve
            }

            Repeater {
                model: ["start", "center", "end", "between", "around", "evenly"]
                delegate: Column {
                    width: parent.width
                    spacing: DS.Theme.spacing.xs

                    Text {
                        text: "justifyContent: \"" + modelData + "\""
                        font.family: DS.Theme.typography.family
                        font.pixelSize: DS.Theme.typography.sizeSm
                        color: DS.Theme.colors.subtext0
                    }

                    Rectangle {
                        width: parent.width
                        height: 44
                        color: DS.Theme.colors.mantle
                        radius: DS.Theme.geometry.radiusSm
                        border.color: DS.Theme.colors.surface1
                        border.width: 1

                        DS.HStack {
                            anchors.fill: parent
                            anchors.margins: DS.Theme.spacing.sm
                            justifyContent: modelData
                            alignItems: "center"

                            Repeater {
                                model: ["A", "B", "C"]
                                delegate: Rectangle {
                                    width: 40
                                    height: 28
                                    radius: DS.Theme.geometry.radiusSm
                                    color: {
                                        var colors = [DS.Theme.colors.mauve, DS.Theme.colors.blue, DS.Theme.colors.green]
                                        return colors[index]
                                    }

                                    Text {
                                        text: modelData
                                        color: DS.Theme.colors.crust
                                        font.family: DS.Theme.typography.familyBold
                                        font.pixelSize: DS.Theme.typography.sizeSm
                                        anchors.centerIn: parent
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        // ============================================================
        // HStack — alignItems (with varying child heights)
        // ============================================================
        Column {
            spacing: DS.Theme.spacing.lg
            width: parent.width

            Text {
                text: "HStack | alignItems"
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeXl
                color: DS.Theme.colors.sky
            }

            Repeater {
                model: ["start", "center", "end", "stretch"]
                delegate: Column {
                    width: parent.width
                    spacing: DS.Theme.spacing.xs

                    Text {
                        text: "alignItems: \"" + modelData + "\""
                        font.family: DS.Theme.typography.family
                        font.pixelSize: DS.Theme.typography.sizeSm
                        color: DS.Theme.colors.subtext0
                    }

                    Rectangle {
                        width: parent.width
                        height: 60
                        color: DS.Theme.colors.mantle
                        radius: DS.Theme.geometry.radiusSm
                        border.color: DS.Theme.colors.surface1
                        border.width: 1

                        DS.HStack {
                            anchors.fill: parent
                            anchors.margins: DS.Theme.spacing.sm
                            justifyContent: "start"
                            alignItems: modelData

                            Rectangle { width: 40; height: 20; radius: 4; color: DS.Theme.colors.mauve }
                            Rectangle { width: 40; height: 36; radius: 4; color: DS.Theme.colors.blue }
                            Rectangle { width: 40; height: 28; radius: 4; color: DS.Theme.colors.green }
                        }
                    }
                }
            }
        }


        // ============================================================
        // VStack — justifyContent
        // ============================================================
        Column {
            spacing: DS.Theme.spacing.lg
            width: parent.width

            Text {
                text: "VStack | justifyContent"
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeXl
                color: DS.Theme.colors.green
            }

            Repeater {
                model: ["start", "center", "end", "between", "around", "evenly"]
                delegate: Column {
                    width: parent.width
                    spacing: DS.Theme.spacing.xs

                    Text {
                        text: "justifyContent: \"" + modelData + "\""
                        font.family: DS.Theme.typography.family
                        font.pixelSize: DS.Theme.typography.sizeSm
                        color: DS.Theme.colors.subtext0
                    }

                    Rectangle {
                        width: parent.width
                        height: 120
                        color: DS.Theme.colors.mantle
                        radius: DS.Theme.geometry.radiusSm
                        border.color: DS.Theme.colors.surface1
                        border.width: 1

                        DS.VStack {
                            anchors.fill: parent
                            anchors.margins: DS.Theme.spacing.sm
                            justifyContent: modelData
                            alignItems: "center"

                            Repeater {
                                model: ["A", "B", "C"]
                                delegate: Rectangle {
                                    width: 60
                                    height: 24
                                    radius: DS.Theme.geometry.radiusSm
                                    color: {
                                        var colors = [DS.Theme.colors.green, DS.Theme.colors.teal, DS.Theme.colors.sapphire]
                                        return colors[index]
                                    }

                                    Text {
                                        text: modelData
                                        color: DS.Theme.colors.crust
                                        font.family: DS.Theme.typography.familyBold
                                        font.pixelSize: DS.Theme.typography.sizeSm
                                        anchors.centerIn: parent
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }


        // ============================================================
        // VStack — alignItems (with varying child widths)
        // ============================================================
        Column {
            spacing: DS.Theme.spacing.lg
            width: parent.width

            Text {
                text: "VStack | alignItems"
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeXl
                color: DS.Theme.colors.peach
            }

            Repeater {
                model: ["start", "center", "end", "stretch"]
                delegate: Column {
                    width: parent.width
                    spacing: DS.Theme.spacing.xs

                    Text {
                        text: "alignItems: \"" + modelData + "\""
                        font.family: DS.Theme.typography.family
                        font.pixelSize: DS.Theme.typography.sizeSm
                        color: DS.Theme.colors.subtext0
                    }

                    Rectangle {
                        width: parent.width
                        height: 100
                        color: DS.Theme.colors.mantle
                        radius: DS.Theme.geometry.radiusSm
                        border.color: DS.Theme.colors.surface1
                        border.width: 1

                        DS.VStack {
                            anchors.fill: parent
                            anchors.margins: DS.Theme.spacing.sm
                            justifyContent: "start"
                            alignItems: modelData

                            Rectangle { width: 40; height: 20; radius: 4; color: DS.Theme.colors.peach }
                            Rectangle { width: 80; height: 20; radius: 4; color: DS.Theme.colors.yellow }
                            Rectangle { width: 60; height: 20; radius: 4; color: DS.Theme.colors.maroon }
                        }
                    }
                }
            }
        }


        // ============================================================
        // Box demo
        // ============================================================
        Column {
            spacing: DS.Theme.spacing.lg
            width: parent.width

            Text {
                text: "Box — padding & margin (CSS-like)"
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeXl
                color: DS.Theme.colors.yellow
            }

            // Margin demo
            Column {
                width: parent.width
                spacing: DS.Theme.spacing.xs
                Text {
                    text: "Box { p: \"md\" colorName: \"mauve\" }"
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeSm
                    color: DS.Theme.colors.subtext0
                }
                Rectangle {
                    width: parent.width
                    color: "transparent"
                    height: 80
                    DS.Box {
                        p: "md"
                        colorName: "mauve"
                        anchors.centerIn: parent
                        Text {
                            text: "padding md"
                            color: DS.Theme.colors.crust
                            font.family: DS.Theme.typography.familyBold
                            anchors.centerIn: parent
                        }
                    }
                }
            }

            Column {
                width: parent.width
                spacing: DS.Theme.spacing.xs
                Text {
                    text: "Box { p: \"lg\" m: \"xl\" variant: \"surface\" }"
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeSm
                    color: DS.Theme.colors.subtext0
                }
                Rectangle {
                    width: parent.width
                    color: DS.Theme.colors.crust
                    height: 80
                    border.color: DS.Theme.colors.surface0
                    border.width: 1
                    DS.Box {
                        p: "lg"
                        m: "xl"
                        variant: "surface"
                        anchors.centerIn: parent
                        Text {
                            text: "padding lg + margin xl"
                            color: DS.Theme.colors.text
                            font.family: DS.Theme.typography.family
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }
    }
}
