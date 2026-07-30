import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    
    // Position of the toast stack: "top-right" | "top-left" | "bottom-right" | "bottom-left"
    property string position: "top-right"
    property alias toastModel: toastModel


    // High z-index to overlay visual controls
    z: 999999

    // Anchors to fill parent overlay
    anchors.fill: parent

    // ==========================================
    // Internal Models & Stacking View
    // ==========================================
    ListModel {
        id: toastModel
    }

    ListView {
        id: toastListView
        width: 320
        height: Math.min(parent.height - Theme.spacing.lg * 2, contentHeight)
        spacing: Theme.spacing.sm
        model: toastModel
        clip: false
        interactive: false
        boundsBehavior: Flickable.StopAtBounds

        // Margins
        anchors.topMargin: root.position.startsWith("top") ? Theme.spacing.lg : 0
        anchors.bottomMargin: root.position.startsWith("bottom") ? Theme.spacing.lg : 0
        anchors.rightMargin: root.position.endsWith("right") ? Theme.spacing.lg : 0
        anchors.leftMargin: root.position.endsWith("left") ? Theme.spacing.lg : 0

        // Delegate renderer mapping Model fields to Toast properties
        delegate: Toast {
            title: model.title
            message: model.message
            type: model.type
            duration: model.duration
            showClose: model.showClose !== undefined ? model.showClose : true

            onDismissed: {
                // Remove from model, triggers delegate destruction
                toastModel.remove(index);
            }
        }

        // Cozy transition when items move/adjust heights
        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 250
                easing.type: Easing.OutBack
            }
        }

        // Dynamic anchors using states & AnchorChanges
        states: [
            State {
                name: "top-right"
                when: root.position === "top-right"
                AnchorChanges { target: toastListView; anchors.top: parent.top; anchors.right: parent.right; anchors.bottom: undefined; anchors.left: undefined }
            },
            State {
                name: "top-left"
                when: root.position === "top-left"
                AnchorChanges { target: toastListView; anchors.top: parent.top; anchors.left: parent.left; anchors.bottom: undefined; anchors.right: undefined }
            },
            State {
                name: "bottom-right"
                when: root.position === "bottom-right"
                AnchorChanges { target: toastListView; anchors.bottom: parent.bottom; anchors.right: parent.right; anchors.top: undefined; anchors.left: undefined }
            },
            State {
                name: "bottom-left"
                when: root.position === "bottom-left"
                AnchorChanges { target: toastListView; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.top: undefined; anchors.right: undefined }
            }
        ]
    }

    // ==========================================
    // Developer helper methods
    // ==========================================
    
    // Core spawn method
    function show(message, type, title, duration) {
        root.z = Theme.getNextMaxZ();
        var t = type !== undefined ? type : "info";
        var ttl = title !== undefined ? title : "";
        var dur = duration !== undefined ? duration : 3000;

        toastModel.append({
            "message": message,
            "type": t,
            "title": ttl,
            "duration": dur,
            "showClose": true
        });
    }

    // Semantic shorthands
    function success(message, title, duration) {
        show(message, "success", title !== undefined ? title : "Sucesso", duration);
    }

    function error(message, title, duration) {
        show(message, "error", title !== undefined ? title : "Erro", duration);
    }

    // Warning alert
    function warning(message, title, duration) {
        show(message, "warning", title !== undefined ? title : "Atenção", duration);
    }

    // Informational alert
    function info(message, title, duration) {
        show(message, "info", title !== undefined ? title : "Informação", duration);
    }
}
