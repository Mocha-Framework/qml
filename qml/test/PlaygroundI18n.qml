import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Item {
    id: root
    width: 600
    height: 400

    Component.onCompleted: {
        // Set the path to our test i18n directory
        DS.MochaI18n.basePath = Qt.resolvedUrl("i18n").toString();
        // Force reload with the new path
        DS.MochaI18n.reload();
        // Enable debug mode for missing keys
        DS.MochaI18n.debugMode = true;
    }

    DS.CozySpinner {
        anchors.centerIn: parent
        visible: !DS.MochaI18n.isReady
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: 400
        spacing: DS.Theme.spacing.lg
        visible: DS.MochaI18n.isReady

        DS.VStack {
            spacing: DS.Theme.spacing.sm
            Layout.fillWidth: true

            Text {
                // Interpolation
                text: DS.MochaI18n.t("greeting", { name: "Developer" })
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeXl
                color: DS.Theme.colors.text
            }

            Text {
                // Flat key lookup
                text: DS.MochaI18n.t("description")
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeMd
                color: DS.Theme.colors.subtext0
                wrapMode: Text.WordWrap
                width: parent.width
            }

            Text {
                // Missing key with debugMode
                text: DS.MochaI18n.t("missing.key.example")
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.red
            }

            Text {
                // Fallback key (missing in pt-BR, present in en)
                text: "Fallback test: " + DS.MochaI18n.t("fallback_example")
                font.family: DS.Theme.typography.family
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.green
            }
        }

        DS.Separator {}

        DS.HStack {
            spacing: DS.Theme.spacing.md

            // Pluralization
            DS.Badge {
                text: DS.MochaI18n.t("notifications.count", { count: 0 })
                variant: "secondary"
            }
            DS.Badge {
                text: DS.MochaI18n.t("notifications.count", { count: 1 })
                variant: "primary"
            }
            DS.Badge {
                text: DS.MochaI18n.t("notifications.count", { count: 2 })
                variant: "warning"
            }
            DS.Badge {
                text: DS.MochaI18n.t("notifications.count", { count: 5 })
                variant: "danger"
            }
        }

        DS.Separator {}

        DS.HStack {
            spacing: DS.Theme.spacing.md
            Layout.alignment: Qt.AlignHCenter

            DS.Button {
                text: DS.MochaI18n.locale === "en" ? "Change to pt-BR" : "Change to en"
                variant: "primary"
                onClicked: {
                    DS.MochaI18n.locale = DS.MochaI18n.locale === "en" ? "pt-BR" : "en";
                }
            }

            DS.Button {
                text: DS.MochaI18n.t("buttons.save")
                variant: "success"
            }

            DS.Button {
                text: DS.MochaI18n.t("buttons.cancel")
                variant: "ghost"
            }
        }
    }
}
