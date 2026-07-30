import QtQuick 2.15

Item {
    id: root
    
    // Identifier for ButtonGroup parent logic
    readonly property bool isButtonGroupItem: true
    
    // ==========================================
    // Public API (Properties)
    // ==========================================
    property string text: ""
    property string iconName: ""
    property string badgeText: ""
    
    // ==========================================
    // Implicit and visual dimensions
    // ==========================================
    implicitWidth: {
        var w = 0
        if (iconName !== "") w += 18 + Theme.spacing.sm
        if (text !== "") w += textElement.implicitWidth
        if (badgeText !== "") {
            w += (text !== "" || iconName !== "" ? Theme.spacing.sm : 0) + badgeContainer.width
        }
        return w + (Theme.spacing.md * 2)
    }
    implicitHeight: parent ? parent.height : 40
    width: {
        if (buttonGroup && buttonGroup.expand) {
            return buttonGroup.itemsList.length > 0 ? (buttonGroup.itemsRow.width / buttonGroup.itemsList.length) : 0
        }
        return implicitWidth
    }
    height: implicitHeight

    // ==========================================
    // Signals
    // ==========================================
    signal clicked()

    // ==========================================
    // Internal state & parent resolution
    // ==========================================
    readonly property Item buttonGroup: {
        var p = parent;
        while (p && !p.isButtonGroup) {
            p = p.parent;
        }
        return p;
    }
    
    readonly property int index: buttonGroup ? buttonGroup.itemsList.indexOf(this) : -1
    readonly property bool isActive: buttonGroup ? buttonGroup.currentIndex === index : false
    readonly property bool isHovered: mouseArea.containsMouse
    
    Component.onCompleted: {
        if (buttonGroup) {
            buttonGroup.registerItem(this);
        }
    }
    
    Component.onDestruction: {
        if (buttonGroup) {
            buttonGroup.unregisterItem(this);
        }
    }
    
    // Cozy scale micro-animation on press
    scale: mouseArea.pressed ? 0.96 : 1.0
    Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }

    // ==========================================
    // Visual Tree
    // ==========================================
    Row {
        id: contentLayout
        anchors.centerIn: parent
        spacing: Theme.spacing.sm
        
        LucideIcon {
            id: icon
            name: root.iconName
            size: 18
            color: root.isActive 
                ? (buttonGroup.variant === "primary" ? Theme.colors.crust : Theme.colors.text)
                : (root.isHovered ? Theme.colors.text : Theme.colors.subtext0)
            visible: name !== ""
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        
        Text {
            id: textElement
            text: root.text
            font.family: Theme.typography.familyMedium
            font.pixelSize: Theme.typography.sizeMd
            color: root.isActive 
                ? (buttonGroup.variant === "primary" ? Theme.colors.crust : Theme.colors.text)
                : (root.isHovered ? Theme.colors.text : Theme.colors.subtext0)
            visible: text !== ""
            anchors.verticalCenter: parent.verticalCenter
            antialiasing: true
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        
        // Badge block
        Rectangle {
            id: badgeContainer
            height: 18
            width: badgeTextElement.implicitWidth + 10
            radius: 9
            color: root.isActive
                ? (buttonGroup.variant === "primary" ? Qt.rgba(0,0,0,0.15) : Theme.colors.surface2)
                : Theme.colors.surface0
            border.color: root.isActive
                ? (buttonGroup.variant === "primary" ? Qt.rgba(0,0,0,0.2) : Theme.colors.surface1)
                : Theme.colors.surface1
            border.width: 1
            visible: root.badgeText !== ""
            anchors.verticalCenter: parent.verticalCenter
            
            Text {
                id: badgeTextElement
                text: root.badgeText
                font.family: Theme.typography.familyMedium
                font.pixelSize: 10
                color: root.isActive
                    ? (buttonGroup.variant === "primary" ? Theme.colors.crust : Theme.colors.text)
                    : Theme.colors.subtext1
                anchors.centerIn: parent
                antialiasing: true
                Behavior on color { ColorAnimation { duration: 150 } }
            }
            
            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (buttonGroup) {
                buttonGroup.currentIndex = root.index;
            }
            root.clicked();
        }
    }
}
