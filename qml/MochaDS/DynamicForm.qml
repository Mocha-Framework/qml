import QtQuick 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    
    // Array of field configuration objects
    property var schema: []
    
    // Dictionary of field values: { fieldName: value }
    property var formValues: ({})
    
    // Dictionary of field errors: { fieldName: errorMessage }
    property var formErrors: ({})
    
    // Dictionary of field statuses: { fieldName: "normal"|"success"|"error" }
    property var formStatuses: ({})

    // Signals
    signal submitted(var values)

    // ==========================================
    // Layout Dimensions
    // ==========================================
    implicitWidth: 350
    implicitHeight: formColumn.implicitHeight
    width: implicitWidth
    height: implicitHeight

    // Raise z-index of the form when any nested FormField is expanded
    z: {
        var anyExpanded = false;
        for (var i = 0; i < formColumn.children.length; i++) {
            var child = formColumn.children[i];
            if (child && child.z !== undefined && child.z > 0) {
                anyExpanded = true;
                break;
            }
        }
        return anyExpanded ? 100 : 0;
    }

    // ==========================================
    // Visual Tree
    // ==========================================
    Column {
        id: formColumn
        width: parent.width
        spacing: Theme.spacing.lg

        Repeater {
            model: root.schema

            delegate: FormField {
                width: formColumn.width
                label: modelData.label || ""
                description: modelData.description || ""
                required: modelData.required || false
                status: root.formStatuses[modelData.name] !== undefined ? root.formStatuses[modelData.name] : "normal"
                errorMessage: root.formErrors[modelData.name] !== undefined ? root.formErrors[modelData.name] : ""

                // Component definitions placed within the scope where modelData is defined
                Component {
                    id: textComponent
                    
                    TextField {
                        type: modelData.type || "text"
                        placeholder: modelData.placeholder || ""
                        text: root.formValues[modelData.name] !== undefined ? String(root.formValues[modelData.name]) : ""
                        iconLeft: modelData.iconLeft || ""
                        iconRight: modelData.iconRight || ""
                        
                        onTextEdited: {
                            root.updateFieldValue(modelData.name, text);
                        }
                    }
                }

                Component {
                    id: selectComponent
                    
                    Select {
                        placeholder: modelData.placeholder || "Selecione..."
                        options: modelData.options || []
                        selectedValue: root.formValues[modelData.name] !== undefined ? root.formValues[modelData.name] : null
                        
                        onValueChanged: {
                            root.updateFieldValue(modelData.name, val);
                        }
                    }
                }

                Component {
                    id: checkboxComponent
                    
                    Checkbox {
                        label: modelData.checkboxLabel || ""
                        checked: root.formValues[modelData.name] !== undefined ? !!root.formValues[modelData.name] : false
                        
                        onToggled: {
                            root.updateFieldValue(modelData.name, isChecked);
                        }
                    }
                }

                Loader {
                    id: fieldLoader
                    width: parent.width
                    
                    // Select appropriate input control based on type
                    sourceComponent: {
                        if (modelData.type === "checkbox") return checkboxComponent;
                        if (modelData.type === "select") return selectComponent;
                        return textComponent; // text, password, email, number
            }
        }
    }
}
}


    // ==========================================
    // Core Functions & Controller Logic
    // ==========================================
    
    onSchemaChanged: {
        initializeForm();
    }

    function initializeForm() {
        var vals = {};
        var errs = {};
        var stats = {};
        
        if (schema && schema.length) {
            for (var i = 0; i < schema.length; i++) {
                var item = schema[i];
                var val = "";
                
                if (item.type === "checkbox") {
                    val = false;
                } else if (item.type === "select") {
                    val = null;
                }
                
                if (item.value !== undefined) {
                    val = item.value;
                }
                
                vals[item.name] = val;
                errs[item.name] = "";
                stats[item.name] = "normal";
            }
        }
        
        formValues = vals;
        formErrors = errs;
        formStatuses = stats;
    }

    function updateFieldValue(name, value) {
        // Create copies of form properties to trigger changes
        var vals = {};
        for (var k in formValues) vals[k] = formValues[k];
        vals[name] = value;
        formValues = vals;

        // Reset validation status on interaction
        var stats = {};
        for (var k in formStatuses) stats[k] = formStatuses[k];
        var errs = {};
        for (var k in formErrors) errs[k] = formErrors[k];
        
        if (stats[name] === "error") {
            stats[name] = "normal";
            errs[name] = "";
            formStatuses = stats;
            formErrors = errs;
        }
    }

    // Get current form data
    function getValues() {
        return formValues;
    }

    // Programmatically populate form data
    function setValues(valuesObject) {
        var vals = {};
        for (var k in formValues) vals[k] = formValues[k];
        
        var stats = {};
        for (var k in formStatuses) stats[k] = formStatuses[k];
        
        var errs = {};
        for (var k in formErrors) errs[k] = formErrors[k];

        for (var name in valuesObject) {
            if (vals.hasOwnProperty(name)) {
                vals[name] = valuesObject[name];
                stats[name] = "normal";
                errs[name] = "";
            }
        }
        
        formValues = vals;
        formStatuses = stats;
        formErrors = errs;
    }

    // Reset the form values and clear errors
    function clear() {
        initializeForm();
    }

    // Validate form against schema
    function validate() {
        var isValid = true;
        var errs = {};
        var stats = {};

        // Initialize empty tracking objects
        for (var i = 0; i < schema.length; i++) {
            var name = schema[i].name;
            errs[name] = "";
            stats[name] = "normal";
        }

        for (var i = 0; i < schema.length; i++) {
            var field = schema[i];
            var val = formValues[field.name];
            var fieldValid = true;
            var errorMsg = "";

            // 1. Required Validation
            if (field.required) {
                if (val === undefined || val === null || val === "" || val === false) {
                    fieldValid = false;
                    errorMsg = field.requiredMessage || "Este campo é obrigatório.";
                }
            }

            // 2. Email Format Validation
            if (fieldValid && field.type === "email" && val) {
                var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(String(val))) {
                    fieldValid = false;
                    errorMsg = field.emailMessage || "Formato de e-mail inválido.";
                }
            }

            // 3. String Length Validation
            if (fieldValid && val && typeof val === "string") {
                if (field.minLength !== undefined && val.length < field.minLength) {
                    fieldValid = false;
                    errorMsg = field.minLengthMessage || ("Mínimo de " + field.minLength + " caracteres.");
                }
                if (fieldValid && field.maxLength !== undefined && val.length > field.maxLength) {
                    fieldValid = false;
                    errorMsg = field.maxLengthMessage || ("Máximo de " + field.maxLength + " caracteres.");
                }
            }

            // 4. Regex Pattern Validation
            if (fieldValid && val && field.pattern && typeof val === "string") {
                var regex = new RegExp(field.pattern);
                if (!regex.test(val)) {
                    fieldValid = false;
                    errorMsg = field.patternMessage || "Formato inválido.";
                }
            }

            // 5. Custom Validation Function
            if (fieldValid && typeof field.validateFunc === "function") {
                var customResult = field.validateFunc(val);
                if (customResult !== true) {
                    fieldValid = false;
                    errorMsg = typeof customResult === "string" ? customResult : "Valor inválido.";
                }
            }

            // Apply validation results
            if (!fieldValid) {
                isValid = false;
                stats[field.name] = "error";
                errs[field.name] = errorMsg;
            } else {
                // If it is valid and has some value, show success state
                var hasValue = val !== undefined && val !== null && val !== "" && val !== false;
                if (hasValue || field.required) {
                    stats[field.name] = "success";
                }
            }
        }

        formErrors = errs;
        formStatuses = stats;
        return isValid;
    }
}
