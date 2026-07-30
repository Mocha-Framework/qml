import QtQuick 2.15

Item {
    id: root

    property real size: 28
    property color color: Theme.colors.primary
    property string _rawSvgText: ""

    implicitWidth: size
    implicitHeight: size * (133.19615 / 116.25877)
    width: size
    height: size * (133.19615 / 116.25877)

    function colorize() {
        var logoPath = Qt.resolvedUrl("assets/logo/mocha-logo.svg").toString();
        var svgText = _rawSvgText;
        if (!svgText) {
            var xhr = new XMLHttpRequest();
            xhr.open("GET", logoPath, false);
            xhr.send();
            if (xhr.status === 200 || xhr.status === 0) {
                svgText = xhr.responseText;
                _rawSvgText = svgText;
            } else {
                console.warn("MochaLogo: Failed to load logo from " + logoPath);
                return;
            }
        }
        if (!svgText) return;

        var rawColor = root.color.toString();
        var hexColor = rawColor;
        if (rawColor.indexOf("#") === 0 && rawColor.length === 9)
            hexColor = "#" + rawColor.substring(3);

        var coloredSvg = svgText.replace(/fill\s*=\s*["']currentColor["']/g, 'fill="' + hexColor + '"');
        try {
            svgImage.source = "data:image/svg+xml;utf8," + encodeURIComponent(coloredSvg);
        } catch (e) {
            console.error("MochaLogo: Failed to apply colored SVG: " + e);
        }
    }

    onColorChanged: colorize()
    Component.onCompleted: colorize()

    Image {
        id: svgImage
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        sourceSize.width: root.size
        sourceSize.height: root.height
        antialiasing: true
        smooth: true
    }
}
