import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // The length of the PIN code (number of input slots)
    property int length: 4

    // The current text value of the PIN code input
    property string text: ""

    // The type of validation: "number" (digits only) or "text" (any character)
    property string type: "number"

    // If true, masks the text with a dot/bullet symbol (like a password field)
    property bool mask: false

    // Validation status: "normal" | "success" | "error"
    property string status: "normal"

    // If true, disables user interaction and dims the control
    property bool disabled: false

    // Size variation: "sm" | "md" | "lg"
    property string size: "md"

    // Spacing between the input slots
    property real spacing: Theme.spacing.sm

    // Form validation
    property string errorText: ""
    property bool isInvalid: errorText.length > 0

    // ==========================================
    // Signals
    // ==========================================

    // Triggered when all slots have been filled with text
    signal completed(string code)

    // Triggered when the user presses Enter/Return
    signal accepted()

    // Triggered whenever the text value is edited
    signal textEdited()

    // ==========================================
    // Methods
    // ==========================================

    // Clears the input code
    function clear() {
        text = "";
        hiddenInput.text = "";
    }

    // Forces focus to the input control
    function forceFocus() {
        hiddenInput.forceActiveFocus();
    }

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================

    readonly property real slotSize: {
        if (size === "sm") return 32
        if (size === "lg") return 48
        return 40 // "md"
    }

    readonly property real slotRadius: {
        if (size === "sm") return Theme.geometry.radiusSm
        if (size === "lg") return Theme.geometry.radiusLg
        return Theme.geometry.radiusMd
    }

    readonly property real slotFontSize: {
        if (size === "sm") return Theme.typography.sizeSm
        if (size === "lg") return Theme.typography.sizeLg
        return Theme.typography.sizeMd
    }

    // Check if the component is visually active / hovered
    property bool isHovered: mouseArea.containsMouse

    // Determine the border color for a given slot index
    function getSlotBorderColor(index) {
        if (disabled) return Theme.colors.surface0
        if (isInvalid) return Theme.colors.danger
        if (status === "success") return Theme.colors.success
        if (status === "error") return Theme.colors.danger
        if (isSlotActive(index)) return Theme.colors.primary
        if (isHovered) return Theme.colors.overlay0
        if (index < text.length) return Theme.colors.surface2 // filled slot
        return Theme.colors.surface1 // empty slot
    }

    // Determine the background color for a given slot index
    function getSlotBackgroundColor(index) {
        if (disabled) return Theme.colors.crust
        if (isSlotActive(index)) return Theme.colors.base
        return Theme.colors.mantle
    }

    // Determine if a slot is currently active (receiving typing next)
    function isSlotActive(index) {
        if (!hiddenInput.activeFocus || disabled) return false
        var len = text.length
        if (len === length) {
            // When full, keep focus on the last slot
            return index === length - 1
        }
        return index === len
    }

    // ==========================================
    // Layout & Dimensions
    // ==========================================
    implicitHeight: slotSize + (isInvalid ? 20 : 0)
    implicitWidth: length * slotSize + (length - 1) * spacing
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Accessibility
    Accessible.role: Accessible.EditableText
    Accessible.name: "PIN input"
    activeFocusOnTab: !root.disabled

    FocusRing {
        target: root
        active: root.activeFocus && !root.disabled
    }

    // Error text label
    Text {
        y: slotSize + 2
        text: root.errorText
        font.family: Theme.typography.family
        font.pixelSize: Theme.typography.sizeXs
        color: Theme.colors.danger
        visible: root.isInvalid
        height: 16
        anchors.horizontalCenter: parent.horizontalCenter
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Row of visual slots
    Row {
        id: slotsRow
        anchors.fill: parent
        spacing: root.spacing

        Repeater {
            model: root.length

            delegate: Rectangle {
                id: slotRect
                width: root.slotSize
                height: root.slotSize
                radius: root.slotRadius
                color: root.getSlotBackgroundColor(index)
                border.color: root.getSlotBorderColor(index)
                border.width: root.isSlotActive(index) ? Theme.geometry.borderMd : Theme.geometry.borderSm

                // Scale pop on active slot to focus user's attention
                scale: root.isSlotActive(index) ? 1.05 : 1.0

                Behavior on scale { NumberAnimation { duration: 100 } }
                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                // Slot Text Character
                Text {
                    id: characterText
                    anchors.centerIn: parent
                    font.family: Theme.typography.familyMedium
                    font.pixelSize: root.slotFontSize
                    font.bold: true
                    color: root.disabled ? Theme.colors.overlay0 : Theme.colors.text
                    antialiasing: true

                    text: {
                        if (index < root.text.length) {
                            return root.mask ? "•" : root.text.charAt(index)
                        }
                        return ""
                    }

                    // Soft pop animation when a character is typed/updated
                    onTextChanged: {
                        popAnimation.restart()
                    }

                    transform: Scale {
                        id: textScale
                        origin.x: characterText.width / 2
                        origin.y: characterText.height / 2
                    }

                    SequentialAnimation {
                        id: popAnimation
                        NumberAnimation { target: textScale; property: "xScale"; from: 0.6; to: 1.15; duration: 80; easing.type: Easing.OutQuad }
                        NumberAnimation { target: textScale; property: "yScale"; from: 0.6; to: 1.15; duration: 80; easing.type: Easing.OutQuad }
                        NumberAnimation { target: textScale; property: "xScale"; to: 1.0; duration: 40 }
                        NumberAnimation { target: textScale; property: "yScale"; to: 1.0; duration: 40 }
                    }
                }

                // Blinking Cursor visual
                Rectangle {
                    id: cursorLine
                    width: 2
                    height: root.slotFontSize * 1.2
                    color: Theme.colors.primary
                    anchors.centerIn: parent
                    visible: root.isSlotActive(index) && root.text.length === index

                    SequentialAnimation on opacity {
                        id: blinkAnim
                        loops: Animation.Infinite
                        running: cursorLine.visible
                        NumberAnimation { from: 1.0; to: 1.0; duration: 450 }
                        NumberAnimation { from: 0.0; to: 0.0; duration: 450 }
                    }

                    onVisibleChanged: {
                        if (visible) {
                            opacity = 1.0
                        }
                    }
                }
            }
        }
    }

    // Hidden native input that handles all editing operations, pasting, backspacing
    TextInput {
        id: hiddenInput
        anchors.fill: parent
        opacity: 0
        color: "transparent"
        cursorVisible: false
        enabled: !root.disabled
        maximumLength: root.length

        // Validator configurations based on type
        validator: root.type === "number" ? numberValidator : null

        RegularExpressionValidator {
            id: numberValidator
            regularExpression: /[0-9]*/
        }

        // Keep root text property synced with typing
        onTextChanged: {
            if (root.text !== text) {
                root.text = text
                root.textEdited()
            }
        }

        // Prevent users from clicking/navigating cursor within the hidden input
        onCursorPositionChanged: {
            if (cursorPosition !== text.length) {
                cursorPosition = text.length
            }
        }

        onAccepted: root.accepted()
    }

    // Handles focusing the hidden text input on user click
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (!root.disabled) {
                hiddenInput.forceActiveFocus()
                hiddenInput.cursorPosition = hiddenInput.text.length
            }
        }
    }

    // Watch external text property changes
    onTextChanged: {
        var clampedText = text.substring(0, root.length)
        if (hiddenInput.text !== clampedText) {
            hiddenInput.text = clampedText
        }
        if (clampedText.length === root.length) {
            root.completed(clampedText)
        }
    }
}
