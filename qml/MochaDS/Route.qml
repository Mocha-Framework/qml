import QtQuick 2.15

// ============================================================
// Route.qml
// Declara uma rota dentro de um Router.
//
// Uso:
//   Route { path: "/home";       view: Component { HomePage {} } }
//   Route { path: "/users/:id";  source: Qt.resolvedUrl("pages/UserDetail.qml") }
// ============================================================

QtObject {
    // Flag de tipo — usado pelo Router para identificar este objeto
    readonly property bool isRoute: true

    // Caminho da rota. Suporta segmentos dinâmicos com :param
    // Exemplos: "/home", "/users/:id", "/posts/:category/:slug"
    property string path: ""

    // OPÇÃO 1: URL do arquivo QML para carregar
    // Use sempre Qt.resolvedUrl() para resolver relativo ao arquivo chamador:
    //   source: Qt.resolvedUrl("pages/UserDetail.qml")
    property string source: ""

    // OPÇÃO 2: Component inline (evita problemas de resolução de URL)
    //   view: Component { UserDetailPage {} }
    property Component view: null

    // Título da rota (opcional — útil para breadcrumbs, document title etc.)
    property string title: ""

    // Router Guards
    // canActivate: function(params, router) → bool
    property var canActivate: null
    // canDeactivate: function(params, router) → bool
    property var canDeactivate: null
    // Rota de redirecionamento caso canActivate retorne false
    property string guardRedirect: ""
}
