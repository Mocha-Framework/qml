import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property int currentPage: 1
    property int totalPages: 1
    property bool showGoToPage: false
    property bool disabled: false
    property alias testInput: pageInput


    // Signals
    signal pageChanged(int page)

    // ==========================================
    // Internal Style Tokens & Helpers
    // ==========================================
    readonly property var pagesList: getPagesList(currentPage, totalPages)
    readonly property real pageItemHeight: 32

    // Confirm state: input is active (focused) or has text
    readonly property bool isConfirmState: !disabled && showGoToPage && (pageInput.activeFocus || pageInput.text !== "")
    property bool suppressPageChangeAnim: true
    property int previousPage: currentPage
    property int pageDirection: 0

    // Layout Dimensions
    implicitWidth: layoutRow.implicitWidth
    implicitHeight: layoutRow.implicitHeight
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    onCurrentPageChanged: {
        if (suppressPageChangeAnim) {
            suppressPageChangeAnim = false;
            previousPage = currentPage;
            return;
        }
        pageDirection = currentPage > previousPage ? 1 : (currentPage < previousPage ? -1 : 0);
        previousPage = currentPage;
        pageChangeAnim.restart();
    }

    // ==========================================
    // Visual Tree
    // ==========================================
    Row {
        id: layoutRow
        spacing: Theme.spacing.sm
        anchors.verticalCenter: parent.verticalCenter

        // Previous Page Button
        Button {
            icon: "chevron-left"
            size: "sm"
            variant: "outline"
            disabled: root.disabled || root.currentPage <= 1
            anchors.verticalCenter: parent.verticalCenter
            
            onClicked: {
                if (root.currentPage > 1) {
                    root.currentPage--;
                    root.pageChanged(root.currentPage);
                }
            }
        }

        // Pages List (Numbered buttons and ellipses)
        Item {
            id: pagesWrapper
            width: pagesRow.implicitWidth
            height: root.pageItemHeight
            anchors.verticalCenter: parent.verticalCenter
            scale: 1.0
            opacity: 1.0
            
            transform: Translate { id: pagesTranslate; x: 0 }

            Behavior on scale {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }
            Behavior on opacity {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }

            Row {
                id: pagesRow
                spacing: Theme.spacing.xs
                anchors.centerIn: parent

                Repeater {
                    model: root.pagesList

                    delegate: Item {
                        width: isEllipsis ? 18 : pageButton.implicitWidth
                        height: root.pageItemHeight
                        anchors.verticalCenter: parent.verticalCenter
                        readonly property bool isEllipsis: modelData === "..."
                        readonly property bool isCurrentPage: !isEllipsis && modelData === root.currentPage
                        readonly property Item paginatorRoot: root
                        scale: isEllipsis ? 1.0 : (isCurrentPage ? 1.04 : 1.0)
                        opacity: isEllipsis ? 0.7 : (isCurrentPage ? 1.0 : 0.9)

                        Behavior on scale {
                            NumberAnimation { duration: 170; easing.type: Easing.OutCubic }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
                        }

                        // Ellipsis text indicator
                        Text {
                            text: "..."
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.overlay1
                            anchors.centerIn: parent
                            visible: parent.isEllipsis
                            antialiasing: true
                        }

                        // Numeric Page Button
                        Button {
                            id: pageButton
                            visible: !parent.isEllipsis
                            text: String(modelData)
                            size: "sm"
                            variant: modelData === parent.paginatorRoot.currentPage ? "primary" : "ghost"
                            disabled: parent.paginatorRoot.disabled
                            customRadius: Theme.geometry.radiusSm
                            anchors.centerIn: parent

                            onClicked: {
                                var p = parseInt(modelData);
                                if (!isNaN(p) && parent.paginatorRoot.currentPage !== p) {
                                    parent.paginatorRoot.currentPage = p;
                                    parent.paginatorRoot.pageChanged(p);
                                }
                            }
                        }
                    }
                }
            }
        }

        // Direct Page Input Field (Optional)
        TextField {
            id: pageInput
            visible: root.showGoToPage
            width: root.isConfirmState ? 64 : 48
            size: "sm"
            placeholder: "Ir"
            type: "number"
            disabled: root.disabled
            anchors.verticalCenter: parent.verticalCenter
            
            Behavior on width {
                NumberAnimation { duration: 140; easing.type: Easing.OutCubic }
            }

            onAccepted: root.confirmJump()
        }

        // Next / Confirm Action Button
        Button {
            icon: root.isConfirmState ? "check" : "chevron-right"
            size: "sm"
            variant: root.isConfirmState ? "primary" : "outline"
            disabled: root.disabled || (!root.isConfirmState && root.currentPage >= root.totalPages)
            anchors.verticalCenter: parent.verticalCenter

            onClicked: {
                if (root.isConfirmState) {
                    root.confirmJump();
                } else {
                    if (root.currentPage < root.totalPages) {
                        root.currentPage++;
                        root.pageChanged(root.currentPage);
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: pageChangeAnim
        ParallelAnimation {
            NumberAnimation { target: pagesWrapper; property: "opacity"; from: 0.8; to: 1.0; duration: 170; easing.type: Easing.OutCubic }
            NumberAnimation { target: pagesWrapper; property: "scale"; from: 0.975; to: 1.0; duration: 210; easing.type: Easing.OutBack; easing.overshoot: 1.12 }
            NumberAnimation {
                target: pagesTranslate
                property: "x"
                from: -root.pageDirection * 10
                to: 0
                duration: 220
                easing.type: Easing.OutCubic
            }
        }
    }

    // ==========================================
    // Controller Functions
    // ==========================================
    
    function confirmJump() {
        if (pageInput.text === "") {
            root.forceActiveFocus(); // just release focus
            return;
        }
        
        var pageNum = parseInt(pageInput.text);
        if (!isNaN(pageNum) && pageNum >= 1 && pageNum <= totalPages) {
            if (currentPage !== pageNum) {
                currentPage = pageNum;
                pageChanged(currentPage);
            }
            pageInput.text = "";
            pageInput.status = "normal";
            root.forceActiveFocus(); // lose text field focus
        } else {
            // Flash input in validation error status (red border)
            pageInput.status = "error";
        }
    }

    // Truncated page number ranges algorithm
    function getPagesList(current, total) {
        var pages = [];
        if (total <= 0) return pages;
        
        if (total <= 7) {
            for (var i = 1; i <= total; i++) {
                pages.push(i);
            }
        } else {
            pages.push(1);
            var start = Math.max(2, current - 1);
            var end = Math.min(total - 1, current + 1);
            
            if (start > 2) {
                pages.push("...");
            }
            
            for (var i = start; i <= end; i++) {
                pages.push(i);
            }
            
            if (end < total - 1) {
                pages.push("...");
            }
            
            pages.push(total);
        }
        return pages;
    }
}
