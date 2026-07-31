import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Item {
    id: root

    property alias componentItem: previewContainer.data
    property alias controls: controlColumn.data
    property string title: "Animações (Novas)"
    property string description: "Demonstração de todos os novos componentes de animação do MochaDS"

    RowLayout {
        anchors.fill: parent
        spacing: 0

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 80
                color: "transparent"

                Row {
                    anchors.fill: parent
                    anchors.margins: DS.Theme.spacing.xl
                    spacing: DS.Theme.spacing.lg

                    Column {
                        width: parent.width - 120
                        spacing: DS.Theme.spacing.xs

                        Text {
                            text: root.title
                            font.family: DS.Theme.typography.familyBold
                            font.pixelSize: DS.Theme.typography.sizeH2
                            color: DS.Theme.colors.text
                        }
                        Text {
                            text: root.description
                            font.family: DS.Theme.typography.family
                            font.pixelSize: DS.Theme.typography.sizeMd
                            color: DS.Theme.colors.subtext0
                        }
                    }
                }
            }

            Rectangle {
                id: previewContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: DS.Theme.colors.mantle
                radius: DS.Theme.geometry.radiusLg
                anchors.margins: DS.Theme.spacing.xl
                border.color: DS.Theme.colors.surface0
                border.width: DS.Theme.geometry.borderSm
                clip: true

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: DS.Theme.spacing.lg
                    clip: true
                    contentWidth: availableWidth

                    Column {
                        id: demoColumn
                        width: parent.width
                        spacing: DS.Theme.spacing.xl

                        // ── ENTRANCE ANIMATIONS ──────────────────────────
                        SectionHeader { text: "Animações de Entrada"; sectionColor: DS.Theme.colors.mauve }

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg
                            DS.Button {
                                text: "► Repetir Todas"
                                variant: "primary"
                                color: "mauve"
                                onClicked: {
                                    entranceLoader.active = false
                                    resetTimer.start()
                                }
                            }
                            Timer {
                                id: resetTimer
                                interval: 50
                                onTriggered: entranceLoader.active = true
                            }
                        }

                        property bool entranceTrigger: true

                        Loader {
                            id: entranceLoader
                            width: parent.width
                            active: true
                            sourceComponent: Component {
                                Flow {
                                    width: entranceLoader.width
                                    spacing: DS.Theme.spacing.lg

                            AnimDemoCard {
                                title: "FadeIn"
                                trigger: demoColumn.entranceTrigger
                                DS.FadeIn { duration: 300; trigger: parent.trigger
                                    ColoredBox { color: DS.Theme.colors.mauve; label: "FadeIn" } }
                            }
                            AnimDemoCard {
                                title: "SlideUp"
                                trigger: demoColumn.entranceTrigger
                                DS.SlideUp { duration: 400; trigger: parent.trigger; offset: 25
                                    ColoredBox { color: DS.Theme.colors.pink; label: "SlideUp" } }
                            }
                            AnimDemoCard {
                                title: "SlideDown"
                                trigger: demoColumn.entranceTrigger
                                DS.SlideDown { duration: 400; trigger: parent.trigger; offset: 25
                                    ColoredBox { color: DS.Theme.colors.sky; label: "SlideDown" } }
                            }
                            AnimDemoCard {
                                title: "SlideLeft"
                                trigger: demoColumn.entranceTrigger
                                DS.SlideLeft { duration: 400; trigger: parent.trigger; offset: 25
                                    ColoredBox { color: DS.Theme.colors.green; label: "SlideLeft" } }
                            }
                            AnimDemoCard {
                                title: "SlideRight"
                                trigger: demoColumn.entranceTrigger
                                DS.SlideRight { duration: 400; trigger: parent.trigger; offset: 25
                                    ColoredBox { color: DS.Theme.colors.peach; label: "SlideRight" } }
                            }
                            AnimDemoCard {
                                title: "ZoomIn"
                                trigger: demoColumn.entranceTrigger
                                DS.ZoomIn { duration: 350; trigger: parent.trigger; fromScale: 0.8
                                    ColoredBox { color: DS.Theme.colors.blue; label: "ZoomIn" } }
                            }
                            AnimDemoCard {
                                title: "Bounce"
                                trigger: demoColumn.entranceTrigger
                                DS.Bounce { duration: 600; trigger: parent.trigger; fromScale: 0.5
                                    ColoredBox { color: DS.Theme.colors.yellow; label: "Bounce!" } }
                            }
                            AnimDemoCard {
                                title: "Flip"
                                trigger: demoColumn.entranceTrigger
                                DS.Flip { duration: 500; trigger: parent.trigger
                                    ColoredBox { color: DS.Theme.colors.teal; label: "Flip" } }
                            }
                            AnimDemoCard {
                                title: "Spin"
                                trigger: demoColumn.entranceTrigger
                                DS.Spin { duration: 500; trigger: parent.trigger; fromRotation: -180
                                    ColoredBox { color: DS.Theme.colors.sapphire; label: "Spin!" } }
                            }
                                }
                            }
                        }

                        // ── EXIT ANIMATIONS ──────────────────────────────
                        SectionHeader { text: "Animações de Saída"; sectionColor: DS.Theme.colors.red }

                        property bool exitTrigger: true

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg
                            DS.Button {
                                text: demoColumn.exitTrigger ? "► Esconder" : "► Mostrar"
                                variant: "primary"
                                color: "red"
                                onClicked: demoColumn.exitTrigger = !demoColumn.exitTrigger
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg

                            AnimDemoCard {
                                title: "FadeOut"
                                DS.FadeOut { duration: 400; trigger: demoColumn.exitTrigger
                                    ColoredBox { color: DS.Theme.colors.red; label: "FadeOut"; textColor: "#fff" } }
                            }
                            AnimDemoCard {
                                title: "SlideOutUp"
                                DS.SlideOutUp { duration: 400; trigger: demoColumn.exitTrigger; offset: 30
                                    ColoredBox { color: DS.Theme.colors.maroon; label: "Out Up"; textColor: "#fff" } }
                            }
                            AnimDemoCard {
                                title: "SlideOutDown"
                                DS.SlideOutDown { duration: 400; trigger: demoColumn.exitTrigger; offset: 30
                                    ColoredBox { color: DS.Theme.colors.rosewater; label: "Out Down"; textColor: "#fff" } }
                            }
                        }

                        // ── ANIMATED PRESENCE ───────────────────────────
                        SectionHeader { text: "AnimatedPresence (entrada + saída)"; sectionColor: DS.Theme.colors.green }

                        property bool presenceShown: false

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg
                            DS.Button {
                                text: demoColumn.presenceShown ? "✕ Esconder" : "✓ Mostrar"
                                variant: demoColumn.presenceShown ? "danger" : "primary"
                                color: "green"
                                onClicked: demoColumn.presenceShown = !demoColumn.presenceShown
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg

                            DS.AnimatedPresence {
                                shown: demoColumn.presenceShown
                                enterAnimation: "all"
                                exitAnimation: "all"
                                enterOffset: 30; exitOffset: 30
                                Rectangle { width: 140; height: 80; radius: DS.Theme.geometry.radiusMd; color: DS.Theme.colors.green
                                    Text { text: "All (Slide+Zoom+Spin)"; anchors.centerIn: parent; color: DS.Theme.colors.crust; font.pixelSize: 12; font.family: DS.Theme.typography.familyBold } }
                            }
                            DS.AnimatedPresence {
                                shown: demoColumn.presenceShown
                                enterAnimation: "flip"
                                exitAnimation: "flip"
                                Rectangle { width: 140; height: 80; radius: DS.Theme.geometry.radiusMd; color: DS.Theme.colors.sapphire
                                    Text { text: "Flip (Eixo 3D)"; anchors.centerIn: parent; color: DS.Theme.colors.crust; font.pixelSize: 12; font.family: DS.Theme.typography.familyBold } }
                            }
                            DS.AnimatedPresence {
                                shown: demoColumn.presenceShown
                                enterAnimation: "bounce"
                                exitAnimation: "zoom"
                                enterDuration: 500
                                Rectangle { width: 140; height: 80; radius: DS.Theme.geometry.radiusMd; color: DS.Theme.colors.yellow
                                    Text { text: "Bounce (Quicar)"; anchors.centerIn: parent; color: DS.Theme.colors.crust; font.pixelSize: 12; font.family: DS.Theme.typography.familyBold } }
                            }
                            DS.AnimatedPresence {
                                shown: demoColumn.presenceShown
                                enterAnimation: "fade"
                                exitAnimation: "fade"
                                enterDuration: 500
                                Rectangle { width: 140; height: 80; radius: DS.Theme.geometry.radiusMd; color: DS.Theme.colors.mauve
                                    Text { text: "Fade (Opacidade)"; anchors.centerIn: parent; color: DS.Theme.colors.crust; font.pixelSize: 12; font.family: DS.Theme.typography.familyBold } }
                            }
                        }

                        // ── STAGGER LIST ────────────────────────────────
                        SectionHeader { text: "AnimateList (stagger cascata)"; sectionColor: DS.Theme.colors.blue }

                        property var items: ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5"]
                        property bool staggerTrigger: true

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg
                            DS.Button {
                                text: "► Re-animar Lista"
                                variant: "primary"
                                color: "blue"
                                onClicked: demoColumn.staggerTrigger = !demoColumn.staggerTrigger
                            }
                        }

                        DS.AnimateList {
                            width: parent.width
                            model: demoColumn.items
                            duration: 300
                            perItemDelay: 80
                            offset: 20
                            fromScale: 0.8
                            trigger: demoColumn.staggerTrigger

                            delegate: Rectangle {
                                property var modelData
                                property int index
                                width: parent ? parent.width - DS.Theme.spacing.md : 0
                                height: 50
                                radius: DS.Theme.geometry.radiusSm
                                color: DS.Theme.colors.surface0

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: DS.Theme.spacing.md
                                    spacing: DS.Theme.spacing.sm
                                    DS.Badge { text: modelData; variant: "primary"; anchors.verticalCenter: parent.verticalCenter }
                                    Text {
                                        text: "delay " + (index * 80) + "ms"
                                        color: DS.Theme.colors.subtext0
                                        anchors.verticalCenter: parent.verticalCenter
                                        font.family: DS.Theme.typography.family
                                    }
                                }
                            }
                        }

                        // ── ANIMATED NUMBER ─────────────────────────────
                        SectionHeader { text: "AnimatedNumber (contador)"; sectionColor: DS.Theme.colors.peach }

                        property real counterValue: 0

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg

                            DS.Slider {
                                width: 300
                                minimum: 0; maximum: 10000; value: 0
                                onValueChanged: demoColumn.counterValue = value
                            }
                            Text { text: "→ Arraste"; color: DS.Theme.colors.subtext0 }
                        }

                        Rectangle {
                            width: parent.width - DS.Theme.spacing.md
                            height: 80
                            radius: DS.Theme.geometry.radiusMd
                            color: DS.Theme.colors.surface0

                            DS.AnimatedNumber {
                                anchors.centerIn: parent
                                value: demoColumn.counterValue
                                from: 0; duration: 600; easing: "OutQuint"
                                decimalPlaces: 0
                                prefix: "R$ "
                                separator: "."
                                font.pixelSize: DS.Theme.typography.sizeH1
                                font.family: DS.Theme.typography.familyBold
                                color: DS.Theme.colors.peach
                            }
                        }

                        // ── GLOW PULSE ──────────────────────────────────
                        SectionHeader { text: "GlowPulse (borda pulsante)"; sectionColor: DS.Theme.colors.mauve }

                        Rectangle {
                            width: 200; height: 80
                            radius: DS.Theme.geometry.radiusMd
                            color: DS.Theme.colors.base

                            DS.GlowPulse {
                                anchors.fill: parent
                                color: DS.Theme.colors.mauve
                                pulseMin: 0.3; pulseMax: 0.9; duration: 1200

                                Text {
                                    text: "✨ Brilhando!"
                                    anchors.centerIn: parent
                                    color: DS.Theme.colors.text
                                    font.family: DS.Theme.typography.familyBold
                                }
                            }
                        }

                        // ── PARTICLES ──────────────────────────────────
                        SectionHeader { text: "Particles (partículas)"; sectionColor: DS.Theme.colors.sky }

                        Rectangle {
                            width: parent.width - DS.Theme.spacing.md
                            height: 120
                            radius: DS.Theme.geometry.radiusMd
                            color: DS.Theme.colors.base
                            clip: true

                            Text {
                                text: "🌊 Partículas animadas ao fundo"
                                anchors.centerIn: parent
                                color: DS.Theme.colors.subtext0
                                z: 1
                                font.family: DS.Theme.typography.family
                            }

                            DS.Particles {
                                anchors.fill: parent
                                count: 20; color: DS.Theme.colors.sky
                                minSize: 2; maxSize: 5
                                duration: 4000; spread: 80
                                running: true
                            }
                        }

                        // ── BUTTON RIPPLE ──────────────────────────────
                        SectionHeader { text: "Button Ripple (onda no clique)"; sectionColor: DS.Theme.colors.pink }

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg
                            DS.Button { text: "Primary"; variant: "primary"; color: "pink" }
                            DS.Button { text: "Outline"; variant: "outline"; color: "pink" }
                            DS.Button { text: "Tonal"; variant: "tonal"; color: "pink" }
                        }

                        // ── SHAKE TEXTFIELD ────────────────────────────
                        SectionHeader { text: "TextField Shake (erro)"; sectionColor: DS.Theme.colors.red }

                        property string demoError: ""

                        Flow {
                            width: parent.width
                            spacing: DS.Theme.spacing.lg

                            DS.TextField {
                                id: shakeField
                                width: 300
                                placeholder: "Digite algo"
                                errorText: demoColumn.demoError
                            }

                            DS.Button {
                                text: "⚠ Erro"
                                variant: "danger"
                                onClicked: {
                                    shakeField.errorText = shakeField.errorText === "" ? "Campo inválido!" : ""
                                }
                            }

                            DS.Button {
                                text: "Limpar"
                                variant: "ghost"
                                onClicked: {
                                    shakeField.errorText = ""
                                    shakeField.text = ""
                                }
                            }
                        }

                        Item { width: 1; height: DS.Theme.spacing.xl }
                    }
                }
            }
        }

        // ── CONTROLS SIDEBAR ───────────────────────────────────────
        Rectangle {
            Layout.preferredWidth: 300
            Layout.fillHeight: true
            color: DS.Theme.colors.base

            Rectangle {
                anchors.left: parent.left
                width: 1; height: parent.height
                color: DS.Theme.colors.surface0
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: DS.Theme.spacing.xl
                spacing: DS.Theme.spacing.lg

                Text {
                    text: "Controles Globais"
                    font.family: DS.Theme.typography.familyBold
                    font.pixelSize: DS.Theme.typography.sizeLg
                    color: DS.Theme.colors.text
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    Column {
                        id: controlColumn
                        width: parent.width - DS.Theme.spacing.md
                        spacing: DS.Theme.spacing.xl

                        InfoCard {
                            title: "Duração Global"
                            DS.Slider { id: durationSlider; width: parent.width; minimum: 100; maximum: 1000; value: 400 }
                            Text { text: durationSlider.value.toFixed(0) + "ms"; color: DS.Theme.colors.subtext0 }
                        }

                        InfoCard {
                            title: "Offset / Distância"
                            DS.Slider { id: offsetSlider; width: parent.width; minimum: 5; maximum: 60; value: 25 }
                            Text { text: offsetSlider.value.toFixed(0) + "px"; color: DS.Theme.colors.subtext0 }
                        }

                        InfoCard {
                            title: "Easings Utilizados"
                            Repeater {
                                model: ["OutQuad → Fade", "OutCubic → Slide/Spin", "OutBack → Zoom/Scale", "OutBounce → Bounce", "InQuad/InCubic → Exit"]
                                delegate: Text {
                                    text: "• " + modelData
                                    color: DS.Theme.colors.subtext0
                                    font.family: DS.Theme.typography.family
                                    font.pixelSize: DS.Theme.typography.sizeSm
                                }
                            }
                        }

                        InfoCard {
                            title: "AnimateList API"
                            CodeBlock {
                                text: "model + delegate\nperItemDelay: xx ms\nduration: xx ms\noffset: xx\nfromScale: x.x"
                            }
                        }

                        InfoCard {
                            title: "AnimatedNumber API"
                            CodeBlock {
                                text: "value + from\nduration: xx ms\neasing: OutQuart\nprefix/suffix\ndecimalPlaces\nseparator"
                            }
                        }

                        InfoCard {
                            title: "AnimatedPresence API"
                            CodeBlock {
                                text: "shown: bool\nenterAnimation: fade|zoom|slide|spin|all\nexitAnimation: fade|zoom|slide|all\nenterDuration / exitDuration"
                            }
                        }

                        InfoCard {
                            title: "Scroll-Trigger (novo!)"
                            CodeBlock {
                                text: "FadeIn / ZoomIn / SlideUp\ntriggerOnVisibility: true\nvisibilityThreshold: 0.3"
                            }
                        }

                        InfoCard {
                            title: "Melhorias"
                            CodeBlock {
                                text: "✓ Button: ripple effect\n✓ TextField: shake em erro\n✓ FadeIn/ZoomIn/SlideUp:\n  triggerOnVisibility"
                            }
                        }
                    }
                }
            }
        }
    }

    // ── INLINE COMPONENTS ─────────────────────────────────────────

    component AnimDemoCard : Item {
        id: demoCard

        property string title: ""
        property bool trigger: true

        default property alias data: contentArea.data

        width: 130
        height: 170

        Column {
            anchors.fill: parent
            spacing: DS.Theme.spacing.xs

            Text {
                text: demoCard.title
                font.family: DS.Theme.typography.familyMedium
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.subtext0
            }

            Item {
                id: contentArea
                readonly property alias trigger: demoCard.trigger
                width: parent.width
                height: 130
            }
        }
    }

    component ColoredBox : Rectangle {
        property string label: ""
        property color textColor: DS.Theme.colors.crust

        width: 120
        height: 80
        radius: DS.Theme.geometry.radiusMd

        Text {
            text: parent.label
            anchors.centerIn: parent
            color: parent.textColor
            font.family: DS.Theme.typography.familyBold
        }
    }

    component SectionHeader : Item {
        id: sectionHdr

        property string text: ""
        property color sectionColor: DS.Theme.colors.mauve

        width: parent.width
        height: 40

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            Rectangle {
                width: 3
                height: parent.height - 10
                anchors.verticalCenter: parent.verticalCenter
                color: sectionHdr.sectionColor
                radius: 1.5
            }

            Text {
                text: sectionHdr.text
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeXl
                color: sectionHdr.sectionColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: DS.Theme.spacing.md
            }
        }
    }

    component InfoCard : Rectangle {
        id: infoCard

        property string title: ""

        width: parent ? parent.width : 260
        height: childrenRect.height + DS.Theme.spacing.lg * 2
        radius: DS.Theme.geometry.radiusSm
        color: DS.Theme.colors.surface0

        default property alias data: infoContent.data

        Column {
            id: infoContent
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: DS.Theme.spacing.md
            spacing: DS.Theme.spacing.sm

            Text {
                text: infoCard.title
                font.family: DS.Theme.typography.familyBold
                font.pixelSize: DS.Theme.typography.sizeSm
                color: DS.Theme.colors.text
            }
        }
    }

    component CodeBlock : Text {
        text: ""
        color: DS.Theme.colors.subtext0
        font.family: DS.Theme.typography.family
        font.pixelSize: DS.Theme.typography.sizeXs
        lineHeight: 1.5
    }
}
