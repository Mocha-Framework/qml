import QtQuick 2.15

Item {
    id: root

    property var fields: ({})
    property var errors: ({})

    signal validationComplete(bool isValid)
    signal fieldError(string fieldName, string errorText)

    function register(fieldId, item, rules) {
        root.fields[fieldId] = {
            item: item,
            rules: rules || {}
        }
    }

    function unregister(fieldId) {
        delete root.fields[fieldId]
        delete root.errors[fieldId]
    }

    function validate() {
        var valid = true
        var fieldIds = Object.keys(root.fields)

        for (var i = 0; i < fieldIds.length; i++) {
            var id = fieldIds[i]
            var field = root.fields[id]
            var value = field.item.text !== undefined ? field.item.text
                      : field.item.checked !== undefined ? field.item.checked
                      : field.item.selectedValue !== undefined ? field.item.selectedValue
                      : ""
            var error = _validateField(value, field.rules)
            if (error) {
                root.errors[id] = error
                if (field.item.errorText !== undefined) field.item.errorText = error
                valid = false
                root.fieldError(id, error)
            } else {
                delete root.errors[id]
                if (field.item.errorText !== undefined) field.item.errorText = ""
            }
        }

        root.validationComplete(valid)
        return valid
    }

    function getValues() {
        var values = {}
        var fieldIds = Object.keys(root.fields)
        for (var i = 0; i < fieldIds.length; i++) {
            var id = fieldIds[i]
            var field = root.fields[id]
            values[id] = field.item.text !== undefined ? field.item.text
                       : field.item.checked !== undefined ? field.item.checked
                       : field.item.selectedValue !== undefined ? field.item.selectedValue
                       : ""
        }
        return values
    }

    function setValues(vals) {
        var fieldIds = Object.keys(vals)
        for (var i = 0; i < fieldIds.length; i++) {
            var id = fieldIds[i]
            var field = root.fields[id]
            if (!field) continue
            if (field.item.text !== undefined) field.item.text = String(vals[id])
            else if (field.item.checked !== undefined) field.item.checked = Boolean(vals[id])
            else if (field.item.selectedValue !== undefined) field.item.selectedValue = vals[id]
        }
    }

    function clearErrors() {
        root.errors = {}
        var fieldIds = Object.keys(root.fields)
        for (var i = 0; i < fieldIds.length; i++) {
            var field = root.fields[fieldIds[i]]
            if (field.item.errorText !== undefined) field.item.errorText = ""
        }
    }

    function reset() {
        clearErrors()
        var fieldIds = Object.keys(root.fields)
        for (var i = 0; i < fieldIds.length; i++) {
            var field = root.fields[fieldIds[i]]
            if (field.item.text !== undefined) field.item.text = ""
            else if (field.item.checked !== undefined) field.item.checked = false
            else if (field.item.selectedValue !== undefined) field.item.selectedValue = null
        }
    }

    function _validateField(value, rules) {
        if (!rules) return ""

        if (rules.required && (value === "" || value === null || value === undefined)) {
            return rules.requiredMessage || "Campo obrigatório"
        }

        if (rules.minLength && typeof value === "string" && value.length < rules.minLength) {
            return rules.minLengthMessage || "Mínimo de " + rules.minLength + " caracteres"
        }

        if (rules.maxLength && typeof value === "string" && value.length > rules.maxLength) {
            return rules.maxLengthMessage || "Máximo de " + rules.maxLength + " caracteres"
        }

        if (rules.pattern && typeof value === "string") {
            var regex = new RegExp(rules.pattern)
            if (!regex.test(value)) {
                return rules.patternMessage || "Formato inválido"
            }
        }

        if (rules.custom) {
            var customError = rules.custom(value)
            if (customError) return customError
        }

        return ""
    }
}
