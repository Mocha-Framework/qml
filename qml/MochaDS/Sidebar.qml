import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================

    // Layout variant: "fixed" | "floated"
    property string variant: "fixed"

    // Collapse state
    property bool isCollapsed: false

    // Expand on hover when collapsed
    property bool expandOnHover: false

    // Dimensions
    property real collapsedWidth: 68
    property real expandedWidth: 260

    // Default property: filhos vão para o slot de seções (SidebarSection, SidebarItem, etc.)
    // mas SidebarHeader/SidebarFooter são detectados pelo flag isSidebarHeader/isSidebarFooter.
    default property list<Item> content

    // ── Slots livres ──────────────────────────────────────────
    // Use estes slots quando quiser colocar QUALQUER item no topo
    // ou rodapé da sidebar, sem precisar usar SidebarHeader/SidebarFooter.
    //
    // Exemplo:
    //   Sidebar {
    //       header: Rectangle { color: "red"; height: 60 }
    //       footer: Button { text: "Sair" }
    //       SidebarSection { ... }
    //   }
    //
    // SidebarHeader/SidebarFooter continuam funcionando normalmente
    // como filhos do slot default — eles têm prioridade sobre estes slots
    // caso ambos sejam fornecidos simultaneamente.
    property list<Item> header
    property list<Item> footer

    // ==========================================
    // Internal State and Animation
    // ==========================================

    readonly property bool isHovered: hoverHandler.hovered
    readonly property bool isFullyExpanded: !isCollapsed || (expandOnHover && isHovered)
    readonly property real targetWidth: isFullyExpanded ? expandedWidth : collapsedWidth
    readonly property real floatedShadowOpacity: root.variant === "floated" ? (root.isFullyExpanded ? 1.0 : 0.72) : 0.0

    property real currentWidth: targetWidth
    Behavior on currentWidth {
        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    }

    implicitWidth: isCollapsed ? collapsedWidth : expandedWidth
    implicitHeight: 600

    width: isCollapsed ? collapsedWidth : expandedWidth
    height: implicitHeight

    HoverHandler {
        id: hoverHandler
        enabled: root.isCollapsed && root.expandOnHover
    }

    // ==========================================
    // Visual Tree
    // ==========================================

    Rectangle {
        id: shadowEffect
        anchors.fill: bgRect
        anchors.margins: -4
        radius: bgRect.radius + 4
        color: "transparent"
        border.color: Qt.rgba(0, 0, 0, 0.15)
        border.width: 4
        visible: root.variant === "floated"
        z: -1
        opacity: root.floatedShadowOpacity

        Behavior on opacity {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
    }

    Rectangle {
        id: bgRect

        width: root.currentWidth
        height: root.variant === "floated" ? root.height - Theme.spacing.md * 2 : root.height

        anchors.left: parent.left
        anchors.leftMargin: root.variant === "floated" ? Theme.spacing.md : 0
        anchors.verticalCenter: parent.verticalCenter

        color: root.variant === "fixed" ? Theme.colors.crust : Theme.colors.mantle

        border.color: Theme.colors.surface0
        border.width: root.variant === "fixed" ? Theme.geometry.borderSm : 0

        radius: root.variant === "floated" ? Theme.geometry.radiusLg : 0
        clip: true
        z: 10

        Behavior on color {
            ColorAnimation { duration: 180 }
        }

        // Borda direita apenas no modo fixed
        Rectangle {
            id: rightBorder
            width: Theme.geometry.borderSm
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            color: Theme.colors.surface0
            visible: root.variant === "fixed"
        }

        // ── 1. Header Container ───────────────────────────────
        Item {
            id: headerContainer
            width: parent.width
            height: childrenRect.height
            anchors.top: parent.top
            anchors.topMargin: root.variant === "floated" ? Theme.spacing.sm : 0
        }

        // ── 3. Footer Container ───────────────────────────────
        Item {
            id: footerContainer
            width: parent.width
            height: childrenRect.height
            anchors.bottom: parent.bottom
            anchors.bottomMargin: root.variant === "floated" ? Theme.spacing.sm : 0
        }

        // ── 2. Section Container (espaço restante) ────────────
        Item {
            id: sectionContainer
            width: parent.width
            anchors.top: headerContainer.bottom
            anchors.bottom: footerContainer.top
            clip: true
        }
    }

    // ==========================================
    // Reparenting de Filhos
    // ==========================================

    Component.onCompleted: {
        var i;

        // 1. Slots livres: header / footer (propriedades explícitas)
        //    São inseridos ANTES do loop do content para que o SidebarHeader/Footer
        //    possa ainda sobrescrever via content se o dev quiser.
        for (i = 0; i < root.header.length; i++) {
            var hItem = root.header[i];
            hItem.parent = headerContainer;
            hItem.width = Qt.binding(function() { return headerContainer.width; });
        }

        for (i = 0; i < root.footer.length; i++) {
            var fItem = root.footer[i];
            fItem.parent = footerContainer;
            fItem.width = Qt.binding(function() { return footerContainer.width; });
        }

        // 2. Slot default: detecta SidebarHeader/SidebarFooter pelos flags,
        //    o restante vai para o sectionContainer.
        for (i = 0; i < content.length; i++) {
            var child = content[i];
            if (child.isSidebarHeader === true) {
                child.parent = headerContainer;
            } else if (child.isSidebarFooter === true) {
                child.parent = footerContainer;
            } else {
                child.parent = sectionContainer;
                child.anchors.left  = sectionContainer.left;
                child.anchors.right = sectionContainer.right;
                child.anchors.top   = sectionContainer.top;
                child.anchors.bottom = sectionContainer.bottom;
            }
        }
    }
}

