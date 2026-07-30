import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property int currentStep: 0
    property int stepsCount: 3
    property var labels: []

    // Variant: "timeline" | "carousel"
    property string variant: "timeline"

    // Accent Color
    property string color: "mauve"

    // Orientation: "horizontal" | "vertical"
    property string orientation: "horizontal"

    // ==========================================
    // Signals
    // ==========================================
    signal changeStep(int step)

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property bool isVertical: orientation === "vertical"
    readonly property color resolvedAccentColor: {
        var stdColor = Theme.colors[color]
        if (stdColor !== undefined) return stdColor
        return Theme.colors.primary
    }

    implicitWidth: variant === "carousel" ? (stepsCount * 24) : (isVertical ? 240 : 400)
    implicitHeight: variant === "carousel" ? 24 : (isVertical ? 400 : 60)
    width: implicitWidth
    height: implicitHeight

    // 1. CAROUSEL DOTS VARIANT
    Row {
        id: carouselRow
        anchors.centerIn: parent
        spacing: Theme.spacing.sm
        visible: root.variant === "carousel"

        Repeater {
            model: root.stepsCount

            Rectangle {
                width: index === root.currentStep ? 20 : 8
                height: 8
                radius: 4
                color: index === root.currentStep ? root.resolvedAccentColor : Theme.colors.surface2

                Behavior on width {
                    NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                }
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.changeStep(index)
                }
            }
        }
    }

    // 2. TIMELINE VARIANT
    Item {
        id: timelineContainer
        anchors.fill: parent
        visible: root.variant === "timeline"

        readonly property real segments: Math.max(1, root.stepsCount - 1)
        readonly property real progressPercent: Math.min(100, Math.max(0, (root.currentStep / segments) * 100))

        // Line Track (Horizontal)
        Rectangle {
            id: trackH
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: 12 // center of dot
            height: 4
            color: Theme.colors.surface0
            radius: 2
            visible: !root.isVertical

            // Active Track Segment overlay
            Rectangle {
                anchors.left: parent.left
                height: parent.height
                width: parent.width * (timelineContainer.progressPercent / 100)
                color: root.resolvedAccentColor
                radius: parent.radius

                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }
        }

        // Line Track (Vertical)
        Rectangle {
            id: trackV
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.left
            anchors.horizontalCenterOffset: 12
            width: 4
            color: Theme.colors.surface0
            radius: 2
            visible: root.isVertical

            // Active Track Segment overlay
            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: parent.height * (timelineContainer.progressPercent / 100)
                color: root.resolvedAccentColor
                radius: parent.radius

                Behavior on height {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }
        }

        // Timeline Items Layout (Horizontal)
        Row {
            anchors.fill: parent
            visible: !root.isVertical
            spacing: 0

            Repeater {
                model: root.stepsCount

                Item {
                    width: parent.width / root.stepsCount
                    height: parent.height

                    readonly property int stepIdx: index
                    readonly property bool isActive: index === root.currentStep
                    readonly property bool isCompleted: index < root.currentStep

                    // Step Dot Button
                    Rectangle {
                        id: dotBtnH
                        width: isActive ? 16 : 12
                        height: isActive ? 16 : 12
                        radius: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: isActive ? 4 : 6

                        color: (isActive || isCompleted) ? root.resolvedAccentColor : Theme.colors.surface2
                        border.color: Theme.colors.base
                        border.width: isActive ? 2 : 0

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                    }

                    // Label
                    Text {
                        text: (root.labels !== undefined && root.labels[index] !== undefined) ? root.labels[index] : ""
                        font.family: Theme.typography.familyMedium
                        font.pixelSize: Theme.typography.sizeSm
                        color: isActive ? Theme.colors.text : Theme.colors.subtext0
                        anchors.top: dotBtnH.bottom
                        anchors.topMargin: Theme.spacing.xs
                        anchors.horizontalCenter: parent.horizontalCenter
                        elide: Text.ElideRight
                        width: parent.width - Theme.spacing.xs
                        horizontalAlignment: Text.AlignHCenter
                        antialiasing: true
                    }

                    // Clickable area covers the entire item (dot + label)
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changeStep(stepIdx)
                    }
                }
            }
        }

        // Timeline Items Layout (Vertical)
        Column {
            anchors.fill: parent
            visible: root.isVertical
            spacing: 0

            Repeater {
                model: root.stepsCount

                Item {
                    width: parent.width
                    height: parent.height / root.stepsCount

                    readonly property int stepIdx: index
                    readonly property bool isActive: index === root.currentStep
                    readonly property bool isCompleted: index < root.currentStep

                    // Step Dot Button
                    Rectangle {
                        id: dotBtnV
                        width: isActive ? 16 : 12
                        height: isActive ? 16 : 12
                        radius: 8
                        anchors.left: parent.left
                        anchors.leftMargin: isActive ? 4 : 6
                        anchors.verticalCenter: parent.verticalCenter

                        color: (isActive || isCompleted) ? root.resolvedAccentColor : Theme.colors.surface2
                        border.color: Theme.colors.base
                        border.width: isActive ? 2 : 0

                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    // Label
                    Text {
                        text: (root.labels !== undefined && root.labels[index] !== undefined) ? root.labels[index] : ""
                        font.family: Theme.typography.familyMedium
                        font.pixelSize: Theme.typography.sizeSm
                        color: isActive ? Theme.colors.text : Theme.colors.subtext0
                        anchors.left: dotBtnV.right
                        anchors.leftMargin: Theme.spacing.md
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacing.xs
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        antialiasing: true
                    }

                    // Clickable area covers the entire item (dot + label)
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.changeStep(stepIdx)
                    }
                }
            }
        }
    }
}
