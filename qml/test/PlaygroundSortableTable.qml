import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Playground {
    id: pg
    title: "Sortable Table"
    description: "Tabela de dados avançada que permite reordenação manual das linhas."

    property var mockEmployees: [
        { id: "EMP-1011", name: "Bernardo Dias", email: "bernardo@empresa.com", role: "DevOps Engineer", status: "Ativo" },
        { id: "EMP-1012", name: "Clara Mendes", email: "clara@empresa.com", role: "UX Designer", status: "Ativo" },
        { id: "EMP-1013", name: "Daniel Sousa", email: "daniel@empresa.com", role: "Frontend Developer", status: "Pendente" },
        { id: "EMP-1014", name: "Elisa Santos", email: "elisa@empresa.com", role: "Product Manager", status: "Ativo" },
        { id: "EMP-1015", name: "Alice Moreira", email: "alice@empresa.com", role: "Tech Lead", status: "Ativo" }
    ]

    componentItem: [
        DS.Table {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl
            rows: pg.mockEmployees
            columns: [
                { name: "id", label: "ID", width: 100, sortable: true },
                { name: "name", label: "Nome", width: 200, sortable: true },
                { name: "email", label: "Email", width: 200 },
                { name: "role", label: "Cargo", width: 150 },
                { name: "status", label: "Status", width: 100 }
            ]
            selectable: true
            showPagination: true
            dragToReorder: true
            
            onRowsReordered: function(fromIndex, toIndex) {
                var arr = pg.mockEmployees.slice();
                var item = arr.splice(fromIndex, 1)[0];
                arr.splice(toIndex, 0, item);
                pg.mockEmployees = arr;
                console.log("Linhas reordenadas: " + fromIndex + " -> " + toIndex);
            }
        }
    ]

    controls: [
        Text {
            text: "Experimente arrastar as linhas pelo ícone de grip (⋮⋮) no início de cada linha para reordená-las."
            font.family: DS.Theme.typography.family
            font.pixelSize: DS.Theme.typography.sizeMd
            color: DS.Theme.colors.subtext0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    ]
}
