import QtQuick 2.15

Item {
    id: root

    Rectangle {
        id: container
    }

    property alias myItems: container.data

    myItems: [
        Rectangle { width: 10; height: 10 }
    ]
}
