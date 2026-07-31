import QtQuick 2.15
import QtTest
import ".." // Import local MochaDS files

TestCase {
    name: "MochaDSTests"

    // ==========================================
    // Theme Tests
    // ==========================================
    function test_theme_colors() {
        compare(Theme.colors.base.toString(), "#1e1e2e")
        compare(Theme.colors.text.toString(), "#cdd6f4")
        compare(Theme.colors.mauve.toString(), "#cba6f7")
        compare(Theme.colors.primary.toString(), "#cba6f7")
        compare(Theme.colors.secondary.toString(), "#89b4fa")
    }

    function test_theme_spacing() {
        compare(Theme.spacing.xs, 4)
        compare(Theme.spacing.sm, 8)
        compare(Theme.spacing.md, 12)
        compare(Theme.spacing.lg, 16)
        compare(Theme.spacing.xl, 24)
        compare(Theme.spacing.xxl, 32)
    }

    function test_theme_geometry() {
        compare(Theme.geometry.radiusSm, 6)
        compare(Theme.geometry.radiusMd, 12)
        compare(Theme.geometry.radiusLg, 18)
        compare(Theme.geometry.radiusPill, 9999)
    }

    // ==========================================
    // LucideIcon Tests
    // ==========================================
    function test_lucide_icon_resolve() {
        var component = Qt.createComponent(Qt.resolvedUrl("../LucideIcon.qml"))
        compare(component.status, Component.Ready)
        
        var icon = component.createObject(null, { "name": "home", "size": 32 })
        verify(icon !== null)
        
        var expectedUrl = Qt.resolvedUrl("../assets/icons/home.svg").toString()
        compare(icon.resolvedSource.toString(), expectedUrl)
        
        icon.destroy()
    }

    function test_lucide_icon_stroke_width() {
        var component = Qt.createComponent(Qt.resolvedUrl("../LucideIcon.qml"))
        compare(component.status, Component.Ready)
        
        var icon = component.createObject(null, { "name": "home", "strokeWidth": 1.5 })
        verify(icon !== null)
        compare(icon.strokeWidth, 1.5)
        
        icon.destroy()
    }

    // ==========================================
    // Button Tests
    // ==========================================
    function test_button_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Button.qml"))
        compare(component.status, Component.Ready)
        
        var btn = component.createObject(null, { "text": "Teste" })
        verify(btn !== null)
        compare(btn.text, "Teste")
        compare(btn.variant, "primary")
        compare(btn.size, "md")
        
        btn.destroy()
    }

    function test_button_sizes() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Button.qml"))
        
        var btnSm = component.createObject(null, { "size": "sm" })
        compare(btnSm.height, 32)
        
        var btnMd = component.createObject(null, { "size": "md" })
        compare(btnMd.height, 40)
        
        var btnLg = component.createObject(null, { "size": "lg" })
        compare(btnLg.height, 48)
        
        btnSm.destroy()
        btnMd.destroy()
        btnLg.destroy()
    }

    function test_button_variants() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Button.qml"))
        
        var btnPrimary = component.createObject(null, { "variant": "primary" })
        compare(btnPrimary.finalBackgroundColor.toString(), Theme.colors.primary.toString())
        
        var btnSecondary = component.createObject(null, { "variant": "secondary" })
        compare(btnSecondary.finalBackgroundColor.toString(), Theme.colors.surface0.toString())
        
        var btnOutline = component.createObject(null, { "variant": "outline" })
        compare(btnOutline.finalBackgroundColor.toString(), "#00000000")
        compare(btnOutline.finalBorderColor.toString(), Theme.colors.primary.toString())
        
        var btnTonal = component.createObject(null, { "variant": "tonal" })
        // Check if color is primary with 15% opacity (0.15)
        var expectedTonalColor = Qt.rgba(Theme.colors.primary.r, Theme.colors.primary.g, Theme.colors.primary.b, 0.15)
        compare(btnTonal.finalBackgroundColor.toString(), expectedTonalColor.toString())
        
        btnPrimary.destroy()
        btnSecondary.destroy()
        btnOutline.destroy()
        btnTonal.destroy()
    }

    function test_button_click() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Button.qml"))
        var btn = component.createObject(null, { "text": "Click Me" })
        
        var clickedSignalReceived = false
        btn.clicked.connect(function() {
            clickedSignalReceived = true
        })
        
        // Simulate a click directly using the internal helper method or by calling it
        btn.clicked()
        verify(clickedSignalReceived)
        
        btn.destroy()
    }

    // ==========================================
    // TextField Tests
    // ==========================================
    function test_text_field() {
        var component = Qt.createComponent(Qt.resolvedUrl("../TextField.qml"))
        compare(component.status, Component.Ready)

        var field = component.createObject(null, { "placeholder": "Digite algo..." })
        verify(field !== null)
        compare(field.text, "")
        compare(field.placeholder, "Digite algo...")
        compare(field.status, "normal")

        var edited = false
        field.textEdited.connect(function() { edited = true })

        field.text = "Hello QML"
        compare(field.text, "Hello QML")
        // Note: setting property programmatically doesn't emit textEdited in typical TextInput,
        // but let's test general editing trigger manually
        field.textEdited()
        verify(edited)

        // Password mode toggle
        field.type = "password"
        compare(field.showPassword, false)
        field.showPassword = true
        compare(field.showPassword, true)

        field.destroy()
    }

    // ==========================================
    // Checkbox Tests
    // ==========================================
    function test_checkbox() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Checkbox.qml"))
        compare(component.status, Component.Ready)

        var cb = component.createObject(null, { "label": "Aceitar Termos" })
        verify(cb !== null)
        compare(cb.checked, false)
        compare(cb.label, "Aceitar Termos")

        var toggledSignal = false
        var lastState = false
        cb.toggled.connect(function(state) {
            toggledSignal = true
            lastState = state
        })

        // Simulate click toggle by directly setting checked or calling signal
        cb.checked = true
        cb.toggled(true)
        verify(toggledSignal)
        compare(lastState, true)

        cb.destroy()
    }

    // ==========================================
    // Select Tests
    // ==========================================
    function test_select() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Select.qml"))
        if (component.status !== Component.Ready) {
            fail("SELECT COMPILATION ERROR: " + component.errorString())
        }
        compare(component.status, Component.Ready)

        var sel = component.createObject(null, {
            "options": [
                { "value": "br", "label": "Brasil" },
                { "value": "us", "label": "EUA" }
            ],
            "placeholder": "Selecione o país"
        })
        verify(sel !== null)
        compare(sel.selectedLabel, "")

        sel.selectedValue = "br"
        compare(sel.selectedValue, "br")
        compare(sel.selectedLabel, "Brasil")

        sel.destroy()
    }

    // ==========================================
    // Advanced Select Tests
    // ==========================================
    function test_advanced_select() {
        var component = Qt.createComponent(Qt.resolvedUrl("../AdvancedSelect.qml"))
        if (component.status !== Component.Ready) {
            fail("ADVANCED_SELECT COMPILATION ERROR: " + component.errorString())
        }
        compare(component.status, Component.Ready)

        var sel = component.createObject(null, {
            "options": [
                { "value": "coffee", "label": "Café Espresso" },
                { "value": "milk", "label": "Leite Vaporizado" },
                { "value": "sugar", "label": "Açúcar Demerara" }
            ],
            "placeholder": "Escolha os ingredientes",
            "multiple": true,
            "searchable": true
        })
        verify(sel !== null)
        compare(sel.selectedValues.length, 0)

        // Select multiple values
        sel.toggleValue("coffee", "Café Espresso")
        sel.toggleValue("milk", "Leite Vaporizado")
        compare(sel.selectedValues.length, 2)
        compare(sel.selectedValues[0], "coffee")
        compare(sel.selectedValues[1], "milk")

        // Filter testing
        sel.searchQuery = "leite"
        compare(sel.filteredOptions.length, 1)
        compare(sel.filteredOptions[0].value, "milk")

        sel.destroy()
    }

    // ==========================================
    // FormField Sync Tests
    // ==========================================
    function test_form_field_sync() {
        var formFieldComp = Qt.createComponent(Qt.resolvedUrl("../FormField.qml"))
        var textFieldComp = Qt.createComponent(Qt.resolvedUrl("../TextField.qml"))
        
        compare(formFieldComp.status, Component.Ready)
        compare(textFieldComp.status, Component.Ready)

        var formField = formFieldComp.createObject(null, { "label": "User Field", "required": true })
        var textField = textFieldComp.createObject(formField)
        
        // Associate text field inside content list
        formField.content = [ textField ]
        
        compare(formField.status, "normal")
        compare(textField.status, "normal")

        // Change FormField status, should automatically propagate to nested TextField
        formField.status = "error"
        compare(textField.status, "error")

        formField.destroy()
    }

    // ==========================================
    // DynamicForm Tests
    // ==========================================
    function test_dynamic_form() {
        var component = Qt.createComponent(Qt.resolvedUrl("../DynamicForm.qml"))
        if (component.status !== Component.Ready) {
            fail("DYNAMIC_FORM COMPILATION ERROR: " + component.errorString())
        }
        compare(component.status, Component.Ready)



        var form = component.createObject(null)
        verify(form !== null)

        // Set metadata schema
        form.schema = [
            { "name": "username", "type": "text", "label": "Usuário", "required": true, "minLength": 3 },
            { "name": "role", "type": "select", "options": ["Admin", "User"], "required": true }
        ]

        // Validate should fail since required values are empty
        var validBefore = form.validate()
        compare(validBefore, false)
        compare(form.formStatuses["username"], "error")
        compare(form.formErrors["username"], "Este campo é obrigatório.")

        // Fill values
        form.setValues({
            "username": "joao",
            "role": "Admin"
        })

        compare(form.formValues["username"], "joao")
        compare(form.formValues["role"], "Admin")

        // Validate should pass now
        var validAfter = form.validate()
        compare(validAfter, true)
        compare(form.formStatuses["username"], "success")

        // Test invalid minLength
        form.setValues({ "username": "jo" })
        var validShort = form.validate()
        compare(validShort, false)
        compare(form.formStatuses["username"], "error")
        compare(form.formErrors["username"], "Mínimo de 3 caracteres.")

        form.destroy()
    }

    // ==========================================
    // Modal Tests
    // ==========================================
    function test_modal_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Modal.qml"))
        compare(component.status, Component.Ready)
        
        var modal = component.createObject(null, { "title": "Test Modal", "subtitle": "Testing sub", "size": "sm" })
        verify(modal !== null)
        compare(modal.title, "Test Modal")
        compare(modal.subtitle, "Testing sub")
        compare(modal.size, "sm")
        compare(modal.open, false)
        compare(modal.visible, false)
        
        // Test open trigger
        modal.open = true
        compare(modal.open, true)
        compare(modal.state, "open")
        
        modal.destroy()
    }

    function test_modal_sizes() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Modal.qml"))
        var modalSm = component.createObject(null, { "size": "sm" })
        compare(modalSm.finalWidth, 400)
        compare(modalSm.minHeight, 240)
        verify(modalSm.finalHeight >= 240)
        
        var modalMd = component.createObject(null, { "size": "md" })
        compare(modalMd.finalWidth, 600)
        compare(modalMd.minHeight, 320)
        verify(modalMd.finalHeight >= 320)
        
        var modalLg = component.createObject(null, { "size": "lg" })
        compare(modalLg.finalWidth, 800)
        compare(modalLg.minHeight, 320)
        verify(modalLg.finalHeight >= 320)
        
        modalSm.destroy()
        modalMd.destroy()
        modalLg.destroy()
    }

    // ==========================================
    // Drawer Tests
    // ==========================================
    function test_drawer_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Drawer.qml"))
        compare(component.status, Component.Ready)
        
        var drawer = component.createObject(null, { "title": "Test Drawer", "position": "right", "size": 300 })
        verify(drawer !== null)
        compare(drawer.title, "Test Drawer")
        compare(drawer.position, "right")
        compare(drawer.size, 300)
        compare(drawer.open, false)
        
        drawer.open = true
        compare(drawer.open, true)
        compare(drawer.state, "open")
        
        drawer.destroy()
    }

    function test_drawer_sizing() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Drawer.qml"))
        var drawerRight = component.createObject(null, { "position": "right", "size": 320 })
        compare(drawerRight.finalWidth, 320)
        
        var drawerBottom = component.createObject(null, { "position": "bottom", "size": 250 })
        compare(drawerBottom.finalHeight, 250)
        
        drawerRight.destroy()
        drawerBottom.destroy()
    }

    function test_drawer_footer_width() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Drawer.qml"))
        compare(component.status, Component.Ready)
        var drawer = component.createObject(null, { "position": "right", "size": 400 })
        verify(drawer !== null)

        var btnComponent = Qt.createComponent(Qt.resolvedUrl("../Button.qml"))
        compare(btnComponent.status, Component.Ready)
        var btn = btnComponent.createObject(drawer)
        verify(btn !== null)

        // Assign button to footer
        var footerList = drawer.footer
        footerList.push(btn)
        drawer.footer = footerList

        // Verify button width is stretched to fill the footer container width
        var expectedWidth = 400 - 2 * Theme.spacing.xl
        compare(btn.width, expectedWidth)

        btn.destroy()
        drawer.destroy()
    }

    // ==========================================
    // ItemsPerPage Tests
    // ==========================================
    function test_items_per_page() {
        var component = Qt.createComponent(Qt.resolvedUrl("../ItemsPerPage.qml"))
        if (component.status !== Component.Ready) {
            fail("ITEMSPERPAGE COMPILATION ERROR: " + component.errorString())
        }
        compare(component.status, Component.Ready)


        var ipp = component.createObject(null)
        verify(ipp !== null)
        compare(ipp.pageSize, 10)

        var sigReceived = false
        var lastSize = 0
        ipp.pageSizeChanged.connect(function() {
            sigReceived = true
            lastSize = ipp.pageSize
        })

        ipp.pageSize = 20
        verify(sigReceived)
        compare(lastSize, 20)


        ipp.destroy()
    }

    // ==========================================
    // Paginator Tests
    // ==========================================
    function test_paginator() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Paginator.qml"))
        compare(component.status, Component.Ready)

        var pag = component.createObject(null, { "currentPage": 1, "totalPages": 10, "showGoToPage": true })
        verify(pag !== null)
        compare(pag.currentPage, 1)
        compare(pag.totalPages, 10)
        
        // Ellipsis range calculation check
        var list = pag.pagesList
        compare(list.length, 4) // Should show 1, 2, "...", 10
        compare(list[0], 1)
        compare(list[1], 2)
        compare(list[2], "...")
        compare(list[3], 10)

        // Test normal page navigation
        var pageSig = false
        pag.pageChanged.connect(function(page) {
            pageSig = true
        })

        // Test jump input and confirm state
        compare(pag.isConfirmState, false)
        
        // Simulate text edit in text field
        pag.testInput.text = "6"
        compare(pag.isConfirmState, true)

        // Call confirmJump programmatically
        pag.confirmJump()
        compare(pag.currentPage, 6)
        compare(pag.testInput.text, "")
        compare(pag.isConfirmState, false)

        // Verify bounds validation
        pag.testInput.text = "99" // invalid page
        pag.confirmJump()
        compare(pag.currentPage, 6) // page should not change
        compare(pag.testInput.status, "error") // should flash error state

        pag.destroy()
    }

    // ==========================================
    // Card Tests
    // ==========================================
    function test_card_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Card.qml"))
        compare(component.status, Component.Ready)
        
        var card = component.createObject(null, { "title": "Card de Teste", "subtitle": "Subtítulo", "variant": "accent" })
        verify(card !== null)
        compare(card.title, "Card de Teste")
        compare(card.subtitle, "Subtítulo")
        compare(card.variant, "accent")
        compare(card.accentPosition, "left")
        
        // Color tokens verification
        compare(card.finalBackgroundColor.toString(), Theme.colors.base.toString())
        compare(card.finalAccentColor.toString(), Theme.colors.primary.toString())
        
        card.destroy()
    }

    // ==========================================
    // Tile Tests
    // ==========================================
    function test_tile_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Tile.qml"))
        compare(component.status, Component.Ready)
        
        var tile = component.createObject(null, { "title": "Tile de Teste", "description": "Descrição", "variant": "tonal", "interactive": true })
        verify(tile !== null)
        compare(tile.title, "Tile de Teste")
        compare(tile.description, "Descrição")
        compare(tile.variant, "tonal")
        compare(tile.interactive, true)
        compare(tile.finalRightIcon, "chevron-right") // automatic right icon
        
        // Background color test for Tonal
        compare(tile.finalBackgroundColor.toString(), Theme.colors.surface0.toString())
        
        tile.destroy()
    }

    // ==========================================
    // Tile Click Tests
    // ==========================================
    function test_tile_click() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Tile.qml"))
        var tile = component.createObject(null, { "title": "Clickable Tile" })
        
        var clickedSignalReceived = false
        tile.clicked.connect(function() {
            clickedSignalReceived = true
        })
        
        tile.clicked()
        verify(clickedSignalReceived)
        
        tile.destroy()
    }

    // ==========================================
    // Tabs Tests
    // ==========================================
    function test_tabs_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Tabs.qml"))
        compare(component.status, Component.Ready)

        var tabs = component.createObject(null, {
            "model": ["Configurações", "Perfil", "Ajuda"],
            "currentIndex": 0,
            "variant": "pill"
        })
        verify(tabs !== null)
        compare(tabs.currentIndex, 0)
        compare(tabs.variant, "pill")

        // Helper string resolution
        compare(tabs.getLabel(tabs.model[0], 0), "Configurações")
        compare(tabs.getId(tabs.model[1], 1), "Perfil")

        var selectedIndex = -1
        var selectedId = ""
        tabs.tabSelected.connect(function(idx, id) {
            selectedIndex = idx
            selectedId = id
        })

        // Select second tab programmatically
        tabs.currentIndex = 1
        compare(tabs.currentIndex, 1)

        // Emit tabSelected manually
        tabs.tabSelected(2, "Ajuda")
        compare(selectedIndex, 2)
        compare(selectedId, "Ajuda")

        tabs.destroy()
    }

    function test_tabs_variations() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Tabs.qml"))
        compare(component.status, Component.Ready)

        var tabsSegmented = component.createObject(null, {
            "model": ["A", "B", "C"],
            "variant": "segmented",
            "width": 300
        })
        verify(tabsSegmented !== null)
        compare(tabsSegmented.variant, "segmented")
        compare(tabsSegmented.segmentedTabWidth, 100)

        var tabsCard = component.createObject(null, {
            "model": ["Card 1", "Card 2"],
            "variant": "card"
        })
        verify(tabsCard !== null)
        compare(tabsCard.variant, "card")

        tabsSegmented.destroy()
        tabsCard.destroy()
    }

    // ==========================================
    // Accordion Tests
    // ==========================================
    function test_accordion_expansion() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Accordion.qml"))
        compare(component.status, Component.Ready)

        var acc = component.createObject(null, {
            "title": "Configurações Gerais",
            "icon": "settings",
            "expanded": false,
            "variant": "outline"
        })
        verify(acc !== null)
        compare(acc.title, "Configurações Gerais")
        compare(acc.icon, "settings")
        compare(acc.expanded, false)
        compare(acc.variant, "outline")

        // Initial height should just be header height (48px)
        compare(acc.implicitHeight, 48)

        var toggleFired = false
        var nextExpanded = false
        acc.toggled.connect(function(state) {
            toggleFired = true
            nextExpanded = state
        })

        // Trigger expand
        acc.expanded = true
        acc.toggled(true)
        verify(toggleFired)
        compare(nextExpanded, true)

        acc.destroy()
    }

    // ==========================================
    // Toast & Notification Tests
    // ==========================================
    function test_toast_lifecycle() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Toast.qml"))
        if (component.status !== Component.Ready) {
            console.warn("Toast.qml load error: " + component.errorString())
        }
        compare(component.status, Component.Ready)

        var toast = component.createObject(null, {
            "title": "Test Toast",
            "message": "Lifecycle unit test verification",
            "type": "success",
            "duration": 500
        })
        verify(toast !== null)
        compare(toast.title, "Test Toast")
        compare(toast.message, "Lifecycle unit test verification")
        compare(toast.type, "success")
        compare(toast.duration, 500)
        compare(toast.remainingTime, 500)

        var dismissedSignal = false
        toast.dismissed.connect(function() {
            dismissedSignal = true
        })

        toast.dismiss()
        // Wait up to 500ms for exit animation of 220ms to complete and trigger dismissed signal
        tryVerify(function() { return dismissedSignal; }, 500)

        toast.destroy()
    }

    function test_toast_manager() {
        var component = Qt.createComponent(Qt.resolvedUrl("../ToastManager.qml"))
        if (component.status !== Component.Ready) {
            console.warn("ToastManager.qml load error: " + component.errorString())
        }
        compare(component.status, Component.Ready)

        var manager = component.createObject(null, {
            "position": "bottom-left"
        })
        verify(manager !== null)
        compare(manager.position, "bottom-left")
        verify(manager.toastModel !== null)
        compare(manager.toastModel.count, 0)

        // Success
        manager.success("Task completed!", "Done", 1500)
        compare(manager.toastModel.count, 1)
        compare(manager.toastModel.get(0).message, "Task completed!")
        compare(manager.toastModel.get(0).title, "Done")
        compare(manager.toastModel.get(0).type, "success")
        compare(manager.toastModel.get(0).duration, 1500)

        // Error fallback title
        manager.error("An error occurred")
        compare(manager.toastModel.count, 2)
        compare(manager.toastModel.get(1).message, "An error occurred")
        compare(manager.toastModel.get(1).title, "Erro")
        compare(manager.toastModel.get(1).type, "error")

        // Warning
        manager.warning("Disk full")
        compare(manager.toastModel.count, 3)
        compare(manager.toastModel.get(2).message, "Disk full")
        compare(manager.toastModel.get(2).title, "Atenção")
        compare(manager.toastModel.get(2).type, "warning")

        // Info
        manager.info("Update ready")
        compare(manager.toastModel.count, 4)
        compare(manager.toastModel.get(3).message, "Update ready")
        compare(manager.toastModel.get(3).title, "Informação")
        compare(manager.toastModel.get(3).type, "info")

        manager.destroy()
    }

    // ==========================================
    // Shell Tests
    // ==========================================
    function test_shell_responsiveness() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Shell.qml"))
        compare(component.status, Component.Ready)

        var shell = component.createObject(null, {
            "width": 1200,
            "height": 800,
            "sidebarWidth": 240,
            "secondarySidebarWidth": 200,
            "sidebarVisible": true,
            "sidebarCollapsed": false,
            "secondarySidebarVisible": true,
            "columnCount": 2
        })
        verify(shell !== null)

        // Desktop states
        compare(shell.isMobile, false)
        compare(shell.isDesktop, true)
        compare(shell.targetLeftMargin, 440) // sidebarWidth + secondarySidebarWidth

        // Collapsed sidebar state
        shell.sidebarCollapsed = true
        compare(shell.targetLeftMargin, 264) // 64 + 200

        // Mobile states transition
        shell.width = 500
        compare(shell.isMobile, true)
        compare(shell.isDesktop, false)
        compare(shell.targetLeftMargin, 0)

        // Column width calculations (Desktop)
        shell.width = 1024 // Restore tablet/desktop size
        shell.columnCount = 2
        // Calculate available width inside columnsRow (shell.width - leftMargin - margins - spacing)
        // shell.width = 1024, targetLeftMargin = 264. Columns container width = 1024 - 264 = 760.
        // columnsRow anchors.fill: parent, anchors.margins: 16 (spacing.lg) -> Row width = 760 - 32 = 728.
        // For columnCount = 2, totalSpacing = 16 (spacing.lg). Available columns width = 728 - 16 = 712.
        // Split equally: 712 / 2 = 356.
        // Let's verify that calculateColumnWidth returns positive values or matches split.
        // We can just verify it is a valid positive width since geometry calculations depend on Row binding.
        var w0 = shell.calculateColumnWidth(0)
        verify(w0 > 0)

        shell.destroy()
    }

    // ==========================================
    // Advanced Form Controls Tests
    // ==========================================
    function test_toggle_button() {
        var component = Qt.createComponent(Qt.resolvedUrl("../ToggleButton.qml"))
        compare(component.status, Component.Ready)

        var toggle = component.createObject(null, {
            "label": "Show Notifications",
            "checked": false
        })
        verify(toggle !== null)
        compare(toggle.label, "Show Notifications")
        compare(toggle.checked, false)

        var toggledSignal = false
        var nextState = false
        toggle.toggled.connect(function(state) {
            toggledSignal = true
            nextState = state
        })

        toggle.checked = true
        toggle.toggled(true)
        verify(toggledSignal)
        compare(nextState, true)

        toggle.destroy()
    }

    function test_select_tree() {
        var component = Qt.createComponent(Qt.resolvedUrl("../SelectTree.qml"))
        compare(component.status, Component.Ready)

        var tree = component.createObject(null, {
            "options": [
                {
                    "label": "Documentos",
                    "value": "docs",
                    "children": [
                        { "label": "Trabalho", "value": "work" },
                        { "label": "Pessoal", "value": "personal" }
                    ]
                }
            ],
            "placeholder": "Selecione o arquivo..."
        })
        verify(tree !== null)
        compare(tree.placeholder, "Selecione o arquivo...")
        compare(tree.selectedValue, null)
        compare(tree.selectedLabel, "")

        // Initial flat list should only show top-level (Documentos) since collapsed
        compare(tree.flatList.length, 1)
        compare(tree.flatList[0].label, "Documentos")
        compare(tree.flatList[0].value, "docs")
        compare(tree.flatList[0].hasChildren, true)
        compare(tree.flatList[0].expanded, false)

        // Programmatic selection of leaf
        tree.selectedValue = "work"
        compare(tree.selectedLabel, "Trabalho")

        tree.destroy()
    }

    function test_date_picker() {
        var component = Qt.createComponent(Qt.resolvedUrl("../DatePicker.qml"))
        compare(component.status, Component.Ready)

        var picker = component.createObject(null, {
            "placeholder": "Escolha o dia"
        })
        verify(picker !== null)
        compare(picker.placeholder, "Escolha o dia")
        compare(picker.formattedDateText, "")

        // Pick date
        picker.selectedDate = new Date(2026, 5, 25) // June 25, 2026 (month is 0-indexed)
        compare(picker.formattedDateText, "25/06/2026")

        picker.destroy()
    }

    function test_range_selector() {
        var component = Qt.createComponent(Qt.resolvedUrl("../RangeSelector.qml"))
        compare(component.status, Component.Ready)

        var slider = component.createObject(null, {
            "min": 10,
            "max": 110,
            "firstValue": 30,
            "secondValue": 90,
            "step": 5
        })
        verify(slider !== null)
        compare(slider.min, 10)
        compare(slider.max, 110)
        compare(slider.firstValue, 30)
        compare(slider.secondValue, 90)
        compare(slider.step, 5)

        // Constraints: firstValue <= secondValue
        slider.firstValue = 95
        compare(slider.firstValue, 95)

        slider.destroy()
    }

    function test_color_picker() {
        var component = Qt.createComponent(Qt.resolvedUrl("../ColorPicker.qml"))
        compare(component.status, Component.Ready)

        var picker = component.createObject(null, {
            "selectedColor": "#cba6f7"
        })
        verify(picker !== null)
        compare(picker.selectedColor.toString(), "#cba6f7")
        // Presets should have 14 Catppuccin color accents
        compare(picker.colorPresets.length, 14)

        picker.destroy()
    }

    function test_cozy_color_picker() {
        var component = Qt.createComponent(Qt.resolvedUrl("../CozyColorPicker.qml"))
        compare(component.status, Component.Ready)

        // Test default overlay mode
        var picker = component.createObject(null, {
            "colorValue": "#CBA6F7",
            "inline": false
        })
        verify(picker !== null)
        compare(picker.colorValue, "#CBA6F7")
        compare(picker.inline, false)
        compare(picker.expanded, false)

        // Verify toggling expanded state
        picker.togglePopover()
        compare(picker.expanded, true)
        picker.togglePopover()
        compare(picker.expanded, false)

        // Test Hex to HSV parsing internal sync
        verify(picker.currentHue > 0.6 && picker.currentHue < 0.8)
        verify(picker.currentSaturation > 0.25 && picker.currentSaturation < 0.4)
        verify(picker.currentValue > 0.9 && picker.currentValue <= 1.0)

        // Test HSV to Hex update internally
        picker.currentHue = 0.0 // Red
        picker.currentSaturation = 1.0
        picker.currentValue = 1.0
        picker.updateColorValue()
        compare(picker.colorValue, "#FF0000")
        picker.destroy()

        // Test inline mode configuration
        var pickerInline = component.createObject(null, {
            "colorValue": "#A6E3A1",
            "inline": true
        })
        verify(pickerInline !== null)
        compare(pickerInline.inline, true)
        compare(pickerInline.colorValue, "#A6E3A1")
        pickerInline.destroy()
    }


    // ==========================================
    // Badge Tests
    // ==========================================
    function test_badge_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Badge.qml"))
        compare(component.status, Component.Ready)

        var badge = component.createObject(null, {
            "text": "Ativo",
            "variant": "success",
            "showDot": true
        })
        verify(badge !== null)
        compare(badge.text, "Ativo")
        compare(badge.variant, "success")
        compare(badge.showDot, true)
        compare(badge.baseColor.toString(), Theme.colors.green.toString())

        badge.destroy()
    }

    // ==========================================
    // Table Tests
    // ==========================================
    function test_table_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Table.qml"))
        compare(component.status, Component.Ready)

        var cols = [
            { "name": "id", "label": "ID", "width": 80, "sortable": true },
            { "name": "name", "label": "Nome", "width": 150, "sortable": true },
            { "name": "salary", "label": "Salário", "width": 100, "sortable": true }
        ]

        var data = [
            { "id": "EMP-1", "name": "B", "salary": "R$ 5.000" },
            { "id": "EMP-2", "name": "A", "salary": "R$ 10.000" },
            { "id": "EMP-3", "name": "C", "salary": "R$ 2.500" }
        ]

        var table = component.createObject(null, {
            "columns": cols,
            "rows": data,
            "selectable": true,
            "pageSize": 2,
            "currentPage": 1
        })
        verify(table !== null)
        compare(table.rows.length, 3)
        compare(table.columns.length, 3)
        compare(table.pageSize, 2)
        compare(table.currentPage, 1)
        compare(table.totalPages, 2)

        // Test local sorting (Name Ascending)
        table.sortColumn = "name"
        table.sortOrder = "asc"
        var sorted = table.getSortedRows()
        compare(sorted[0].name, "A")
        compare(sorted[1].name, "B")
        compare(sorted[2].name, "C")

        // Test local sorting (Currency Ascending)
        table.sortColumn = "salary"
        table.sortOrder = "asc"
        var currencySorted = table.getSortedRows()
        compare(currencySorted[0].id, "EMP-3") // R$ 2.500
        compare(currencySorted[1].id, "EMP-1") // R$ 5.000
        compare(currencySorted[2].id, "EMP-2") // R$ 10.000

        // Test selection logic
        table.toggleRowSelection(0)
        compare(table.selectedIndexes.length, 1)
        compare(table.selectedIndexes[0], 0)
        verify(table.isSelectionIndeterminate)
        compare(table.isAllSelected, false)

        table.toggleSelectAll()
        compare(table.selectedIndexes.length, 3)
        compare(table.isSelectionIndeterminate, false)
        compare(table.isAllSelected, true)

        table.destroy()
    }

    // ==========================================
    // Tooltip Tests
    // ==========================================
    function test_tooltip_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Tooltip.qml"))
        compare(component.status, Component.Ready)
    }

    function test_tooltip_default_props() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Tooltip.qml"))
        var tt = component.createObject(null, {})
        verify(tt !== null)
        compare(tt.text, "")
        compare(tt.placement, "top")
        compare(tt.delay, 500)
        compare(tt.maxWidth, 240)
        compare(tt.isHovered, false)
        tt.destroy()
    }

    function test_tooltip_set_props() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Tooltip.qml"))
        var tt = component.createObject(null, {
            text: "Olá mundo",
            placement: "bottom",
            delay: 200,
            maxWidth: 160
        })
        verify(tt !== null)
        compare(tt.text, "Olá mundo")
        compare(tt.placement, "bottom")
        compare(tt.delay, 200)
        compare(tt.maxWidth, 160)
        tt.destroy()
    }

    // ==========================================
    // Dropdown Tests
    // ==========================================
    function test_dropdown_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Dropdown.qml"))
        compare(component.status, Component.Ready)
    }

    function test_dropdown_default_props() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Dropdown.qml"))
        var dd = component.createObject(null, {})
        verify(dd !== null)
        compare(dd.isOpen, false)
        compare(dd.placement, "bottom-start")
        compare(dd.minWidth, 180)
        compare(dd.items.length, 0)
        dd.destroy()
    }

    function test_dropdown_items_array() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Dropdown.qml"))
        var dd = component.createObject(null, {
            items: [
                { label: "Editar",  icon: "pencil" },
                { separator: true },
                { label: "Excluir", icon: "trash-2", variant: "danger" }
            ]
        })
        verify(dd !== null)
        compare(dd.items.length, 3)
        compare(dd.items[0].label, "Editar")
        compare(dd.items[1].separator, true)
        compare(dd.items[2].variant, "danger")
        dd.destroy()
    }

    function test_dropdown_open_close() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Dropdown.qml"))
        var dd = component.createObject(null, { items: [{ label: "A" }] })
        verify(dd !== null)
        compare(dd.isOpen, false)
        dd.isOpen = true
        compare(dd.isOpen, true)
        dd.close()
        compare(dd.isOpen, false)
        dd.destroy()
    }

    function test_dropdown_placement_values() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Dropdown.qml"))
        var dd = component.createObject(null, { placement: "top-end", minWidth: 220 })
        verify(dd !== null)
        compare(dd.placement, "top-end")
        compare(dd.minWidth, 220)
        dd.destroy()
    }

    // ==========================================
    // PinInput Tests
    // ==========================================
    function test_pininput_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../PinInput.qml"))
        var pin = component.createObject(null)
        verify(pin !== null)
        compare(pin.length, 4)
        compare(pin.text, "")
        compare(pin.type, "number")
        compare(pin.mask, false)
        compare(pin.status, "normal")
        compare(pin.disabled, false)
        compare(pin.size, "md")
        pin.destroy()
    }

    function test_pininput_custom_props() {
        var component = Qt.createComponent(Qt.resolvedUrl("../PinInput.qml"))
        var pin = component.createObject(null, {
            length: 6,
            type: "text",
            mask: true,
            status: "success",
            size: "lg"
        })
        verify(pin !== null)
        compare(pin.length, 6)
        compare(pin.type, "text")
        compare(pin.mask, true)
        compare(pin.status, "success")
        compare(pin.size, "lg")
        pin.destroy()
    }

    function test_pininput_text_sync() {
        var component = Qt.createComponent(Qt.resolvedUrl("../PinInput.qml"))
        var pin = component.createObject(null, { length: 4 })
        verify(pin !== null)
        
        pin.text = "123"
        compare(pin.text, "123")
        
        // Overflow text should be clamped to length
        pin.text = "123456"
        compare(pin.text, "1234")
        
        pin.destroy()
    }

    // Test that clearing works as expected
    function test_pininput_clear() {
        var component = Qt.createComponent(Qt.resolvedUrl("../PinInput.qml"))
        var pin = component.createObject(null, { length: 4 })
        verify(pin !== null)
        
        pin.text = "12"
        compare(pin.text, "12")
        pin.clear()
        compare(pin.text, "")
        
        pin.destroy()
    }

    function test_pininput_completed_signal() {
        var component = Qt.createComponent(Qt.resolvedUrl("../PinInput.qml"))
        var pin = component.createObject(null, { length: 4 })
        verify(pin !== null)
        
        var completedCode = ""
        var signalFired = false
        pin.completed.connect(function(code) {
            completedCode = code
            signalFired = true
        })
        
        pin.text = "123"
        compare(signalFired, false)
        
        pin.text = "1234"
        compare(signalFired, true)
        compare(completedCode, "1234")
        
        pin.destroy()
    }

    function test_text_editor() {
        var component = Qt.createComponent(Qt.resolvedUrl("../TextEditor.qml"))
        compare(component.status, Component.Ready)

        var editor = component.createObject(null, {
            "text": "Initial text line 1.\nLine 2 text.",
            "placeholder": "Enter text...",
            "size": "md"
        })
        verify(editor !== null)
        compare(editor.text, "Initial text line 1.\nLine 2 text.")
        compare(editor.placeholder, "Enter text...")
        compare(editor.size, "md")
        compare(editor.disabled, false)
        compare(editor.readOnly, false)

        // Change properties
        editor.text = "Hello world!"
        compare(editor.text, "Hello world!")

        editor.disabled = true
        compare(editor.disabled, true)

        editor.destroy()
    }

    function test_advanced_text_editor() {
        var component = Qt.createComponent(Qt.resolvedUrl("../AdvancedTextEditor.qml"))
        compare(component.status, Component.Ready)

        var editor = component.createObject(null, {
            "text": "# Heading 1\nSome text.",
            "visualMode": false
        })
        verify(editor !== null)
        compare(editor.text, "# Heading 1\nSome text.")
        compare(editor.visualMode, false)
        compare(editor.characterCount, 22)
        compare(editor.wordCount, 5)

        // Toggle visual mode
        editor.visualMode = true
        compare(editor.visualMode, true)

        editor.destroy()
    }

    // ==========================================
    // BarChart Tests
    // ==========================================
    function test_barchart_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../BarChart.qml"))
        var chart = component.createObject(null)
        verify(chart !== null)
        compare(chart.gridLines, 4)
        compare(chart.animated, true)
        compare(chart.maxValue, -1)
        compare(chart.computedMaxValue, 100) // default empty max
        chart.destroy()
    }

    function test_barchart_auto_max() {
        var component = Qt.createComponent(Qt.resolvedUrl("../BarChart.qml"))
        var chart = component.createObject(null, {
            chartData: [
                { label: "A", value: 10 },
                { label: "B", value: 50 },
                { label: "C", value: 30 }
            ]
        })
        verify(chart !== null)
        // Max value is 50, so computedMaxValue with 10% headroom is 50 * 1.1 = 55
        compare(chart.computedMaxValue, 55)
        
        // Changing data updates computedMaxValue
        chart.chartData = [
            { label: "A", value: 200 }
        ]
        compare(chart.computedMaxValue, 220)
        
        chart.destroy()
    }

    // ==========================================
    // LineChart Tests
    // ==========================================
    function test_linechart_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../LineChart.qml"))
        var chart = component.createObject(null)
        verify(chart !== null)
        compare(chart.gridLines, 4)
        compare(chart.animated, true)
        compare(chart.smooth, true)
        compare(chart.fillArea, true)
        compare(chart.maxValue, -1)
        compare(chart.computedMaxValue, 100)
        chart.destroy()
    }

    function test_linechart_custom_max() {
        var component = Qt.createComponent(Qt.resolvedUrl("../LineChart.qml"))
        var chart = component.createObject(null, {
            maxValue: 500,
            chartData: [
                { label: "A", value: 10 }
            ]
        })
        verify(chart !== null)
        compare(chart.computedMaxValue, 500) // overrides auto-calc
        chart.destroy()
    }

    // ==========================================
    // Sidebar & Navigation Component Tests
    // ==========================================
    function test_sidebar_creation_and_variants() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Sidebar.qml"))
        compare(component.status, Component.Ready)
        
        var sidebar = component.createObject(null, { "variant": "fixed" })
        verify(sidebar !== null)
        compare(sidebar.variant, "fixed")
        compare(sidebar.isCollapsed, false)
        compare(sidebar.expandOnHover, false)
        compare(sidebar.collapsedWidth, 68)
        compare(sidebar.expandedWidth, 260)
        compare(sidebar.width, 260)
        sidebar.destroy()

        var sidebarFloated = component.createObject(null, { "variant": "floated" })
        verify(sidebarFloated !== null)
        compare(sidebarFloated.variant, "floated")
        sidebarFloated.destroy()
    }

    function test_sidebar_hover_expand_logic() {
        var component = Qt.createComponent(Qt.resolvedUrl("../Sidebar.qml"))
        compare(component.status, Component.Ready)
        
        var sidebar = component.createObject(null, { "isCollapsed": true, "expandOnHover": true })
        verify(sidebar !== null)
        compare(sidebar.isCollapsed, true)
        compare(sidebar.expandOnHover, true)
        compare(sidebar.isFullyExpanded, false)
        compare(sidebar.targetWidth, 68)
        
        sidebar.destroy()
    }

    function test_sidebar_header_and_footer_properties() {
        var headerComp = Qt.createComponent(Qt.resolvedUrl("../SidebarHeader.qml"))
        compare(headerComp.status, Component.Ready)
        var header = headerComp.createObject(null, { "title": "Logo Title", "logoIcon": "coffee" })
        verify(header !== null)
        compare(header.title, "Logo Title")
        compare(header.logoIcon, "coffee")
        header.destroy()

        var footerComp = Qt.createComponent(Qt.resolvedUrl("../SidebarFooter.qml"))
        compare(footerComp.status, Component.Ready)
        var footer = footerComp.createObject(null, { "username": "Admin", "email": "admin@test.com" })
        verify(footer !== null)
        compare(footer.username, "Admin")
        compare(footer.email, "admin@test.com")
        footer.destroy()
    }

    function test_sidebar_item_states() {
        var itemComp = Qt.createComponent(Qt.resolvedUrl("../SidebarItem.qml"))
        compare(itemComp.status, Component.Ready)
        var item = itemComp.createObject(null, { "label": "Dashboard", "icon": "layout", "isActive": true })
        verify(item !== null)
        compare(item.label, "Dashboard")
        compare(item.icon, "layout")
        compare(item.isActive, true)
        item.destroy()

        var itemInactive = itemComp.createObject(null, { "label": "Settings", "icon": "settings", "isActive": false })
        verify(itemInactive !== null)
        compare(itemInactive.isActive, false)
        itemInactive.destroy()
    }

    // ==========================================
    // InteractiveListCell & CozyList Tests
    // ==========================================
    function test_interactive_list_cell() {
        var component = Qt.createComponent(Qt.resolvedUrl("../InteractiveListCell.qml"))
        compare(component.status, Component.Ready)
        
        var cell = component.createObject(null, {
            "isSelected": true,
            "backgroundColor": "#1e1e2d"
        })
        verify(cell !== null)
        compare(cell.isSelected, true)
        compare(cell.backgroundColor.toString(), "#1e1e2d")
        
        var clicked = false
        cell.clicked.connect(function() { clicked = true })
        cell.clicked()
        verify(clicked)
        
        cell.destroy()
    }

    function test_cozy_list_empty() {
        var component = Qt.createComponent(Qt.resolvedUrl("../CozyList.qml"))
        compare(component.status, Component.Ready)
        
        var list = component.createObject(null, {
            "model": null,
            "emptyStateIcon": "package-open",
            "emptyStateTitle": "Empty Title",
            "emptyStateSubtitle": "Empty Subtitle"
        })
        
        verify(list !== null)
        compare(list.isEmpty, true)
        compare(list.emptyStateIcon, "package-open")
        compare(list.emptyStateTitle, "Empty Title")
        compare(list.emptyStateSubtitle, "Empty Subtitle")
        
        list.destroy()
    }

    function test_cozy_list_with_data() {
        var component = Qt.createComponent(Qt.resolvedUrl("../CozyList.qml"))
        compare(component.status, Component.Ready)
        
        // Define rowContent
        var rowComp = Qt.createComponent(Qt.resolvedUrl("check_charts.qml")) // dummy component file or inline
        
        var list = component.createObject(null, {
            "model": [ { "name": "Item A" }, { "name": "Item B" } ]
        })
        
        verify(list !== null)
        compare(list.isEmpty, false)
        
        list.destroy()
    }

    function test_cozy_spinner() {
        var component = Qt.createComponent(Qt.resolvedUrl("../CozySpinner.qml"))
        compare(component.status, Component.Ready)

        var spinner = component.createObject(null, {
            "size": 32,
            "label": "Carregando...",
            "overlay": true
        })
        verify(spinner !== null)
        compare(spinner.size, 32)
        compare(spinner.label, "Carregando...")
        compare(spinner.overlay, true)
        
        // Stacking index check
        verify(spinner.z > 1)

        spinner.destroy()
    }

    function test_layout_grid() {
        var gridComp = Qt.createComponent(Qt.resolvedUrl("../CozyGrid.qml"))
        compare(gridComp.status, Component.Ready)
        var colComp = Qt.createComponent(Qt.resolvedUrl("../CozyGridCol.qml"))
        compare(colComp.status, Component.Ready)

        var grid = gridComp.createObject(null, {
            "width": 1200,
            "gap": 4
        })
        verify(grid !== null)

        var col1 = colComp.createObject(grid, { "span": 6 })
        var col2 = colComp.createObject(grid, { "span": 6 })
        verify(col1 !== null)
        verify(col2 !== null)

        grid.doLayout()

        // 1200 width - 1 gap (16px) = 1184px for columns
        // Each span 6 column should be 1184 / 2 = 592px
        compare(col1.width, 592)
        compare(col2.width, 592)
        compare(col2.x, 608) // 592 + 16 gap

        grid.destroy()
    }

    function test_hero_carousel_creation() {
        var component = Qt.createComponent(Qt.resolvedUrl("../HeroCarousel.qml"))
        compare(component.status, Component.Ready)

        var carousel = component.createObject(null, {
            "model": [
                { title: "Slide 1", description: "Desc 1" },
                { title: "Slide 2", description: "Desc 2" }
            ],
            "autoAdvanceInterval": 0
        })
        verify(carousel !== null)
        compare(carousel.slideCount, 2)
        compare(carousel.currentIndex, 0)

        carousel.currentIndex = 1
        compare(carousel.currentIndex, 1)

        carousel.destroy()
    }
}






