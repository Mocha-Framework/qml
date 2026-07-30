import QtQuick 2.15

Item {
    id: root

    property var items: []
    property Component delegate: null

    property real spacing: 0
    property string orientation: "vertical"

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    Column {
        id: container
        width: root.width
        spacing: root.spacing
        visible: true

        Repeater {
            id: repeater
            model: root.items

            delegate: Item {
                id: wrapper
                width: container.width
                height: loader.implicitHeight

                property var modelData: model.modelData !== undefined ? model.modelData : modelData
                property int index: model.index

                Loader {
                    id: loader
                    sourceComponent: root.delegate
                    width: parent.width

                    onLoaded: {
                        if (item) {
                            item.modelData = wrapper.modelData
                            item.index = wrapper.index
                        }
                    }
                }
            }
        }
    }
}
