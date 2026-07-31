import QtQuick 2.15

Item {
    id: root

    Rectangle {
        id: container
    }

    property list<Item> myItems

    onMyItemsChanged: {
        for (var i = 0; i < myItems.length; i++) {
            myItems[i].parent = container;
        }
    }

    myItems: [
        Rectangle { width: 10; height: 10 }
    ]
}
