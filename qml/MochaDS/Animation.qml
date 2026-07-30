import QtQuick 2.15

Item {
    id: root

    property string animationProperty: ""
    property var keyframes: []
    property int duration: 1000
    property int iterations: 1
    property real easingValue: Easing.Linear
    property bool running: false

    property var _target: null

    Component.onCompleted: {
        _target = parent
    }

    onRunningChanged: {
        if (running) play()
    }

    function play() {
        if (!_target || !animationProperty || !keyframes || keyframes.length < 2) return

        seq.stop()

        var sorted = keyframes.slice().sort(function(a, b) { return (a.at || 0) - (b.at || 0) })
        var prop = animationProperty
        var dur = duration
        var iters = iterations

        while (seq.animations.length > 0) {
            var old = seq.animations[0]
            old.target = null
            old.destroy()
        }

        for (var k = 1; k < sorted.length; k++) {
            var prev = sorted[k - 1]
            var curr = sorted[k]
            var segDur = Math.max(1, (curr.at - prev.at) * dur)

            var seg = Qt.createQmlObject(
                "import QtQuick; NumberAnimation { id: _seg; target: segParent; property: \"" + prop + "\"; from: " + prev.value + "; to: " + curr.value + "; duration: " + segDur + " }",
                seq, "keySeg" + k)
            seg.segParent = _target
        }

        if (iters === -1) {
            seq.loops = Animation.Infinite
        } else {
            seq.loops = iters
        }

        seq.restart()
    }

    function stop() {
        seq.stop()
    }

    SequentialAnimation {
        id: seq
    }
}
