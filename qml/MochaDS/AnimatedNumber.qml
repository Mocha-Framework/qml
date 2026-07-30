import QtQuick 2.15

Item {
    id: root

    property real value: 0
    property real from: 0
    property bool animated: true
    property int duration: 800
    property string easing: "OutQuart"

    property string prefix: ""
    property string suffix: ""
    property int decimalPlaces: 0
    property string separator: ""

    property alias font: numberText.font
    property alias color: numberText.color
    property alias horizontalAlignment: numberText.horizontalAlignment
    property alias verticalAlignment: numberText.verticalAlignment
    property alias elide: numberText.elide

    implicitWidth: numberText.implicitWidth
    implicitHeight: numberText.implicitHeight
    width: implicitWidth
    height: implicitHeight

    property real _displayValue: root.from

    onValueChanged: {
        if (root.animated) {
            anim.from = _displayValue
            anim.to = root.value
            anim.start()
        } else {
            _displayValue = root.value
        }
    }

    NumberAnimation {
        id: anim
        target: root
        property: "_displayValue"
        duration: root.duration
        easing.type: {
            if (root.easing === "OutQuad") return Easing.OutQuad
            if (root.easing === "OutCubic") return Easing.OutCubic
            if (root.easing === "OutQuart") return Easing.OutQuart
            if (root.easing === "OutQuint") return Easing.OutQuint
            if (root.easing === "OutExpo") return Easing.OutExpo
            if (root.easing === "OutBack") return Easing.OutBack
            return Easing.OutQuart
        }
    }

    function formatNumber(num) {
        var formatted = num.toFixed(root.decimalPlaces)

        if (root.separator !== "") {
            var parts = formatted.split(".")
            parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, root.separator)
            formatted = parts.join(".")
        }

        return root.prefix + formatted + root.suffix
    }

    Text {
        id: numberText
        text: formatNumber(root._displayValue)
        font.family: Theme ? Theme.typography.familyBold : "monospace"
        font.pixelSize: Theme ? Theme.typography.sizeH2 : 24
        color: Theme ? Theme.colors.text : "#000000"
    }
}
