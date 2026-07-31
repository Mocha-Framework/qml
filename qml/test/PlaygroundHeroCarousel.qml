import QtQuick 2.15
import QtQuick.Layouts 1.15
import MochaDS as DS

Item {
    id: root
    anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: DS.Theme.spacing.xl
        spacing: DS.Theme.spacing.lg

        Text {
            text: "HeroCarousel"
            font.family: DS.Theme.typography.familyBold
            font.pixelSize: DS.Theme.typography.sizeH2
            color: DS.Theme.colors.text
        }

        Text {
            text: "Carrossel hero para destaques principais de um aplicativo, desenhado para se adequar a grandes telas com suporte a navegação por botões, temporizador automático e suporte a indicadores."
            font.family: DS.Theme.typography.family
            font.pixelSize: DS.Theme.typography.sizeMd
            color: DS.Theme.colors.subtext0
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
        }

        DS.HeroCarousel {
            Layout.fillWidth: true
            Layout.preferredHeight: 380
            Layout.margins: DS.Theme.spacing.md
            
            // Intervalo de auto-play. Coloque 0 para desativar.
            autoAdvanceInterval: 4500

            model: [
                {
                    image: "https://images.unsplash.com/photo-1542751371-adc38448a05e?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                    title: "Cyberpunk Gaming",
                    description: "Explore o universo cyberpunk com gráficos impressionantes e jogabilidade intensa.",
                    badge: "DESTAQUE",
                    badgeVariant: "primary",
                    accentColor: DS.Theme.colors.peach,
                    primaryButtonText: "Instalar Agora",
                    primaryButtonIcon: "download",
                    primaryButtonVariant: "success",
                    secondaryButtonText: "Ver Detalhes"
                },
                {
                    image: "https://images.unsplash.com/photo-1550745165-9bc0b252726f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                    title: "Retro Console",
                    description: "Jogue os clássicos do passado com a experiência de amanhã. Suporte para mais de 50 sistemas retrô.",
                    badge: "ATUALIZAÇÃO",
                    badgeVariant: "secondary",
                    accentColor: DS.Theme.colors.blue,
                    primaryButtonText: "Atualizar",
                    primaryButtonIcon: "refresh-cw",
                    primaryButtonVariant: "primary"
                },
                {
                    image: "https://images.unsplash.com/photo-1605810230434-7631ac76ec81?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80",
                    title: "Design de Interiores",
                    description: "Aplicativo líder mundial em modelagem 3D e design de espaços interiores.",
                    badge: "APLICATIVO",
                    badgeVariant: "outline",
                    accentColor: DS.Theme.colors.green,
                    primaryButtonText: "Abrir",
                    primaryButtonIcon: "play"
                }
            ]

            onPrimaryActionClicked: function(index, itemData) {
                console.log("Ação Primária Clicada no slide", index, "-", itemData.title)
            }

            onSecondaryActionClicked: function(index, itemData) {
                console.log("Ação Secundária Clicada no slide", index, "-", itemData.title)
            }
        }
        
        Item { Layout.fillHeight: true }
    }
}
