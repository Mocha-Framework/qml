import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import ".." // Import the local MochaDS files


Window {
    id: window
    width: 950
    height: 900
    visible: true
    title: "Mocha-DS Design System Preview"
    color: Theme.colors.crust

    // Mock dataset for interactive pagination demo
    property var mockCoffees: [
        { name: "Espresso Mocha", origin: "Etiópia", roast: "Média" },
        { name: "Catppuccin Latte", origin: "Colômbia", roast: "Clara" },
        { name: "Macchiato Mauve", origin: "Brasil", roast: "Escura" },
        { name: "Rosewater Flat White", origin: "Quênia", roast: "Média" },
        { name: "Flamingo Affogato", origin: "Itália", roast: "Escura" },
        { name: "Lavender Cold Brew", origin: "Guatemala", roast: "Clara" },
        { name: "Sapphire Espresso", origin: "Costa Rica", roast: "Média" },
        { name: "Peach Pour Over", origin: "Panamá", roast: "Clara" },
        { name: "Maroon Mocha", origin: "Indonésia", roast: "Escura" },
        { name: "Red Cappuccino", origin: "Ruanda", roast: "Média" },
        { name: "Teal Cortado", origin: "Honduras", roast: "Média" },
        { name: "Green Matcha Latte", origin: "Japão", roast: "Clara" },
        { name: "Mauve Moka Pot", origin: "Iêmen", roast: "Escura" },
        { name: "Blue Velvet Latte", origin: "Vietnã", roast: "Média" },
        { name: "Caramel Cozy Macchiato", origin: "Peru", roast: "Média" },
        { name: "Pumpkin Spice Flamingo", origin: "México", roast: "Clara" },
        { name: "Irish Cream Crust", origin: "Irlanda", roast: "Escura" },
        { name: "Mocha Almond Milk Latte", origin: "Nicarágua", roast: "Média" },
        { name: "Hazelnut Hot Brew", origin: "El Salvador", roast: "Média" },
        { name: "Vanilla Bean Latte", origin: "Madagascar", roast: "Clara" },
        { name: "Double Shot Espresso", origin: "Colômbia", roast: "Escura" },
        { name: "Decaf Delight", origin: "Brasil", roast: "Média" },
        { name: "Organic Cozy Blend", origin: "Etiópia", roast: "Clara" }
    ]

    // Mock dataset for interactive Table demo
    property var mockEmployees: [
        { id: "EMP-1011", name: "Bernardo Dias", email: "bernardo@empresa.com", role: "DevOps Engineer", dept: "Infraestrutura", status: "Ativo", salary: "R$ 8.500" },
        { id: "EMP-1012", name: "Clara Mendes", email: "clara@empresa.com", role: "UX Designer", dept: "Produto", status: "Ativo", salary: "R$ 7.200" },
        { id: "EMP-1013", name: "Daniel Sousa", email: "daniel@empresa.com", role: "Frontend Developer", dept: "Engenharia", status: "Pendente", salary: "R$ 6.800" },
        { id: "EMP-1014", name: "Elisa Santos", email: "elisa@empresa.com", role: "Product Manager", dept: "Produto", status: "Ativo", salary: "R$ 11.500" },
        { id: "EMP-1015", name: "Alice Moreira", email: "alice@empresa.com", role: "Tech Lead", dept: "Engenharia", status: "Ativo", salary: "R$ 14.200" },
        { id: "EMP-1016", name: "Felipe Lima", email: "felipe@empresa.com", role: "Backend Developer", dept: "Engenharia", status: "Inativo", salary: "R$ 8.000" },
        { id: "EMP-1017", name: "Gabriela Costa", email: "gabriela@empresa.com", role: "HR Manager", dept: "Recursos Humanos", status: "Ativo", salary: "R$ 9.000" },
        { id: "EMP-1018", name: "Hugo Vieira", email: "hugo@empresa.com", role: "QA Analyst", dept: "Engenharia", status: "Pendente", salary: "R$ 6.000" },
        { id: "EMP-1019", name: "Isabela Rocha", email: "isabela@empresa.com", role: "Data Scientist", dept: "Inteligência Artificial", status: "Ativo", salary: "R$ 12.000" },
        { id: "EMP-1020", name: "João Silva", email: "joao@empresa.com", role: "Security Engineer", dept: "Infraestrutura", status: "Inativo", salary: "R$ 9.500" }
    ]

    // Main Scrollable Container
    ScrollView {
        id: mainScroll
        anchors.fill: parent
        clip: true
        contentHeight: contentColumn.height + Theme.spacing.xxl * 4

        Column {
            id: contentColumn
            width: mainScroll.width - Theme.spacing.xxl * 2
            x: Theme.spacing.xxl
            y: Theme.spacing.xxl
            spacing: Theme.spacing.xl

            // ==========================================
            // HEADER SECTION
            // ==========================================
            Row {
                spacing: Theme.spacing.md
                anchors.horizontalCenter: parent.horizontalCenter

                LucideIcon {
                    name: "coffee"
                    size: 40
                    color: Theme.colors.peach
                }

                Column {
                    spacing: Theme.spacing.xs
                    
                    Text {
                        text: "Mocha-DS"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeH1
                        color: Theme.colors.text
                        antialiasing: true
                    }
                    Text {
                        text: "Design System Cozy em QML • Focado em DX"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                        antialiasing: true
                    }
                }
            }

            // Launcher for Shell Demo
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacing.md

                Button {
                    text: "Abrir Shell Responsivo Completo"
                    icon: "layout"
                    variant: "primary"
                    size: "md"
                    onClicked: shellDemoWindow.visible = true
                }

                Button {
                    text: "Abrir Dashboard Integrado"
                    icon: "monitor"
                    variant: "outline"
                    size: "md"
                    onClicked: Qt.createQmlObject('import QtQuick 2.15; import QtQuick.Window; Window { width: 1280; height: 800; visible: true; Loader { anchors.fill: parent; source: "dashboard.qml" } }', window);
                }
            }

            // Theme Switcher Section (Mocha, Macchiato, Frappé, Latte)
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.spacing.md

                Text {
                    text: "Sabor do Tema:"
                    font.family: Theme.typography.familyBold
                    font.pixelSize: Theme.typography.sizeMd
                    color: Theme.colors.text
                    anchors.verticalCenter: parent.verticalCenter
                }

                ButtonGroup {
                    id: themeToggle
                    currentIndex: Theme.flavor === "mocha" ? 0 : (Theme.flavor === "macchiato" ? 1 : (Theme.flavor === "frappe" ? 2 : (Theme.flavor === "latte" ? 3 : (Theme.flavor === "vercel" ? 4 : 5))))
                    expand: false
                    ButtonGroupItem { text: "Mocha"; onClicked: Theme.flavor = "mocha" }
                    ButtonGroupItem { text: "Macchiato"; onClicked: Theme.flavor = "macchiato" }
                    ButtonGroupItem { text: "Frappé"; onClicked: Theme.flavor = "frappe" }
                    ButtonGroupItem { text: "Latte"; onClicked: Theme.flavor = "latte" }
                    ButtonGroupItem { text: "Vercel"; onClicked: Theme.flavor = "vercel" }
                    ButtonGroupItem { text: "Vercel Light"; onClicked: Theme.flavor = "vercel-light" }
                }
            }

            // ==========================================
            // SEGMENTED CONTROL / BUTTON GROUP SECTION
            // ==========================================
            Text {
                text: "Mocha Segmented Control (ButtonGroup)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: buttonGroupDemoColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: buttonGroupDemoColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    Text {
                        text: "Default Variant (surface1 pill, sliding indicator)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Row {
                        spacing: Theme.spacing.lg
                        
                        ButtonGroup {
                            currentIndex: 0
                            expand: false
                            ButtonGroupItem { iconName: "monitor"; text: "System" }
                            ButtonGroupItem { iconName: "sun"; text: "Light" }
                            ButtonGroupItem { iconName: "moon"; text: "Dark" }
                        }

                        ButtonGroup {
                            currentIndex: 1
                            expand: false
                            ButtonGroupItem { text: "1D" }
                            ButtonGroupItem { text: "1W" }
                            ButtonGroupItem { text: "1M" }
                            ButtonGroupItem { text: "1Y" }
                        }
                    }

                    Text {
                        text: "Primary Variant (mauve pill, crust text contrast)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Row {
                        spacing: Theme.spacing.lg
                        
                        ButtonGroup {
                            currentIndex: 0
                            variant: "primary"
                            expand: false
                            ButtonGroupItem { iconName: "home" }
                            ButtonGroupItem { iconName: "settings" }
                            ButtonGroupItem { iconName: "user" }
                        }

                        ButtonGroup {
                            currentIndex: 2
                            variant: "primary"
                            expand: false
                            ButtonGroupItem { text: "Monthly" }
                            ButtonGroupItem { text: "Quarterly" }
                            ButtonGroupItem { text: "Yearly"; badgeText: "-40%" }
                        }
                    }

                    Text {
                        text: "Expanded Mode (Auto-stretching to fill parent width)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    ButtonGroup {
                        width: parent.width
                        currentIndex: 0
                        expand: true
                        variant: "default"
                        ButtonGroupItem { text: "Inbox"; badgeText: "48" }
                        ButtonGroupItem { text: "Sent" }
                        ButtonGroupItem { text: "Trash"; iconName: "trash-2" }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // BUTTONS SECTION
            // ==========================================
            Text {
                text: "Mocha Buttons (Interativos)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: buttonColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: buttonColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    // Row 1: Variants
                    Text {
                        text: "Variantes da API"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Button { text: "Primary"; variant: "primary"; icon: "zap" }
                        Button { text: "Secondary"; variant: "secondary"; icon: "settings" }
                        Button { text: "Danger"; variant: "danger"; icon: "alert-triangle" }
                        Button { text: "Outline"; variant: "outline"; icon: "square" }
                        Button { text: "Tonal"; variant: "tonal"; icon: "layers" }
                        Button { text: "Ghost"; variant: "ghost"; icon: "ghost" }
                    }

                    // React-aligned API properties
                    Text {
                        text: "Variantes e Cores Alinhadas ao React (Filled, Tonal, Outline, Ghost, Shapes)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Button { text: "Filled Mauve (Pill)"; variant: "filled"; color: "mauve"; shape: "pill"; leftIcon: "zap" }
                        Button { text: "Tonal Green (Rounded)"; variant: "tonal"; color: "green"; shape: "rounded"; rightIcon: "check" }
                        Button { text: "Outline Peach (Square)"; variant: "outline"; color: "peach"; shape: "square" }
                        Button { text: "Ghost Flamingo (Loading)"; variant: "ghost"; color: "flamingo"; isLoading: true }
                    }

                    // Row 1b: Semantic Status Variants
                    Text {
                        text: "Variantes Semânticas (Catppuccin)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        // Solid fills
                        Button { text: "Success"; variant: "success"; icon: "check-circle" }
                        Button { text: "Warning"; variant: "warning"; icon: "alert-triangle" }
                        Button { text: "Info";    variant: "info";    icon: "info" }
                        Button { text: "Danger";  variant: "danger";  icon: "x-circle" }
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        // Tonal versions
                        Button { text: "Success Tonal"; variant: "tonal"; customColor: Theme.colors.success; icon: "check" }
                        Button { text: "Warning Tonal"; variant: "tonal"; customColor: Theme.colors.warning; icon: "alert-triangle" }
                        Button { text: "Info Tonal";    variant: "tonal"; customColor: Theme.colors.info;    icon: "info" }
                        Button { text: "Danger Tonal";  variant: "tonal"; customColor: Theme.colors.danger;  icon: "x" }
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        // Outline versions
                        Button { text: "Success Outline"; variant: "outline"; customColor: Theme.colors.success; icon: "check" }
                        Button { text: "Warning Outline"; variant: "outline"; customColor: Theme.colors.warning; icon: "alert-triangle" }
                        Button { text: "Info Outline";    variant: "outline"; customColor: Theme.colors.info;    icon: "info" }
                        Button { text: "Danger Outline";  variant: "outline"; customColor: Theme.colors.danger;  icon: "x" }
                    }

                    // Row 2: Sizes & Icons
                    Text {
                        text: "Tamanhos e Ícones (DX Centered)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Button { text: "Small Icon"; size: "sm"; icon: "plus" }
                        Button { text: "Medium Icon Right"; size: "md"; icon: "settings"; iconRight: true; variant: "outline" }
                        Button { text: "Large Tonal Icon"; size: "lg"; icon: "heart"; variant: "tonal" }
                        Button { text: "Ghost Icon"; icon: "trash-2"; variant: "ghost" }
                    }

                    // Row 3: States & Overrides
                    Text {
                        text: "Estados e Sobrescritas (Overrides)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Button { text: "Desabilitado"; disabled: true; icon: "lock" }
                        Button { text: "Carregando"; loading: true; variant: "tonal" }
                        Button { text: "Custom Teal"; customColor: Theme.colors.teal; customTextColor: Theme.colors.base; icon: "check" }
                        
                        // Custom Content slot injection
                        Button {
                            variant: "outline"
                            customRadius: Theme.geometry.radiusPill // override radius to pill shape
                            
                            Row {
                                spacing: Theme.spacing.sm
                                anchors.centerIn: parent

                                Rectangle {
                                    width: 10
                                    height: 10
                                    radius: 5
                                    color: Theme.colors.green
                                    anchors.verticalCenter: parent.verticalCenter
                                    
                                    // Glowing pulse animation
                                    SequentialAnimation on opacity {
                                        loops: Animation.Infinite
                                        NumberAnimation { from: 0.3; to: 1.0; duration: 800; easing.type: Easing.OutQuad }
                                        NumberAnimation { from: 1.0; to: 0.3; duration: 800; easing.type: Easing.OutQuad }
                                    }
                                }

                                Text {
                                    text: "Custom Content Slot"
                                    font.family: Theme.typography.familyBold
                                    font.pixelSize: Theme.typography.sizeSm
                                    color: Theme.colors.primary
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // STEPPER & STEPS SHOWCASE
            // ==========================================
            Text {
                text: "Stepper, Steps & StepsSlider (Fluxos)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: stepperDemoCol.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: stepperDemoCol
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Theme.spacing.lg
                    spacing: Theme.spacing.xl

                    Text {
                        text: "1. Stepper Horizontal (default, icon, dots)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    // Horizontal Stepper
                    Stepper {
                        id: stepperDemo
                        width: parent.width
                        currentStep: 1
                        steps: [
                            { label: "Perfil", description: "Dados Pessoais", icon: "user" },
                            { label: "Endereço", description: "Local de Entrega", icon: "map-pin" },
                            { label: "Pagamento", description: "Cartão / Pix", icon: "credit-card" }
                        ]
                    }

                    Row {
                        spacing: Theme.spacing.md
                        anchors.horizontalCenter: parent.horizontalCenter

                        Button {
                            text: "Anterior"
                            size: "sm"
                            variant: "outline"
                            disabled: stepperDemo.currentStep === 0
                            onClicked: stepperDemo.currentStep--
                        }
                        Button {
                            text: "Próximo"
                            size: "sm"
                            disabled: stepperDemo.currentStep === 2
                            onClicked: stepperDemo.currentStep++
                        }
                    }

                    Text {
                        text: "2. Steps Timeline & Carousel Integrados com StepsSlider"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    // Steps Timeline
                    Steps {
                        id: stepsTimelineDemo
                        width: parent.width
                        stepsCount: 3
                        labels: ["Identificação", "Confirmação", "Finalizado"]
                        currentStep: 0
                        onChangeStep: function(step) {
                            stepsSliderDemo.currentStep = step
                            stepsCarouselDemo.currentStep = step
                        }
                    }

                    // StepsSlider holding 3 slides
                    StepsSlider {
                        id: stepsSliderDemo
                        width: parent.width
                        height: 100
                        currentStep: 0

                        Rectangle {
                            color: Theme.colors.mantle
                            radius: Theme.geometry.radiusSm
                            border.color: Theme.colors.surface0
                            border.width: Theme.geometry.borderSm

                            Text {
                                text: "Slide 1: Identificação do Usuário\nInsira seus dados para prosseguir."
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.text
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Rectangle {
                            color: Theme.colors.mantle
                            radius: Theme.geometry.radiusSm
                            border.color: Theme.colors.surface0
                            border.width: Theme.geometry.borderSm

                            Text {
                                text: "Slide 2: Confirmação de Dados\nPor favor revise as informações do lote."
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.text
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        Rectangle {
                            color: Theme.colors.mantle
                            radius: Theme.geometry.radiusSm
                            border.color: Theme.colors.surface0
                            border.width: Theme.geometry.borderSm

                            Text {
                                text: "Slide 3: Processo Finalizado!\nTodos os itens foram processados."
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.green
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }

                    // Steps Carousel indicators
                    Steps {
                        id: stepsCarouselDemo
                        variant: "carousel"
                        stepsCount: 3
                        currentStep: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        onChangeStep: function(step) {
                            stepsSliderDemo.currentStep = step
                            stepsTimelineDemo.currentStep = step
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // TYPOGRAPHY SECTION
            // ==========================================
            Text {
                text: "Outfit Typography"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: typoColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: typoColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.md

                    Text {
                        text: "H1: Grande Título (32px Bold)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeH1
                        color: Theme.colors.text
                        antialiasing: true
                    }
                    Text {
                        text: "H2: Subtítulo de Seção (24px Medium)"
                        font.family: Theme.typography.familyMedium
                        font.pixelSize: Theme.typography.sizeH2
                        color: Theme.colors.subtext1
                        antialiasing: true
                    }
                    Text {
                        text: "Body Large: Texto de Destaque (16px Regular)"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeLg
                        color: Theme.colors.subtext0
                        antialiasing: true
                    }
                    Text {
                        text: "Body Medium: Texto Padrão (14px Regular)"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                        antialiasing: true
                    }
                    Text {
                        text: "Caption: Detalhes e Rótulos Pequenos (12px Regular)"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.overlay1
                        antialiasing: true
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // COLOR PALETTE SECTION
            // ==========================================
            Text {
                text: "Catppuccin Mocha Colors"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Grid {
                width: parent.width
                columns: 4
                spacing: Theme.spacing.md

                // Helper component for Color Cards
                Component {
                    id: colorCardComponent
                    Rectangle {
                        id: cardRoot
                        anchors.fill: parent
                        color: cardRoot.cardColor
                        radius: Theme.geometry.radiusSm
                        border.color: Theme.colors.surface0
                        border.width: Theme.geometry.borderSm

                        property color cardColor: parent && parent.cardColor !== undefined ? parent.cardColor : "white"
                        property string cardName: parent && parent.cardName !== undefined ? parent.cardName : ""
                        property string hexString: parent && parent.hexString !== undefined ? parent.hexString : ""
                        property color textColor: parent && parent.textColor !== undefined ? parent.textColor : Theme.colors.text

                        Column {
                            anchors.centerIn: parent
                            spacing: Theme.spacing.xs

                            Text {
                                text: cardRoot.cardName
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeSm
                                color: cardRoot.textColor
                                anchors.horizontalCenter: parent.horizontalCenter
                                antialiasing: true
                            }
                            Text {
                                text: cardRoot.hexString
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeXs
                                color: cardRoot.textColor
                                opacity: 0.8
                                anchors.horizontalCenter: parent.horizontalCenter
                                antialiasing: true
                            }
                        }
                    }
                }

                // Add colors to Grid
                Loader { width: (parent.width - Theme.spacing.md * 3) / 4; height: 70; sourceComponent: colorCardComponent; property color cardColor: Theme.colors.mauve; property string cardName: "Mauve (Primary)"; property string hexString: "#cba6f7"; property color textColor: Theme.colors.base }
                Loader { width: (parent.width - Theme.spacing.md * 3) / 4; height: 70; sourceComponent: colorCardComponent; property color cardColor: Theme.colors.blue; property string cardName: "Blue (Secondary)"; property string hexString: "#89b4fa"; property color textColor: Theme.colors.base }
                Loader { width: (parent.width - Theme.spacing.md * 3) / 4; height: 70; sourceComponent: colorCardComponent; property color cardColor: Theme.colors.green; property string cardName: "Green (Success)"; property string hexString: "#a6e3a1"; property color textColor: Theme.colors.base }
                Loader { width: (parent.width - Theme.spacing.md * 3) / 4; height: 70; sourceComponent: colorCardComponent; property color cardColor: Theme.colors.red; property string cardName: "Red (Danger)"; property string hexString: "#f38ba8"; property color textColor: Theme.colors.base }
                Loader { width: (parent.width - Theme.spacing.md * 3) / 4; height: 70; sourceComponent: colorCardComponent; property color cardColor: Theme.colors.base; property string cardName: "Base"; property string hexString: "#1e1e2e"; property color textColor: Theme.colors.text }
                Loader { width: (parent.width - Theme.spacing.md * 3) / 4; height: 70; sourceComponent: colorCardComponent; property color cardColor: Theme.colors.mantle; property string cardName: "Mantle"; property string hexString: "#181825"; property color textColor: Theme.colors.text }
                Loader { width: (parent.width - Theme.spacing.md * 3) / 4; height: 70; sourceComponent: colorCardComponent; property color cardColor: Theme.colors.surface0; property string cardName: "Surface 0"; property string hexString: "#313244"; property color textColor: Theme.colors.text }
                Loader { width: (parent.width - Theme.spacing.md * 3) / 4; height: 70; sourceComponent: colorCardComponent; property color cardColor: Theme.colors.surface1; property string cardName: "Surface 1"; property string hexString: "#45475a"; property color textColor: Theme.colors.text }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // ICONS SECTION (Interactive)
            // ==========================================
            Text {
                text: "Lucide Icons (Interativos e Espessura Regulável)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: iconSectionColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: iconSectionColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    // Active state to bind all icons
                    property real selectedStrokeWidth: 2.0

                    // Sub-section 1: Stroke Width Showcase
                    Text {
                        text: "Ajuste de Espessura do Traço (strokeWidth)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Row {
                        spacing: Theme.spacing.xl
                        anchors.horizontalCenter: parent.horizontalCenter

                        Repeater {
                            model: [
                                { val: 1.0, label: "Fino (1.0)" },
                                { val: 1.5, label: "Suave (1.5)" },
                                { val: 2.0, label: "Médio (2.0)" },
                                { val: 3.0, label: "Grosso (3.0)" }
                            ]

                            Rectangle {
                                width: 85
                                height: 85
                                color: iconSectionColumn.selectedStrokeWidth === modelData.val ? Theme.colors.surface0 : "transparent"
                                radius: Theme.geometry.radiusMd
                                border.color: iconSectionColumn.selectedStrokeWidth === modelData.val ? Theme.colors.mauve : "transparent"
                                border.width: Theme.geometry.borderSm
                                
                                scale: strokeMouseArea.containsMouse ? 1.05 : 1.0
                                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                Behavior on color { ColorAnimation { duration: 150 } }

                                Column {
                                    anchors.centerIn: parent
                                    spacing: Theme.spacing.xs
                                    
                                    LucideIcon {
                                        name: "settings"
                                        size: 36
                                        color: iconSectionColumn.selectedStrokeWidth === modelData.val ? Theme.colors.mauve : Theme.colors.peach
                                        strokeWidth: modelData.val
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }

                                    Text {
                                        text: modelData.label
                                        font.family: Theme.typography.familyMedium
                                        font.pixelSize: Theme.typography.sizeSm
                                        color: iconSectionColumn.selectedStrokeWidth === modelData.val ? Theme.colors.text : Theme.colors.subtext1
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                }

                                MouseArea {
                                    id: strokeMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        iconSectionColumn.selectedStrokeWidth = modelData.val;
                                    }
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.colors.surface0
                    }

                    // Sub-section 2: Grid of Icons
                    Text {
                        text: "Grade de Ícones (88 exemplos disponíveis no Mocha-DS - Use o Scroll)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Rectangle {
                        width: parent.width
                        height: 320
                        color: Theme.colors.mantle
                        radius: Theme.geometry.radiusMd
                        border.color: Theme.colors.surface0
                        border.width: Theme.geometry.borderSm
                        clip: true

                        Flickable {
                            id: iconFlickable
                            anchors.fill: parent
                            anchors.margins: Theme.spacing.md
                            contentWidth: width - Theme.spacing.md * 2
                            contentHeight: iconGrid.implicitHeight
                            clip: true

                            Grid {
                                id: iconGrid
                                width: parent.width
                                columns: 8
                                spacing: Theme.spacing.lg

                                Repeater {
                                    model: [
                                        // Basic & Navigation
                                        "home", "settings", "user", "bell", "heart", "check-circle", "help-circle", "trash-2",
                                        "search", "edit", "share-2", "download", "plus", "minus", "lock", "unlock",
                                        "calendar", "clock", "mail", "phone", "coffee", "info", "alert-triangle", "menu",
                                        "arrow-right", "arrow-left", "arrow-up", "arrow-down", "chevron-right", "chevron-left", "chevron-up", "chevron-down",
                                        // File & Folder
                                        "file", "file-text", "folder", "folder-open", "copy", "clipboard", "archive", "save",
                                        // Media & Devices
                                        "camera", "image", "play", "pause", "volume-2", "volume-x", "music", "film",
                                        "monitor", "laptop", "tablet", "smartphone", "tv", "speaker", "wifi", "bluetooth",
                                        // Social & Actions
                                        "thumbs-up", "thumbs-down", "send", "message-square", "users", "user-plus", "eye", "eye-off",
                                        "activity", "alert-circle", "bookmark", "globe", "gift", "shopping-cart", "credit-card", "database",
                                        // Business, Tools & Tech
                                        "briefcase", "compass", "map-pin", "tag", "key", "link", "shield", "zap",
                                        "pencil", "wrench", "hammer", "scissors", "terminal", "code", "file-code", "cpu",
                                        "printer", "refresh-cw", "cloud", "cloud-lightning"
                                    ]

                                    Rectangle {
                                        width: (parent.width - Theme.spacing.lg * 7) / 8
                                        height: width
                                        color: mouseArea.containsMouse ? Theme.colors.surface1 : "transparent"
                                        radius: Theme.geometry.radiusMd
                                        scale: mouseArea.containsMouse ? 1.1 : 1.0
                                        
                                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                        Behavior on color { ColorAnimation { duration: 150 } }

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: Theme.spacing.xs

                                            LucideIcon {
                                                name: modelData
                                                size: 28
                                                color: mouseArea.containsMouse ? Theme.colors.mauve : Theme.colors.subtext0
                                                strokeWidth: iconSectionColumn.selectedStrokeWidth
                                                anchors.horizontalCenter: parent.horizontalCenter
                                            }

                                            Text {
                                                text: modelData
                                                font.family: Theme.typography.family
                                                font.pixelSize: Theme.typography.sizeXs
                                                color: mouseArea.containsMouse ? Theme.colors.text : Theme.colors.overlay1
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                elide: Text.ElideRight
                                                width: parent.parent.width - Theme.spacing.xs * 2
                                                horizontalAlignment: Text.AlignHCenter
                                            }
                                        }

                                        MouseArea {
                                            id: mouseArea
                                            anchors.fill: parent
                                            hoverEnabled: true
                                        }
                                    }
                                }
                            }
                        }

                        // Scrollbar indicator
                        Rectangle {
                            id: iconScrollbarTrack
                            anchors.right: parent.right
                            anchors.rightMargin: Theme.spacing.xs
                            anchors.top: parent.top
                            anchors.topMargin: Theme.spacing.sm
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: Theme.spacing.sm
                            width: 4
                            radius: 2
                            color: Theme.colors.surface0
                            opacity: iconFlickable.visibleArea.heightRatio < 1.0 ? 0.3 : 0.0

                            Behavior on opacity { NumberAnimation { duration: 150 } }

                            Rectangle {
                                width: parent.width
                                height: Math.max(20, parent.height * iconFlickable.visibleArea.heightRatio)
                                y: parent.height * iconFlickable.visibleArea.yPosition
                                radius: parent.radius
                                color: Theme.colors.primary
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // CARDS & TILES SECTION
            // ==========================================
            Text {
                text: "Mocha Cards & Tiles (Contêineres e Listas)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            CozyGrid {
                width: parent.width
                gap: 4
                mobile: false

                // Column 1: Card Showcase
                CozyGridCol {
                    span: 6
                    md: 6
                    sm: 12

                    Column {
                        width: parent.width
                        spacing: Theme.spacing.lg

                        Text {
                            text: "Mocha Cards (Vários Estilos)"
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext0
                        }

                        Card {
                            width: parent.width
                            title: "Card Default"
                            subtitle: "Organização flat padrão"
                            icon: "info"
                            
                            Text {
                                text: "Este é um card padrão com preenchimento da cor de base do Mocha. Ele exibe um cabeçalho simples com ícone e título."
                                width: parent.width
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.subtext0
                                wrapMode: Text.WordWrap
                            }
                        }

                        Card {
                            width: parent.width
                            title: "Card Accent (Highlight à Esquerda)"
                            subtitle: "Estilo cozy em destaque"
                            variant: "accent"
                            accentPosition: "left"
                            
                            Text {
                                text: "Este card possui uma linha de destaque reativa à esquerda e fundo base. Excelente para cards de status ou blocos importantes."
                                width: parent.width
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.subtext0
                                wrapMode: Text.WordWrap
                            }
                        }

                        Card {
                            width: parent.width
                            title: "Card Tonal com Rodapé"
                            subtitle: "Fundo surface0 e botões"
                            variant: "tonal"
                            
                            Text {
                                text: "Os cards suportam injeção de rodapé (footer) e cabeçalhos customizados. Aqui injetamos uma linha de botões de ação."
                                width: parent.width
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.subtext0
                                wrapMode: Text.WordWrap
                            }

                            footer: Row {
                                spacing: Theme.spacing.md
                                anchors.right: parent.right

                                Button {
                                    text: "Ignorar"
                                    variant: "ghost"
                                    size: "sm"
                                }
                                Button {
                                    text: "Confirmar"
                                    variant: "primary"
                                    size: "sm"
                                    icon: "check"
                                }
                            }
                        }
                    }
                }

                // Column 2: Tile Showcase
                CozyGridCol {
                    span: 6
                    md: 6
                    sm: 12

                    Column {
                        width: parent.width
                        spacing: Theme.spacing.lg

                        Text {
                            text: "Mocha Tiles (Lista / Controles Compactos)"
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext0
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacing.md

                            Tile {
                                width: parent.width
                                title: "Configurações do Perfil"
                                description: "Gerenciar nome, e-mail e avatar"
                                icon: "user"
                                variant: "default"
                                onClicked: console.log("Tile Perfil clicado!")
                            }

                            Tile {
                                width: parent.width
                                title: "Segurança e Privacidade"
                                description: "Autenticação em duas etapas"
                                icon: "lock"
                                variant: "tonal"
                                onClicked: console.log("Tile Segurança clicado!")
                            }

                            Tile {
                                width: parent.width
                                title: "Notificações do Sistema"
                                description: "Sons e avisos push"
                                icon: "bell"
                                variant: "accent"
                                onClicked: console.log("Tile Notificações clicado!")
                            }

                            Tile {
                                width: parent.width
                                title: "Modo de Desenvolvedor"
                                description: "Acesso a ferramentas avançadas de depuração"
                                icon: "code"
                                variant: "outline"
                                
                                // Custom right control inside dedicated slot (prevents layout loops)
                                rightContent: [
                                    Row {
                                        spacing: Theme.spacing.xs
                                        
                                        Rectangle {
                                            width: 10; height: 10; radius: 5
                                            color: Theme.colors.green
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                        
                                        Text {
                                            text: "Ativo"
                                            font.family: Theme.typography.familyBold
                                            font.pixelSize: Theme.typography.sizeSm
                                            color: Theme.colors.green
                                            anchors.verticalCenter: parent.verticalCenter
                                        }
                                    }
                                ]
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // FORMS & INPUTS SECTION
            // ==========================================
            Text {
                text: "Mocha Forms & Inputs (Campos e Formulários Dinâmicos)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: formsColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: formsColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.xl

                    // Sub-section 1: Individual Controls
                    Column {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Text {
                            text: "Controles Individuais (TextField, Checkbox, Select)"
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext0
                        }

                        Grid {
                            width: parent.width
                            columns: 2
                            spacing: Theme.spacing.lg

                            // Text Fields Row
                            Column {
                                spacing: Theme.spacing.sm
                                width: (parent.width - Theme.spacing.lg) / 2

                                Text { text: "Campos de Texto"; font.family: Theme.typography.familyBold; font.pixelSize: Theme.typography.sizeSm; color: Theme.colors.overlay1 }
                                TextField { placeholder: "Campo padrão"; width: parent.width }
                                TextField { placeholder: "Senha"; type: "password"; iconLeft: "lock"; width: parent.width }
                                TextField { placeholder: "Com ícone de ação"; iconLeft: "search"; iconRight: "arrow-right"; width: parent.width }
                            }

                            // Selection Controls Row
                            Column {
                                spacing: Theme.spacing.sm
                                width: (parent.width - Theme.spacing.lg) / 2

                                Text { text: "Seleções e Validações"; font.family: Theme.typography.familyBold; font.pixelSize: Theme.typography.sizeSm; color: Theme.colors.overlay1 }
                                Select { 
                                    placeholder: "Selecione o idioma..."
                                    options: [
                                        { value: "pt", label: "Português (Brasil)" },
                                        { value: "en", label: "Inglês (EUA)" },
                                        { value: "es", label: "Espanhol" }
                                    ]
                                    width: parent.width 
                                }

                                Text { text: "Advanced Select (Multi-seleção & Busca)"; font.family: Theme.typography.familyBold; font.pixelSize: Theme.typography.sizeXs; color: Theme.colors.overlay1 }
                                AdvancedSelect {
                                    placeholder: "Escolha os ingredientes..."
                                    options: [
                                        { value: "coffee", label: "Café Espresso" },
                                        { value: "milk", label: "Leite Vaporizado" },
                                        { value: "chocolate", label: "Cacau em Pó" },
                                        { value: "caramel", label: "Xarope de Caramelo" },
                                        { value: "cinnamon", label: "Canela Salpicada" }
                                    ]
                                    width: parent.width
                                    multiple: true
                                    searchable: true
                                }
                                FormField {
                                    label: "E-mail Corporativo"
                                    required: true
                                    status: "error"
                                    errorMessage: "Este endereço de e-mail não pertence a um domínio válido."
                                    width: parent.width
                                    TextField {
                                        text: "usuario@invalido"
                                        iconLeft: "mail"
                                    }
                                }
                            }
                        }

                        Flow {
                            width: parent.width
                            spacing: Theme.spacing.xl

                            Checkbox { label: "Checkbox Padrão"; checked: false }
                            Checkbox { label: "Checkbox Selecionado"; checked: true }
                            Checkbox { label: "Checkbox Desabilitado"; disabled: true }
                        }
                    }

                    // Divider
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.colors.surface0
                    }

                    // Sub-section 2: Dynamic Form Demo
                    Column {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Text {
                            text: "Formulário Dinâmico Orientado a Esquema (Live JSON)"
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext0
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacing.xl

                            // Form Column
                            Column {
                                width: (parent.width - Theme.spacing.xl) * 0.58
                                spacing: Theme.spacing.lg

                                DynamicForm {
                                    id: liveForm
                                    width: parent.width
                                    schema: [
                                        { name: "fullname", type: "text", label: "Nome Completo", placeholder: "Insira seu nome", required: true, minLength: 3, iconLeft: "user" },
                                        { name: "email", type: "email", label: "Endereço de E-mail", placeholder: "seu@email.com", required: true, iconLeft: "mail" },
                                        { name: "role", type: "select", label: "Cargo na Empresa", placeholder: "Selecione seu cargo...", required: true, options: [
                                            { value: "dev", label: "Desenvolvedor" },
                                            { value: "design", label: "Product Designer" },
                                            { value: "pm", label: "Product Manager" }
                                        ]},
                                        { name: "terms", type: "checkbox", checkboxLabel: "Li e aceito as políticas de privacidade", required: true, requiredMessage: "Você precisa aceitar os termos de privacidade." }
                                    ]
                                }

                                Row {
                                    spacing: Theme.spacing.md

                                    Button {
                                        text: "Validar e Enviar"
                                        variant: "primary"
                                        icon: "check"
                                        onClicked: {
                                            var isValid = liveForm.validate();
                                            if (isValid) {
                                                resultPanel.submittedData = JSON.stringify(liveForm.getValues(), null, 2);
                                                resultPanel.hasError = false;
                                            } else {
                                                resultPanel.submittedData = "Erro: O formulário contém campos inválidos.";
                                                resultPanel.hasError = true;
                                            }
                                        }
                                    }

                                    Button {
                                        text: "Limpar Campos"
                                        variant: "outline"
                                        icon: "rotate-ccw"
                                        onClicked: {
                                            liveForm.clear();
                                            resultPanel.submittedData = "";
                                            resultPanel.hasError = false;
                                        }
                                    }
                                }
                            }

                            // Result Panel Column
                            Column {
                                width: (parent.width - Theme.spacing.xl) * 0.40
                                spacing: Theme.spacing.sm

                                Text {
                                    text: "Dados de Saída (JSON)"
                                    font.family: Theme.typography.familyBold
                                    font.pixelSize: Theme.typography.sizeSm
                                    color: Theme.colors.overlay1
                                }

                                Rectangle {
                                    id: resultPanel
                                    width: parent.width
                                    height: Math.max(260, liveForm.height)
                                    color: Theme.colors.mantle
                                    radius: Theme.geometry.radiusMd
                                    border.color: hasError ? Theme.colors.red : (submittedData !== "" ? Theme.colors.green : Theme.colors.surface1)
                                    border.width: Theme.geometry.borderSm

                                    property string submittedData: ""
                                    property bool hasError: false

                                    Text {
                                        text: resultPanel.submittedData !== "" ? resultPanel.submittedData : "Preencha o formulário e clique em Validar e Enviar..."
                                        font.family: "Courier New"
                                        font.pixelSize: Theme.typography.sizeSm
                                        color: resultPanel.hasError ? Theme.colors.red : (resultPanel.submittedData !== "" ? Theme.colors.green : Theme.colors.overlay1)
                                        anchors.fill: parent
                                        anchors.margins: Theme.spacing.md
                                        wrapMode: Text.WordWrap
                                        antialiasing: true
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // TABLE & PAGINATION SECTION
            // ==========================================
            Text {
                text: "Mocha Table & Pagination (Tabela Interativa Cozy)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                id: tableContainer
                width: parent.width
                height: 520
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: tableColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.centerIn: parent
                    spacing: Theme.spacing.md

                    Text {
                        text: "Lista de Colaboradores (Exemplo Alice Moreira)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Table {
                        id: employeeTable
                        width: parent.width
                        height: 440
                        pageSize: 5
                        selectable: true
                        
                        columns: [
                            { name: "id", label: "ID", width: 90, sortable: true, type: "bold" },
                            { name: "name", label: "Nome", width: 140, sortable: true, type: "text" },
                            { name: "email", label: "E-mail", width: 180, sortable: true, type: "subtext" },
                            { name: "role", label: "Cargo", width: 130, sortable: true, type: "text" },
                            { name: "dept", label: "Departamento", width: 120, sortable: true, type: "text" },
                            { name: "status", label: "Status", width: 100, sortable: true, type: "badge" },
                            { name: "salary", label: "Salário", width: 100, sortable: true, type: "text" }
                        ]
                        
                        rows: window.mockEmployees

                        onEditSelected: {
                            console.log("Editar selecionados:", JSON.stringify(selectedRows));
                        }
                        onDownloadSelected: {
                            console.log("Download selecionados:", JSON.stringify(selectedRows));
                        }
                        onDeleteSelected: {
                            console.log("Deletar selecionados:", JSON.stringify(selectedRows));
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // TOAST & NOTIFICATIONS SECTION
            // ==========================================
            Text {
                text: "Mocha Toast Notifications (Alertas e Mensagens)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: toastDemoColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm
                z: 10

                Column {
                    id: toastDemoColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    Text {
                        text: "Disparar Alertas com Temporizador Cozy e Pause on Hover"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Row {
                        spacing: Theme.spacing.md
                        z: 100
                        
                        Text {
                            text: "Posicionamento do Stack:"
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeSm
                            color: Theme.colors.overlay1
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Select {
                            id: positionSelect
                            placeholder: "Posição do Toast..."
                            options: [
                                { value: "top-right", label: "Superior Direito (top-right)" },
                                { value: "top-left", label: "Superior Esquerdo (top-left)" },
                                { value: "bottom-right", label: "Inferior Direito (bottom-right)" },
                                { value: "bottom-left", label: "Inferior Esquerdo (bottom-left)" }
                            ]
                            selectedValue: "top-right"
                            selectedLabel: "Superior Direito (top-right)"
                            width: 280
                            onValueChanged: {
                                toastManager.position = val;
                            }
                        }
                    }

                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Button {
                            text: "Toast Sucesso"
                            variant: "primary"
                            onClicked: {
                                toastManager.success("A operação foi concluída com êxito! Todos os dados foram gravados no banco.", "Sucesso");
                            }
                        }

                        Button {
                            text: "Toast Erro"
                            variant: "danger"
                            onClicked: {
                                toastManager.error("Falha ao salvar as configurações. Verifique os campos e tente novamente.", "Erro");
                            }
                        }

                        Button {
                            text: "Toast Aviso"
                            variant: "secondary"
                            onClicked: {
                                toastManager.warning("Atenção! Sua chave de API expira em breve. Por favor, renove-a.", "Aviso");
                            }
                        }

                        Button {
                            text: "Toast Informação"
                            variant: "tonal"
                            onClicked: {
                                toastManager.info("Uma atualização de sistema está agendada para hoje às 23:00.", "Informação");
                            }
                        }

                        Button {
                            text: "Toast Rápido (1.5s)"
                            variant: "outline"
                            onClicked: {
                                toastManager.show("Alerta rápido!", "info", "Aviso Rápido", 1500);
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // TABS & ACCORDION SECTION
            // ==========================================
            Text {
                text: "Mocha Tabs & Accordions (Navegação e Organização)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Grid {
                width: parent.width
                columns: 2
                spacing: Theme.spacing.xl

                // Column 1: Tabs Showcase
                Column {
                    width: (parent.width - Theme.spacing.xl) / 2
                    spacing: Theme.spacing.lg

                    Text {
                        text: "Seletor de Abas (Line & Pill)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Tabs {
                        id: demoTabsLine
                        width: parent.width
                        model: ["Painel", "Configurações", "Mensagens"]
                        variant: "line"
                    }

                    Tabs {
                        id: demoTabsPill
                        width: parent.width
                        model: [
                            { id: "home", label: "Início", icon: "home" },
                            { id: "users", label: "Usuários", icon: "users" },
                            { id: "security", label: "Segurança", icon: "shield" }
                        ]
                        variant: "pill"
                    }

                    Text {
                        text: "Seletor de Abas (Segmented & Card)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Tabs {
                        id: demoTabsSegmented
                        width: parent.width
                        model: ["Semanal", "Mensal", "Anual"]
                        variant: "segmented"
                    }

                    Tabs {
                        id: demoTabsCard
                        width: parent.width
                        model: [
                            { id: "opt1", label: "Geral", icon: "settings" },
                            { id: "opt2", label: "Avançado", icon: "cpu" }
                        ]
                        variant: "card"
                    }

                    // A Card showing the active tab content
                    Card {
                        width: parent.width
                        title: "Conteúdo da Aba Ativa"
                        subtitle: "Index Selecionado: " + demoTabsPill.currentIndex
                        icon: "info"

                        Text {
                            text: {
                                if (demoTabsPill.currentIndex === 0) return "Visualizando painel inicial com estatísticas gerais do sistema."
                                if (demoTabsPill.currentIndex === 1) return "Gerenciamento de contas de usuários, permissões e perfis de acesso."
                                return "Configurações de segurança: firewalls, chaves de criptografia e certificados SSL."
                            }
                            width: parent.width - Theme.spacing.lg * 2
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext0
                            wrapMode: Text.WordWrap
                            antialiasing: true
                        }
                    }
                }

                // Column 2: Accordions Showcase
                Column {
                    width: (parent.width - Theme.spacing.xl) / 2
                    spacing: Theme.spacing.lg

                    Text {
                        text: "Seções Colapsáveis (Accordion)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Accordion {
                        width: parent.width
                        title: "Informações Básicas (Default)"
                        icon: "user"
                        variant: "default"
                        expanded: true

                        Column {
                            width: parent.width
                            spacing: Theme.spacing.sm
                            Text {
                                text: "Nome Completo: Café Mocha Catppuccin\nCargo: Developer Experience Engineer"
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeSm
                                color: Theme.colors.subtext1
                                antialiasing: true
                            }
                        }
                    }

                    Accordion {
                        width: parent.width
                        title: "Configurações Avançadas (Outline)"
                        icon: "settings"
                        variant: "outline"

                        Column {
                            width: parent.width
                            spacing: Theme.spacing.md

                            Checkbox {
                                label: "Habilitar Modo de Depuração"
                                checked: true
                            }
                            Checkbox {
                                label: "Enviar logs de telemetria anonimizados"
                            }
                        }
                    }

                    Accordion {
                        width: parent.width
                        title: "Central de Ajuda (Tonal)"
                        icon: "help-circle"
                        variant: "tonal"

                        Column {
                            width: parent.width
                            spacing: Theme.spacing.sm
                            Text {
                                text: "Para obter ajuda adicional com o Mocha-DS, acesse o canal de slack da equipe de design system ou leia os guias de Developer Experience."
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeSm
                                color: Theme.colors.subtext0
                                wrapMode: Text.WordWrap
                                width: parent.width
                                antialiasing: true
                            }
                            Button {
                                text: "Abrir Central de Suporte"
                                size: "sm"
                                variant: "outline"
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // OVERLAYS SECTION (Modals & Drawers)
            // ==========================================
            Text {
                text: "Modals & Drawers (Portal Overlay Stacking)"

                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: overlayColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: overlayColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    // Row 1: Modals
                    Text {
                        text: "Modais Cozy (Escala + Opacidade)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Button {
                            text: "Abrir Modal Pequeno"
                            variant: "outline"
                            onClicked: {
                                modalDemo.title = "Aviso Importante"
                                modalDemo.subtitle = "Confirmação de ação sensível"
                                modalDemo.size = "sm"
                                modalDemo.open = true
                            }
                        }
                        Button {
                            text: "Abrir Modal Médio"
                            variant: "primary"
                            onClicked: {
                                modalDemo.title = "Editar Perfil do Usuário"
                                modalDemo.subtitle = "Atualize suas informações cadastrais"
                                modalDemo.size = "md"
                                modalDemo.open = true
                            }
                        }
                        Button {
                            text: "Abrir Modal Grande (Scrollable)"
                            variant: "tonal"
                            onClicked: {
                                modalScrollDemo.open = true
                            }
                        }
                    }

                    // Row 2: Drawers
                    Text {
                        text: "Gavetas / Sidebars (Slide por Direção)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }
                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Button {
                            text: "Drawer Direita"
                            variant: "outline"
                            onClicked: {
                                drawerDemo.position = "right"
                                drawerDemo.title = "Menu Lateral Direito"
                                drawerDemo.open = true
                            }
                        }
                        Button {
                            text: "Drawer Esquerda"
                            variant: "outline"
                            onClicked: {
                                drawerDemo.position = "left"
                                drawerDemo.title = "Menu Lateral Esquerdo"
                                drawerDemo.open = true
                            }
                        }
                        Button {
                            text: "Drawer Superior"
                            variant: "outline"
                            onClicked: {
                                drawerDemo.position = "top"
                                drawerDemo.title = "Aviso Superior"
                                drawerDemo.open = true
                            }
                        }
                        Button {
                            text: "Drawer Inferior"
                            variant: "outline"
                            onClicked: {
                                drawerDemo.position = "bottom"
                                drawerDemo.title = "Painel de Ações Inferior"
                                drawerDemo.open = true
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // ADVANCED FORMS SECTION
            // ==========================================
            Text {
                text: "Mocha Advanced Forms (Controles de Formulários Avançados)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: advFormsColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm
                z: 15

                Column {
                    id: advFormsColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.xl

                    Grid {
                        width: parent.width
                        columns: 2
                        spacing: Theme.spacing.xl
                        z: 200

                        // Col 1: Toggle & Dropdown Trees
                        Column {
                            width: (parent.width - Theme.spacing.xl) / 2
                            spacing: Theme.spacing.lg
                            z: 210

                            Text {
                                text: "Interruptores (Toggles) e Árvores (SelectTree)"
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.subtext0
                            }

                            Row {
                                spacing: Theme.spacing.xl
                                ToggleButton {
                                    label: "Enviar Notificações"
                                    checked: true
                                    onToggled: console.log("Notificações toggled: " + state)
                                }
                                ToggleButton {
                                    label: "Modo Admin (Desabilitado)"
                                    checked: false
                                    disabled: true
                                }
                            }

                            Column {
                                spacing: Theme.spacing.xs
                                width: parent.width
                                z: 220

                                Text {
                                    text: "Seletor de Árvore (SelectTree):"
                                    font.family: Theme.typography.family
                                    font.pixelSize: Theme.typography.sizeSm
                                    color: Theme.colors.overlay1
                                }

                                SelectTree {
                                    id: selectTreeDemo
                                    width: parent.width
                                    placeholder: "Escolha um arquivo do sistema..."
                                    options: [
                                        {
                                            label: "Documentos",
                                            value: "docs",
                                            children: [
                                                { label: "Relatório Financeiro.pdf", value: "fin_rep" },
                                                { label: "Apresentação Pitch.pptx", value: "pitch" },
                                                {
                                                    label: "Pasta Pessoal",
                                                    value: "personal",
                                                    children: [
                                                        { label: "Fotos Férias.jpg", value: "vacation_photos" }
                                                    ]
                                                }
                                            ]
                                        },
                                        {
                                            label: "Configurações",
                                            value: "settings",
                                            children: [
                                                { label: "Preferências do Usuário.json", value: "prefs" }
                                            ]
                                        }
                                    ]
                                    onValueChanged: console.log("Tree select changed to value: " + val)
                                }
                            }
                        }

                        // Col 2: Date Picker, Range Selector, Color Picker
                        Column {
                            width: (parent.width - Theme.spacing.xl) / 2
                            spacing: Theme.spacing.lg
                            z: 100

                            Text {
                                text: "Calendário, Seleção de Faixa e Cores"
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.subtext0
                            }

                            Grid {
                                columns: 2
                                spacing: Theme.spacing.md
                                width: parent.width
                                z: 120

                                Column {
                                    spacing: Theme.spacing.xs
                                    width: (parent.width - Theme.spacing.md) / 2
                                    z: 130

                                    Text {
                                        text: "Data (DatePicker):"
                                        font.family: Theme.typography.family
                                        font.pixelSize: Theme.typography.sizeSm
                                        color: Theme.colors.overlay1
                                    }

                                    DatePicker {
                                        width: parent.width
                                        placeholder: "Escolha uma data..."
                                        onSelectedDateChanged: console.log("Date changed: " + selectedDate)
                                    }
                                }

                                Column {
                                    spacing: Theme.spacing.xs
                                    width: (parent.width - Theme.spacing.md) / 2
                                    z: 140

                                    Text {
                                        text: "Paleta (ColorPicker):"
                                        font.family: Theme.typography.family
                                        font.pixelSize: Theme.typography.sizeSm
                                        color: Theme.colors.overlay1
                                    }

                                    ColorPicker {
                                        width: parent.width
                                        selectedColor: Theme.colors.mauve
                                        onSelectedColorChanged: console.log("Color selected: " + selectedColor)
                                    }

                                    Item { width: 1; height: Theme.spacing.md }

                                    Text {
                                        text: "ColorPicker Avançado - Overlay (CozyColorPicker):"
                                        font.family: Theme.typography.family
                                        font.pixelSize: Theme.typography.sizeSm
                                        color: Theme.colors.overlay1
                                    }

                                    CozyColorPicker {
                                        width: parent.width
                                        colorValue: "#CBA6F7"
                                        onColorChanged: (newHex) => console.log("Nova cor Cozy Overlay:", newHex)
                                    }

                                    Item { width: 1; height: Theme.spacing.md }

                                    Text {
                                        text: "ColorPicker Avançado - Inline (CozyColorPicker):"
                                        font.family: Theme.typography.family
                                        font.pixelSize: Theme.typography.sizeSm
                                        color: Theme.colors.overlay1
                                    }

                                    CozyColorPicker {
                                        width: parent.width
                                        inline: true
                                        colorValue: "#A6E3A1"
                                        onColorChanged: (newHex) => console.log("Nova cor Cozy Inline:", newHex)
                                    }
                                }
                            }

                            Column {
                                spacing: Theme.spacing.xs
                                width: parent.width

                                Text {
                                    text: "Seletor de Faixa (RangeSelector):"
                                    font.family: Theme.typography.family
                                    font.pixelSize: Theme.typography.sizeSm
                                    color: Theme.colors.overlay1
                                }

                                RangeSelector {
                                    width: parent.width
                                    min: 0
                                    max: 100
                                    firstValue: 25
                                    secondValue: 75
                                    step: 1
                                    onValuesChanged: console.log("Range values changed: first=" + first + ", second=" + second)
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // MARKDOWN EDITOR SECTION
            // ==========================================
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            Text {
                text: "Mocha Text Editor (Editor de Texto Multilinha)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: 250
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    anchors.fill: parent
                    anchors.margins: Theme.spacing.md
                    spacing: 0

                    TextEditor {
                        width: parent.width
                        height: parent.height
                        placeholder: "Digite suas anotações multilinha aqui..."
                        text: "Bem-vindo ao MochaDS!\n\nEste é o TextEditor, o componente de edição de texto multilinha padrão do Cozy Design System. Ele herda os mesmos tokens visuais e estilos (focus borders, background colors, custom radius) do TextField, suportando rolagem automática e barra de rolagem customizada integrada."
                        onTextEdited: console.log("TextEditor content edited!")
                    }
                }
            }

            // ==========================================
            // TOOLTIP SECTION
            // ==========================================
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            Text {
                text: "Mocha Tooltip & Dropdown"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: tooltipDemoCol.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: tooltipDemoCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    // ---- Tooltip row ----
                    Text {
                        text: "Tooltip — passe o mouse sobre os botões"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.subtext0
                        antialiasing: true
                    }

                    Row {
                        spacing: Theme.spacing.md

                        Button {
                            id: _ttTopBtn
                            text: "Hover (top)"
                            variant: "outline"
                            Tooltip { text: "Aparece acima! (placement: top)"; placement: "top" }
                        }

                        Button {
                            id: _ttBottomBtn
                            text: "Hover (bottom)"
                            variant: "outline"
                            Tooltip { text: "Aparece abaixo! (placement: bottom)"; placement: "bottom" }
                        }

                        Button {
                            id: _ttRightBtn
                            text: "Hover (right)"
                            variant: "outline"
                            Tooltip { text: "À direita (placement: right)"; placement: "right" }
                        }

                        Button {
                            id: _ttLeftBtn
                            text: "Hover (left)"
                            variant: "outline"
                            Tooltip { text: "À esquerda (placement: left)"; placement: "left" }
                        }

                        LucideIcon {
                            id: _ttIconTarget
                            name: "info"
                            size: 20
                            color: Theme.colors.blue
                            anchors.verticalCenter: parent.verticalCenter
                            Tooltip { text: "Funciona em qualquer Item, não só botões! Delay: 300ms"; delay: 300; maxWidth: 200 }
                        }
                    }

                    // ---- Dropdown row ----
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.colors.surface1
                        opacity: 0.5
                    }

                    Text {
                        text: "Dropdown — clique nos botões para abrir o menu"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.subtext0
                        antialiasing: true
                    }

                    Row {
                        spacing: Theme.spacing.md

                        Button {
                            id: _ddActionsBtn
                            text: "Ações"
                            icon: "chevron-down"
                            variant: "outline"
                            onClicked: _globalDropdown.toggle(_ddActionsBtn)
                        }

                        Button {
                            id: _ddUserBtn
                            text: "Conta"
                            icon: "user"
                            variant: "secondary"
                            onClicked: _userDropdown.toggle(_ddUserBtn)
                        }

                        Button {
                            id: _ddDangerBtn
                            text: "Mais opções"
                            icon: "ellipsis"
                            variant: "ghost"
                            onClicked: _globalDropdown.toggle(_ddDangerBtn)
                        }
                    }
                }
            }

            // ==========================================
            // PIN / OTP INPUT SECTION
            // ==========================================
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            Text {
                text: "Mocha Code / PIN Input"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: pinDemoCol.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: pinDemoCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    // ---- Interactive Demo ----
                    Text {
                        text: "Demonstração Interativa (6 dígitos, validação de número)"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.subtext0
                        antialiasing: true
                    }

                    Row {
                        spacing: Theme.spacing.xl
                        width: parent.width

                        PinInput {
                            id: pinDemo
                            length: 6
                            type: "number"
                            onCompleted: function(code) {
                                toastManager.show("Código Completo: " + code, "success")
                            }
                            onTextEdited: {
                                // Reset status when user starts editing
                                if (status !== "normal") status = "normal"
                            }
                        }

                        // Code details & Actions
                        Column {
                            spacing: Theme.spacing.sm
                            anchors.verticalCenter: pinDemo.verticalCenter

                            Text {
                                text: "Código: <font color='" + Theme.colors.primary + "'><b>" + (pinDemo.text !== "" ? pinDemo.text : "vazio") + "</b></font>"
                                font.family: Theme.typography.family
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.text
                                textFormat: Text.RichText
                            }

                            Row {
                                spacing: Theme.spacing.sm
                                Button {
                                    text: "Simular Sucesso"
                                    variant: "success"
                                    size: "sm"
                                    onClicked: pinDemo.status = "success"
                                }
                                Button {
                                    text: "Simular Erro"
                                    variant: "danger"
                                    size: "sm"
                                    onClicked: pinDemo.status = "error"
                                }
                                Button {
                                    text: "Limpar"
                                    variant: "ghost"
                                    size: "sm"
                                    onClicked: {
                                        pinDemo.clear()
                                        pinDemo.status = "normal"
                                    }
                                }
                            }
                        }
                    }

                    // Divider
                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.colors.surface1
                        opacity: 0.5
                    }

                    // ---- Variants Showcase ----
                    Text {
                        text: "Variações e Tamanhos"
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeSm
                        color: Theme.colors.subtext0
                        antialiasing: true
                    }

                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.xl

                        // Var 1: Standard 4 digit
                        Column {
                            spacing: Theme.spacing.xs
                            Text { text: "Padrão (4 dígitos)"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeXs; color: Theme.colors.overlay1 }
                            PinInput { length: 4 }
                        }

                        // Var 2: Masked
                        Column {
                            spacing: Theme.spacing.xs
                            Text { text: "Oculto / Mask (6 dígitos)"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeXs; color: Theme.colors.overlay1 }
                            PinInput { length: 6; mask: true; text: "123" }
                        }

                        // Var 3: Disabled
                        Column {
                            spacing: Theme.spacing.xs
                            Text { text: "Desabilitado"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeXs; color: Theme.colors.overlay1 }
                            PinInput { length: 4; disabled: true; text: "9876" }
                        }
                    }

                    Flow {
                        width: parent.width
                        spacing: Theme.spacing.xl

                        // Size SM
                        Column {
                            spacing: Theme.spacing.xs
                            Text { text: "Tamanho Pequeno (sm)"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeXs; color: Theme.colors.overlay1 }
                            PinInput { size: "sm"; length: 4 }
                        }

                        // Size MD
                        Column {
                            spacing: Theme.spacing.xs
                            Text { text: "Tamanho Médio (md)"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeXs; color: Theme.colors.overlay1 }
                            PinInput { size: "md"; length: 4 }
                        }

                        // Size LG
                        Column {
                            spacing: Theme.spacing.xs
                            Text { text: "Tamanho Grande (lg)"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeXs; color: Theme.colors.overlay1 }
                            PinInput { size: "lg"; length: 4 }
                        }
                    }
                }
            }

            // ==========================================
            // PROGRESS & SCROLLING SECTION
            // ==========================================
            Rectangle { width: parent.width; height: 1; color: Theme.colors.surface0 }

            Text {
                text: "Progress & Scrolling (Indicadores e Navegação)"
                font.family: Theme.typography.familyBold; font.pixelSize: Theme.typography.sizeXl; color: Theme.colors.mauve; antialiasing: true
            }

            Grid {
                width: parent.width; columns: 2; spacing: Theme.spacing.xl

                // 1. Progress Bars
                Card {
                    width: (parent.width - parent.spacing) / 2
                    title: "Progress Bars"; subtitle: "Indicadores de carregamento e progresso"
                    content: Column {
                        width: parent.width; spacing: Theme.spacing.lg
                        ProgressBar { width: parent.width; value: 0.45; showLabel: true; label: "Progresso Padrão" }
                        ProgressBar { width: parent.width; value: 0.85; variant: "success"; showLabel: true }
                        ProgressBar { width: parent.width; variant: "warning"; indeterminate: true }
                        ProgressBar { width: parent.width; value: 0.3; variant: "danger"; pill: false }
                    }
                }

                // 2. Custom ScrollBar
                Card {
                    width: (parent.width - parent.spacing) / 2
                    title: "Custom ScrollBar"; subtitle: "Navegação fluida e reativa"
                    content: Item {
                        width: parent.width; height: 150
                        
                        Flickable {
                            id: scrollDemoFlick
                            anchors.fill: parent; contentHeight: 400; clip: true
                            Column {
                                width: parent.width; spacing: Theme.spacing.sm
                                Repeater {
                                    model: 20
                                    delegate: Rectangle {
                                        width: parent.width; height: 30; radius: 4
                                        color: index % 2 === 0 ? Theme.colors.surface0 : Theme.colors.mantle
                                        Text { text: "Item de lista #" + index; anchors.centerIn: parent; color: Theme.colors.subtext1; font.pixelSize: 12 }
                                    }
                                }
                            }
                        }

                        ScrollBar {
                            flickable: scrollDemoFlick
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.bottom: parent.bottom
                        }
                    }
                }
            }

            // ==========================================
            // CHARTS SECTION
            // ==========================================
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            Text {
                text: "Mocha Visual Charts"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: chartsDemoCol.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: chartsDemoCol
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    // Controller Row
                    Row {
                        spacing: Theme.spacing.md
                        width: parent.width

                        Button {
                            text: "Aleatorizar Dados"
                            icon: "refresh-cw"
                            variant: "primary"
                            size: "sm"
                            onClicked: {
                                var months = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul"]
                                var newBarData = []
                                for (var i = 0; i < months.length; i++) {
                                    newBarData.push({
                                        label: months[i],
                                        value: Math.floor(Math.random() * 150) + 20
                                    })
                                }
                                barChartDemo.chartData = newBarData

                                var years = ["2020", "2021", "2022", "2023", "2024", "2025"]
                                var newLineData = []
                                for (var j = 0; j < years.length; j++) {
                                    newLineData.push({
                                        label: years[j],
                                        value: Math.floor(Math.random() * 550) + 80
                                    })
                                }
                                lineChartDemo.chartData = newLineData

                                var pieData = [
                                    { label: "Espresso", value: Math.floor(Math.random() * 100) + 10 },
                                    { label: "Latte", value: Math.floor(Math.random() * 100) + 10 },
                                    { label: "Mocha", value: Math.floor(Math.random() * 100) + 10 },
                                    { label: "Cold Brew", value: Math.floor(Math.random() * 100) + 10 }
                                ]
                                pieChartDemo.chartData = pieData

                                var radarData = [
                                    { label: "Aroma", value: Math.floor(Math.random() * 60) + 40 },
                                    { label: "Acidez", value: Math.floor(Math.random() * 60) + 40 },
                                    { label: "Corpo", value: Math.floor(Math.random() * 60) + 40 },
                                    { label: "Doçura", value: Math.floor(Math.random() * 60) + 40 },
                                    { label: "Finalização", value: Math.floor(Math.random() * 60) + 40 }
                                ]
                                radarChartDemo.chartData = radarData
                                
                                gaugeDemo.value = Math.random() * 0.8 + 0.2
                            }
                        }

                        Button {
                            text: lineChartDemo.smooth ? "Linha Reta" : "Suavizar Curva"
                            icon: "git-commit"
                            variant: "outline"
                            size: "sm"
                            onClicked: lineChartDemo.smooth = !lineChartDemo.smooth
                        }

                        Button {
                            text: lineChartDemo.fillArea ? "Remover Preenchimento" : "Adicionar Preenchimento"
                            icon: "droplet"
                            variant: "outline"
                            size: "sm"
                            onClicked: lineChartDemo.fillArea = !lineChartDemo.fillArea
                        }
                        
                        Button {
                            text: pieChartDemo.donutRatio > 0 ? "Modo Pizza" : "Modo Donut"
                            icon: "pie-chart"
                            variant: "outline"
                            size: "sm"
                            onClicked: pieChartDemo.donutRatio = pieChartDemo.donutRatio > 0 ? 0.0 : 0.6
                        }
                    }

                    // Charts Grid (2 Columns)
                    Grid {
                        width: parent.width
                        columns: 2
                        columnSpacing: Theme.spacing.xl
                        rowSpacing: Theme.spacing.xl

                        // 1. Bar Chart
                        Column {
                            spacing: Theme.spacing.sm
                            width: (parent.width - parent.columnSpacing) / 2
                            Text { text: "Performance Mensal (BarChart)"; font.family: Theme.typography.familyBold; font.pixelSize: 13; color: Theme.colors.subtext0 }
                            BarChart {
                                id: barChartDemo
                                width: parent.width; height: 220
                                chartData: [ {label:"Jan", value:45}, {label:"Fev", value:80}, {label:"Mar", value:65}, {label:"Abr", value:120} ]
                            }
                        }

                        // 2. Line Chart
                        Column {
                            spacing: Theme.spacing.sm
                            width: (parent.width - parent.columnSpacing) / 2
                            Text { text: "Faturamento Anual (LineChart)"; font.family: Theme.typography.familyBold; font.pixelSize: 13; color: Theme.colors.subtext0 }
                            LineChart {
                                id: lineChartDemo
                                width: parent.width; height: 220; lineColor: Theme.colors.mauve
                                chartData: [ {label:"2022", value:180}, {label:"2023", value:420}, {label:"2024", value:380}, {label:"2025", value:600} ]
                            }
                        }

                        // 3. Pie/Donut Chart
                        Column {
                            spacing: Theme.spacing.sm
                            width: (parent.width - parent.columnSpacing) / 2
                            Text { text: "Mix de Vendas (PieChart)"; font.family: Theme.typography.familyBold; font.pixelSize: 13; color: Theme.colors.subtext0 }
                            PieChart {
                                id: pieChartDemo
                                width: parent.width; height: 220; donutRatio: 0.6
                                chartData: [ {label:"Espresso", value:45}, {label:"Latte", value:30}, {label:"Mocha", value:15}, {label:"Outros", value:10} ]
                            }
                        }

                        // 4. Radar & Gauge Mix
                        Row {
                            spacing: Theme.spacing.lg
                            width: (parent.width - parent.columnSpacing) / 2
                            
                            Column {
                                spacing: Theme.spacing.sm
                                width: parent.width * 0.55
                                Text { text: "Análise Sensorial (Radar)"; font.family: Theme.typography.familyBold; font.pixelSize: 13; color: Theme.colors.subtext0 }
                                RadarChart {
                                    id: radarChartDemo
                                    width: parent.width; height: 220
                                    chartData: [ {label:"Aroma", value:80}, {label:"Acidez", value:60}, {label:"Corpo", value:70}, {label:"Doçura", value:90}, {label:"Finalização", value:75} ]
                                }
                            }
                            
                            Column {
                                spacing: Theme.spacing.sm
                                width: parent.width * 0.45 - parent.spacing
                                Text { text: "Saúde do Sistema (Gauge)"; font.family: Theme.typography.familyBold; font.pixelSize: 13; color: Theme.colors.subtext0 }
                                GaugeChart {
                                    id: gaugeDemo
                                    width: parent.width; height: 220
                                    value: 0.72; label: "CPU Load"; color: Theme.colors.peach
                                }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // NAVIGATION BAR SECTION
            // ==========================================
            Text {
                text: "Mocha Navigation Bar (Floating Pill - Multiestilo)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: navigationBarDemoColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm
                clip: false // Crucial for floating variant to pop out

                Column {
                    id: navigationBarDemoColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.xl

                    Text {
                        text: "Standard Variant (Círculo Ativo)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    NavigationBar {
                        variant: "standard"
                        currentIndex: 0
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        NavigationItem { iconName: "home"; label: "Home" }
                        NavigationItem { iconName: "shopping-bag"; label: "Shop" }
                        NavigationItem { iconName: "message-circle"; label: "Chat" }
                        NavigationItem { iconName: "layout-grid"; label: "Apps" }
                        NavigationItem { iconName: "user"; label: "Profile" }
                    }

                    Text {
                        text: "Floating Variant (Pop-out ativo no eixo Y)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    // Extra spacing wrapper to accommodate the Y displacement
                    Item {
                        width: parent.width
                        height: 56
                        NavigationBar {
                            variant: "floating"
                            currentIndex: 1
                            anchors.centerIn: parent
                            
                            NavigationItem { iconName: "home"; label: "Home" }
                            NavigationItem { iconName: "shopping-bag"; label: "Shop" }
                            NavigationItem { iconName: "message-circle"; label: "Chat" }
                            NavigationItem { iconName: "layout-grid"; label: "Apps" }
                            NavigationItem { iconName: "user"; label: "Profile" }
                        }
                    }

                    Text {
                        text: "Expanding Variant (Pill elástica com texto fade-in)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    NavigationBar {
                        variant: "expanding"
                        currentIndex: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        NavigationItem { iconName: "home"; label: "Home" }
                        NavigationItem { iconName: "shopping-bag"; label: "Shop" }
                        NavigationItem { iconName: "message-circle"; label: "Chat" }
                        NavigationItem { iconName: "layout-grid"; label: "Apps" }
                        NavigationItem { iconName: "user"; label: "Profile" }
                    }

                    Text {
                        text: "Labeled Variant (Layout Column centralizado)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    NavigationBar {
                        variant: "labeled"
                        currentIndex: 3
                        anchors.horizontalCenter: parent.horizontalCenter
                        
                        NavigationItem { iconName: "home"; label: "Home" }
                        NavigationItem { iconName: "shopping-bag"; label: "Shop" }
                        NavigationItem { iconName: "message-circle"; label: "Chat" }
                        NavigationItem { iconName: "layout-grid"; label: "Apps" }
                        NavigationItem { iconName: "user"; label: "Profile" }
                    }
                }
            }

            // ==========================================
            // STEPPED PROGRESS SECTION
            // ==========================================
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            Text {
                text: "Mocha Stepped Progress Indicator (Etapas)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: steppedProgressDemoCol.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: steppedProgressDemoCol
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    // Interactive controller step variable
                    property int activeStep: 2

                    Row {
                        spacing: Theme.spacing.md
                        width: parent.width
                        
                        Button {
                            text: "Passo Anterior"
                            icon: "arrow-left"
                            variant: "outline"
                            size: "sm"
                            disabled: steppedProgressDemoCol.activeStep <= 1
                            onClicked: steppedProgressDemoCol.activeStep = Math.max(1, steppedProgressDemoCol.activeStep - 1)
                        }

                        Button {
                            text: "Próximo Passo"
                            icon: "arrow-right"
                            variant: "primary"
                            size: "sm"
                            disabled: steppedProgressDemoCol.activeStep >= 5
                            onClicked: steppedProgressDemoCol.activeStep = Math.min(5, steppedProgressDemoCol.activeStep + 1)
                        }
                        
                        Text {
                            text: "Etapa Atual: " + steppedProgressDemoCol.activeStep + " / 5"
                            font.family: Theme.typography.familyMedium
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext0
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }

                    // Showcase 1: Interactive SteppedProgress (5 Steps, primary variant)
                    Text {
                        text: "Wizard Interativo (5 etapas - Primary/Mauve)"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    SteppedProgress {
                        width: parent.width
                        totalSteps: 5
                        currentStep: steppedProgressDemoCol.activeStep
                        variant: "primary"
                    }

                    // Showcase 2: Different Variants (4 steps)
                    Text {
                        text: "Variantes Semânticas e Estilos"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                    }

                    Grid {
                        width: parent.width
                        columns: 2
                        spacing: Theme.spacing.xl

                        Column {
                            width: (parent.width - Theme.spacing.xl) / 2
                            spacing: Theme.spacing.md

                            Text { text: "Secondary (Blue)"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeSm; color: Theme.colors.overlay1 }
                            SteppedProgress { width: parent.width; totalSteps: 4; currentStep: 2; variant: "secondary" }

                            Text { text: "Success (Green)"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeSm; color: Theme.colors.overlay1 }
                            SteppedProgress { width: parent.width; totalSteps: 4; currentStep: 3; variant: "success" }
                        }

                        Column {
                            width: (parent.width - Theme.spacing.xl) / 2
                            spacing: Theme.spacing.md

                            Text { text: "Warning (Yellow)"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeSm; color: Theme.colors.overlay1 }
                            SteppedProgress { width: parent.width; totalSteps: 4; currentStep: 1; variant: "warning" }

                            Text { text: "Danger (Red) sem listras animadas"; font.family: Theme.typography.family; font.pixelSize: Theme.typography.sizeSm; color: Theme.colors.overlay1 }
                            SteppedProgress { width: parent.width; totalSteps: 4; currentStep: 2; variant: "danger"; showStripes: false }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // COZYLIST SECTION
            // ==========================================
            Text {
                text: "Mocha CozyList & InteractiveListCell"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: cozyListPreviewRow.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Row {
                    id: cozyListPreviewRow
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.xl

                    // CozyList with mock data
                    Column {
                        width: (parent.width - Theme.spacing.xl) / 2
                        spacing: Theme.spacing.md

                        Text {
                            text: "Lista com Dados (CozyList)"
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext0
                        }

                        CozyList {
                            width: parent.width
                            height: 280
                            model: mockCoffees
                            
                            rowContent: Component {
                                Item {
                                    anchors.fill: parent

                                    LucideIcon {
                                        id: coffeeIcon
                                        name: "coffee"
                                        size: 20
                                        color: Theme.colors.peach
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                    }

                                    Column {
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: coffeeIcon.right
                                        anchors.leftMargin: Theme.spacing.md
                                        anchors.right: roastBadge.left
                                        anchors.rightMargin: Theme.spacing.md
                                        spacing: 2

                                        Text {
                                            text: modelData.name
                                            font.family: Theme.typography.familyBold
                                            font.pixelSize: Theme.typography.sizeMd
                                            color: Theme.colors.text
                                            elide: Text.ElideRight
                                            width: parent.width
                                            antialiasing: true
                                        }

                                        Text {
                                            text: modelData.origin + " • Torra " + modelData.roast
                                            font.family: Theme.typography.family
                                            font.pixelSize: Theme.typography.sizeSm
                                            color: Theme.colors.subtext0
                                            elide: Text.ElideRight
                                            width: parent.width
                                            antialiasing: true
                                        }
                                    }

                                    Badge {
                                        id: roastBadge
                                        text: modelData.roast === "Escura" ? "Forte" : "Suave"
                                        variant: modelData.roast === "Escura" ? "danger" : "info"
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.right: parent.right
                                    }
                                }
                            }
                        }
                    }

                    // CozyList with empty state
                    Column {
                        width: (parent.width - Theme.spacing.xl) / 2
                        spacing: Theme.spacing.md

                        Text {
                            text: "Lista Vazia / Empty State (CozyList)"
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeMd
                            color: Theme.colors.subtext0
                        }

                        CozyList {
                            width: parent.width
                            height: 280
                            model: null
                            emptyStateIcon: "package-open"
                            emptyStateTitle: "Nenhuma integração encontrada"
                            emptyStateSubtitle: "Conecte sua primeira plataforma para começar."
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // LOADING STATES SECTION (Spinner & Skeletons)
            // ==========================================
            Text {
                text: "Mocha Loading States (Spinner & Skeleton UI)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: loadingStatesLayout.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                ColumnLayout {
                    id: loadingStatesLayout
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: Theme.spacing.lg
                    spacing: Theme.spacing.xl

                    RowLayout {
                        spacing: Theme.spacing.xl
                        Layout.fillWidth: true

                        // Column 1: Spinner showcase
                        Column {
                            Layout.fillWidth: true
                            spacing: Theme.spacing.md

                            Text {
                                text: "CozySpinner"
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.subtext0
                            }

                            Row {
                                spacing: Theme.spacing.lg
                                anchors.horizontalCenter: parent.horizontalCenter

                                CozySpinner { size: 16 }
                                CozySpinner { size: 24; color: Theme.colors.mauve }
                                CozySpinner { size: 32; color: Theme.colors.blue }
                                CozySpinner { size: 48; color: Theme.colors.green }
                            }
                        }

                        // Column 2: Skeleton variants showcase
                        Column {
                            Layout.fillWidth: true
                            spacing: Theme.spacing.md

                            Text {
                                text: "CozySkeleton Shapes"
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.subtext0
                            }

                            RowLayout {
                                spacing: Theme.spacing.md
                                anchors.horizontalCenter: parent.horizontalCenter

                                CozySkeleton { variant: "circle"; width: 40; height: 40 }
                                ColumnLayout {
                                    spacing: Theme.spacing.xs
                                    CozySkeleton { variant: "rectangle"; width: 150; height: 16 }
                                    CozySkeleton { variant: "rectangle"; width: 100; height: 12 }
                                }
                            }
                        }
                    }

                    // Interactive CozyList toggle loader
                    ColumnLayout {
                        spacing: Theme.spacing.md
                        Layout.fillWidth: true

                        RowLayout {
                            spacing: Theme.spacing.md
                            Layout.fillWidth: true

                            Text {
                                text: "CozyList com Carregamento Reativo"
                                font.family: Theme.typography.familyBold
                                font.pixelSize: Theme.typography.sizeMd
                                color: Theme.colors.subtext0
                                Layout.fillWidth: true
                            }

                            Button {
                                id: toggleLoadButton
                                text: cozyInteractiveList.isLoading ? "Mostrar Dados" : "Carregar Lista"
                                icon: cozyInteractiveList.isLoading ? "eye" : "refresh-cw"
                                variant: "tonal"
                                size: "sm"
                                onClicked: cozyInteractiveList.isLoading = !cozyInteractiveList.isLoading
                            }
                        }

                        CozyList {
                            id: cozyInteractiveList
                            width: parent.width
                            height: 200
                            model: mockCoffees.slice(0, 3)
                            isLoading: true // Starts as loading to showcase skeletons immediately
                            
                            rowContent: Component {
                                Item {
                                    anchors.fill: parent
                                    LucideIcon {
                                        id: coffeeIcon2
                                        name: "coffee"
                                        size: 20
                                        color: Theme.colors.peach
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: parent.left
                                    }
                                    Text {
                                        text: modelData.name
                                        font.family: Theme.typography.familyMedium
                                        font.pixelSize: Theme.typography.sizeMd
                                        color: Theme.colors.text
                                        anchors.verticalCenter: parent.verticalCenter
                                        anchors.left: coffeeIcon2.right
                                        anchors.leftMargin: Theme.spacing.md
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            // ==========================================
            // OVERLAY PLAYGROUND SECTION
            // ==========================================
            Text {
                text: "Playground de Empilhamento e Portal (Overlays)"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeXl
                color: Theme.colors.mauve
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: overlayPlaygroundColumn.height + Theme.spacing.lg * 2
                color: Theme.colors.base
                radius: Theme.geometry.radiusMd
                border.color: Theme.colors.surface0
                border.width: Theme.geometry.borderSm

                Column {
                    id: overlayPlaygroundColumn
                    width: parent.width - Theme.spacing.lg * 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: Theme.spacing.lg
                    spacing: Theme.spacing.lg

                    Text {
                        text: "Verifique o comportamento de Modals, Selects e DatePickers em cenários de agrupamento e clipping."
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.sizeMd
                        color: Theme.colors.subtext0
                        width: parent.width
                        wrapMode: Text.WordWrap
                    }

                    Row {
                        spacing: Theme.spacing.md
                        width: parent.width

                        // Button to trigger modal overlay demo
                        Button {
                            text: "Abrir Modal Overlay Playground"
                            icon: "layers"
                            variant: "primary"
                            onClicked: modalOverlayDemo.open = true
                        }

                        Button {
                            text: "Abrir Drawer Lateral Overlay"
                            icon: "sidebar"
                            variant: "outline"
                            onClicked: drawerOverlayDemo.open = true
                        }
                    }

                    // Clipped Container Simulation
                    Column {
                        spacing: Theme.spacing.sm
                        width: parent.width

                        Text {
                            text: "Simulador de Clipping Parent (Flickable clip: true - dropdowns devem abrir por fora do limite de 120px):"
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeSm
                            color: Theme.colors.subtext0
                        }

                        Rectangle {
                            width: parent.width
                            height: 120
                            color: Theme.colors.mantle
                            radius: Theme.geometry.radiusMd
                            border.color: Theme.colors.surface1
                            border.width: Theme.geometry.borderSm
                            clip: true

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: Theme.spacing.md
                                contentHeight: clippedRow.height
                                clip: true

                                Row {
                                    id: clippedRow
                                    spacing: Theme.spacing.md
                                    width: parent.width

                                    Select {
                                        width: (parent.width - Theme.spacing.md) / 2
                                        placeholder: "Selecione País..."
                                        options: ["Brasil", "EUA", "Japão", "Alemanha", "França", "Canadá"]
                                    }

                                    DatePicker {
                                        width: (parent.width - Theme.spacing.md) / 2
                                        placeholder: "Data de Início..."
                                    }
                                }
                            }
                        }
                }
            }


            // Bottom padding spacer
            Item {
                width: parent.width
                height: Theme.spacing.xxl * 2
            }
        }
    }



    // ==========================================
    // DEMO COMPONENTS DECLARATION
    // ==========================================

    // Simple Demo Modal
    Modal {
        id: modalDemo
        title: "Editar Perfil"
        subtitle: "Modifique suas informações e salve"

        Column {
            width: parent.width
            spacing: Theme.spacing.md

            Text {
                text: "Aqui você pode inserir o corpo do seu modal. Ele aceita qualquer elemento QML customizado por meio do slot padrão, expandindo a altura dinamicamente de acordo com as regras cozy."
                width: parent.width
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.subtext0
                wrapMode: Text.WordWrap
                antialiasing: true
            }
        }

        footer: Row {
            spacing: Theme.spacing.md
            anchors.right: parent.right

            Button {
                text: "Cancelar"
                variant: "ghost"
                onClicked: modalDemo.open = false
            }
            Button {
                text: "Salvar Alterações"
                variant: "primary"
                onClicked: modalDemo.open = false
            }
        }
    }

    // Scrollable Large Modal
    Modal {
        id: modalScrollDemo
        title: "Termos de Uso e Privacidade"
        subtitle: "Leia atentamente antes de aceitar"
        size: "lg"

        Column {
            width: parent.width
            spacing: Theme.spacing.lg

            Text {
                text: "1. Introdução\nBem-vindo ao Mocha-DS. Ao utilizar nossa biblioteca de componentes QML Cozy, você concorda com todos os termos e diretrizes de design system estabelecidos.\n\n" +
                      "2. Licença de Uso\nConcedemos a você uma licença limitada, não exclusiva e intransferível para utilizar, modificar e integrar estes componentes em seus aplicativos Qt Quick.\n\n" +
                      "3. Propriedade Intelectual\nTodo o código-fonte, estilos Catppuccin e configurações de tipografia são de autoria dos desenvolvedores originais e protegidos pelas leis de software aplicáveis.\n\n" +
                      "4. Limitação de Responsabilidade\nEstes componentes são fornecidos 'como estão', sem garantias explícitas de ausência de bugs ou compatibilidade universal com todas as versões do Qt.\n\n" +
                      "5. Contribuições\nContribuições são bem-vindas! Ao submeter Pull Requests, você concorda em licenciar sua contribuição sob os mesmos termos da licença deste projeto."
                width: parent.width
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.subtext0
                wrapMode: Text.WordWrap
                antialiasing: true
            }
        }

        footer: Row {
            spacing: Theme.spacing.md
            anchors.right: parent.right

            Button {
                text: "Recusar"
                variant: "danger"
                onClicked: modalScrollDemo.open = false
            }
            Button {
                text: "Aceitar e Continuar"
                variant: "primary"
                onClicked: modalScrollDemo.open = false
            }
        }
    }

    // Slide-out Drawer Demo
    Drawer {
        id: drawerDemo
        title: "Configurações"
        subtitle: "Painel lateral do sistema"

        Column {
            width: parent.width
            spacing: Theme.spacing.lg

            Text {
                text: "Este painel lateral é ideal para configurações do sistema, feeds de notificações, chats ou formulários auxiliares."
                width: parent.width
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.subtext0
                wrapMode: Text.WordWrap
                antialiasing: true
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Theme.colors.surface0
            }

            Column {
                width: parent.width
                spacing: Theme.spacing.sm

                Text {
                    text: "Preferências de Exibição"
                    font.family: Theme.typography.familyBold
                    font.pixelSize: Theme.typography.sizeSm
                    color: Theme.colors.mauve
                    antialiasing: true
                }

                Button {
                    text: "Mudar Tema (Escuro)"
                    variant: "tonal"
                    width: parent.width
                }
                Button {
                    text: "Limpar Cache de Ícones"
                    variant: "outline"
                    width: parent.width
                }
            }
        }

        footer: Row {
            spacing: Theme.spacing.md
            anchors.right: parent.right

            Button {
                text: "Fechar Painel"
                variant: "primary"
                onClicked: drawerDemo.open = false
            }
        }
    }

    // Modal Overlay Demo Stacking
    Modal {
        id: modalOverlayDemo
        title: "Playground de Empilhamento"
        subtitle: "Selecione e manipule elementos de overlay agrupados"
        size: "md"

        Column {
            width: parent.width
            spacing: Theme.spacing.md

            Text {
                text: "Este modal valida se múltiplos dropdowns, popovers e sub-modais empilham corretamente. Clique nos elementos para testar a pilha global."
                width: parent.width
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.subtext0
                wrapMode: Text.WordWrap
                antialiasing: true
            }

            Row {
                spacing: Theme.spacing.md
                width: parent.width

                Select {
                    width: (parent.width - Theme.spacing.md) / 2
                    placeholder: "Selecione Categoria..."
                    options: ["Design", "Engenharia", "Marketing", "Suporte", "Vendas"]
                }

                DatePicker {
                    width: (parent.width - Theme.spacing.md) / 2
                    placeholder: "Data Limite..."
                }
            }

            Row {
                spacing: Theme.spacing.md
                width: parent.width

                Button {
                    id: btnSubMenu
                    text: "Abrir Dropdown"
                    icon: "more-vertical"
                    width: (parent.width - Theme.spacing.md) / 2
                    onClicked: _globalDropdown.toggle(btnSubMenu)
                }

                Button {
                    text: "Testar Toast"
                    icon: "bell"
                    variant: "outline"
                    width: (parent.width - Theme.spacing.md) / 2
                    onClicked: toastManager.show("Notificação disparada do Modal!", "success", "Sucesso")
                }
            }

            Row {
                spacing: Theme.spacing.md
                width: parent.width

                Button {
                    text: "Abrir Sub-Modal (+1 Z)"
                    icon: "layers"
                    variant: "tonal"
                    width: (parent.width - Theme.spacing.md) / 2
                    onClicked: secondModalOverlay.open = true
                }

                Button {
                    text: "Abrir Sub-Drawer (+1 Z)"
                    icon: "sidebar"
                    variant: "tonal"
                    width: (parent.width - Theme.spacing.md) / 2
                    onClicked: secondDrawerOverlay.open = true
                }
            }

            Text {
                text: "ColorPicker Avançado (Overlay):"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.subtext0
            }

            CozyColorPicker {
                width: parent.width
                colorValue: "#A6E3A1"
                onColorChanged: (newHex) => console.log("Nova cor selecionada no modal:", newHex)
            }

            Item {
                width: parent.width
                height: 40
                
                Button {
                    text: "Botão com Tooltip"
                    anchors.centerIn: parent
                    Tooltip { text: "Este é um tooltip flutuando por cima do modal!" }
                }
            }
        }

        footer: Row {
            spacing: Theme.spacing.md
            anchors.right: parent.right

            Button {
                text: "Cancelar"
                variant: "ghost"
                onClicked: modalOverlayDemo.open = false
            }
            Button {
                text: "Confirmar"
                variant: "primary"
                onClicked: modalOverlayDemo.open = false
            }
        }
    }

    // Lateral Drawer Overlay Demo Stacking
    Drawer {
        id: drawerOverlayDemo
        title: "Configurações Globais (Overlay)"
        subtitle: "Filtros e parametrizações complexas"
        position: "right"
        size: 380

        Column {
            width: parent.width
            spacing: Theme.spacing.md

            Text {
                text: "Ajuste os filtros de data e tags do sistema:"
                width: parent.width
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.subtext0
                wrapMode: Text.WordWrap
            }

            Select {
                width: parent.width
                placeholder: "Filtrar por Status..."
                options: ["Ativo", "Pendente", "Inativo"]
            }

            DatePicker {
                width: parent.width
                placeholder: "Data do Filtro..."
            }

            Button {
                id: btnDrawerMenu
                text: "Dropdown no Drawer"
                icon: "more-horizontal"
                width: parent.width
                onClicked: _userDropdown.toggle(btnDrawerMenu)
            }

            Button {
                text: "Disparar Toast"
                icon: "alert-triangle"
                variant: "outline"
                width: parent.width
                onClicked: toastManager.show("Alerta enviado do painel lateral!", "warning", "Atenção")
            }

            Button {
                text: "Abrir Sub-Modal no Drawer"
                icon: "layers"
                variant: "tonal"
                width: parent.width
                onClicked: secondModalOverlay.open = true
            }

            Text {
                text: "Color Selector:"
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.subtext0
            }

            CozyColorPicker {
                width: parent.width
                colorValue: "#FAB387"
            }
        }

        footer: Row {
            spacing: Theme.spacing.md
            anchors.right: parent.right

            Button {
                text: "Fechar"
                variant: "ghost"
                onClicked: drawerOverlayDemo.open = false
            }
            Button {
                text: "Aplicar Filtros"
                variant: "primary"
                onClicked: drawerOverlayDemo.open = false
            }
        }
    }

    // Secondary Modal Overlay for testing +1 Stacking depth
    Modal {
        id: secondModalOverlay
        title: "Sub-Modal de Confirmação"
        subtitle: "Confirme a operação de segundo nível"
        size: "sm"

        Column {
            width: parent.width
            spacing: Theme.spacing.md

            Text {
                text: "Este é o segundo nível de modal. Ele deve abrir sobrepondo o modal original ou o drawer perfeitamente devido ao incremento dinâmico de Z."
                width: parent.width
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.subtext0
                wrapMode: Text.WordWrap
            }
            
            Select {
                width: parent.width
                placeholder: "Escolha prioridade..."
                options: ["Baixa", "Média", "Alta"]
            }
        }

        footer: Row {
            spacing: Theme.spacing.md
            anchors.right: parent.right

            Button {
                text: "Fechar Sub-Modal"
                variant: "primary"
                onClicked: secondModalOverlay.open = false
            }
        }
    }

    // Secondary Drawer Overlay for testing +1 Stacking depth
    Drawer {
        id: secondDrawerOverlay
        title: "Sub-Drawer de Detalhes"
        subtitle: "Informações adicionais de segundo nível"
        position: "left"
        size: 300

        Column {
            width: parent.width
            spacing: Theme.spacing.md

            Text {
                text: "Este é o segundo nível de drawer lateral. Ele abre do lado esquerdo e sobrepõe a visualização atual do modal."
                width: parent.width
                font.family: Theme.typography.family
                font.pixelSize: Theme.typography.sizeSm
                color: Theme.colors.subtext0
                wrapMode: Text.WordWrap
            }
            
            DatePicker {
                width: parent.width
                placeholder: "Data secundária..."
            }
        }

        footer: Row {
            spacing: Theme.spacing.md
            anchors.right: parent.right

            Button {
                text: "Fechar Sub-Drawer"
                variant: "primary"
                onClicked: secondDrawerOverlay.open = false
            }
        }
    }


    // ==========================================================
    // Dedicated window for Shell layout component demonstration
    // ==========================================================
    Window {
        id: shellDemoWindow
        title: "Mocha-DS Shell - Responsivo & Flexível"
        width: 1100
        height: 700
        visible: false
        color: Theme.colors.crust

        Shell {
            id: appShell
            anchors.fill: parent

            // 1. Header Bar Content
            header: [
                Row {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.lg
                    anchors.rightMargin: Theme.spacing.lg
                    spacing: Theme.spacing.md

                    Button {
                        icon: "menu"
                        variant: "ghost"
                        size: "sm"
                        visible: appShell.isMobile
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked: appShell.sidebarOpenMobile = !appShell.sidebarOpenMobile
                    }

                    Text {
                        text: "Painel de Controle Mocha"
                        font.family: Theme.typography.familyBold
                        font.pixelSize: Theme.typography.sizeLg
                        color: Theme.colors.text
                        anchors.verticalCenter: parent.verticalCenter
                        antialiasing: true
                    }

                    // Spacer
                    Item {
                        width: parent.width - (appShell.isMobile ? 240 : 680)
                        height: 1
                    }

                    // Shell controls for testing in desktop mode
                    Row {
                        spacing: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter
                        visible: !appShell.isMobile

                        Button {
                            text: appShell.sidebarCollapsed ? "Expandir Sidebar" : "Recolher Sidebar"
                            size: "sm"
                            variant: "outline"
                            icon: appShell.sidebarCollapsed ? "chevron-right" : "chevron-left"
                            onClicked: appShell.sidebarCollapsed = !appShell.sidebarCollapsed
                        }

                        Button {
                            text: appShell.secondarySidebarVisible ? "Ocultar Submenu" : "Mostrar Submenu"
                            size: "sm"
                            variant: "outline"
                            icon: "columns"
                            onClicked: appShell.secondarySidebarVisible = !appShell.secondarySidebarVisible
                        }

                        // Separator line
                        Rectangle {
                            width: 1
                            height: 20
                            color: Theme.colors.surface0
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: "Colunas:"
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeSm
                            color: Theme.colors.overlay1
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Button {
                            text: "1"
                            size: "sm"
                            variant: appShell.columnCount === 1 ? "primary" : "outline"
                            onClicked: appShell.columnCount = 1
                        }

                        Button {
                            text: "2"
                            size: "sm"
                            variant: appShell.columnCount === 2 ? "primary" : "outline"
                            onClicked: appShell.columnCount = 2
                        }

                        Button {
                            text: "3"
                            size: "sm"
                            variant: appShell.columnCount === 3 ? "primary" : "outline"
                            onClicked: appShell.columnCount = 3
                        }
                    }

                    // Mobile Column selector
                    Row {
                        spacing: Theme.spacing.sm
                        anchors.verticalCenter: parent.verticalCenter
                        visible: appShell.isMobile

                        Button {
                            text: "Lista"
                            size: "sm"
                            variant: appShell.activeMobileColumn === 0 ? "primary" : "outline"
                            onClicked: appShell.activeMobileColumn = 0
                        }
                        Button {
                            text: "Detalhes"
                            size: "sm"
                            variant: appShell.activeMobileColumn === 1 ? "primary" : "outline"
                            onClicked: appShell.activeMobileColumn = 1
                        }
                        Button {
                            text: "Ações"
                            size: "sm"
                            variant: appShell.activeMobileColumn === 2 ? "primary" : "outline"
                            onClicked: appShell.activeMobileColumn = 2
                        }
                    }
                }
            ]

            // 2. Primary Sidebar Content
            sidebar: [
                Sidebar {
                    id: previewSidebar
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    collapsedWidth: 64
                    expandedWidth: appShell.sidebarWidth
                    isCollapsed: appShell.sidebarCollapsed
                    expandOnHover: true

                    SidebarHeader {
                        title: "Mocha Shell"
                        logoIcon: "coffee"
                    }

                    SidebarSection {
                        SidebarItem {
                            label: "Início"
                            icon: "home"
                            isActive: true
                        }
                        SidebarItem {
                            label: "Analíticos"
                            icon: "bar-chart-2"
                        }
                        SidebarItem {
                            label: "Configurações"
                            icon: "settings"
                            expanded: true

                            SidebarItem {
                                label: "Visual"
                                icon: "palette"
                            }
                            SidebarItem {
                                label: "Segurança"
                                icon: "shield"
                            }
                        }
                    }

                    SidebarFooter {
                        username: "Usuário Mocha"
                        email: "user@mocha.org"
                        avatarIcon: "smile"
                    }
                }
            ]

            // 3. Secondary Sidebar Content (No longer used, submenus are inside primary sidebar accordion)
            secondarySidebar: []

            // 4. Column 1 Content
            col1: [
                Card {
                    anchors.fill: parent
                    title: "Menu de Cafés"
                    subtitle: "Clique para inspecionar o lote"
                    icon: "coffee"

                    Column {
                        width: parent.width
                        spacing: Theme.spacing.sm

                        Repeater {
                            model: ["Cappuccino Latte", "Espresso Mocha", "Macchiato Mauve", "Flat White Cozy"]
                            delegate: Tile {
                                width: parent.width
                                title: modelData
                                description: "Grãos selecionados 100% Arábica"
                                icon: "coffee"
                                interactive: true
                                onClicked: {
                                    appShell.columnCount = 2
                                    detailTitle.text = modelData
                                    if (appShell.isMobile) {
                                        appShell.activeMobileColumn = 1
                                    }
                                }
                            }
                        }
                    }
                }
            ]

            // 5. Column 2 Content
            col2: [
                Card {
                    anchors.fill: parent
                    title: "Indicadores de Vendas"
                    subtitle: "Performance em tempo real"
                    icon: "bar-chart-2"

                    Column {
                        width: parent.width
                        spacing: Theme.spacing.lg

                        Text {
                            id: detailTitle
                            text: "Visão Geral"
                            font.family: Theme.typography.familyBold
                            font.pixelSize: Theme.typography.sizeLg
                            color: Theme.colors.primary
                            antialiasing: true
                        }

                        BarChart {
                            width: parent.width
                            height: 140
                            chartData: [
                                {label: "Seg", value: 45},
                                {label: "Ter", value: 80},
                                {label: "Qua", value: 65},
                                {label: "Qui", value: 120}
                            ]
                        }

                        LineChart {
                            width: parent.width
                            height: 140
                            lineColor: Theme.colors.peach
                            chartData: [
                                {label: "W1", value: 100},
                                {label: "W2", value: 250},
                                {label: "W3", value: 180},
                                {label: "W4", value: 420}
                            ]
                        }

                        PieChart {
                            width: parent.width
                            height: 140
                            donutRatio: 0.5
                            chartData: [
                                {label: "A", value: 40},
                                {label: "B", value: 30},
                                {label: "C", value: 30}
                            ]
                        }

                        Button {
                            text: "Expandir Ações (Col 3)"
                            variant: "outline"
                            width: parent.width
                            onClicked: {
                                appShell.columnCount = 3
                                if (appShell.isMobile) {
                                    appShell.activeMobileColumn = 2
                                }
                            }
                        }
                    }
                }
            ]

            // 6. Column 3 Content
            col3: [
                Card {
                    anchors.fill: parent
                    title: "Ações Administrativas"
                    subtitle: "Exportações e exclusões"
                    icon: "sliders"

                    Column {
                        width: parent.width
                        spacing: Theme.spacing.md

                        Button {
                            text: "Exportar Ficha (.pdf)"
                            icon: "download"
                            variant: "primary"
                            width: parent.width
                        }

                        Button {
                            text: "Excluir Registro"
                            icon: "trash-2"
                            variant: "danger"
                            width: parent.width
                        }

                        Button {
                            text: "Voltar para Lote"
                            variant: "ghost"
                            width: parent.width
                            onClicked: {
                                appShell.columnCount = 2
                                if (appShell.isMobile) {
                                    appShell.activeMobileColumn = 1
                                }
                            }
                        }
                    }
                }
            ]
        }
    }

    // Global overlay for toast notifications
    ToastManager {
        id: toastManager
    }

    // ==========================================
    // DROPDOWN SHOWCASE
    // ==========================================
    Dropdown {
        id: _globalDropdown
        placement: "bottom-start"
        items: [
            { label: "Editar",    icon: "pencil",   shortcut: "Ctrl+E" },
            { label: "Duplicar",  icon: "copy",     shortcut: "Ctrl+D" },
            { label: "Favoritar", icon: "star" },
            { separator: true },
            { label: "Arquivar",  icon: "archive",  disabled: true },
            { separator: true },
            { label: "Excluir",   icon: "trash-2",  variant: "danger", shortcut: "Del" }
        ]
        onItemSelected: function(item) {
            toastManager.show("Ação: " + item.label, "info")
        }
    }

    Dropdown {
        id: _userDropdown
        placement: "bottom-end"
        items: [
            { label: "Meu perfil",    icon: "user" },
            { label: "Configurações", icon: "settings" },
            { label: "Atalhos",       icon: "keyboard", shortcut: "?" },
            { separator: true },
            { label: "Sair",          icon: "log-out",  variant: "danger" }
        ]
        onItemSelected: function(item) {
            toastManager.show(item.label, "success")
        }
    }
}
}

