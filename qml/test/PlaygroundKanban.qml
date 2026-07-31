import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "Kanban Board"
    description: "Multi-lista com drag & drop entre colunas (Kanban) com cards customizados."

    componentItem: [
        Item {
            id: kanbanRoot
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.sm

            // ==========================================
            // Rich Task Data Models
            // ==========================================
            property var modelTodo: [
                { id: "todo-1", label: "Testar Acessibilidade Teclado", desc: "Garantir que a reordenação das colunas e cartões atenda aos requisitos WCAG.", tags: ["Acessibilidade"], color: DS.Theme.colors.red }
            ]

            property var modelReady: [
                { id: "ready-1", label: "Redigir Documentação Técnica", desc: "Escrever guias detalhados sobre como consumir os pacotes do design system.", tags: ["Docs"], color: DS.Theme.colors.peach }
            ]

            property var modelDoing: [
                { id: "doing-1", label: "Implementar Componentes Core", desc: "Desenvolvimento e testes dos botões, inputs, modais e accordion.", tags: ["React", "Core"], color: DS.Theme.colors.blue },
                { id: "doing-2", label: "Criar Componente de Kanban Pro", desc: "Novo componente Kanban com suporte nativo a arrastar e soltar (reordenável).", tags: ["Pro", "Dev"], color: DS.Theme.colors.blue }
            ]

            property var modelDone: [
                { id: "done-1", label: "Configurar Environment", desc: "Estruturação dos ambientes de homologação e testes de pacotes individuais do design system.", tags: ["Dev", "Setup"], color: DS.Theme.colors.green },
                { id: "done-2", label: "Definir Paleta de Cores", desc: "Integração das cores base do Catppuccin com suporte a múltiplos sabores de temas.", tags: ["Design"], color: DS.Theme.colors.green }
            ]

            property var models: [modelTodo, modelReady, modelDoing, modelDone]

            property var listIds: ["todo", "ready", "doing", "done"]
            property var columnTitles: ["A fazer (Backlog)", "Pronto para Iniciar (To Do)", "Em Progresso (In Progress)", "Concluído (Done)"]
            property var columnColors: [DS.Theme.colors.red, DS.Theme.colors.peach, DS.Theme.colors.blue, DS.Theme.colors.green]

            // ==========================================
            // Kanban Core Functions
            // ==========================================
            function moveItem(sourceId, sourceIndex, targetId, insertIndex) {
                var srcIdx = listIds.indexOf(sourceId)
                var tgtIdx = listIds.indexOf(targetId)
                if (srcIdx < 0 || tgtIdx < 0 || sourceIndex < 0) return
                
                // Deep copy to trigger QML reactivity
                var newModels = [
                    models[0].slice(),
                    models[1].slice(),
                    models[2].slice(),
                    models[3].slice()
                ]
                
                var data = newModels[srcIdx][sourceIndex]
                newModels[srcIdx].splice(sourceIndex, 1)
                
                // Update item color to match destination column color
                data.color = columnColors[tgtIdx]
                
                if (insertIndex >= 0 && insertIndex <= newModels[tgtIdx].length) {
                    newModels[tgtIdx].splice(insertIndex, 0, data)
                } else {
                    newModels[tgtIdx].push(data)
                }
                
                kanbanRoot.models = newModels
            }

            function addTask(title, desc, columnLabel, tagsText) {
                if (title.trim() === "") return
                
                var colIdx = columnTitles.indexOf(columnLabel)
                if (colIdx < 0) colIdx = 0
                
                // Parse comma-separated tags
                var tags = []
                if (tagsText.trim() !== "") {
                    var splitTags = tagsText.split(",")
                    for (var i = 0; i < splitTags.length; i++) {
                        var tag = splitTags[i].trim()
                        if (tag !== "") {
                            tags.push(tag)
                        }
                    }
                }
                
                var newTask = {
                    id: "task-" + Date.now(),
                    label: title,
                    desc: desc,
                    tags: tags,
                    color: columnColors[colIdx]
                }
                
                var newModels = [
                    models[0].slice(),
                    models[1].slice(),
                    models[2].slice(),
                    models[3].slice()
                ]
                newModels[colIdx].push(newTask)
                
                kanbanRoot.models = newModels
            }

            // ==========================================
            // Card Template Delegate
            // ==========================================
            Component {
                id: cardDelegate

                Item {
                    id: cardItem
                    width: parent.width
                    height: cardRect.implicitHeight + DS.Theme.spacing.xs

                    Rectangle {
                        id: cardRect
                        width: parent.width
                        implicitHeight: cardLayout.implicitHeight + DS.Theme.spacing.md * 2
                        color: DS.Theme.colors.surface0
                        radius: DS.Theme.geometry.radiusMd
                        border.color: DS.Theme.colors.surface1
                        border.width: 1

                        // Colored status indicator vertical bar
                        Rectangle {
                            width: 4
                            height: parent.height - 16
                            radius: 2
                            color: typeof modelData !== "undefined" && modelData && modelData.color ? modelData.color : DS.Theme.colors.primary
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        ColumnLayout {
                            id: cardLayout
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.right: parent.right
                            anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: DS.Theme.spacing.xs

                            Text {
                                text: typeof modelData !== "undefined" && modelData ? modelData.label : ""
                                font.family: DS.Theme.typography.familyBold
                                font.pixelSize: DS.Theme.typography.sizeMd
                                color: DS.Theme.colors.text
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                text: typeof modelData !== "undefined" && modelData ? modelData.desc : ""
                                font.family: DS.Theme.typography.family
                                font.pixelSize: DS.Theme.typography.sizeSm
                                color: DS.Theme.colors.subtext0
                                Layout.fillWidth: true
                                wrapMode: Text.WordWrap
                                visible: text !== ""
                            }

                            // Tags Flow Layout
                            Flow {
                                Layout.fillWidth: true
                                spacing: 4
                                visible: typeof modelData !== "undefined" && modelData && modelData.tags && modelData.tags.length > 0

                                Repeater {
                                    model: typeof modelData !== "undefined" && modelData ? modelData.tags : []
                                    delegate: Rectangle {
                                        width: tagText.implicitWidth + 12
                                        height: tagText.implicitHeight + 6
                                        radius: DS.Theme.geometry.radiusSm
                                        color: DS.Theme.colors.surface1
                                        border.color: DS.Theme.colors.surface2
                                        border.width: 1

                                        Text {
                                            id: tagText
                                            text: modelData
                                            font.family: DS.Theme.typography.familyMedium
                                            font.pixelSize: DS.Theme.typography.sizeXs
                                            color: DS.Theme.colors.subtext1
                                            anchors.centerIn: parent
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // Main visual Layout
            // ==========================================
            ColumnLayout {
                anchors.fill: parent
                spacing: DS.Theme.spacing.md

                // 1. ADD TASK FORM PANEL
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: formLayout.implicitHeight + DS.Theme.spacing.sm * 2
                    radius: DS.Theme.geometry.radiusMd
                    color: DS.Theme.colors.mantle
                    border.color: DS.Theme.colors.surface0
                    border.width: 1

                    ColumnLayout {
                        id: formLayout
                        anchors.fill: parent
                        anchors.margins: DS.Theme.spacing.sm
                        spacing: DS.Theme.spacing.xs

                        RowLayout {
                            spacing: DS.Theme.spacing.sm
                            DS.LucideIcon { name: "plus-circle"; size: 14; color: DS.Theme.colors.mauve }
                            Text {
                                text: "Adicionar Novo Cartão de Tarefa"
                                font.family: DS.Theme.typography.familyBold
                                font.pixelSize: DS.Theme.typography.sizeSm
                                color: DS.Theme.colors.text
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: DS.Theme.spacing.sm

                            // Task Title
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "Título da Tarefa"
                                    font.family: DS.Theme.typography.familyMedium
                                    font.pixelSize: DS.Theme.typography.sizeXs
                                    color: DS.Theme.colors.subtext0
                                }
                                DS.TextField {
                                    id: taskTitleInput
                                    Layout.fillWidth: true
                                    placeholder: "e.g. Testar Acessibilidade"
                                    size: "sm"
                                }
                            }

                            // Task Description
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: "Descrição da Tarefa"
                                    font.family: DS.Theme.typography.familyMedium
                                    font.pixelSize: DS.Theme.typography.sizeXs
                                    color: DS.Theme.colors.subtext0
                                }
                                DS.TextField {
                                    id: taskDescInput
                                    Layout.fillWidth: true
                                    placeholder: "e.g. Cobertura de testes..."
                                    size: "sm"
                                }
                            }

                            // Column Selection
                            ColumnLayout {
                                Layout.preferredWidth: 160
                                spacing: 2
                                Text {
                                    text: "Coluna Inicial"
                                    font.family: DS.Theme.typography.familyMedium
                                    font.pixelSize: DS.Theme.typography.sizeXs
                                    color: DS.Theme.colors.subtext0
                                }
                                DS.Select {
                                    id: taskColumnSelect
                                    Layout.fillWidth: true
                                    placeholder: "Selecione..."
                                    options: kanbanRoot.columnTitles
                                    selectedValue: kanbanRoot.columnTitles[0]
                                    size: "sm"
                                }
                            }

                            // Tags
                            ColumnLayout {
                                Layout.preferredWidth: 140
                                spacing: 2
                                Text {
                                    text: "Tags (vírgula)"
                                    font.family: DS.Theme.typography.familyMedium
                                    font.pixelSize: DS.Theme.typography.sizeXs
                                    color: DS.Theme.colors.subtext0
                                }
                                DS.TextField {
                                    id: taskTagsInput
                                    Layout.fillWidth: true
                                    placeholder: "e.g. React, Core"
                                    size: "sm"
                                }
                            }

                            // Add Button
                            DS.Button {
                                text: "Adicionar"
                                size: "sm"
                                color: "mauve"
                                Layout.alignment: Qt.AlignBottom
                                onClicked: {
                                    var title = taskTitleInput.text
                                    var desc = taskDescInput.text
                                    var col = taskColumnSelect.selectedLabel ? taskColumnSelect.selectedLabel : kanbanRoot.columnTitles[0]
                                    var tags = taskTagsInput.text
                                    
                                    if (title.trim() !== "") {
                                        kanbanRoot.addTask(title, desc, col, tags)
                                        // Clear inputs
                                        taskTitleInput.text = ""
                                        taskDescInput.text = ""
                                        taskTagsInput.text = ""
                                    }
                                }
                            }
                        }
                    }
                }

                // 2. KANBAN COLUMNS (4 COLUMNS)
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: DS.Theme.spacing.md

                    Repeater {
                        model: 4

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: DS.Theme.spacing.xs

                            // Column Header
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 44
                                radius: DS.Theme.geometry.radiusMd
                                color: DS.Theme.colors.surface0

                                // Colored status top highlight line
                                Rectangle {
                                    width: parent.width
                                    height: 3
                                    color: kanbanRoot.columnColors[index]
                                    anchors.top: parent.top
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    radius: DS.Theme.geometry.radiusSm
                                }

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.topMargin: 3
                                    anchors.leftMargin: DS.Theme.spacing.md
                                    anchors.rightMargin: DS.Theme.spacing.md
                                    spacing: DS.Theme.spacing.sm

                                    // Indicator colored dot
                                    Rectangle {
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: kanbanRoot.columnColors[index]
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    Text {
                                        text: kanbanRoot.columnTitles[index]
                                        font.family: DS.Theme.typography.familyBold
                                        font.pixelSize: DS.Theme.typography.sizeSm
                                        color: DS.Theme.colors.text
                                        Layout.fillWidth: true
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    // Count badge
                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: 10
                                        color: DS.Theme.colors.surface1
                                        Layout.alignment: Qt.AlignVCenter

                                        Text {
                                            text: kanbanRoot.models[index].length
                                            font.family: DS.Theme.typography.familyBold
                                            font.pixelSize: DS.Theme.typography.sizeXs
                                            color: DS.Theme.colors.subtext0
                                            anchors.centerIn: parent
                                        }
                                    }
                                }
                            }

                            // DropZone for tasks reordering
                            DS.DropZone {
                                id: columnDropZone
                                key: "mochads-sortable"
                                accentColor: kanbanRoot.columnColors[index]
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                radius: DS.Theme.geometry.radiusMd
                                forceHighlight: sortableList.dragTargetIndex >= 0

                                DS.SortableList {
                                    id: sortableList
                                    anchors.fill: parent
                                    anchors.margins: DS.Theme.spacing.xs
                                    listId: kanbanRoot.listIds[index]
                                    sortable: true
                                    model: kanbanRoot.models[index]
                                    spacing: DS.Theme.spacing.xs

                                    delegate: cardDelegate

                                    onItemsReordered: function(fromIndex, toIndex) {
                                        var srcIdx = kanbanRoot.listIds.indexOf(listId)
                                        if (srcIdx < 0) return
                                        var newModels = [
                                            kanbanRoot.models[0].slice(),
                                            kanbanRoot.models[1].slice(),
                                            kanbanRoot.models[2].slice(),
                                            kanbanRoot.models[3].slice()
                                        ]
                                        var item = newModels[srcIdx].splice(fromIndex, 1)[0]
                                        newModels[srcIdx].splice(toIndex, 0, item)
                                        kanbanRoot.models = newModels
                                    }

                                    onExternalItemDropped: function(source, insertIndex) {
                                        var srcId = source.__sourceListId
                                        var srcIndex = source.__sourceIndex
                                        var tgtId = sortableList.listId
                                        if (srcId && srcIndex >= 0 && srcId !== tgtId) {
                                            kanbanRoot.moveItem(srcId, srcIndex, tgtId, insertIndex)
                                        }
                                    }
                                }

                                onDropped: function(source) {
                                    var srcId = source.__sourceListId
                                    var srcIndex = source.__sourceIndex
                                    var tgtId = sortableList.listId
                                    if (srcId && srcIndex >= 0 && srcId !== tgtId) {
                                        kanbanRoot.moveItem(srcId, srcIndex, tgtId, -1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    ]

    controls: [
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: DS.Theme.spacing.md

            Button {
                text: "Resetar Quadro"
                onClicked: {
                    kanbanRoot.models = [
                        [
                            { id: "todo-1", label: "Testar Acessibilidade Teclado", desc: "Garantir que a reordenação das colunas e cartões atenda aos requisitos WCAG.", tags: ["Acessibilidade"], color: DS.Theme.colors.red }
                        ],
                        [
                            { id: "ready-1", label: "Redigir Documentação Técnica", desc: "Escrever guias detalhados sobre como consumir os pacotes do design system.", tags: ["Docs"], color: DS.Theme.colors.peach }
                        ],
                        [
                            { id: "doing-1", label: "Implementar Componentes Core", desc: "Desenvolvimento e testes dos botões, inputs, modais e accordion.", tags: ["React", "Core"], color: DS.Theme.colors.blue },
                            { id: "doing-2", label: "Criar Componente de Kanban Pro", desc: "Novo componente Kanban com suporte nativo a arrastar e soltar (reordenável).", tags: ["Pro", "Dev"], color: DS.Theme.colors.blue }
                        ],
                        [
                            { id: "done-1", label: "Configurar Environment", desc: "Estruturação dos ambientes de homologação e testes de pacotes individuais do design system.", tags: ["Dev", "Setup"], color: DS.Theme.colors.green },
                            { id: "done-2", label: "Definir Paleta de Cores", desc: "Integração das cores base do Catppuccin com suporte a múltiplos sabores de temas.", tags: ["Design"], color: DS.Theme.colors.green }
                        ]
                    ]
                }
            }
        }
    ]
}
