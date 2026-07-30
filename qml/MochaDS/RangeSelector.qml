import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property real min: 0
    property real max: 100
    property real firstValue: 20
    property real secondValue: 80
    property real step: 1
    property bool disabled: false

    property bool showFirstThumb: true
    property var onChange: null

    // Signals
    signal valuesChanged(real first, real second)

    // Internal Drag State
    property int activeThumb: 0 // 0: none, 1: first, 2: second

    implicitWidth: 280
    implicitHeight: 40
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.5 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Helpers to get positions
    readonly property real trackWidth: width - 20 // pad for thumb radius
    
    readonly property real firstPos: {
        if (max === min) return 0;
        var fVal = root.showFirstThumb ? root.firstValue : root.min;
        return ((fVal - min) / (max - min)) * trackWidth;
    }

    readonly property real secondPos: {
        if (max === min) return 0;
        return ((secondValue - min) / (max - min)) * trackWidth;
    }
    readonly property bool isHovered: rangeMouseArea.containsMouse

    // Main Track Background
    Rectangle {
        id: trackBg
        width: root.trackWidth
        height: 6
        radius: 3
        color: (root.isHovered || root.activeThumb !== 0) ? Theme.colors.surface1 : Theme.colors.surface0
        anchors.centerIn: parent

        Behavior on color { ColorAnimation { duration: 120 } }

        // Active Track (between thumbs)
        Rectangle {
            id: activeTrack
            x: root.showFirstThumb ? (root.firstPos + 10) : 0
            width: root.showFirstThumb ? (root.secondPos - root.firstPos) : (root.secondPos + 10)
            height: parent.height
            radius: parent.radius
            color: Theme.colors.primary

            Behavior on x { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
        }

        // First Thumb
        Rectangle {
            id: firstThumb
            x: root.firstPos
            width: 20
            height: 20
            radius: 10
            color: Theme.colors.text
            border.color: Theme.colors.primary
            border.width: 2
            anchors.verticalCenter: parent.verticalCenter
            z: root.activeThumb === 1 ? 10 : 1
            visible: root.showFirstThumb

            scale: (firstThumbMouse.containsMouse || root.activeThumb === 1) ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }

            MouseArea {
                id: firstThumbMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: false // let the main track mouse area handle the clicks and drags
            }

            // Value Tooltip
            Rectangle {
                id: firstTooltip
                width: firstTooltipText.implicitWidth + Theme.spacing.sm * 2
                height: 20
                radius: Theme.geometry.radiusSm
                color: Theme.colors.mantle
                border.color: Theme.colors.surface1
                border.width: Theme.geometry.borderSm
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                visible: firstThumbMouse.containsMouse || root.activeThumb === 1
                opacity: visible ? 1.0 : 0.0
                scale: visible ? 1.0 : 0.96

                Text {
                    id: firstTooltipText
                    text: root.firstValue.toFixed(0)
                    font.family: Theme.typography.familyMedium
                    font.pixelSize: Theme.typography.sizeXs
                    color: Theme.colors.text
                    anchors.centerIn: parent
                }

                Behavior on opacity { NumberAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }
        }

        // Second Thumb
        Rectangle {
            id: secondThumb
            x: root.secondPos
            width: 20
            height: 20
            radius: 10
            color: Theme.colors.text
            border.color: Theme.colors.primary
            border.width: 2
            anchors.verticalCenter: parent.verticalCenter
            z: root.activeThumb === 2 ? 10 : 1

            scale: (secondThumbMouse.containsMouse || root.activeThumb === 2) ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }

            MouseArea {
                id: secondThumbMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: false
            }

            // Value Tooltip
            Rectangle {
                id: secondTooltip
                width: secondTooltipText.implicitWidth + Theme.spacing.sm * 2
                height: 20
                radius: Theme.geometry.radiusSm
                color: Theme.colors.mantle
                border.color: Theme.colors.surface1
                border.width: Theme.geometry.borderSm
                anchors.bottom: parent.top
                anchors.bottomMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                visible: secondThumbMouse.containsMouse || root.activeThumb === 2
                opacity: visible ? 1.0 : 0.0
                scale: visible ? 1.0 : 0.96

                Text {
                    id: secondTooltipText
                    text: root.secondValue.toFixed(0)
                    font.family: Theme.typography.familyMedium
                    font.pixelSize: Theme.typography.sizeXs
                    color: Theme.colors.text
                    anchors.centerIn: parent
                }

                Behavior on opacity { NumberAnimation { duration: 120 } }
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
            }
        }
    }

    // Main Interactive Area across the whole track
    MouseArea {
        id: rangeMouseArea
        anchors.fill: parent
        enabled: !root.disabled
        hoverEnabled: true

        onPressed: {
            var localX = mouse.x - 10; // offset for thumb pad padding
            var pct = localX / root.trackWidth;
            pct = Math.max(0.0, Math.min(1.0, pct));
            var val = root.min + pct * (root.max - root.min);
            if (root.step > 0) {
                val = Math.round(val / root.step) * root.step;
            }

            if (!root.showFirstThumb) {
                root.activeThumb = 2;
                root.secondValue = val;
            } else {
                var dist1 = Math.abs(val - root.firstValue);
                var dist2 = Math.abs(val - root.secondValue);

                if (root.firstValue === root.secondValue) {
                    if (val <= root.firstValue) {
                        root.activeThumb = 1;
                        root.firstValue = val;
                    } else {
                        root.activeThumb = 2;
                        root.secondValue = val;
                    }
                } else if (val < root.firstValue) {
                    root.activeThumb = 1;
                    root.firstValue = val;
                } else if (val > root.secondValue) {
                    root.activeThumb = 2;
                    root.secondValue = val;
                } else {
                    if (dist1 < dist2) {
                        root.activeThumb = 1;
                        root.firstValue = val;
                    } else {
                        root.activeThumb = 2;
                        root.secondValue = val;
                    }
                }
            }
            root.valuesChanged(root.firstValue, root.secondValue);
            if (root.onChange) root.onChange(root.firstValue, root.secondValue);
        }

        onPositionChanged: {
            if (root.activeThumb === 0) return;
            var localX = mouse.x - 10;
            var pct = localX / root.trackWidth;
            pct = Math.max(0.0, Math.min(1.0, pct));
            var val = root.min + pct * (root.max - root.min);
            if (root.step > 0) {
                val = Math.round(val / root.step) * root.step;
            }

            if (root.activeThumb === 1) {
                root.firstValue = Math.min(val, root.secondValue);
            } else {
                if (root.showFirstThumb) {
                    root.secondValue = Math.max(val, root.firstValue);
                } else {
                    root.secondValue = val;
                }
            }
            root.valuesChanged(root.firstValue, root.secondValue);
            if (root.onChange) root.onChange(root.firstValue, root.secondValue);
        }

        onReleased: {
            root.activeThumb = 0;
        }
    }
}
