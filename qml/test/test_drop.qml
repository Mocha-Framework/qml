import QtQuick 2.15
import QtQuick.Window 2.15

Window {
    width: 400
    height: 400
    visible: true

    Item {
        id: draggable
        width: 50; height: 50; x: 10; y: 10
        Rectangle { anchors.fill: parent; color: "red" }
        Drag.active: dragHandler.active
        Drag.source: draggable
        DragHandler { id: dragHandler }
        onXChanged: if(x>200 && Drag.active) Drag.drop()
    }

    DropArea {
        width: 200; height: 400; x: 200; y: 0
        Rectangle { anchors.fill: parent; color: "blue"; opacity: 0.5 }
        onEntered: function(drag) { console.log("entered", drag.source) }
        onDropped: function(drop) { console.log("dropped", drop.source) }
    }
}
