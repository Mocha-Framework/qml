import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Playground {
    id: pg
    title: "Tree Table"
    description: "Tabela avançada para exibição de dados hierárquicos em estrutura de árvore."

    property var mockDepartments: [
        { 
            id: "DEP-1", name: "Diretoria", type: "Departamento", budget: "R$ 5.000.000",
            children: [
                { id: "EMP-10", name: "Roberto Justo", type: "CEO", budget: "R$ 2.000.000" },
                { id: "EMP-11", name: "Ana Maria", type: "CFO", budget: "R$ 3.000.000" }
            ]
        },
        { 
            id: "DEP-2", name: "Engenharia", type: "Departamento", budget: "R$ 8.500.000",
            children: [
                {
                    id: "TEAM-A", name: "Frontend Core", type: "Equipe", budget: "R$ 2.500.000",
                    children: [
                        { id: "EMP-20", name: "Carlos Silva", type: "Tech Lead", budget: "-" },
                        { id: "EMP-21", name: "Julia Santos", type: "Engenheira Sênior", budget: "-" },
                        { id: "EMP-22", name: "Marcos Lee", type: "Engenheiro Pleno", budget: "-" }
                    ]
                },
                {
                    id: "TEAM-B", name: "Backend Services", type: "Equipe", budget: "R$ 6.000.000",
                    children: [
                        { id: "EMP-30", name: "Diana Costa", type: "Arquiteta", budget: "-" },
                        { id: "EMP-31", name: "Tiago Gomes", type: "Engenheiro Staff", budget: "-" }
                    ]
                }
            ]
        },
        { 
            id: "DEP-3", name: "Recursos Humanos", type: "Departamento", budget: "R$ 1.200.000",
            children: [
                { id: "EMP-40", name: "Sara Lima", type: "HR Business Partner", budget: "-" },
                { id: "EMP-41", name: "Renato Alves", type: "Tech Recruiter", budget: "-" }
            ]
        }
    ]

    componentItem: [
        DS.TreeTable {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl
            rows: pg.mockDepartments
            columns: [
                { name: "name", label: "Nome", width: 280, sortable: true, type: "bold" },
                { name: "id", label: "Código", width: 100 },
                { name: "type", label: "Tipo", width: 150, type: "badge" },
                { name: "budget", label: "Orçamento", width: 150 }
            ]
            selectable: selectSwitch.checked
        }
    ]

    controls: [
        PlaygroundCtrlSwitch {
            id: selectSwitch
            label: "Selecionável"
            checked: true
        }
    ]
}
