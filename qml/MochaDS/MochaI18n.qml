import QtQuick 2.15

pragma Singleton

QtObject {
    id: root

    // Public API
    property string locale: "en"
    property string fallbackLocale: "en"
    property string basePath: ""
    property bool isReady: false
    property bool debugMode: false

    // Internal state
    property int _version: 0
    property var _messages: ({})
    property var _fallbackMessages: ({})

    // Signals
    signal missingTranslation(string key, string locale)

    onLocaleChanged: {
        _loadFallback();
        reload();
    }

    onFallbackLocaleChanged: {
        _loadFallback();
    }

    onBasePathChanged: {
        _loadFallback();
        reload();
    }

    Component.onCompleted: {
        _loadFallback();
        // Initial load
        reload();
    }

    function reload() {
        isReady = false;
        _loadLocale(locale, function(data) {
            _messages = _flattenJSON(data);
            isReady = true;
            _version++;
        });
    }

    function t(key, params) {
        var _ = _version; // Binding trick for hot-reload
        var text = _messages[key];

        if (text === undefined) {
            text = _fallbackMessages[key];
        }

        if (text === undefined) {
            if (debugMode) {
                console.warn("MochaI18n: Missing key -> " + key);
                missingTranslation(key, locale);
                return "⚠️ " + key;
            }
            return key;
        }

        // Pluralization handling
        if (params && params.count !== undefined && typeof text === 'object') {
            var count = params.count;
            if (count === 0 && text.zero !== undefined) {
                text = text.zero;
            } else if (count === 1 && text.one !== undefined) {
                text = text.one;
            } else if (count === 2 && text.two !== undefined) {
                text = text.two;
            } else if (text.other !== undefined) {
                text = text.other;
            } else {
                // Fallback to whatever is available in the plural object
                text = text.other || text.one || text.two || text.zero || key;
            }
        }

        if (typeof text !== 'string') {
            return key;
        }

        // Variable Interpolation: {{varName}}
        if (params) {
            text = text.replace(/\{\{(\w+)\}\}/g, function(match, p1) {
                return params[p1] !== undefined ? params[p1] : match;
            });
        }

        return text;
    }

    function _loadFallback() {
        if (locale === fallbackLocale) {
            _fallbackMessages = {};
            _version++;
            return;
        }
        _loadLocale(fallbackLocale, function(data) {
            _fallbackMessages = _flattenJSON(data);
            _version++;
        });
    }

    function _loadLocale(loc, callback) {
        var path = basePath;
        if (path === "") {
            // Default to i18n folder relative to this file if not set
            path = Qt.resolvedUrl("i18n").toString();
        }
        
        var xhr = new XMLHttpRequest();
        var url = path + "/" + loc + ".json";
        
        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 0) { // 0 handles local file://
                    try {
                        var json = JSON.parse(xhr.responseText);
                        callback(json.messages || json);
                    } catch (e) {
                        console.error("MochaI18n: Failed to parse JSON for locale " + loc);
                        callback({});
                    }
                } else {
                    if (debugMode) {
                        console.warn("MochaI18n: Failed to load locale file for " + loc + " at " + url);
                    }
                    callback({});
                }
            }
        };
        xhr.send();
    }

    function _flattenJSON(data) {
        var result = {};
        function recurse(cur, prop) {
            if (Object(cur) !== cur) {
                result[prop] = cur;
            } else if (Array.isArray(cur)) {
                for (var i = 0, l = cur.length; i < l; i++) {
                    recurse(cur[i], prop ? prop + "." + i : "" + i);
                }
                if (l === 0) {
                    result[prop] = [];
                }
            } else {
                var isEmpty = true;
                // Check if this object is a pluralization object
                var curKeys = Object.keys(cur);
                var pluralKeys = ["zero", "one", "two", "few", "many", "other"];
                var isPluralObject = curKeys.length > 0 && curKeys.every(function(k) {
                    return pluralKeys.indexOf(k) !== -1;
                });
                
                if (isPluralObject) {
                    // Stop flattening here, keep it as an object for the t() function to consume
                    result[prop] = cur;
                    return;
                }
                
                for (var p in cur) {
                    isEmpty = false;
                    recurse(cur[p], prop ? prop + "." + p : p);
                }
                if (isEmpty && prop) {
                    result[prop] = {};
                }
            }
        }
        recurse(data, "");
        return result;
    }
}
