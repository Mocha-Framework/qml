import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Playground {
    id: pg
    title: "DynamicForm"
    description: "Formulário dinâmico gerado a partir de schema JSON."

    componentItem: [
        DS.DynamicForm {
            anchors.fill: parent
            anchors.margins: DS.Theme.spacing.xl

            schema: [
                { type: "text", name: "fullname", label: "Nome Completo", placeholder: "Seu nome" },
                { type: "email", name: "email", label: "Email", placeholder: "email@exemplo.com" },
                { type: "select", name: "department", label: "Departamento", options: ["TI", "RH", "Marketing", "Financeiro"] },
                { type: "textarea", name: "bio", label: "Biografia", placeholder: "Conte um pouco sobre você..." }
            ]

            onSubmitted: {
                print("Form submitted:", JSON.stringify(values));
            }
        }
    ]

    controls: []
}
