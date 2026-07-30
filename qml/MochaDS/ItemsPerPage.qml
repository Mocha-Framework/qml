import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property int pageSize: 10
    property var options: [10, 20, 50, 100]
    property bool disabled: false
    property string size: "sm" // compact default size for footer bars

    // ==========================================
    // Layout Dimensions
    // ==========================================
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // ==========================================
    // Visual Tree
    // ==========================================
    Row {
        id: rowLayout
        spacing: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: "Exibir:"
            font.family: Theme.typography.family
            font.pixelSize: root.size === "sm" ? Theme.typography.sizeSm : Theme.typography.sizeMd
            color: Theme.colors.subtext0
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
        }

        Select {
            id: sizeSelect
            width: root.size === "sm" ? 75 : (root.size === "lg" ? 95 : 85)
            size: root.size
            disabled: root.disabled
            options: root.options
            selectedValue: root.pageSize
            placeholder: String(root.pageSize)
            
            onValueChanged: {
                var sizeInt = parseInt(val);
                if (!isNaN(sizeInt) && root.pageSize !== sizeInt) {
                    root.pageSize = sizeInt;
                }
            }
        }
    }

    // Sync external changes
    onPageSizeChanged: {
        if (sizeSelect.selectedValue !== pageSize) {
            sizeSelect.selectedValue = pageSize;
        }
    }
}
