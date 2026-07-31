import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "SelectTree"
    description: "Seletor hierárquico com suporte a árvore de opções e busca."

    componentItem: [
        Column {
            spacing: DS.Theme.spacing.lg
            anchors.centerIn: parent
            width: 350

            DS.SelectTree {
                width: parent.width
                placeholder: "Selecione uma categoria..."
                size: sizeSelect.model[sizeSelect.currentIndex]

                options: [
                    { label: "Tecnologia", value: "tech", children: [
                        { label: "Frontend", value: "frontend", children: [
                            { label: "React", value: "react" },
                            { label: "Vue", value: "vue" }
                        ] },
                        { label: "Backend", value: "backend", children: [
                            { label: "Node.js", value: "node" },
                            { label: "Python", value: "python" }
                        ] }
                    ] },
                    { label: "Design", value: "design", children: [
                        { label: "UI/UX", value: "uiux" },
                        { label: "Graphic", value: "graphic" }
                    ] },
                    { label: "Marketing", value: "marketing" }
                ]
            }
        }
    ]

    controls: [
        PlaygroundCtrlSelect {
            id: sizeSelect
            label: "Tamanho"
            model: ["sm", "md", "lg"]
            currentIndex: 1
        }
    ]
}
