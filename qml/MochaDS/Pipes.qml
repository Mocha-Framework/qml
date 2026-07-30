pragma Singleton
import QtQuick 2.15

QtObject {
    id: root

    property var _registry: ({
        uppercase:  function(v) { return typeof v === "string" ? v.toUpperCase() : v },
        lowercase:  function(v) { return typeof v === "string" ? v.toLowerCase() : v },
        trim:       function(v) { return typeof v === "string" ? v.trim() : v },
        capitalize: function(v) {
            var s = String(v)
            return s.charAt(0).toUpperCase() + s.slice(1).toLowerCase()
        },
        slugify:    function(v) {
            return String(v).toLowerCase()
                .replace(/[àáâãäå]/g, "a")
                .replace(/[èéêë]/g, "e")
                .replace(/[ìíîï]/g, "i")
                .replace(/[òóôõö]/g, "o")
                .replace(/[ùúûü]/g, "u")
                .replace(/[ç]/g, "c")
                .replace(/[^a-z0-9]+/g, "-")
                .replace(/^-|-$/g, "")
        }
    })

    function apply(value, pipeName) {
        var fn = _registry[pipeName]
        return fn ? fn(value) : value
    }

    function applyAll(value, pipeString) {
        if (!pipeString) return value
        var pipes = pipeString.split("|")
        var result = value
        for (var i = 0; i < pipes.length; i++) {
            var name = pipes[i].trim()
            if (name) result = apply(result, name)
        }
        return result
    }

    function register(name, fn) {
        _registry[name] = fn
    }
}
