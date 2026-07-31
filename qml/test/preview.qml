import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import MochaDS as DS

Window {
    id: window
    width: 1100
    height: 850
    visible: true
    title: "Mocha-DS Showcase Playground"
    color: DS.Theme.colors.crust

    // ==========================================
    // State Management
    // ==========================================
    property var categories: [
        { id: "actions", label: "Ações", icon: "mouse-pointer", components: ["Button", "ButtonGroup", "ToggleButton", "Switch", "Dropdown", "ContextMenu"] },
        { id: "inputs", label: "Inputs", icon: "edit-3", components: ["TextField", "Checkbox", "RadioButton", "RadioGroup", "Select", "AdvancedSelect", "SelectTree", "Slider", "Tag", "PinInput", "DatePicker", "RangeSelector", "ColorPicker", "CozyColorPicker"] },
        { id: "text", label: "Texto", icon: "file-text", components: ["TextEditor", "AdvancedTextEditor", "FormField", "DynamicForm", "I18n"] },
        { id: "display", label: "Display", icon: "eye", components: ["HeroCarousel", "Badge", "Avatar", "ProgressBar", "Spinner", "Skeleton", "Tooltip", "Toast", "StripedFill", "SteppedProgress", "Stepper"] },
        { id: "layout", label: "Layout", icon: "layout", components: ["HStack", "VStack", "Box", "Card", "Tile", "Accordion", "Modal", "AlertDialog", "Popover", "Drawer", "EmptyState", "Separator", "Shell", "CozyGrid"] },
        { id: "data", label: "Dados", icon: "database", components: ["Table", "TreeTable", "Paginator", "InteractiveListCell", "CozyList", "DataGrid"] },
        { id: "charts", label: "Gráficos", icon: "pie-chart", components: ["Charts", "PieChart", "BarChart", "LineChart"] },
        { id: "navigation", label: "Navegação", icon: "navigation", components: ["Navigation", "NavigationBar", "Sidebar", "Breadcrumb", "Router"] },
        { id: "interactivity", label: "Interatividade", icon: "move", components: ["SortableTabs", "Draggable", "DropZone", "SortableList", "Kanban", "SortableTable"] },
        { id: "animations", label: "Animações", icon: "zap", components: ["Animations"] }
    ]

    property int activeCategoryIndex: 0
    readonly property var activeCategory: categories[activeCategoryIndex]
    property int activeComponentIndex: 0
    readonly property string activeComponentName: activeCategory.components[activeComponentIndex]

    onActiveCategoryIndexChanged: activeComponentIndex = 0

    // ==========================================
    // UI Layout
    // ==========================================

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // 1. TOP HEADER & FLAVOR SWITCHER
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: DS.Theme.colors.mantle
            z: 10

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: DS.Theme.spacing.xl
                anchors.rightMargin: DS.Theme.spacing.xl
                spacing: DS.Theme.spacing.lg

                DS.MochaLogo {
                    size: 28
                    color: DS.Theme.colors.primary
                }

                Text {
                    text: "Mocha-DS"
                    font.family: DS.Theme.typography.familyBold
                    font.pixelSize: DS.Theme.typography.sizeH2
                    color: DS.Theme.colors.text
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Sabor:"
                    font.family: DS.Theme.typography.family
                    font.pixelSize: DS.Theme.typography.sizeSm
                    color: DS.Theme.colors.subtext0
                }

                DS.ButtonGroup {
                    currentIndex: DS.Theme.flavor === "mocha" ? 0 : (DS.Theme.flavor === "macchiato" ? 1 : (DS.Theme.flavor === "frappe" ? 2 : (DS.Theme.flavor === "latte" ? 3 : (DS.Theme.flavor === "vercel" ? 4 : 5))))
                    expand: false
                    Layout.preferredHeight: 32
                    DS.ButtonGroupItem { text: "Mocha"; onClicked: DS.Theme.flavor = "mocha" }
                    DS.ButtonGroupItem { text: "Macchiato"; onClicked: DS.Theme.flavor = "macchiato" }
                    DS.ButtonGroupItem { text: "Frappé"; onClicked: DS.Theme.flavor = "frappe" }
                    DS.ButtonGroupItem { text: "Latte"; onClicked: DS.Theme.flavor = "latte" }
                    DS.ButtonGroupItem { text: "Vercel"; onClicked: DS.Theme.flavor = "vercel" }
                    DS.ButtonGroupItem { text: "Vercel Light"; onClicked: DS.Theme.flavor = "vercel-light" }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: DS.Theme.colors.surface0
            }
        }

        // 2. CATEGORY TABS
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: DS.Theme.colors.mantle
            z: 9

            DS.Tabs {
                anchors.fill: parent
                model: categories
                currentIndex: activeCategoryIndex
                variant: "line"
                onTabSelected: function(index) { activeCategoryIndex = index }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: DS.Theme.colors.surface0
            }
        }

        // 3. MAIN CONTENT AREA (Sidebar + Playground)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Left Sidebar: Component Selection
            Rectangle {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                color: DS.Theme.colors.base

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: DS.Theme.spacing.lg
                    spacing: DS.Theme.spacing.lg

                    Text {
                        text: activeCategory.label
                        font.family: DS.Theme.typography.familyBold
                        font.pixelSize: DS.Theme.typography.sizeLg
                        color: DS.Theme.colors.mauve
                    }

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        DS.Steps {
                            width: parent.width
                            orientation: "vertical"
                            variant: "timeline"
                            stepsCount: activeCategory.components.length
                            labels: activeCategory.components
                            currentStep: activeComponentIndex
                            onChangeStep: function(step) { activeComponentIndex = step }
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    width: 1
                    height: parent.height
                    color: DS.Theme.colors.surface0
                }
            }

            // Center/Main Area: The Playground
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: DS.Theme.colors.crust

                Loader {
                    id: playgroundLoader
                    anchors.fill: parent
                    source: Qt.resolvedUrl("Playground" + activeComponentName + ".qml")
                    
                    onStatusChanged: {
                        if (status === Loader.Error) {
                            fallback.visible = true;
                        } else if (status === Loader.Ready) {
                            fallback.visible = false;
                        }
                    }
                }

                Rectangle {
                    id: fallback
                    anchors.fill: parent
                    color: DS.Theme.colors.crust
                    visible: false

                    Column {
                        anchors.centerIn: parent
                        spacing: DS.Theme.spacing.lg
                        
                        DS.LucideIcon {
                            name: "hammer"
                            size: 64
                            color: DS.Theme.colors.surface2
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        
                        Text {
                            text: "Playground em Desenvolvimento"
                            font.family: DS.Theme.typography.familyBold
                            font.pixelSize: DS.Theme.typography.sizeH2
                            color: DS.Theme.colors.subtext1
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Text {
                            text: "O componente " + activeComponentName + " ainda está sendo migrado para o novo formato."
                            font.family: DS.Theme.typography.family
                            font.pixelSize: DS.Theme.typography.sizeMd
                            color: DS.Theme.colors.subtext0
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }
}
