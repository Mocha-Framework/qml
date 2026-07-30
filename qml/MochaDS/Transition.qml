import QtQuick 2.15

Item {
    id: root

    property string transitionProperty: ""
    property int duration: 300
    property real easingValue: Easing.OutQuad
    property int delay: 0
    property bool running: false

    onRunningChanged: {
        if (running) play()
    }

    function play(fromVal, toVal) {
        var f = fromVal !== undefined ? fromVal : (parent ? parent[transitionProperty] : 0)
        var t = toVal
        anim.target = parent
        anim.property = transitionProperty
        anim.from = f
        anim.to = t
        anim.duration = duration
        anim.easing.type = easingValue
        anim.restart()
    }

    function animateTo(val) {
        var f = parent ? parent[transitionProperty] : 0
        play(f, val)
    }

    NumberAnimation {
        id: anim
    }
}
