import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    
    // Array of objects: [{ label: "Step 1", description: "Desc", icon: "user" }]
    property var steps: []
    
    // Active step index (0-indexed)
    property int currentStep: 0

    // Orientation: "horizontal" | "vertical"
    property string orientation: "horizontal"

    // Variant: "default" | "dots" | "icon" | "labeled-icon"
    property string variant: "default"

    // Accent color
    property string color: "mauve"

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property bool isVertical: orientation === "vertical"
    readonly property color resolvedAccentColor: {
        var stdColor = Theme.colors[color]
        if (stdColor !== undefined) return stdColor
        return Theme.colors.primary // default mauve
    }

    implicitWidth: isVertical ? 300 : 600
    implicitHeight: isVertical ? 400 : 80
    width: implicitWidth
    height: implicitHeight

    // Track Calculation
    readonly property real totalSteps: steps.length
    readonly property real segments: Math.max(1, totalSteps - 1)
    readonly property real progressPercent: Math.min(100, Math.max(0, (currentStep / segments) * 100))

    // Horizontal Layout
    Item {
        anchors.fill: parent
        visible: !root.isVertical

        // Horizontal Track Line
        Rectangle {
            id: trackBg
            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.verticalCenter: parent.top
            anchors.verticalCenterOffset: 20 // center of node
            height: 4
            color: Theme.colors.surface0
            radius: 2

            // Active Track Segment overlay
            Rectangle {
                anchors.left: parent.left
                height: parent.height
                width: parent.width * (root.progressPercent / 100)
                color: root.resolvedAccentColor
                radius: parent.radius

                Behavior on width {
                    NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                }
            }
        }

        // Horizontal Repeater for Step Nodes
        Row {
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: root.steps

                Item {
                    width: parent.width / root.totalSteps
                    height: parent.height

                    readonly property int stepIndex: index
                    readonly property var stepData: modelData
                    readonly property string stepStatus: {
                        if (index < root.currentStep) return "completed"
                        if (index === root.currentStep) return "active"
                        return "upcoming"
                    }

                    // Node Circle
                    Rectangle {
                        id: nodeCircle
                        width: 40
                        height: 40
                        radius: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top

                        color: {
                            if (stepStatus === "completed") return root.resolvedAccentColor
                            if (stepStatus === "active") return Theme.colors.base
                            return Theme.colors.surface0
                        }
                        border.color: {
                            if (stepStatus === "active") return root.resolvedAccentColor
                            return "transparent"
                        }
                        border.width: stepStatus === "active" ? 2 : 0

                        scale: stepStatus === "active" ? 1.1 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        Behavior on color { ColorAnimation { duration: 150 } }

                        // Node Content (Check mark, Icon, Number, or Dot)
                        Item {
                            anchors.fill: parent

                            // Dot mode
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: stepStatus === "completed" ? Theme.colors.crust : (stepStatus === "active" ? root.resolvedAccentColor : Theme.colors.overlay1)
                                anchors.centerIn: parent
                                visible: root.variant === "dots"
                            }

                            // Normal Checkmark (if completed)
                            LucideIcon {
                                name: "check"
                                size: 18
                                color: Theme.colors.crust
                                anchors.centerIn: parent
                                visible: root.variant !== "dots" && stepStatus === "completed"
                            }

                            // Custom Icon (if active/upcoming and variant is icon/labeled-icon)
                            LucideIcon {
                                name: stepData.icon || ""
                                size: 18
                                color: stepStatus === "active" ? root.resolvedAccentColor : Theme.colors.overlay1
                                anchors.centerIn: parent
                                visible: root.variant !== "dots" && stepStatus !== "completed" && (root.variant === "icon" || root.variant === "labeled-icon") && stepData.icon
                            }

                            // Step Number (fallback)
                            Text {
                                text: index + 1
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeSm
                                color: stepStatus === "active" ? root.resolvedAccentColor : Theme.colors.overlay1
                                anchors.centerIn: parent
                                visible: root.variant !== "dots" && stepStatus !== "completed" && !((root.variant === "icon" || root.variant === "labeled-icon") && stepData.icon)
                            }
                        }
                    }

                    // Labels underneath (hidden if dots layout is on)
                    Column {
                        anchors.top: nodeCircle.bottom
                        anchors.topMargin: Theme.spacing.xs
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width - Theme.spacing.md
                        visible: root.variant !== "dots"

                        Text {
                            text: stepData.label || ""
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeSm
                            color: stepStatus === "upcoming" ? Theme.colors.overlay1 : Theme.colors.text
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: stepData.description || ""
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeXs
                            color: Theme.colors.subtext0
                            horizontalAlignment: Text.AlignHCenter
                            anchors.horizontalCenter: parent.horizontalCenter
                            elide: Text.ElideRight
                            width: parent.width
                            visible: stepData.description !== undefined && stepData.description !== ""
                        }
                    }
                }
            }
        }
    }

    // Vertical Layout
    Column {
        anchors.fill: parent
        visible: root.isVertical
        spacing: 0

        Repeater {
            model: root.steps

            Item {
                width: parent.width
                height: parent.height / root.totalSteps

                readonly property int stepIndex: index
                readonly property var stepData: modelData
                readonly property string stepStatus: {
                    if (index < root.currentStep) return "completed"
                    if (index === root.currentStep) return "active"
                    return "upcoming"
                }

                // Left track segment line to link nodes vertically
                Rectangle {
                    anchors.horizontalCenter: nodeCircleVert.horizontalCenter
                    anchors.top: nodeCircleVert.bottom
                    anchors.bottom: parent.bottom
                    width: 4
                    color: Theme.colors.surface0
                    visible: index < root.totalSteps - 1

                    // Active progress fill
                    Rectangle {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: parent.height * (index < root.currentStep ? 1.0 : (index === root.currentStep ? 0.5 : 0.0))
                        color: root.resolvedAccentColor
                        
                        Behavior on height {
                            NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
                        }
                    }
                }

                // Vertical Node Circle
                Rectangle {
                    id: nodeCircleVert
                    width: 40
                    height: 40
                    radius: 20
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacing.md
                    anchors.top: parent.top

                    color: {
                        if (stepStatus === "completed") return root.resolvedAccentColor
                        if (stepStatus === "active") return Theme.colors.base
                        return Theme.colors.surface0
                    }
                    border.color: {
                        if (stepStatus === "active") return root.resolvedAccentColor
                        return "transparent"
                    }
                    border.width: stepStatus === "active" ? 2 : 0

                    scale: stepStatus === "active" ? 1.1 : 1.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                    Item {
                        anchors.fill: parent

                        // Dot mode
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: stepStatus === "completed" ? Theme.colors.crust : (stepStatus === "active" ? root.resolvedAccentColor : Theme.colors.overlay1)
                            anchors.centerIn: parent
                            visible: root.variant === "dots"
                        }

                        // Normal Checkmark (completed)
                        LucideIcon {
                            name: "check"
                            size: 18
                            color: Theme.colors.crust
                            anchors.centerIn: parent
                            visible: root.variant !== "dots" && stepStatus === "completed"
                        }

                        // Custom Icon
                        LucideIcon {
                            name: stepData.icon || ""
                            size: 18
                            color: stepStatus === "active" ? root.resolvedAccentColor : Theme.colors.overlay1
                            anchors.centerIn: parent
                            visible: root.variant !== "dots" && stepStatus !== "completed" && (root.variant === "icon" || root.variant === "labeled-icon") && stepData.icon
                        }

                        // Step Number
                        Text {
                            text: index + 1
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeSm
                            color: stepStatus === "active" ? root.resolvedAccentColor : Theme.colors.overlay1
                            anchors.centerIn: parent
                            visible: root.variant !== "dots" && stepStatus !== "completed" && !((root.variant === "icon" || root.variant === "labeled-icon") && stepData.icon)
                        }
                    }
                }

                // Vertical Labels on Right side
                Column {
                    anchors.left: nodeCircleVert.right
                    anchors.leftMargin: Theme.spacing.md
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.spacing.md
                    anchors.verticalCenter: nodeCircleVert.verticalCenter

                    Text {
                        text: stepData.label || ""
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: stepStatus === "upcoming" ? Theme.colors.overlay1 : Theme.colors.text
                        elide: Text.ElideRight
                        width: parent.width
                    }

                    Text {
                        text: stepData.description || ""
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.subtext0
                        elide: Text.ElideRight
                        width: parent.width
                        visible: stepData.description !== undefined && stepData.description !== ""
                    }
                }
            }
        }
    }
}
