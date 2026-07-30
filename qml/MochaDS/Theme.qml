pragma Singleton
import QtQuick

Item {
    id: root

    Component.onCompleted: root._refreshFromBrand()

    // ==========================================
    // Universal Overlay Stacking Order Manager
    // ==========================================
    property int currentMaxZ: 10000

    function getNextMaxZ() {
        currentMaxZ = currentMaxZ + 1;
        return currentMaxZ;
    }

    // ==========================================
    // Font Loaders
    // ==========================================
    FontLoader {
        id: outfitRegularLoader
        source: "../assets/fonts/Outfit-Regular.ttf"
    }

    FontLoader {
        id: outfitMediumLoader
        source: "../assets/fonts/Outfit-Medium.ttf"
    }

    FontLoader {
        id: outfitBoldLoader
        source: "../assets/fonts/Outfit-Bold.ttf"
    }

    // Expose loaded font names
    readonly property string fontFamily: outfitRegularLoader.name
    readonly property string fontFamilyMedium: outfitMediumLoader.name
    readonly property string fontFamilyBold: outfitBoldLoader.name

    // ==========================================
    // Visual Tokens
    // ==========================================

    // Spacing Tokens
    readonly property QtObject spacing: QtObject {
        readonly property real xs: 4
        readonly property real sm: 8
        readonly property real md: 12
        readonly property real lg: 16
        readonly property real xl: 24
        readonly property real xxl: 32
    }

    // Geometry Tokens (Cozy, soft corners)
    readonly property QtObject geometry: QtObject {
        readonly property real radiusSm: 6
        readonly property real radiusMd: 12
        readonly property real radiusLg: 18
        readonly property real radiusPill: 9999
        
        readonly property real borderSm: 1
        readonly property real borderMd: 2
    }

    // ==========================================
    // Theme & Palette Setup
    // ==========================================
    property string flavor: "mocha" // "mocha" | "macchiato" | "frappe" | "latte" | "vercel" | "vercel-light"
    property bool useSystemTheme: false

    SystemPalette {
        id: sysPalette
        colorGroup: SystemPalette.Active
    }

    function isDarkColor(color) {
        var luminance = (0.2126 * color.r) + (0.7152 * color.g) + (0.0722 * color.b);
        return luminance < 0.5;
    }

    readonly property bool isDark: useSystemTheme
        ? isDarkColor(sysPalette.window)
        : root._brandIsDark

    function getColor(name) {
        if (useSystemTheme) {
            var systemDark = isDarkColor(sysPalette.window)

            // Base and surface layout structure always respects native light/dark theme
            if (name === "base" || name === "background") return sysPalette.window
            // Rule 2: Integrate sysPalette.base for input fields (mantle) to separate them from buttons
            if (name === "mantle") return sysPalette.base
            if (name === "crust") return Qt.darker(sysPalette.window, 1.1)
            
            if (name === "text") return sysPalette.windowText
            // Rule 4: Opaque solid colors to preserve subpixel antialiasing
            if (name === "subtext1") return Qt.tint(sysPalette.window, Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.8))
            if (name === "subtext0") return Qt.tint(sysPalette.window, Qt.rgba(sysPalette.windowText.r, sysPalette.windowText.g, sysPalette.windowText.b, 0.6))
            
            if (name === "surface0") return sysPalette.button
            if (name === "surface1") return Qt.darker(sysPalette.button, 1.05)
            if (name === "surface2") return Qt.darker(sysPalette.button, 1.1)
            
            if (name === "overlay0") return sysPalette.mid
            if (name === "overlay1") return sysPalette.dark
            if (name === "overlay2") return sysPalette.shadow
            
            // Rule 1: Correct Light Mode fallback using the latte palette
            if (!systemDark) {
                return ThemeGenerated.resolveColor("latte", name);
            }

            // Rule 3: Programmatic variations for semantic and accent colors to prevent pointing to the same highlight color
            if (name === "red" || name === "danger") return Qt.tint(sysPalette.window, Qt.rgba(0.9, 0.15, 0.15, 0.8))
            if (name === "green" || name === "success") return Qt.tint(sysPalette.window, Qt.rgba(0.15, 0.75, 0.15, 0.8))
            if (name === "yellow" || name === "warning") return Qt.tint(sysPalette.window, Qt.rgba(0.9, 0.65, 0.15, 0.8))

            // Primary accents
            if (name === "mauve" || name === "primary" || name === "accent") return sysPalette.highlight
            
            // Differentiated accents
            if (name === "blue" || name === "secondary") {
                return systemDark ? Qt.darker(sysPalette.highlight, 1.1) : Qt.lighter(sysPalette.highlight, 1.1)
            }
            if (name === "sky" || name === "info") {
                return systemDark ? Qt.lighter(sysPalette.highlight, 1.2) : Qt.darker(sysPalette.highlight, 1.2)
            }
            
            // Other accents mapped programmatically to be distinct from highlight
            if (name === "rosewater") return Qt.tint(sysPalette.highlight, Qt.rgba(0.95, 0.85, 0.85, 0.4))
            if (name === "flamingo") return Qt.tint(sysPalette.highlight, Qt.rgba(0.95, 0.75, 0.75, 0.4))
            if (name === "pink") return Qt.tint(sysPalette.highlight, Qt.rgba(0.95, 0.6, 0.85, 0.4))
            if (name === "maroon") return Qt.tint(sysPalette.highlight, Qt.rgba(0.85, 0.4, 0.4, 0.4))
            if (name === "peach") return Qt.tint(sysPalette.highlight, Qt.rgba(0.95, 0.65, 0.4, 0.4))
            if (name === "teal") return Qt.tint(sysPalette.highlight, Qt.rgba(0.2, 0.75, 0.65, 0.4))
            if (name === "sapphire") return Qt.tint(sysPalette.highlight, Qt.rgba(0.2, 0.6, 0.85, 0.4))
            if (name === "lavender") return Qt.tint(sysPalette.highlight, Qt.rgba(0.7, 0.65, 0.95, 0.4))

            return sysPalette.window
        }

        return ThemeGenerated.resolveColor(flavor, name);
    }

    function _schemeFallback(schemeKey) {
        switch (schemeKey) {
            case "schemePrimary": return "mauve"
            case "schemeOnPrimary": return root.isDark ? "crust" : "base"
            case "schemePrimaryContainer": return root.isDark ? "surface2" : "surface0"
            case "schemeOnPrimaryContainer": return root.isDark ? "text" : "text"
            case "schemeSecondary": return "blue"
            case "schemeOnSecondary": return root.isDark ? "crust" : "base"
            case "schemeSecondaryContainer": return root.isDark ? "surface1" : "surface0"
            case "schemeOnSecondaryContainer": return root.isDark ? "text" : "text"
            case "schemeTertiary": return "teal"
            case "schemeOnTertiary": return root.isDark ? "crust" : "base"
            case "schemeSurface": return "surface0"
            case "schemeOnSurface": return "text"
            case "schemeSurfaceVariant": return "surface1"
            case "schemeOnSurfaceVariant": return "subtext0"
            case "schemeBackground": return "base"
            case "schemeOnBackground": return "text"
            case "schemeError": return "red"
            case "schemeOnError": return root.isDark ? "crust" : "base"
            case "schemeOutline": return "overlay0"
            case "schemeOutlineVariant": return "overlay1"
        }
        return "text"
    }

    // ── Semantic Color Scheme (Material-like API) ──
    // Mutable properties manually synced from _brandTheme via Connections
    // because QML binding dependency tracking on QQmlPropertyMap properties
    // does NOT reliably trigger re-evaluation inside singleton singletons.
    // For local ThemeGenerated fallbacks, we explicitly read `flavor` and `isDark` 
    // to force QML to track the dependency!

    property color schemePrimary: { var f = flavor; var d = isDark; return root.getColor("mauve") }
    property color schemeOnPrimary: { var f = flavor; var d = isDark; return root.getColor(d ? "crust" : "base") }
    property color schemePrimaryContainer: { var f = flavor; var d = isDark; return root.getColor(d ? "surface2" : "surface0") }
    property color schemeOnPrimaryContainer: { var f = flavor; var d = isDark; return root.getColor("text") }
    property color schemeSecondary: { var f = flavor; var d = isDark; return root.getColor("blue") }
    property color schemeOnSecondary: { var f = flavor; var d = isDark; return root.getColor(d ? "crust" : "base") }
    property color schemeSecondaryContainer: { var f = flavor; var d = isDark; return root.getColor(d ? "surface1" : "surface0") }
    property color schemeOnSecondaryContainer: { var f = flavor; var d = isDark; return root.getColor("text") }
    property color schemeTertiary: { var f = flavor; var d = isDark; return root.getColor("teal") }
    property color schemeOnTertiary: { var f = flavor; var d = isDark; return root.getColor(d ? "crust" : "base") }
    property color schemeSurface: { var f = flavor; var d = isDark; return root.getColor("surface0") }
    property color schemeOnSurface: { var f = flavor; var d = isDark; return root.getColor("text") }
    property color schemeSurfaceVariant: { var f = flavor; var d = isDark; return root.getColor("surface1") }
    property color schemeOnSurfaceVariant: { var f = flavor; var d = isDark; return root.getColor("subtext0") }
    property color schemeBackground: { var f = flavor; var d = isDark; return root.getColor("base") }
    property color schemeOnBackground: { var f = flavor; var d = isDark; return root.getColor("text") }
    property color schemeError: { var f = flavor; var d = isDark; return root.getColor("red") }
    property color schemeOnError: { var f = flavor; var d = isDark; return root.getColor(d ? "crust" : "base") }
    property color schemeOutline: { var f = flavor; var d = isDark; return root.getColor("overlay0") }
    property color schemeOutlineVariant: { var f = flavor; var d = isDark; return root.getColor("overlay1") }

    function _refreshFromBrand() {
        if (typeof _brandTheme === "undefined" || _brandTheme === null) return
        var b = _brandTheme
        if (b.schemePrimary !== undefined) root.schemePrimary = b.schemePrimary
        if (b.schemeOnPrimary !== undefined) root.schemeOnPrimary = b.schemeOnPrimary
        if (b.schemePrimaryContainer !== undefined) root.schemePrimaryContainer = b.schemePrimaryContainer
        if (b.schemeOnPrimaryContainer !== undefined) root.schemeOnPrimaryContainer = b.schemeOnPrimaryContainer
        if (b.schemeSecondary !== undefined) root.schemeSecondary = b.schemeSecondary
        if (b.schemeOnSecondary !== undefined) root.schemeOnSecondary = b.schemeOnSecondary
        if (b.schemeSecondaryContainer !== undefined) root.schemeSecondaryContainer = b.schemeSecondaryContainer
        if (b.schemeOnSecondaryContainer !== undefined) root.schemeOnSecondaryContainer = b.schemeOnSecondaryContainer
        if (b.schemeTertiary !== undefined) root.schemeTertiary = b.schemeTertiary
        if (b.schemeOnTertiary !== undefined) root.schemeOnTertiary = b.schemeOnTertiary
        if (b.schemeSurface !== undefined) root.schemeSurface = b.schemeSurface
        if (b.schemeOnSurface !== undefined) root.schemeOnSurface = b.schemeOnSurface
        if (b.schemeSurfaceVariant !== undefined) root.schemeSurfaceVariant = b.schemeSurfaceVariant
        if (b.schemeOnSurfaceVariant !== undefined) root.schemeOnSurfaceVariant = b.schemeOnSurfaceVariant
        if (b.schemeBackground !== undefined) root.schemeBackground = b.schemeBackground
        if (b.schemeOnBackground !== undefined) root.schemeOnBackground = b.schemeOnBackground
        if (b.schemeError !== undefined) root.schemeError = b.schemeError
        if (b.schemeOnError !== undefined) root.schemeOnError = b.schemeOnError
        if (b.schemeOutline !== undefined) root.schemeOutline = b.schemeOutline
        if (b.schemeOutlineVariant !== undefined) root.schemeOutlineVariant = b.schemeOutlineVariant
        root._refreshIsDark()
    }

    property bool _brandIsDark: flavor !== "latte" && flavor !== "vercel-light"
    function _refreshIsDark() {
        var d = (typeof _brandTheme !== "undefined" && _brandTheme !== null) ? _brandTheme.isDark : undefined
        if (d !== undefined) {
            root._brandIsDark = (d === "true" || d === true)
        }
    }

    Connections {
        target: typeof _brandTheme !== "undefined" && _brandTheme !== null ? _brandTheme : null
        function onSeqChanged() {
            root._refreshFromBrand()
        }
    }

    // Alias to preserve Theme.scheme.xxx backward compat
    readonly property QtObject scheme: QtObject {
        readonly property color primary: root.schemePrimary
        readonly property color onPrimary: root.schemeOnPrimary
        readonly property color primaryContainer: root.schemePrimaryContainer
        readonly property color onPrimaryContainer: root.schemeOnPrimaryContainer
        readonly property color secondary: root.schemeSecondary
        readonly property color onSecondary: root.schemeOnSecondary
        readonly property color secondaryContainer: root.schemeSecondaryContainer
        readonly property color onSecondaryContainer: root.schemeOnSecondaryContainer
        readonly property color tertiary: root.schemeTertiary
        readonly property color onTertiary: root.schemeOnTertiary
        readonly property color surface: root.schemeSurface
        readonly property color onSurface: root.schemeOnSurface
        readonly property color surfaceVariant: root.schemeSurfaceVariant
        readonly property color onSurfaceVariant: root.schemeOnSurfaceVariant
        readonly property color background: root.schemeBackground
        readonly property color onBackground: root.schemeOnBackground
        readonly property color error: root.schemeError
        readonly property color onError: root.schemeOnError
        readonly property color outline: root.schemeOutline
        readonly property color outlineVariant: root.schemeOutlineVariant
    }

    // Colors (retrocompatível — raw palette)
    readonly property QtObject colors: QtObject {
        // Theme Colors
        readonly property color base: { var f = flavor; return root.getColor("base") }
        readonly property color mantle: { var f = flavor; return root.getColor("mantle") }
        readonly property color crust: { var f = flavor; return root.getColor("crust") }

        readonly property color text: root.schemeOnBackground
        readonly property color subtext1: {
            var f = flavor;
            if (typeof _brandTheme !== "undefined" && _brandTheme && _brandTheme.schemeOnSurfaceVariant !== undefined) return _brandTheme.schemeOnSurfaceVariant
            return root.getColor("subtext1")
        }
        readonly property color subtext0: {
            var f = flavor;
            if (typeof _brandTheme !== "undefined" && _brandTheme && _brandTheme.schemeOnSurfaceVariant !== undefined) {
                var c = _brandTheme.schemeOnSurfaceVariant
                return Qt.rgba(c.r, c.g, c.b, 0.7)
            }
            return root.getColor("subtext0")
        }

        readonly property color overlay2: { var f = flavor; return root.getColor("overlay2") }
        readonly property color overlay1: { var f = flavor; return root.getColor("overlay1") }
        readonly property color overlay0: { var f = flavor; return root.getColor("overlay0") }

        readonly property color surface2: { var f = flavor; return root.getColor("surface2") }
        readonly property color surface1: { var f = flavor; return root.getColor("surface1") }
        readonly property color surface0: { var f = flavor; return root.getColor("surface0") }

        // Accent Colors
        readonly property color lavender: { var f = flavor; return root.getColor("lavender") }
        readonly property color blue: { var f = flavor; return root.getColor("blue") }
        readonly property color sapphire: { var f = flavor; return root.getColor("sapphire") }
        readonly property color sky: { var f = flavor; return root.getColor("sky") }
        readonly property color teal: { var f = flavor; return root.getColor("teal") }
        readonly property color green: { var f = flavor; return root.getColor("green") }
        readonly property color yellow: { var f = flavor; return root.getColor("yellow") }
        readonly property color peach: { var f = flavor; return root.getColor("peach") }
        readonly property color maroon: { var f = flavor; return root.getColor("maroon") }
        readonly property color red: { var f = flavor; return root.getColor("red") }
        readonly property color mauve: { var f = flavor; return root.getColor("mauve") }
        readonly property color pink: { var f = flavor; return root.getColor("pink") }
        readonly property color flamingo: { var f = flavor; return root.getColor("flamingo") }
        readonly property color rosewater: { var f = flavor; return root.getColor("rosewater") }
        
        readonly property color contrastDark: { var f = flavor; return root.getColor("contrastDark") }
        readonly property color contrastLight: { var f = flavor; return root.getColor("contrastLight") }

        // Semantic Colors (use brand-aware scheme when available)
        readonly property color background: root.schemeBackground
        readonly property color primary: root.schemePrimary
        readonly property color secondary: root.schemeSecondary
        readonly property color success: green
        readonly property color warning: yellow
        readonly property color danger: root.schemeError
        readonly property color info: sky
    }

    // Breakpoints (Tailwind-inspired)
    readonly property QtObject breakpoints: QtObject {
        readonly property real xs: 0
        readonly property real sm: 640
        readonly property real md: 768
        readonly property real lg: 1024
        readonly property real xl: 1280
    }

    // Typography Config
    readonly property QtObject typography: QtObject {
        // Font Families (overridable via _brandTheme)
        readonly property string family: {
            var b = (typeof _brandTheme !== "undefined" && _brandTheme !== null) ? _brandTheme : null
            if (b && b.typeFamily !== undefined) return b.typeFamily
            return root.fontFamily
        }
        readonly property string familyMedium: {
            var b = (typeof _brandTheme !== "undefined" && _brandTheme !== null) ? _brandTheme : null
            if (b) {
                if (b.typeFamilyMedium !== undefined) return b.typeFamilyMedium
                if (b.typeFamily !== undefined) return b.typeFamily
            }
            return root.fontFamilyMedium
        }
        readonly property string familyBold: {
            var b = (typeof _brandTheme !== "undefined" && _brandTheme !== null) ? _brandTheme : null
            if (b) {
                if (b.typeFamilyBold !== undefined) return b.typeFamilyBold
                if (b.typeFamily !== undefined) return b.typeFamily
            }
            return root.fontFamilyBold
        }
        readonly property string familyDisplay: {
            var b = (typeof _brandTheme !== "undefined" && _brandTheme !== null) ? _brandTheme : null
            if (b) {
                if (b.typeFamilyDisplay !== undefined) return b.typeFamilyDisplay
                if (b.typeFamily !== undefined) return b.typeFamily
            }
            return "Geist"
        }
        readonly property string familyMono: {
            var b = (typeof _brandTheme !== "undefined" && _brandTheme !== null) ? _brandTheme : null
            if (b && b.typeFamilyMono !== undefined) return b.typeFamilyMono
            return "Geist Mono"
        }

        // Font Sizes
        readonly property real sizeXs: 10
        readonly property real sizeSm: 12
        readonly property real sizeMd: 14 // Body text
        readonly property real sizeLg: 16 // Large text
        readonly property real sizeXl: 20 // Subheadings
        readonly property real sizeH2: 24 // Medium headings
        readonly property real sizeH1: 32 // Large headings
    }
}
