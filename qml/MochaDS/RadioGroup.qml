import QtQuick 2.15

Item {
    id: root

    property string selectedValue: ""
    property string direction: "vertical"
    property real spacing: Theme.spacing.md

    default property alias content: container.data

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    width: implicitWidth
    height: implicitHeight

    function select(value) {
        selectedValue = value;
        for (var i = 0; i < container.children.length; i++) {
            var child = container.children[i];
            if (child.hasOwnProperty("checked") && child.hasOwnProperty("value")) {
                child.checked = (child.value === value);
            }
        }
    }

    function selectByIndex(index) {
        var count = 0;
        for (var i = 0; i < container.children.length; i++) {
            var child = container.children[i];
            if (child.hasOwnProperty("checked") && child.hasOwnProperty("value")) {
                if (count === index) {
                    select(child.value);
                    return;
                }
                count++;
            }
        }
    }

    Column {
        id: container
        spacing: root.spacing

        Component.onCompleted: {
            for (var i = 0; i < root.children.length; i++) {
                var child = root.children[i];
                if (child !== container) {
                    child.parent = container;
                    if (child.hasOwnProperty("checked") && child.hasOwnProperty("clicked")) {
                        child.clicked.connect(function(c) {
                            return function() { root.select(c.value); };
                        }(child));
                    }
                    if (child.checked) {
                        root.selectedValue = child.value;
                    }
                }
            }
        }
    }
}
