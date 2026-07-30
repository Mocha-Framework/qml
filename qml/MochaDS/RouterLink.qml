import QtQuick 2.15

// ============================================================
// RouterLink.qml
// Componente de link de navegação declarativo.
// Envolve qualquer componente visual (ou atua como um botão/item clicável)
// e realiza a navegação no Router especificado.
//
// USO BÁSICO:
//   RouterLink {
//       to: "/users/42"
//       router: myRouter
//       
//       // O filho pode ser qualquer coisa, ex: um texto ou botão
//       Text {
//           text: "Ver Perfil"
//           color: parent.isHovered ? Theme.colors.primary : Theme.colors.text
//       }
//   }
//
// USO COMPACTO (Como um item de menu simples):
//   RouterLink {
//       to: "/settings"
//       router: myRouter
//       text: "Configurações"
//       icon: "settings"
//       activeColor: Theme.colors.mauve
//   }
// ============================================================

Item {
    id: root

    // ── Public API ──────────────────────────────────────────

    // O caminho de destino para onde navegar
    property string to: ""

    // Os parâmetros adicionais para a rota (opcional)
    property var params: ({})

    // Referência ao componente Router (se nulo, tenta buscar subindo a árvore de parentesco)
    property var router: null

    // Tipo de navegação: "push" | "replace" | "reset"
    property string action: "push"

    // Rótulo de texto simplificado (caso não queira definir filhos customizados)
    property string text: ""

    // Ícone Lucide opcional (caso não queira definir filhos customizados)
    property string icon: ""

    // Cor quando a rota ativa corresponder ao destino
    property color activeColor: Theme.colors.primary
    property color inactiveColor: Theme.colors.text

    // ── Estado ──────────────────────────────────────────────

    // Indica se o link atual corresponde à rota ativa
    readonly property bool isActive: {
        var r = _getRouter()
        return r ? r.isActive(to) : false
    }

    // Hover state
    readonly property bool isHovered: hoverHandler.hovered

    // Press state
    readonly property bool isPressed: tapHandler.pressed

    // ── Layout e Visual ─────────────────────────────────────

    implicitWidth: childrenRect.width > 0 ? childrenRect.width : (textLayout.visible ? textLayout.implicitWidth : 100)
    implicitHeight: childrenRect.height > 0 ? childrenRect.height : (textLayout.visible ? textLayout.implicitHeight : 40)

    // Cursor pointer para Web DX
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.NoButton // Permite que o TapHandler intercepte cliques
    }

    TapHandler {
        id: tapHandler
        onTapped: {
            var r = _getRouter()
            if (!r) {
                console.warn("RouterLink: Nenhum Router encontrado para navegar até: " + to)
                return
            }

            if (action === "replace") {
                r.replace(to, params)
            } else if (action === "reset") {
                r.reset(to, params)
            } else {
                r.push(to, params)
            }
        }
    }

    HoverHandler {
        id: hoverHandler
    }

    // Layout padrão compacto para uso rápido
    Row {
        id: textLayout
        anchors.centerIn: parent
        spacing: Theme.spacing.sm
        visible: root.text !== "" || root.icon !== ""

        LucideIcon {
            name: root.icon
            size: 16
            color: root.isActive ? root.activeColor : (root.isHovered ? Theme.colors.subtext1 : root.inactiveColor)
            visible: root.icon !== ""
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.text
            font.family: Theme.typography.family
            font.pixelSize: Theme.typography.sizeMd
            color: root.isActive ? root.activeColor : (root.isHovered ? Theme.colors.subtext1 : root.inactiveColor)
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ── Helpers ─────────────────────────────────────────────

    // Encontra o roteador subindo a árvore de parents se não foi explicitamente fornecido
    function _getRouter() {
        if (router) return router

        var p = parent
        while (p) {
            // Um Router possui a propriedade _stack e canGoBack
            if (p.hasOwnProperty("canGoBack") && p.hasOwnProperty("_stack")) {
                return p
            }
            p = p.parent
        }
        return null
    }
}
