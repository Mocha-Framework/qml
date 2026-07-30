import QtQuick 2.15

Item {
    id: root

    // ── Public API (readonly, reactive) ────────────
    readonly property bool valid: _formValid
    readonly property var values: _formValues
    readonly property var errors: _formErrors

    property bool validateOnInput: true

    signal submitted(var values)

    // ── Internal ───────────────────────────────────
    property var _fieldMap: ({})
    property var _valueSnapshot: ({})
    property var _errorSnapshot: ({})

    property bool _formValid: false
    property var _formValues: ({})
    property var _formErrors: ({})

    // ── Field Registration (called by FormField) ──
    function _register(field) {
        if (!field || !field.name) return
        _fieldMap[field.name] = field
        _updateValues()
        _updateValid()
    }

    function _unregister(field) {
        if (!field || !field.name) return
        delete _fieldMap[field.name]
        delete _valueSnapshot[field.name]
        delete _errorSnapshot[field.name]
        _updateValues()
        _updateValid()
    }

    function _fieldChanged(name, value, error) {
        _valueSnapshot[name] = value
        _errorSnapshot[name] = error || ""
        _updateValues()
        if (validateOnInput) _updateValid()
    }

    // ── Reactive exports ───────────────────────────
    function _updateValues() {
        var vals = {}
        for (var k in _valueSnapshot) vals[k] = _valueSnapshot[k]
        _formValues = vals

        var errs = {}
        for (var k in _errorSnapshot) errs[k] = _errorSnapshot[k]
        _formErrors = errs
    }

    function _updateValid() {
        if (Object.keys(_fieldMap).length === 0) {
            _formValid = false
            return
        }
        for (var name in _fieldMap) {
            var field = _fieldMap[name]
            if (_errorSnapshot[name] && String(_errorSnapshot[name]) !== "") {
                _formValid = false
                return
            }
            if (field.required) {
                var val = _valueSnapshot[name]
                if (val === undefined || val === null || val === "" || val === false) {
                    _formValid = false
                    return
                }
            }
        }
        _formValid = true
    }

    // ── Public Methods ─────────────────────────────
    function validate() {
        var ok = true
        for (var name in _fieldMap) {
            var field = _fieldMap[name]
            var error = field._validate()
            _errorSnapshot[name] = error
            if (error) ok = false
        }
        _updateValues()
        _updateValid()
        return ok
    }

    function getValues() {
        var vals = {}
        for (var k in _valueSnapshot) vals[k] = _valueSnapshot[k]
        return vals
    }

    function setValues(vals) {
        for (var name in vals) {
            if (_fieldMap[name]) {
                _fieldMap[name]._setValue(vals[name])
            }
        }
    }

    function reset() {
        for (var name in _fieldMap) {
            _fieldMap[name]._reset()
        }
        _valueSnapshot = {}
        _errorSnapshot = {}
        _updateValues()
        _formValid = false
    }
}
