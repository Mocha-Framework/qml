import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property int currentStep: 0

    // Children will be injected into this container
    default property alias content: container.data

    clip: true
    implicitWidth: 400
    implicitHeight: 250
    width: implicitWidth
    height: implicitHeight

    // Container row to manage child slides
    Row {
        id: container
        height: parent.height
        x: -root.currentStep * root.width

        // Smooth horizontal slide translation
        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }

        onWidthChanged: updateChildrenSizes()
        onChildrenChanged: updateChildrenSizes()
        
        Component.onCompleted: updateChildrenSizes()

        function updateChildrenSizes() {
            for (var i = 0; i < children.length; i++) {
                var child = children[i];
                // Only adjust layoutable visual elements
                if (child.hasOwnProperty("width")) {
                    child.width = root.width;
                }
                if (child.hasOwnProperty("height")) {
                    child.height = root.height;
                }
            }
        }
    }
}
