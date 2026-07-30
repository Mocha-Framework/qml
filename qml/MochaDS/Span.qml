import QtQuick

Item {
    id: root

    // ═══════════════════════════════════════════════
    // Text Content
    // ═══════════════════════════════════════════════
    property string text: ""

    // ═══════════════════════════════════════════════
    // Variant — preset that sets defaults for size/weight/family/color
    // h1 | h2 | h3 | h4 | h5 | h6 | body | caption | overline | inherit
    // ═══════════════════════════════════════════════
    property string variant: "body"

    // ═══════════════════════════════════════════════
    // Color
    // ═══════════════════════════════════════════════
    property string colorName: ""       // token name: "text" | "subtext1" | "mauve" | etc.
    property color customColor: "transparent"

    readonly property bool hasCustomColor: customColor !== undefined
        && customColor !== null
        && customColor.toString() !== "#00000000"
        && customColor.toString() !== "transparent"

    readonly property color finalColor: {
        if (hasCustomColor) return customColor
        if (colorName !== "" && Theme.colors[colorName] !== undefined) return Theme.colors[colorName]
        return _variantDefaultColor()
    }

    // ═══════════════════════════════════════════════
    // Font Family — "display" | "body" | "mono" | ""
    // "" means use variant default
    // ═══════════════════════════════════════════════
    property string fontFamily: ""

    readonly property string finalFontFamily: {
        if (fontFamily === "display") return Theme.typography.familyDisplay || Theme.typography.familyBold
        if (fontFamily === "body") return Theme.typography.family
        if (fontFamily === "mono") return Theme.typography.familyMono || "monospace"
        if (fontFamily !== "") return fontFamily
        return _variantDefaultFamily()
    }

    // ═══════════════════════════════════════════════
    // Font Size — explicit override (0 = use variant default)
    // ═══════════════════════════════════════════════
    property real fontSize: 0

    readonly property real finalFontSize: fontSize > 0 ? fontSize : _variantDefaultSize()

    // ═══════════════════════════════════════════════
    // Weight — "light" | "regular" | "medium" | "semibold" | "bold"
    // numeric value (300-800) when weightNumber > 0
    // "" means use variant default
    // ═══════════════════════════════════════════════
    property string weight: ""
    property int weightNumber: 0

    readonly property int finalWeight: {
        if (weightNumber > 0) return weightNumber
        switch (weight) {
            case "light": return 300
            case "regular": return 400
            case "medium": return 500
            case "semibold": return 600
            case "bold": return 700
            case "extrabold": return 800
        }
        return _variantDefaultWeight()
    }

    // ═══════════════════════════════════════════════
    // Style Modifiers
    // ═══════════════════════════════════════════════
    property bool italic: false
    property string align: "left"          // left | center | right | justify
    property string decoration: "none"     // none | underline | line-through
    property bool uppercase: false         // force uppercase transform

    // ═══════════════════════════════════════════════
    // Line Height — multiplier (0 = use variant default)
    // ═══════════════════════════════════════════════
    property real lineHeight: 0

    readonly property real finalLineHeight: lineHeight > 0 ? lineHeight : _variantDefaultLineHeight()

    // ═══════════════════════════════════════════════
    // Letter Spacing — pixels (0 = use variant default)
    // ═══════════════════════════════════════════════
    property real letterSpacing: 0

    readonly property real finalLetterSpacing: letterSpacing !== 0 ? letterSpacing : _variantDefaultLetterSpacing()

    // ═══════════════════════════════════════════════
    // Interaction
    // ═══════════════════════════════════════════════
    property bool selectable: true
    property int maxLines: 0               // 0 = unlimited

    // ═══════════════════════════════════════════════
    // Gradient — "mauve-blue" | "peach-red" | "green-teal" etc.
    // Note: gradient text requires ShaderEffect in QML.
    // Property is reserved for future / web mapping.
    // ═══════════════════════════════════════════════
    property string gradient: ""

    // ═══════════════════════════════════════════════
    // HTML semantic tag hint (for web codegen)
    // h1 | h2 | h3 | h4 | h5 | h6 | p | span | caption | label | code
    // ═══════════════════════════════════════════════
    property string htmlTag: ""              // overrides variant's default HTML tag mapping

    // ═══════════════════════════════════════════════
    // Variant Defaults
    // ═══════════════════════════════════════════════

    function _variantDefaultColor() {
        switch (variant) {
            case "h1":
            case "h2":
            case "h3":
            case "h4": return Theme.colors.text
            case "h5":
            case "h6": return Theme.colors.text
            case "body": return Theme.colors.subtext1
            case "caption": return Theme.colors.subtext0
            case "overline": return Theme.colors.subtext0
            case "label": return Theme.colors.text
            case "code": return Theme.colors.green
        }
        if (variant === "inherit" && parent && parent.finalColor)
            return parent.finalColor
        return Theme.colors.text
    }

    function _variantDefaultFamily() {
        switch (variant) {
            case "h1":
            case "h2":
            case "h3": return Theme.typography.familyBold
            case "h4":
            case "h5":
            case "h6": return Theme.typography.familyMedium
            case "body":
            case "caption":
            case "label": return Theme.typography.family
            case "code": return Theme.typography.familyMono || "monospace"
            case "overline": return Theme.typography.familyBold
        }
        return Theme.typography.family
    }

    function _variantDefaultSize() {
        switch (variant) {
            case "h1": return Theme.typography.sizeH1      // 32
            case "h2": return Theme.typography.sizeH2      // 24
            case "h3": return Theme.typography.sizeXl      // 20
            case "h4": return Theme.typography.sizeLg      // 16
            case "h5": return Theme.typography.sizeMd      // 14
            case "h6": return Theme.typography.sizeSm      // 12
            case "body": return Theme.typography.sizeMd    // 14
            case "caption": return Theme.typography.sizeXs // 10
            case "overline": return Theme.typography.sizeXs // 10
            case "label": return Theme.typography.sizeSm   // 12
            case "code": return Theme.typography.sizeSm    // 12
        }
        if (variant === "inherit" && parent && parent.finalFontSize)
            return parent.finalFontSize
        return Theme.typography.sizeMd
    }

    function _variantDefaultWeight() {
        switch (variant) {
            case "h1":
            case "h2": return 700  // bold
            case "h3": return 600  // semibold
            case "h4": return 600  // semibold
            case "h5": return 500  // medium
            case "h6": return 500  // medium
            case "body": return 400  // regular
            case "caption": return 400  // regular
            case "overline": return 700  // bold
            case "label": return 500  // medium
            case "code": return 400  // regular
        }
        return 400
    }

    function _variantDefaultLineHeight() {
        switch (variant) {
            case "h1":
            case "h2": return 1.25
            case "h3": return 1.30
            case "h4":
            case "h5":
            case "h6": return 1.35
            case "body": return 1.60
            case "caption": return 1.40
            case "overline": return 1.20
            case "label": return 1.40
            case "code": return 1.50
        }
        return 1.50
    }

    function _variantDefaultLetterSpacing() {
        switch (variant) {
            case "h1": return -1.0
            case "h2": return -0.5
            case "h3": return -0.3
            case "overline": return 2.0
            case "h6": return 1.0
        }
        return 0
    }

    // ═══════════════════════════════════════════════
    // Layout
    // ═══════════════════════════════════════════════

    implicitWidth: label.implicitWidth
    implicitHeight: {
        if (maxLines > 0) {
            return Math.min(label.implicitHeight, finalFontSize * finalLineHeight * maxLines)
        }
        return label.implicitHeight
    }
    width: implicitWidth
    height: implicitHeight

    clip: maxLines > 0

    // ═══════════════════════════════════════════════
    // Label (Text + selection support)
    // ═══════════════════════════════════════════════

    Text {
        id: label
        anchors.fill: parent

        text: root.uppercase ? root.text.toUpperCase() : root.text
        color: root.finalColor
        font.family: root.finalFontFamily
        font.pixelSize: root.finalFontSize
        font.weight: root.finalWeight
        font.italic: root.italic
        font.letterSpacing: root.finalLetterSpacing

        lineHeight: root.finalLineHeight
        lineHeightMode: Text.ProportionalHeight

        horizontalAlignment: {
            switch (root.align) {
                case "center": return Text.AlignHCenter
                case "right": return Text.AlignRight
                case "justify": return Text.AlignJustify
                default: return Text.AlignLeft
            }
        }
        verticalAlignment: Text.AlignTop

        textFormat: Text.PlainText
        wrapMode: {
            if (root.variant === "code") return Text.NoWrap
            return Text.WordWrap
        }
        elide: maxLines > 0 ? Text.ElideRight : Text.ElideNone
        maximumLineCount: maxLines > 0 ? maxLines : 9999

        font.underline: root.decoration === "underline"
        font.strikeout: root.decoration === "line-through"
    }
}
