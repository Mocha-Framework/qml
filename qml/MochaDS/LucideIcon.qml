import QtQuick 2.15

Item {
    // ==========================================
    // Public API (Properties)
    // ==========================================
    // ==========================================
    // Internal Logic
    // ==========================================

    id: iconRoot

    // The name of the icon (e.g., "home", "settings") or a direct path/url to an SVG
    property string name: ""
    // The size of the icon (both width and height)
    property real size: 24
    // Color to apply to the icon
    property color color: Theme.colors.text
    // Stroke width (thickness) of the icon paths (default is 2)
    property real strokeWidth: 2
    // Internal cache for raw SVG text
    property string _rawSvgText: ""
    readonly property url resolvedSource: {
        if (!name)
            return "";

        if (name.indexOf("/") !== -1 || name.indexOf(":") !== -1)
            return name;

        return Qt.resolvedUrl("../assets/icons/" + name + ".svg");
    }

    function colorize() {
        var path = resolvedSource.toString();
        if (!path) {
            svgImage.source = "";
            _rawSvgText = "";
            return ;
        }
        var svgText = _rawSvgText;
        if (!svgText) {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", path, false); // Synchronous request (cuidado se o arquivo for remoto, mas para assets locais é ok)
            xhr.send();
            if (xhr.status === 200 || xhr.status === 0) {
                svgText = xhr.responseText;
                _rawSvgText = svgText;
            } else {
                console.warn("LucideIcon: Failed to load icon " + name + " from " + path + " (Status: " + xhr.status + ")");
                svgImage.source = "";
                return ;
            }
        }
        if (!svgText)
            return ;

        // Formatar cor para o SVG (removendo o Alpha do ARGB se presente)
        var rawColor = iconRoot.color.toString();
        var hexColor = rawColor;
        if (rawColor.indexOf("#") === 0 && rawColor.length === 9)
            hexColor = "#" + rawColor.substring(3);

        // Aplicar as cores e stroke
        var coloredSvg = svgText.replace(/stroke\s*=\s*["']currentColor["']/g, 'stroke="' + hexColor + '"').replace(/fill\s*=\s*["']currentColor["']/g, 'fill="' + hexColor + '"').replace(/stroke-width\s*=\s*["'][^"']*["']/g, 'stroke-width="' + iconRoot.strokeWidth + '"');
        try {
            // Usa codificação URL direta em vez de Base64.
            // O Qt entende data:image/svg+xml;utf8, perfeitamente.
            // encodeURIComponent cuida de transformar <, >, # e espaços nos códigos % corretos.
            svgImage.source = "data:image/svg+xml;utf8," + encodeURIComponent(coloredSvg);
        } catch (e) {
            console.error("LucideIcon: Failed to apply colored SVG for " + name + ": " + e);
            svgImage.source = path; // Fallback
        }
    }

    // Implicit sizes for layouts
    implicitWidth: size
    implicitHeight: size
    width: size
    height: size
    onResolvedSourceChanged: {
        _rawSvgText = "";
        colorize();
    }
    onColorChanged: colorize()
    onStrokeWidthChanged: colorize()
    Component.onCompleted: colorize()

    Image {
        id: svgImage

        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        sourceSize.width: iconRoot.size
        sourceSize.height: iconRoot.size
        antialiasing: true
        smooth: true
    }

}
