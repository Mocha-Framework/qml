import QtQuick 2.15
import QtQuick.Layouts 1.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // The data model (Array of JavaScript objects)
    // Expected object structure:
    // {
    //   image: string,
    //   title: string,
    //   description: string,
    //   badge: string,
    //   badgeVariant: string,
    //   accentColor: color/string,
    //   primaryButtonText: string,
    //   primaryButtonIcon: string,
    //   primaryButtonVariant: string,
    //   primaryButtonDisabled: bool,
    //   secondaryButtonText: string,
    //   secondaryButtonIcon: string
    // }
    property var model: []
    
    // Auto-advance interval in milliseconds. Set to 0 to disable.
    property int autoAdvanceInterval: 5500

    // Currently visible slide index
    property int currentIndex: 0

    // ==========================================
    // Signals
    // ==========================================
    signal primaryActionClicked(int index, var itemData)
    signal secondaryActionClicked(int index, var itemData)

    // ==========================================
    // Internal States & Logic
    // ==========================================
    
    // Safe property to handle edge cases where model is undefined or empty
    readonly property int slideCount: (model && Array.isArray(model)) ? model.length : 0

    Timer {
        id: autoTimer
        interval: root.autoAdvanceInterval
        repeat: true
        running: root.slideCount > 1 && root.autoAdvanceInterval > 0
        onTriggered: {
            if (root.slideCount > 0) {
                root.currentIndex = (root.currentIndex + 1) % root.slideCount;
            }
        }
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    Item {
        id: slideArea
        anchors.fill: parent
        clip: true

        // Background placeholder when empty
        Rectangle {
            anchors.fill: parent
            color: Theme.colors.surface0
            radius: Theme.geometry.radiusLg
            visible: root.slideCount === 0
            
            LucideIcon {
                name: "image"
                size: 32
                color: Theme.colors.surface2
                anchors.centerIn: parent
            }
        }

        Repeater {
            id: slideRepeater
            model: root.slideCount

            delegate: Rectangle {
                id: slide
                anchors.fill: parent
                color: Theme.colors.crust
                radius: Theme.geometry.radiusLg
                clip: true
                
                readonly property var itemData: root.model[index] || {}

                // Crossfade animation
                opacity: index === root.currentIndex ? 1.0 : 0.0
                visible: opacity > 0

                Behavior on opacity {
                    NumberAnimation { duration: 600; easing.type: Easing.InOutQuad }
                }

                // ── Hero background image ─────────────────────────────────────
                Image {
                    id: heroImg
                    anchors.fill: parent
                    source: slide.itemData.image || ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true

                    // Fade in when ready
                    opacity: status === Image.Ready ? 1.0 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 400 } }
                }

                // Loading skeleton/shimmer while image loads
                Rectangle {
                    anchors.fill: parent
                    visible: heroImg.status !== Image.Ready
                    color: Theme.colors.surface0
                    opacity: 0.9
                }

                // ── Gradient overlay ──────────────────────────────────────────
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "transparent" }
                        GradientStop { position: 0.45; color: Qt.rgba(0, 0, 0, 0.35) }
                        GradientStop { position: 1.0;  color: Qt.rgba(0, 0, 0, 0.85) }
                    }
                }

                // ── Accent left bar (branding color) ─────────────────────────
                Rectangle {
                    width: 4
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    color: slide.itemData.accentColor || Theme.colors.primary
                    opacity: 0.9
                    visible: slide.itemData.accentColor !== undefined
                }

                // ── Content Layout ────────────────────────────────────────────
                RowLayout {
                    anchors {
                        left: parent.left
                        right: parent.right
                        bottom: parent.bottom
                        leftMargin: Theme.spacing.xl
                        rightMargin: Theme.spacing.xl
                        bottomMargin: Theme.spacing.xl + 20 // Extra margin to accommodate dots
                    }
                    spacing: Theme.spacing.lg

                    // Text block
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignBottom
                        spacing: Theme.spacing.xs

                        // Type badge
                        Badge {
                            text: slide.itemData.badge || ""
                            variant: slide.itemData.badgeVariant || "primary"
                            visible: text !== ""
                        }

                        Text {
                            text: slide.itemData.title || ""
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeH1
                            color: "#ffffff"
                            style: Text.Normal
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            antialiasing: true
                        }

                        Text {
                            text: slide.itemData.description || ""
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeMd
                            color: "#d0d0d0"
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                            maximumLineCount: 2
                            antialiasing: true
                        }
                    }

                    // Action buttons
                    ColumnLayout {
                        Layout.alignment: Qt.AlignBottom
                        spacing: Theme.spacing.sm

                        Button {
                            text: slide.itemData.primaryButtonText || "Ação Principal"
                            variant: slide.itemData.primaryButtonVariant || "primary"
                            icon: slide.itemData.primaryButtonIcon || ""
                            disabled: slide.itemData.primaryButtonDisabled || false
                            visible: slide.itemData.primaryButtonText !== undefined
                            Layout.alignment: Qt.AlignRight
                            onClicked: root.primaryActionClicked(index, slide.itemData)
                        }

                        Button {
                            text: slide.itemData.secondaryButtonText || "Detalhes"
                            variant: "outline"
                            icon: slide.itemData.secondaryButtonIcon || ""
                            visible: slide.itemData.secondaryButtonText !== undefined
                            Layout.alignment: Qt.AlignRight
                            onClicked: root.secondaryActionClicked(index, slide.itemData)
                        }
                    }
                }
            }
        }

        // ── Prev button ───────────────────────────────────────────────────────
        Item {
            id: prevBtn
            width: 40
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.spacing.md
            visible: root.slideCount > 1

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: prevHover.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.45)
                border.color: Qt.rgba(1, 1, 1, 0.1)
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                LucideIcon {
                    name: "chevron-left"
                    size: 20
                    color: "#ffffff"
                    anchors.centerIn: parent
                }
            }

            MouseArea {
                id: prevHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    autoTimer.restart()
                    root.currentIndex = (root.currentIndex - 1 + root.slideCount) % root.slideCount
                }
            }
        }

        // ── Next button ───────────────────────────────────────────────────────
        Item {
            id: nextBtn
            width: 40
            height: 40
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: Theme.spacing.md
            visible: root.slideCount > 1

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: nextHover.containsMouse ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(0, 0, 0, 0.45)
                border.color: Qt.rgba(1, 1, 1, 0.1)
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                LucideIcon {
                    name: "chevron-right"
                    size: 20
                    color: "#ffffff"
                    anchors.centerIn: parent
                }
            }

            MouseArea {
                id: nextHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    autoTimer.restart()
                    root.currentIndex = (root.currentIndex + 1) % root.slideCount
                }
            }
        }

        // ── Dot indicators ────────────────────────────────────────────────────
        Row {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Theme.spacing.md
            visible: root.slideCount > 1

            Repeater {
                model: root.slideCount
                delegate: Rectangle {
                    width: index === root.currentIndex ? 24 : 8
                    height: 8
                    radius: 4
                    color: index === root.currentIndex ? "#ffffff" : Qt.rgba(1, 1, 1, 0.4)
                    
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 250 } }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4 // expand hit area
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            autoTimer.restart()
                            root.currentIndex = index
                        }
                    }
                }
            }
        }
    }
}
