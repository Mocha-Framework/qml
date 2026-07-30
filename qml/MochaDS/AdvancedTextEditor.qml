import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property string text: ""
    property string placeholder: "Digite em Markdown..."
    property bool disabled: false
    property bool readOnly: false
    property bool visualMode: true // true: WYSIWYG (editable formatted view), false: Raw Code
    property bool showToolbar: true
    property bool showStatusbar: true

    // Style overrides
    property real customRadius: -1
    property color customBorderColor: "transparent"
    property color customBackgroundColor: "transparent"

    // Signals
    signal textEdited()

    // ==========================================
    // Internal Properties & Calculations
    // ==========================================
    readonly property real finalRadius: customRadius >= 0 ? customRadius : Theme.geometry.radiusMd
    readonly property color finalBorderColor: customBorderColor.toString() !== "#00000000" && customBorderColor.toString() !== "transparent" ? customBorderColor : Theme.colors.surface1
    readonly property color finalBackgroundColor: disabled ? Theme.colors.crust : Theme.colors.mantle

    readonly property int characterCount: text.length
    readonly property int wordCount: {
        var cleanText = text.trim();
        if (cleanText === "") return 0;
        return cleanText.split(/\s+/).length;
    }

    implicitWidth: 600
    implicitHeight: 400
    width: implicitWidth
    height: implicitHeight

    // ==========================================
    // Formatting & Helper Functions (Raw-Space)
    // ==========================================
    function formatText(prefix, suffix) {
        if (readOnly) return;
        
        textEdit.forceActiveFocus();
        
        var start = textEdit.selectionStart;
        var end = textEdit.selectionEnd;
        var textVal = textEdit.text;
        
        var isHeading = prefix.trim().indexOf("#") === 0 || prefix.trim() === ">" || prefix.trim() === "-";
        
        if (isHeading) {
            var lineStart = textVal.lastIndexOf("\n", start - 1) + 1;
            var lineEnd = textVal.indexOf("\n", start);
            if (lineEnd === -1) lineEnd = textVal.length;

            var lineText = textVal.substring(lineStart, lineEnd);
            var cleanLine = lineText;
            var currentPrefix = "";
            
            var prefixMatch = lineText.match(/^(#{1,6}\s+|>\s+|-\s+|\*\s+|\+\s+|\d+\.\s+)/);
            if (prefixMatch) {
                currentPrefix = prefixMatch[1];
                cleanLine = lineText.substring(currentPrefix.length);
            }

            var newLineText = (currentPrefix === prefix) ? cleanLine : prefix + cleanLine;

            textEdit.remove(lineStart, lineEnd);
            textEdit.insert(lineStart, newLineText);
            
            textEdit.cursorPosition = lineStart + newLineText.length;
        } else {
            if (start !== end) {
                var selectedRaw = textVal.substring(start, end);
                
                var hasInsidePrefix = selectedRaw.indexOf(prefix) === 0;
                var hasInsideSuffix = selectedRaw.lastIndexOf(suffix) === (selectedRaw.length - suffix.length) && suffix.length > 0;
                
                var hasOutsidePrefix = (start >= prefix.length) && (textVal.substring(start - prefix.length, start) === prefix);
                var hasOutsideSuffix = (end + suffix.length <= textVal.length) && (textVal.substring(end, end + suffix.length) === suffix);
                
                if (hasInsidePrefix && hasInsideSuffix) {
                    var newText = selectedRaw.substring(prefix.length, selectedRaw.length - suffix.length);
                    textEdit.remove(start, end);
                    textEdit.insert(start, newText);
                    textEdit.select(start, start + newText.length);
                } else if (hasOutsidePrefix && hasOutsideSuffix) {
                    textEdit.remove(end, end + suffix.length);
                    textEdit.remove(start - prefix.length, start);
                    var newStart = start - prefix.length;
                    textEdit.select(newStart, newStart + selectedRaw.length);
                } else {
                    textEdit.remove(start, end);
                    textEdit.insert(start, prefix + selectedRaw + suffix);
                    textEdit.select(start + prefix.length, start + prefix.length + selectedRaw.length);
                }
            } else {
                textEdit.insert(start, prefix + suffix);
                textEdit.cursorPosition = start + prefix.length;
            }
        }
        
        root.textEdited();
    }

    // ==========================================
    // Visual Hierarchy
    // ==========================================

    Rectangle {
        id: bgPanel
        anchors.fill: parent
        color: Theme.colors.base
        radius: root.finalRadius
        border.color: root.finalBorderColor
        border.width: textEdit.activeFocus ? Theme.geometry.borderMd : Theme.geometry.borderSm
        clip: true

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    Column {
        anchors.fill: parent
        spacing: 0

        // 1. WYSIWYG Formatting Toolbar
        Rectangle {
            id: toolbar
            width: parent.width
            height: root.showToolbar ? 42 : 0
            visible: root.showToolbar
            color: Theme.colors.mantle

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.md
                anchors.rightMargin: Theme.spacing.md
                spacing: Theme.spacing.sm

                // Formatting group
                Row {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.xs
                    visible: !root.readOnly

                    ToolbarButton { icon: "bold"; tooltip: "Negrito"; onClicked: root.formatText("**", "**") }
                    ToolbarButton { icon: "italic"; tooltip: "Itálico"; onClicked: root.formatText("*", "*") }
                    
                    ToolbarSeparator {}

                    ToolbarButton { icon: "heading-1"; tooltip: "Título 1"; onClicked: root.formatText("# ", "") }
                    ToolbarButton { icon: "heading-2"; tooltip: "Título 2"; onClicked: root.formatText("## ", "") }
                    ToolbarButton { icon: "heading-3"; tooltip: "Título 3"; onClicked: root.formatText("### ", "") }

                    ToolbarSeparator {}

                    ToolbarButton { icon: "code"; tooltip: "Código"; onClicked: root.formatText("`", "`") }
                    ToolbarButton { icon: "text-quote"; tooltip: "Citação"; onClicked: root.formatText("> ", "") }
                    ToolbarButton { icon: "list"; tooltip: "Lista"; onClicked: root.formatText("- ", "") }
                }

                // Spacer
                Item {
                    width: parent.width - (root.readOnly ? 0 : 340) - modeSelector.width - Theme.spacing.md * 2
                    height: 1
                }

                // Mode switcher (Visual WYSIWYG vs Raw Code)
                Row {
                    id: modeSelector
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.spacing.xs

                    ToolbarButton {
                        icon: "eye"
                        tooltip: "Visual (Editável)"
                        active: root.visualMode
                        onClicked: root.visualMode = true
                    }

                    ToolbarButton {
                        icon: "code-2"
                        tooltip: "Código Fonte"
                        active: !root.visualMode
                        onClicked: root.visualMode = false
                    }
                }
            }
        }

        // 2. Main Editing Viewport
        Item {
            width: parent.width
            height: parent.height - toolbar.height - statusbar.height
            clip: true

            // Hover focus catcher MouseArea (placed behind Flickable)
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton
                onClicked: {
                    if (!root.readOnly) {
                        textEdit.forceActiveFocus();
                    }
                }
            }

            Flickable {
                id: editorFlickable
                anchors.fill: parent
                anchors.margins: Theme.spacing.md
                contentWidth: width - Theme.spacing.md * 2
                contentHeight: textEdit.paintedHeight
                clip: true

                TextEdit {
                    id: textEdit
                    width: parent.width
                    text: root.text
                    textFormat: root.visualMode ? TextEdit.MarkdownText : TextEdit.PlainText
                    font.family: root.visualMode ? Theme.typography.family : "monospace"
                    font.pixelSize: Theme.typography.sizeMd
                    color: Theme.colors.text
                    selectionColor: Theme.colors.surface2
                    selectedTextColor: Theme.colors.text
                    wrapMode: TextEdit.Wrap
                    selectByMouse: true
                    readOnly: root.readOnly
                    cursorVisible: activeFocus
                    antialiasing: true

                    onTextChanged: {
                        if (root.text !== text) {
                            root.text = text;
                            root.textEdited();
                        }
                    }

                    Keys.onPressed: {
                        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (root.visualMode && !root.readOnly) {
                                var rawText = textEdit.text;
                                var pos = textEdit.cursorPosition;
                                
                                var lineStart = rawText.lastIndexOf("\n", pos - 1) + 1;
                                var lineEnd = rawText.indexOf("\n", pos);
                                if (lineEnd === -1) lineEnd = rawText.length;
                                
                                var lineText = rawText.substring(lineStart, lineEnd);
                                
                                // 1. If line is just a prefix (e.g. "# ", "- ", etc.), clear it
                                var prefixMatch = lineText.match(/^(#{1,6}\s+|>\s+|-\s+|\*\s+|\+\s+|\d+\.\s+)$/);
                                if (prefixMatch) {
                                    textEdit.remove(lineStart, lineEnd);
                                    event.accepted = true;
                                    root.textEdited();
                                    return;
                                }
                                
                                // 2. If it's a heading and cursor is at the end, insert newline manually to break block formatting
                                if (lineText.indexOf("#") === 0 && pos === lineEnd) {
                                    textEdit.insert(textEdit.cursorPosition, "\n");
                                    event.accepted = true;
                                    root.textEdited();
                                    return;
                                }
                            }
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

                    // Placeholder
                    Text {
                        text: root.placeholder
                        font.family: parent.font.family
                        font.pixelSize: parent.font.pixelSize
                        color: Theme.colors.overlay0
                        visible: parent.text === "" && !textEdit.activeFocus
                        anchors.fill: parent
                        wrapMode: Text.Wrap
                        antialiasing: true
                    }
                }
            }

            ScrollBar {
                flickable: editorFlickable
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacing.xs
                anchors.top: parent.top
                anchors.topMargin: Theme.spacing.xs
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Theme.spacing.xs
            }
        }

        // 3. Status Bar
        Rectangle {
            id: statusbar
            width: parent.width
            height: root.showStatusbar ? 26 : 0
            visible: root.showStatusbar
            color: Theme.colors.mantle

            Rectangle {
                anchors.top: parent.top
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            Row {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.md
                spacing: Theme.spacing.lg

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.wordCount + " palavras"
                    font.pixelSize: 11
                    font.family: Theme.typography.family
                    color: Theme.colors.overlay1
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.characterCount + " caracteres"
                    font.pixelSize: 11
                    font.family: Theme.typography.family
                    color: Theme.colors.overlay1
                }
            }
        }
    }

    // Toggle logic helper
    onVisualModeChanged: {
        var cursor = textEdit.cursorPosition;
        var savedText = textEdit.text;
        textEdit.text = "";
        textEdit.textFormat = root.visualMode ? TextEdit.MarkdownText : TextEdit.PlainText;
        textEdit.text = savedText;
        textEdit.cursorPosition = cursor;
    }

    onTextChanged: {
        if (textEdit.text !== text) {
            textEdit.text = text;
        }
    }

    // ==========================================
    // Internal Components (Toolbar Items)
    // ==========================================
    component ToolbarButton : Rectangle {
        id: btnRoot
        property string icon: ""
        property string tooltip: ""
        property bool active: false
        signal clicked()

        width: 30
        height: 30
        radius: Theme.geometry.radiusSm
        color: active ? Theme.colors.surface1 : (ma.containsMouse ? Theme.colors.surface0 : "transparent")

        Behavior on color { ColorAnimation { duration: 150 } }

        LucideIcon {
            anchors.centerIn: parent
            name: btnRoot.icon
            size: 16
            color: btnRoot.active ? Theme.colors.primary : (ma.containsMouse ? Theme.colors.text : Theme.colors.subtext0)
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: btnRoot.clicked()
        }

        Tooltip {
            text: btnRoot.tooltip
        }
    }

    component ToolbarSeparator : Rectangle {
        width: 1
        height: 18
        color: Theme.colors.surface0
        anchors.verticalCenter: parent.verticalCenter
    }
}
