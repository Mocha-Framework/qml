import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property string text: ""
    property string placeholder: "Digite aqui..."
    property bool disabled: false
    property bool readOnly: false
    property string size: "md" // "sm" | "md" | "lg"
    property string status: "normal" // "normal" | "success" | "error"

    // Style overrides
    property real customRadius: -1
    property color customBorderColor: "transparent"
    property color customBackgroundColor: "transparent"

    // Signals
    signal textEdited()

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
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

    readonly property real defaultRadius: {
        if (size === "sm") return Theme.geometry.radiusSm
        if (size === "lg") return Theme.geometry.radiusLg
        return Theme.geometry.radiusMd
    }

    readonly property real finalRadius: customRadius >= 0 ? customRadius : defaultRadius

    readonly property color finalBackgroundColor: {
        if (disabled) return Theme.colors.crust
        if (customBackgroundColor.toString() !== "#00000000" && customBackgroundColor.toString() !== "transparent") {
            return customBackgroundColor
        }
        return Theme.colors.mantle
    }

    readonly property color finalBorderColor: {
        if (disabled) return Theme.colors.surface0
        if (customBorderColor.toString() !== "#00000000" && customBorderColor.toString() !== "transparent") {
            return customBorderColor
        }
        if (status === "success") return Theme.colors.success
        if (status === "error") return Theme.colors.danger
        if (textEdit.activeFocus) return Theme.colors.primary
        if (mouseArea.containsMouse) return Theme.colors.overlay0
        return Theme.colors.surface1
    }

    // Layout Dimensions
    implicitWidth: 320
    implicitHeight: 180
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // ==========================================
    // Visual Tree
    // ==========================================

    // Background Panel
    Rectangle {
        id: bgPanel
        anchors.fill: parent
        color: root.finalBackgroundColor
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: textEdit.activeFocus ? Theme.geometry.borderMd : Theme.geometry.borderSm
        clip: true

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // Hover detection MouseArea
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (!root.disabled && !root.readOnly) {
                textEdit.forceActiveFocus();
            }
        }
    }

    // Scrollable container for multi-line editing
    Flickable {
        id: flickable
        anchors.fill: parent
        anchors.margins: root.currentPadding
        contentWidth: width
        contentHeight: textEdit.paintedHeight
        clip: true

        // Actual TextEdit control
        TextEdit {
            id: textEdit
            width: parent.width
            text: root.text
            font.family: Theme.typography.family
            font.pixelSize: root.currentFontSize
            color: root.disabled ? Theme.colors.overlay0 : Theme.colors.text
            selectionColor: Theme.colors.surface2
            selectedTextColor: Theme.colors.text
            wrapMode: TextEdit.Wrap
            selectByMouse: true
            readOnly: root.readOnly
            enabled: !root.disabled
            cursorVisible: activeFocus
            antialiasing: true

            onTextChanged: {
                if (root.text !== text) {
                    root.text = text;
                    root.textEdited();
                }
            }

            Keys.onTabPressed: function(event) {
                var next = root.nextItemInFocusChain(true);
                if (next) {
                    next.forceActiveFocus();
                    event.accepted = true;
                }
            }

            Keys.onBacktabPressed: function(event) {
                var prev = root.nextItemInFocusChain(false);
                if (prev) {
                    prev.forceActiveFocus();
                    event.accepted = true;
                }
            }
        }
    }

    // Placeholder (irmão do Flickable, não filho do TextEdit)
    Text {
        text: root.placeholder
        font.family: Theme.typography.family
        font.pixelSize: root.currentFontSize
        color: Theme.colors.overlay0
        visible: textEdit.text === "" && !textEdit.activeFocus
        anchors.fill: flickable
        anchors.leftMargin: root.currentPadding
        anchors.topMargin: root.currentPadding
        wrapMode: Text.Wrap
        antialiasing: true
    }

    // Cozy Custom Scrollbar
    ScrollBar {
        id: scrollbar
        flickable: flickable
        anchors.right: parent.right
        anchors.rightMargin: Theme.spacing.xs
        anchors.top: parent.top
        anchors.topMargin: root.currentPadding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: root.currentPadding
    }

    activeFocusOnTab: !root.disabled && !root.readOnly

    onActiveFocusChanged: {
        if (activeFocus) {
            textEdit.forceActiveFocus()
        }
    }

    // Sync text from outside into the TextEdit
    Connections {
        target: root
        function onTextChanged() {
            if (textEdit.text !== root.text) {
                textEdit.text = root.text;
            }
        }
    }
}
