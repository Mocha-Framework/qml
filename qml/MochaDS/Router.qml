import QtQuick 2.15

// ============================================================
// Router.qml
// Roteador declarativo para QML com DX inspirada no React Router.
//
// FUNCIONALIDADES:
//   ✅ Rotas declarativas (Route { path: ... })
//   ✅ Parâmetros de rota (/users/:id)
//   ✅ Histórico com push / replace / back / forward / go(n)
//   ✅ Injeção automática de `params` e `router` na página carregada
//   ✅ Fallback 404 customizável
//   ✅ Wildcard "*" para catch-all
//   ✅ Animação de transição entre rotas
//
// USO BÁSICO:
//   Router {
//       id: router
//       initialRoute: "/home"
//
//       Route { path: "/home";      view: Component { HomePage {} } }
//       Route { path: "/users";     view: Component { UsersPage {} } }
//       Route { path: "/users/:id"; source: Qt.resolvedUrl("pages/UserDetail.qml") }
//       Route { path: "*";          view: Component { NotFoundPage {} } }
//   }
//
// NAVEGAÇÃO:
//   router.push("/users/42")
//   router.push("/users/:id", { id: selectedUser.id })
//   router.replace("/login")
//   router.back()
//   router.forward()
//   router.go(-2)
//
// NA PÁGINA CARREGADA:
//   Item {
//       property var params: ({})   // ← injetado automaticamente
//       property var router: null   // ← injetado automaticamente
//
//       Text { text: "ID: " + params.id }
//       Button { text: "Voltar"; onClicked: router.back() }
//   }
// ============================================================

Item {
    id: root

    // ── Public API ──────────────────────────────────────────

    // Rota inicial ao montar o componente
    property string initialRoute: "/"

    // Filhos declarados externamente (Route items)
    default property list<QtObject> routes

    // Duração da animação de transição (0 para desativar)
    property int transitionDuration: 220

    // Componente 404 customizável
    property Component notFoundComponent: _defaultNotFound

    // ── Estado atual (readonly) ─────────────────────────────

    readonly property string currentPath: _stack.length > 0
        ? _stack[_stackIndex].path
        : initialRoute

    readonly property var currentParams: _stack.length > 0
        ? _stack[_stackIndex].params
        : ({})

    readonly property string currentTitle: _stack.length > 0
        ? (_stack[_stackIndex].title ?? "")
        : ""

    readonly property bool canGoBack: _stackIndex > 0
    readonly property bool canGoForward: _stackIndex < _stack.length - 1
    readonly property int historyLength: _stack.length
    readonly property int historyIndex: _stackIndex

    // ── Sinais ──────────────────────────────────────────────

    signal navigationStarted(string path, var params)
    signal navigationFinished(string path, var params)
    signal routeNotFound(string path)
    signal navigationBlocked(string path, string reason)

    // ── Lifecycle hooks ───────────────────────────────────────

    property var onRouteLeave: null  // called with oldPath before navigation
    property var onRouteEnter: null  // called with newPath after content loaded

    // ── Métodos de Navegação ────────────────────────────────

    function _fireRouteLeave(newPath) {
        if (root.onRouteLeave && currentPath && currentPath !== newPath) {
            root.onRouteLeave(currentPath)
        }
    }

    // Empurra uma nova entrada no histórico e navega
    function push(path, params) {
        var resolved = _resolve(path, params ?? {})
        if (!_checkCanDeactivate()) return
        if (!_checkCanActivate(resolved.path, resolved.params)) return

        _fireRouteLeave(resolved.path)
        var newStack = _stack.slice(0, _stackIndex + 1)
        newStack.push(resolved)
        _stack = newStack
        _stackIndex = newStack.length - 1
        navigationStarted(resolved.path, resolved.params)
    }

    // Substitui a entrada atual no histórico (sem criar nova entrada)
    function replace(path, params) {
        var resolved = _resolve(path, params ?? {})
        if (!_checkCanActivate(resolved.path, resolved.params)) return

        _fireRouteLeave(resolved.path)
        var newStack = _stack.slice()
        newStack[_stackIndex] = resolved
        _stack = newStack
        navigationStarted(resolved.path, resolved.params)
    }

    // Volta uma entrada no histórico
    function back() {
        if (canGoBack) {
            if (!_checkCanDeactivate()) return
            var prevEntry = _stack[_stackIndex - 1]
            if (!_checkCanActivate(prevEntry.path, prevEntry.params)) return

            _fireRouteLeave(prevEntry.path)
            _stackIndex--
            navigationStarted(currentPath, currentParams)
        }
    }

    // Avança uma entrada no histórico
    function forward() {
        if (canGoForward) {
            if (!_checkCanDeactivate()) return
            var nextEntry = _stack[_stackIndex + 1]
            if (!_checkCanActivate(nextEntry.path, nextEntry.params)) return

            _fireRouteLeave(nextEntry.path)
            _stackIndex++
            navigationStarted(currentPath, currentParams)
        }
    }

    // Navega n entradas no histórico (negativo = back, positivo = forward)
    function go(delta) {
        var newIndex = _stackIndex + delta
        if (newIndex >= 0 && newIndex < _stack.length) {
            if (!_checkCanDeactivate()) return
            var targetEntry = _stack[newIndex]
            if (!_checkCanActivate(targetEntry.path, targetEntry.params)) return

            _fireRouteLeave(targetEntry.path)
            _stackIndex = newIndex
            navigationStarted(currentPath, currentParams)
        }
    }

    // Limpa todo o histórico e navega para uma rota
    function reset(path, params) {
        var resolved = _resolve(path, params ?? {})
        if (!_checkCanDeactivate()) return
        if (!_checkCanActivate(resolved.path, resolved.params)) return

        _fireRouteLeave(resolved.path)
        _stack = [resolved]
        _stackIndex = 0
        navigationStarted(resolved.path, resolved.params)
    }

    // ── Router Guards ────────────────────────────────────

    function _checkCanActivate(path, params) {
        var route = _findRoute(path)
        if (!route || !route.canActivate) return true

        var result = route.canActivate(params, root)
        if (!result) {
            navigationBlocked(path, "canActivate")
            if (route.guardRedirect && _cleanPath(route.guardRedirect) !== path) {
                push(route.guardRedirect)
            }
            return false
        }
        return true
    }

    function _checkCanDeactivate() {
        if (_stack.length === 0) return true
        var route = _findRoute(currentPath)
        if (!route || !route.canDeactivate) return true

        var result = route.canDeactivate(currentParams, root)
        if (!result) {
            navigationBlocked(currentPath, "canDeactivate")
            return false
        }
        return true
    }

    // Verifica se um caminho combina com a rota atual
    function isActive(path) {
        return _matchPath(path, currentPath) !== null
    }

    // ── Estado Interno ──────────────────────────────────────

    property var _stack: []
    property int _stackIndex: -1
    property bool _transitioning: false

    // ── Helpers de Path ────────────────────────────────────

    // Remove trailing slash (exceto para "/")
    function _cleanPath(path) {
        if (path.length > 1 && path[path.length - 1] === "/") {
            return path.slice(0, -1)
        }
        return path
    }

    // Resolve caminho + params (extrai :params do path se houver padrão)
    function _resolve(path, extraParams) {
        var cleanedPath = _cleanPath(path)

        // Encontra a rota que combina e obtém o título
        var route = _findRoute(cleanedPath)
        var title = route ? (route.title ?? "") : ""

        // Extrai params do path (e.g. /users/42 → { id: "42" })
        var extractedParams = {}
        if (route && route.path.indexOf(":") !== -1) {
            extractedParams = _matchPath(route.path, cleanedPath) ?? {}
        }

        // Merge: extraParams têm prioridade sobre os extraídos do path
        var finalParams = {}
        for (var k in extractedParams) finalParams[k] = extractedParams[k]
        for (var k2 in extraParams)    finalParams[k2] = extraParams[k2]

        return { path: cleanedPath, params: finalParams, title: title }
    }

    // Encontra a Route que combina com um caminho concreto
    function _findRoute(concretePath) {
        var wildcard = null

        for (var i = 0; i < routes.length; i++) {
            var r = routes[i]
            if (!r || !r.isRoute) continue

            // Guarda o wildcard para usar como fallback
            if (r.path === "*") { wildcard = r; continue }

            if (_matchPath(r.path, concretePath) !== null) {
                return r
            }
        }

        // Nenhuma rota encontrou, retorna wildcard ("*") se existir
        return wildcard
    }

    // Testa se um padrão de rota combina com um caminho concreto.
    // Retorna objeto de params ou null se não combinar.
    function _matchPath(pattern, concretePath) {
        if (pattern === "*") return {}

        var paramNames = []
        // Transforma /:param em grupo de captura regex
        var regexStr = "^" + pattern.replace(/:[^/]+/g, function(m) {
            paramNames.push(m.slice(1))
            return "([^/]+)"
        }) + "$"

        var rx = new RegExp(regexStr)
        var match = concretePath.match(rx)
        if (!match) return null

        var params = {}
        for (var i = 0; i < paramNames.length; i++) {
            params[paramNames[i]] = match[i + 1]
        }
        return params
    }

    // ── Carregamento de Rota ────────────────────────────────

    function _loadRoute() {
        var route = _findRoute(currentPath)

        if (!route) {
            routeNotFound(currentPath)
            loader.sourceComponent = notFoundComponent
            return
        }

        if (transitionDuration > 0) {
            fadeOut.start()
        } else {
            _applyRoute(route)
        }
    }

    function _applyRoute(route) {
        if (route.view) {
            loader.sourceComponent = null // força recriação se for a mesma
            loader.sourceComponent = route.view
        } else if (route.source !== "") {
            loader.source = ""
            loader.source = route.source
        } else {
            loader.sourceComponent = notFoundComponent
        }
    }

    // ── Transição de Fade ───────────────────────────────────

    SequentialAnimation {
        id: fadeOut
        NumberAnimation {
            target: loader
            property: "opacity"
            to: 0
            duration: root.transitionDuration / 2
            easing.type: Easing.OutQuad
        }
        ScriptAction {
            script: {
                var route = root._findRoute(root.currentPath)
                root._applyRoute(route ?? { view: root.notFoundComponent, source: "" })
            }
        }
    }

    // ── Loader Central ──────────────────────────────────────

    Loader {
        id: loader
        anchors.fill: parent
        opacity: 0  // começa invisível até a animação de entrada

        // Quando a página carrega, injeta params e referência ao router
        onLoaded: {
            if (item) {
                // Injetar params se a página os declarar
                if ("params" in item) {
                    item.params = root.currentParams
                }
                // Injetar referência ao router (para navegação dentro da página)
                if ("router" in item) {
                    item.router = root
                }
            }

            // Fade in após carregar
            if (root.transitionDuration > 0) {
                fadeIn.start()
            } else {
                loader.opacity = 1
            }

            root.navigationFinished(root.currentPath, root.currentParams)

            if (root.onRouteEnter) {
                root.onRouteEnter(root.currentPath)
            }
        }
    }

    NumberAnimation {
        id: fadeIn
        target: loader
        property: "opacity"
        from: 0
        to: 1
        duration: root.transitionDuration / 2
        easing.type: Easing.InQuad
    }

    // ── Reação a mudanças de rota ───────────────────────────

    onCurrentPathChanged:   _loadRoute()
    onCurrentParamsChanged: {
        if (loader.item && "params" in loader.item) {
            loader.item.params = currentParams
        }
    }

    // Inicialização
    Component.onCompleted: push(initialRoute)

    // ── 404 Default ─────────────────────────────────────────

    property Component _defaultNotFound: Component {
        Item {
            property var params: ({})
            property var router: null

            Column {
                anchors.centerIn: parent
                spacing: Theme.spacing.md

                LucideIcon {
                    name: "map-pin-off"
                    size: 56
                    color: Theme.colors.surface2
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "404"
                    font.family: Theme.typography.familyBold
                    font.pixelSize: 48
                    color: Theme.colors.surface2
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "Rota não encontrada"
                    font.family: Theme.typography.family
                    font.pixelSize: Theme.typography.sizeMd
                    color: Theme.colors.subtext0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
