import QtQuick 2.15

Item {
    id: root

    property bool condition: false

    property Component then

    property Component else

    property string transition: "none"
    // Values: "none" | "fade" | "slide" | "zoom" | "bounce" | "spin" | "flip" | "all"

    property int duration: 250

    implicitWidth: activeLoader.implicitWidth
    implicitHeight: activeLoader.implicitHeight

    Loader {
        id: activeLoader
        anchors.fill: parent
        sourceComponent: root.condition
            ? root.then
            : (root.else !== undefined ? root.else : null)

        opacity: 0

        Behavior on opacity {
            enabled: root.transition !== "none"
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.OutQuad
            }
        }

        Component.onCompleted: Qt.callLater(() => activeLoader.opacity = 1)
        onSourceComponentChanged: {
            opacity = 0
            Qt.callLater(() => activeLoader.opacity = 1)
        }
    }
}
