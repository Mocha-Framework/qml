import QtQuick 2.15

Item {
    id: root

    // ── Identity ───────────────────────────────────
    readonly property bool isFormField: true
    property string name: ""

    // ── Public API ─────────────────────────────────
    property string label: ""
    property string description: ""
    property string errorMessage: ""
    property bool required: false
    property string status: "normal"

    // ── Pipes ──────────────────────────────────────
    property string pipe: ""

    // ── Validation Rules ───────────────────────────
    property int minLength: -1
    property int maxLength: -1
    property real min: -Infinity
    property real max: Infinity
    property string pattern: ""
    property var customValidator: null

    // ── Value (readonly, reactive) ─────────────────
    readonly property var rawValue: {
        var child = _getInputChild()
        if (!child) return ""
        if (child.hasOwnProperty("text")) return child.text
        if (child.hasOwnProperty("checked")) return child.checked
        if (child.hasOwnProperty("selectedValue")) return child.selectedValue
        if (child.hasOwnProperty("value")) return child.value
        return ""
    }

    readonly property var value: Pipes.applyAll(rawValue, pipe)

    // ── Layout ─────────────────────────────────────
    default property alias content: contentContainer.data
    implicitWidth: 280
    implicitHeight: layoutColumn.implicitHeight
    width: implicitWidth
    height: implicitHeight

    // ── Internal ───────────────────────────────────
    property var _form: null

    z: {
        if (contentContainer.children.length > 0) {
            var child = contentContainer.children[0]
            if (child && child.hasOwnProperty("item") && child.item) {
                child = child.item
            }
            if (child && child.expanded !== undefined && child.expanded) return 100
        }
        return 0
    }

    // ── Value change → notify Form ─────────────────
    onValueChanged: {
        if (_form) _form._fieldChanged(name, value, errorMessage)
    }

    onErrorMessageChanged: {
        if (_form) _form._fieldChanged(name, value, errorMessage)
    }

    // ── Self-registration ──────────────────────────
    Component.onCompleted: _findForm()
    Component.onDestruction: {
        if (_form) _form._unregister(root)
    }

    function _findForm() {
        var p = parent
        while (p) {
            if (p.hasOwnProperty("_register") && typeof p._register === "function") {
                p._register(root)
                return
            }
            p = p.parent
        }
    }

    // ── Input Child Helper ─────────────────────────
    function _getInputChild() {
        if (contentContainer.children.length === 0) return null
        var child = contentContainer.children[0]
        var seen = [child]
        while (child && typeof child === "object" && child.hasOwnProperty("item")) {
            child = child.item || child
            if (seen.indexOf(child) >= 0) break
            seen.push(child)
        }
        return child
    }

    // ── Value set/reset ────────────────────────────
    function _setValue(v) {
        var child = _getInputChild()
        if (!child) return
        if (child.hasOwnProperty("text")) child.text = v !== undefined ? String(v) : ""
        else if (child.hasOwnProperty("checked")) child.checked = Boolean(v)
        else if (child.hasOwnProperty("selectedValue")) child.selectedValue = v
        else if (child.hasOwnProperty("value")) child.value = v
    }

    function _reset() {
        var child = _getInputChild()
        if (!child) return
        if (child.hasOwnProperty("text")) child.text = ""
        else if (child.hasOwnProperty("checked")) child.checked = false
        else if (child.hasOwnProperty("selectedValue")) child.selectedValue = null
        else if (child.hasOwnProperty("value")) child.value = undefined
        errorMessage = ""
        status = "normal"
    }

    // ── Validation ─────────────────────────────────
    function _validate() {
        var val = value
        var err = ""

        if (required && (val === undefined || val === null || val === "" || val === false)) {
            err = "Campo obrigatório"
        }
        if (!err && pattern && typeof val === "string" && val !== "") {
            var re = new RegExp(pattern)
            if (!re.test(val)) err = "Formato inválido"
        }
        if (!err && minLength > 0 && typeof val === "string" && val.length < minLength) {
            err = "Mínimo de " + minLength + " caracteres"
        }
        if (!err && maxLength > 0 && typeof val === "string" && val.length > maxLength) {
            err = "Máximo de " + maxLength + " caracteres"
        }
        if (!err && min !== -Infinity && Number(val) < min) {
            err = "Valor mínimo: " + min
        }
        if (!err && max !== Infinity && Number(val) > max) {
            err = "Valor máximo: " + max
        }
        if (!err && customValidator && typeof customValidator === "function") {
            var customErr = customValidator(val)
            if (customErr) err = typeof customErr === "string" ? customErr : "Valor inválido"
        }

        errorMessage = err
        status = err ? "error" : "normal"
        return err
    }

    // ── Visual Tree ────────────────────────────────
    Column {
        id: layoutColumn
        width: parent.width
        spacing: Theme.spacing.xs

        Row {
            spacing: Theme.spacing.xs
            visible: root.label !== ""
            width: parent.width

            Text {
                text: root.label
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.subtext1
                antialiasing: true
            }

            Text {
                text: "*"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.red
                visible: root.required
                antialiasing: true
            }
        }

        Text {
            text: root.description
            font.family: Theme.typography.family
            font.pixelSize: Theme.typography.sizeXs
            color: Theme.colors.overlay1
            visible: root.description !== ""
            width: parent.width
            wrapMode: Text.WordWrap
            antialiasing: true
        }

        Item {
            id: contentContainer
            width: parent.width
            height: children.length > 0 ? children[0].height : 0

            onChildrenChanged: {
                if (children.length > 0) {
                    var child = children[0]
                    child.width = Qt.binding(function() { return contentContainer.width })
                    if (child && child.hasOwnProperty("item") && child.hasOwnProperty("loaded")) {
                        try { child.loaded.disconnect(root.syncChildStatus) } catch (e) {}
                        child.loaded.connect(root.syncChildStatus)
                    }
                    syncChildStatus()
                }
            }
        }

        Row {
            spacing: Theme.spacing.xs
            visible: root.status === "error" && root.errorMessage !== ""
            width: parent.width

            LucideIcon {
                name: "alert-circle"
                size: 12
                color: Theme.colors.red
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: root.errorMessage
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeXs
                color: Theme.colors.red
                width: parent.width - 16
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                antialiasing: true
            }
        }
    }

    // ── Status syncing ─────────────────────────────
    onStatusChanged: syncChildStatus()

    function syncChildStatus() {
        if (contentContainer.children.length > 0) {
            var child = contentContainer.children[0]
            if (child && child.hasOwnProperty("item")) child = child.item
            if (child && child.hasOwnProperty("status")) {
                try { child.status = root.status } catch (e) {}
            }
        }
    }
}
