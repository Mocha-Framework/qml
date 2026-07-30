import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property alias text: textInput.text
    property string placeholder: ""
    property string type: "text" // "text" | "password" | "email" | "number"
    property string iconLeft: ""
    property string iconRight: ""
    
    // Validation status: "normal" | "success" | "error"
    property string status: "normal"
    
    property bool disabled: false
    property bool readOnly: false
    property string size: "md" // "sm" | "md" | "lg"

    // Form validation
    property string errorText: ""
    property bool isInvalid: errorText.length > 0

    // Style overrides
    property real customRadius: -1
    property color customBorderColor: "transparent"
    property color customBackgroundColor: "transparent"

    // Signals
    signal accepted()
    signal textEdited()

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property real currentHeight: {
        if (size === "sm") return 32
        if (size === "lg") return 48
        return 40 // "md"
    }

    readonly property real currentPadding: {
        if (size === "sm") return Theme.spacing.sm // 8px
        if (size === "lg") return Theme.spacing.lg // 16px
        return Theme.spacing.md // 12px (md)
    }

    readonly property real currentFontSize: {
        if (size === "sm") return Theme.typography.sizeSm // 12px
        if (size === "lg") return Theme.typography.sizeLg // 16px
        return Theme.typography.sizeMd // 14px (md)
    }

    readonly property real currentIconSize: {
        if (size === "sm") return 14
        if (size === "lg") return 20
        return 18 // md
    }

    readonly property real defaultRadius: {
        if (size === "sm") return Theme.geometry.radiusSm
        if (size === "lg") return Theme.geometry.radiusLg
        return Theme.geometry.radiusMd
    }

    readonly property real finalRadius: customRadius >= 0 ? customRadius : defaultRadius

    // Color definitions
    readonly property color finalBackgroundColor: {
        if (disabled) return Theme.colors.crust
        if (customBackgroundColor.toString() !== "#00000000" && customBackgroundColor.toString() !== "transparent") {
            return customBackgroundColor
        }
        return Theme.colors.mantle
    }

    readonly property color statusColor: {
        if (isInvalid) return Theme.colors.danger
        if (status === "success") return Theme.colors.success
        if (status === "error") return Theme.colors.danger
        return textInput.activeFocus ? Theme.colors.primary : Theme.colors.surface2
    }

    readonly property color finalBorderColor: {
        if (disabled) return Theme.colors.surface0
        if (isInvalid) return Theme.colors.danger
        if (customBorderColor.toString() !== "#00000000" && customBorderColor.toString() !== "transparent") {
            return customBorderColor
        }
        if (status === "success") return Theme.colors.success
        if (status === "error") return Theme.colors.danger
        if (textInput.activeFocus) return Theme.colors.primary
        if (mouseArea.containsMouse) return Theme.colors.overlay0
        return Theme.colors.surface1
    }

    // Password view state
    property bool showPassword: false

    // Layout Dimensions
    implicitWidth: 280
    implicitHeight: currentHeight + (isInvalid ? 20 : 0)

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Background Panel with Border
    Rectangle {
        id: bgPanel
        y: 0
        width: parent.width
        height: root.currentHeight
        color: root.finalBackgroundColor
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: textInput.activeFocus ? Theme.geometry.borderMd : Theme.geometry.borderSm

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // Shake animation for error state
    SequentialAnimation {
        id: shakeAnim
        running: false

        NumberAnimation { target: root; property: "x"; from: 0; to: -6; duration: 40 }
        NumberAnimation { target: root; property: "x"; from: -6; to: 6; duration: 40 }
        NumberAnimation { target: root; property: "x"; from: 6; to: -4; duration: 40 }
        NumberAnimation { target: root; property: "x"; from: -4; to: 4; duration: 40 }
        NumberAnimation { target: root; property: "x"; from: 4; to: -2; duration: 40 }
        NumberAnimation { target: root; property: "x"; from: -2; to: 2; duration: 40 }
        NumberAnimation { target: root; property: "x"; from: 2; to: 0; duration: 40 }
    }

    onErrorTextChanged: {
        if (errorText.length > 0) {
            shakeAnim.restart()
        }
    }

    // Error text label
    Text {
        id: errorLabel
        y: root.currentHeight + 2
        text: root.errorText
        font.family: Theme.typography.family
        font.pixelSize: Theme.typography.sizeXs
        color: Theme.colors.danger
        visible: root.isInvalid
        height: 16
        anchors.left: parent.left
        anchors.leftMargin: 2
    }

    // Outer mouse click focuses the text input (placed behind content Row so it doesn't block actions)
    MouseArea {
        id: mouseArea
        y: 0
        width: parent.width
        height: root.currentHeight
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (!root.disabled && !root.readOnly) {
                textInput.forceActiveFocus();
            }
        }
    }

    // Input Content Layout (Horizontal Stack)
    Row {
        id: contentLayout
        y: 0
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.currentPadding
        anchors.rightMargin: root.currentPadding
        height: root.currentHeight
        spacing: Theme.spacing.sm
        clip: true

        // Prefix Icon (Left Icon)
        LucideIcon {
            name: root.iconLeft
            size: root.currentIconSize
            color: root.disabled ? Theme.colors.overlay0 : (textInput.activeFocus ? Theme.colors.primary : Theme.colors.subtext0)
            visible: root.iconLeft !== ""
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        // Inner Text Container (holds Input + Placeholder)
        Item {
            height: parent.height
            width: parent.width - (leftIconSpace + rightIconSpace + parent.spacing * spacingCount)
            anchors.verticalCenter: parent.verticalCenter

            // Compute icon spacing widths dynamically
            readonly property real leftIconSpace: root.iconLeft !== "" ? root.currentIconSize : 0
            readonly property real rightIconSpace: (root.iconRight !== "" || root.type === "password" || (root.text !== "" && !root.readOnly)) ? root.currentIconSize : 0
            readonly property int spacingCount: (root.iconLeft !== "" ? 1 : 0) + ((root.iconRight !== "" || root.type === "password" || (root.text !== "" && !root.readOnly)) ? 1 : 0)

            // Placeholder Text
            Text {
                text: root.placeholder
                font.family: Theme.typography.family
                font.pixelSize: root.currentFontSize
                color: Theme.colors.overlay0
                visible: root.text === "" && !textInput.activeFocus
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                antialiasing: true
            }

            // Actual TextInput control
            TextInput {
                id: textInput
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter
                font.family: Theme.typography.family
                font.pixelSize: root.currentFontSize
                color: root.disabled ? Theme.colors.overlay0 : Theme.colors.text
                selectionColor: Theme.colors.surface2
                selectedTextColor: Theme.colors.text
                enabled: !root.disabled && !root.readOnly
                readOnly: root.readOnly
                cursorVisible: activeFocus
                antialiasing: true

                // Sync text value
                onTextChanged: {
                    root.textEdited();
                }

                // Echo mode selection for password
                echoMode: {
                    if (root.type === "password" && !root.showPassword) {
                        return TextInput.Password;
                    }
                    return TextInput.Normal;
                }

                // TextInput Validator configurations based on type
                validator: {
                    if (root.type === "number") {
                        return doubleValidator;
                    }
                    return null;
                }

                DoubleValidator {
                    id: doubleValidator
                }

                onAccepted: root.accepted()
            }
        }

        // Suffix Icon (Right Action or Status Icon)
        Item {
            width: root.currentIconSize
            height: root.currentIconSize
            visible: root.type === "password" || root.iconRight !== "" || (root.text !== "" && !root.readOnly && !root.disabled)
            anchors.verticalCenter: parent.verticalCenter

            // Clear Button (visible when there's text, not a password field, and is editable)
            LucideIcon {
                name: "x"
                size: root.currentIconSize
                color: clearMouseArea.containsMouse ? Theme.colors.primary : Theme.colors.overlay0
                visible: root.text !== "" && root.type !== "password" && !root.readOnly && !root.disabled
                anchors.centerIn: parent

                MouseArea {
                    id: clearMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.text = "";
                        textInput.text = "";
                        root.textEdited();
                        textInput.forceActiveFocus();
                    }
                }
            }

            // Password Toggle Button (Eye)
            LucideIcon {
                name: root.showPassword ? "eye-off" : "eye"
                size: root.currentIconSize
                color: passwordMouseArea.containsMouse ? Theme.colors.primary : Theme.colors.subtext0
                visible: root.type === "password" && !root.disabled
                anchors.centerIn: parent

                MouseArea {
                    id: passwordMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.showPassword = !root.showPassword
                }
            }

            // Custom Suffix Icon (fallback if no password or clear button active)
            LucideIcon {
                name: root.iconRight
                size: root.currentIconSize
                color: textInput.activeFocus ? Theme.colors.primary : Theme.colors.subtext0
                visible: root.iconRight !== "" && root.type !== "password" && (root.text === "" || root.readOnly || root.disabled)
                anchors.centerIn: parent
            }
        }
    }

    // Accessibility
    Accessible.role: Accessible.EditableText
    Accessible.name: root.placeholder
    Accessible.description: root.placeholder + " input"
    activeFocusOnTab: !root.disabled && !root.readOnly

    onActiveFocusChanged: {
        if (activeFocus) {
            textInput.forceActiveFocus()
        }
    }

    // Focus ring overlay
    FocusRing {
        target: root
        active: root.activeFocus && !root.disabled
    }
}
