import QtQuick 2.15

Item {
    id: colRoot

    // ═══════════════════════════════════════════════════
    // Public API (Properties)
    // ═══════════════════════════════════════════════════
    property int span: 12
    property int sm: -1
    property int md: -1
    property int lg: -1

    property int offset: 0
    property int smOffset: -1
    property int mdOffset: -1
    property int lgOffset: -1

    // ═══════════════════════════════════════════════════
    // Flex / Self alignment (consumed by parent CozyGrid)
    // ═══════════════════════════════════════════════════
    property string alignSelf: ""           // start | center | end | stretch — overrides grid valign
    property int order: 0                   // CSS order — lower first

    // Internal properties resolved by parent Grid
    property int _resolvedSpan: 12
    property int _resolvedOffset: 0

    // Default container for children
    default property alias content: colRoot.data

    implicitWidth: 100
    implicitHeight: {
        var maxH = 0;
        for (var i = 0; i < children.length; i++) {
            var child = children[i];
            if (child.visible) {
                var ch = child.implicitHeight > 0 ? child.implicitHeight :
                         (child.childrenRect.height > 0 ? child.childrenRect.height : child.height);
                if (ch > maxH) {
                    maxH = ch;
                }
            }
        }
        return maxH > 0 ? maxH : 100;
    }
    width: implicitWidth
    height: implicitHeight

    onImplicitHeightChanged: {
        var p = parent;
        while (p) {
            if (p.hasOwnProperty("requestLayout")) {
                p.requestLayout();
                break;
            }
            p = p.parent;
        }
    }
}
