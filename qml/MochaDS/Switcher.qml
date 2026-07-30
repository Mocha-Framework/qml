import QtQuick 2.15

Item {
    id: root

    property var expression: null

    property Item _visibleCase: null

    implicitWidth: _visibleCase ? _visibleCase.implicitWidth : 0
    implicitHeight: _visibleCase ? _visibleCase.implicitHeight : 0

    onExpressionChanged: _reevaluate()
    onChildrenChanged: _reevaluate()
    Component.onCompleted: _reevaluate()

    function _reevaluate() {
        var def = null
        var found = null

        for (var i = 0; i < children.length; i++) {
            var child = children[i]
            if (!child.hasOwnProperty("isCase") || !child.isCase) continue

            child.visible = false

            if (child.isDefault) { def = child; continue }
            if (!found && child.value === root.expression) { found = child }
        }

        var target = found || def
        if (target) target.visible = true
        _visibleCase = target
    }
}
