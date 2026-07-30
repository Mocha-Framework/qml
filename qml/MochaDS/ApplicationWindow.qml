import QtQuick 2.15
import QtQuick.Controls 2.15
import MochaDS
import "." as DS

ApplicationWindow {
    id: windowRoot

    // Theme Mode: "catppuccin" | "system"
    property string themeMode: "catppuccin"

    // Catppuccin Flavor: "mocha" | "macchiato" | "frappe" | "latte"
    property string flavor: Theme.flavor

    // Dark native title bar — set to false for light themes (latte, vercel-light)
    property bool darkTitleBar: true

    onFlavorChanged: {
        if (Theme.flavor !== flavor) {
            Theme.flavor = flavor;
        }
    }

    Connections {
        target: Theme
        ignoreUnknownSignals: true
        function onFlavorChanged() {
            if (windowRoot.flavor !== Theme.flavor) {
                windowRoot.flavor = Theme.flavor;
            }
        }
    }

    // Update global Theme setting when mode changes
    onThemeModeChanged: {
        Theme.useSystemTheme = (themeMode === "system")
    }

    Component.onCompleted: {
        Theme.useSystemTheme = (themeMode === "system")
    }

    // Default window styling based on theme
    color: Theme.colors.background

    font.family: Theme.typography.family
    font.pixelSize: Theme.typography.sizeMd
}
