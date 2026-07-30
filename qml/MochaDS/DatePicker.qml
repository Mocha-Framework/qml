import QtQuick 2.15
import QtQuick.Window 2.15

Item {
    id: root

    // ==========================================
    // Public API (Properties)
    // ==========================================
    property var selectedDate: null
    property string placeholder: "Selecione uma data..."
    property string format: "dd/MM/yyyy"
    property bool disabled: false
    property string size: "md"

    // Popup expanded state
    property bool expanded: false

    // Smart flip: true when popup should open upward
    property bool openUpward: false

    // Fixed popup height (used for flip calculation)
    readonly property int popupHeight: 320

    // Calendar view states
    property int viewMonth: new Date().getMonth()
    property int viewYear: new Date().getFullYear()
    property var calendarDays: []

    // Size tokens mapping
    readonly property real currentHeight: {
        if (size === "sm") return 32
        if (size === "lg") return 48
        return 40 // "md"
    }

    readonly property real currentPadding: {
        if (size === "sm") return Theme.spacing.sm
        if (size === "lg") return Theme.spacing.lg
        return Theme.spacing.md
    }

    readonly property real currentFontSize: {
        if (size === "sm") return Theme.typography.sizeSm
        if (size === "lg") return Theme.typography.sizeLg
        return Theme.typography.sizeMd
    }

    z: expanded ? 100 : 0

    implicitWidth: 280
    implicitHeight: currentHeight
    width: implicitWidth
    height: implicitHeight

    opacity: disabled ? 0.6 : 1.0
    Behavior on opacity { NumberAnimation { duration: 150 } }

    // Text representation of selected date
    readonly property string formattedDateText: {
        if (!selectedDate) return "";
        var d = selectedDate.getDate();
        var m = selectedDate.getMonth() + 1;
        var y = selectedDate.getFullYear();
        var pad = function(val) { return val < 10 ? "0" + val : val; };
        return pad(d) + "/" + pad(m) + "/" + y;
    }

    // Outer box panel
    Rectangle {
        id: triggerBox
        anchors.fill: parent
        color: disabled ? Theme.colors.crust : Theme.colors.mantle
        radius: root.size === "sm" ? Theme.geometry.radiusSm : (root.size === "lg" ? Theme.geometry.radiusLg : Theme.geometry.radiusMd)
        border.color: disabled ? Theme.colors.surface0 : (expanded ? Theme.colors.primary : (mouseArea.containsMouse ? Theme.colors.overlay0 : Theme.colors.surface1))
        border.width: expanded ? Theme.geometry.borderMd : Theme.geometry.borderSm

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    // Trigger content
    Row {
        id: triggerLayout
        anchors.fill: parent
        anchors.leftMargin: root.currentPadding
        anchors.rightMargin: root.currentPadding
        spacing: Theme.spacing.sm

        LucideIcon {
            name: "calendar"
            size: root.currentHeight * 0.45
            color: root.disabled ? Theme.colors.overlay0 : Theme.colors.subtext1
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: root.formattedDateText !== "" ? root.formattedDateText : root.placeholder
            font.family: Theme.typography.family
            font.pixelSize: root.currentFontSize
            color: root.formattedDateText !== "" ? (root.disabled ? Theme.colors.overlay0 : Theme.colors.text) : Theme.colors.overlay0
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 32 - parent.spacing * 2
            elide: Text.ElideRight
            antialiasing: true
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: !root.disabled
        onClicked: {
            if (!expanded) {
                // Reset calendar view to selected date or current date
                var start = selectedDate ? new Date(selectedDate) : new Date();
                viewMonth = start.getMonth();
                viewYear = start.getFullYear();
                updateCalendar();

                // Smart flip: detect if there is room below
                var windowItem = root;
                while (windowItem.parent !== null) windowItem = windowItem.parent;
                var posInWindow = root.mapToItem(windowItem, 0, 0);
                var spaceBelow = windowItem.height - (posInWindow.y + root.height);
                root.openUpward = spaceBelow < (root.popupHeight + Theme.spacing.md);
            }
            root.expanded = !root.expanded;
        }
    }

    // Calendar Popover Container
    Rectangle {
        id: popupContainer
        x: 0
        // Flip: open above trigger when there's not enough space below
        y: root.openUpward
           ? -(popupContainer.height + Theme.spacing.xs)
           : (root.height + Theme.spacing.xs)
        width: 300
        height: root.expanded ? root.popupHeight : 0
        visible: height > 0
        clip: true
        z: 99999

        color: Theme.colors.mantle
        border.color: Theme.colors.surface1
        border.width: Theme.geometry.borderSm
        radius: Theme.geometry.radiusMd

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        // Calendar Header (Month Selector)
        Item {
            id: calendarHeader
            width: parent.width - Theme.spacing.md * 2
            height: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.spacing.sm

            LucideIcon {
                name: "chevron-left"
                size: 20
                color: prevMonthArea.containsMouse ? Theme.colors.text : Theme.colors.overlay1
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: prevMonthArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (viewMonth === 0) {
                            viewMonth = 11;
                            viewYear--;
                        } else {
                            viewMonth--;
                        }
                        updateCalendar();
                    }
                }
            }

            Text {
                text: {
                    var months = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
                    return months[viewMonth] + " " + viewYear;
                }
                font.family: Theme.typography.familyBold
                font.pixelSize: Theme.typography.sizeMd
                color: Theme.colors.text
                anchors.centerIn: parent
                antialiasing: true
            }

            LucideIcon {
                name: "chevron-right"
                size: 20
                color: nextMonthArea.containsMouse ? Theme.colors.text : Theme.colors.overlay1
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    id: nextMonthArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (viewMonth === 11) {
                            viewMonth = 0;
                            viewYear++;
                        } else {
                            viewMonth++;
                        }
                        updateCalendar();
                    }
                }
            }
        }

        // Weekday Names Row
        Grid {
            id: weekdayRow
            columns: 7
            width: parent.width - Theme.spacing.md * 2
            height: 20
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: calendarHeader.bottom
            anchors.topMargin: Theme.spacing.xs

            Repeater {
                model: ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"]
                delegate: Text {
                    text: modelData
                    width: weekdayRow.width / 7
                    horizontalAlignment: Text.AlignHCenter
                    font.family: Theme.typography.familyMedium
                    font.pixelSize: Theme.typography.sizeXs
                    color: Theme.colors.overlay1
                }
            }
        }

        // Days Grid
        Grid {
            id: daysGrid
            columns: 7
            rows: 6
            width: parent.width - Theme.spacing.md * 2
            height: 220
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: weekdayRow.bottom
            anchors.topMargin: Theme.spacing.xs
            spacing: 0

            Repeater {
                model: root.calendarDays
                delegate: Rectangle {
                    id: dayCell
                    width: daysGrid.width / 7
                    height: daysGrid.height / 6
                    color: "transparent"

                    // Inner circle highlighting active date
                    Rectangle {
                        width: Math.min(parent.width, parent.height) - 4
                        height: width
                        radius: width / 2
                        anchors.centerIn: parent
                        color: {
                            if (isSameDate(modelData.day, modelData.month, modelData.year, root.selectedDate)) {
                                return Theme.colors.primary;
                            }
                            return cellMouseArea.containsMouse ? Theme.colors.surface0 : "transparent";
                        }

                        Text {
                            text: modelData.day
                            font.family: Theme.typography.family
                            font.pixelSize: Theme.typography.sizeSm
                            anchors.centerIn: parent
                            color: {
                                if (isSameDate(modelData.day, modelData.month, modelData.year, root.selectedDate)) {
                                    return Theme.colors.base;
                                }
                                return modelData.isCurrentMonth ? Theme.colors.text : Theme.colors.surface2;
                            }
                            antialiasing: true
                        }
                    }

                    MouseArea {
                        id: cellMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            root.selectedDate = new Date(modelData.year, modelData.month, modelData.day);
                            root.expanded = false;
                        }
                    }
                }
            }
        }
    }

    // Click outside catcher
    MouseArea {
        id: outsideClickCatcher
        enabled: root.expanded
        z: 99998
        hoverEnabled: false
        propagateComposedEvents: true

        onPressed: {
            var clickPos = mapToItem(popupContainer, mouse.x, mouse.y);
            if (clickPos.x >= 0 && clickPos.x <= popupContainer.width &&
                clickPos.y >= 0 && clickPos.y <= popupContainer.height) {
                mouse.accepted = false;
            } else {
                mouse.accepted = true;
            }
        }

        onClicked: {
            var clickPos = mapToItem(popupContainer, mouse.x, mouse.y);
            if (clickPos.x >= 0 && clickPos.x <= popupContainer.width &&
                clickPos.y >= 0 && clickPos.y <= popupContainer.height) {
                mouse.accepted = false;
            } else {
                root.expanded = false;
            }
        }
    }

    Component.onCompleted: {
        // Find top-level root element and reparent click catcher to it
        var rootItem = root;
        while (rootItem.parent !== null) {
            rootItem = rootItem.parent;
        }
        outsideClickCatcher.parent = rootItem;
        outsideClickCatcher.anchors.fill = rootItem;

        updateCalendar();

        // Connect to parent Flickable content changes to close on scroll
        var p = root.parent;
        while (p) {
            if (p.hasOwnProperty("flickableDirection") || p.hasOwnProperty("contentY")) {
                p.contentYChanged.connect(function() { root.expanded = false; });
                p.contentXChanged.connect(function() { root.expanded = false; });
            }
            p = p.parent;
        }
    }

    onExpandedChanged: {
        if (expanded) {
            hoistPopup();
        } else {
            restorePopup();
        }
    }

    // Window size change detector
    Connections {
        target: root.Window.window
        enabled: target !== null
        function onWidthChanged() { root.expanded = false; }
        function onHeightChanged() { root.expanded = false; }
    }

    function hoistPopup() {
        var rootItem = root;
        while (rootItem.parent !== null) {
            rootItem = rootItem.parent;
        }
        if (rootItem && rootItem !== root) {
            popupContainer.parent = rootItem;
            popupContainer.x = Qt.binding(function() {
                var pos = root.mapToItem(popupContainer.parent, 0, 0);
                return pos.x;
            });
            popupContainer.y = Qt.binding(function() {
                var pos = root.mapToItem(popupContainer.parent, 0, 0);
                return root.openUpward
                    ? (pos.y - popupContainer.height - Theme.spacing.xs)
                    : (pos.y + root.height + Theme.spacing.xs);
            });
            var nextZ = Theme.getNextMaxZ();
            popupContainer.z = nextZ;
            outsideClickCatcher.z = nextZ - 1;
        }
    }

    function restorePopup() {
        popupContainer.parent = root;
        popupContainer.x = 0;
        popupContainer.y = Qt.binding(function() {
            return root.openUpward
               ? -(popupContainer.height + Theme.spacing.xs)
               : (root.height + Theme.spacing.xs);
        });
    }


    function isSameDate(day, month, year, date) {
        if (!date) return false;
        return date.getDate() === day && date.getMonth() === month && date.getFullYear() === year;
    }

    function getDaysInMonth(year, month) {
        // month is 0-indexed. return days in that month.
        return new Date(year, month + 1, 0).getDate();
    }

    function getFirstDayOfWeek(year, month) {
        return new Date(year, month, 1).getDay();
    }

    function updateCalendar() {
        var days = [];
        var firstDayIndex = getFirstDayOfWeek(viewYear, viewMonth);
        
        // Month calculations (wrapping around year)
        var prevMonth = viewMonth - 1;
        var prevYear = viewYear;
        if (prevMonth < 0) {
            prevMonth = 11;
            prevYear--;
        }
        
        var nextMonth = viewMonth + 1;
        var nextYear = viewYear;
        if (nextMonth > 11) {
            nextMonth = 0;
            nextYear++;
        }

        var prevMonthDays = getDaysInMonth(prevYear, prevMonth);
        var currMonthDays = getDaysInMonth(viewYear, viewMonth);
        
        // Fill previous month days
        for (var i = firstDayIndex - 1; i >= 0; i--) {
            days.push({
                day: prevMonthDays - i,
                month: prevMonth,
                year: prevYear,
                isCurrentMonth: false
            });
        }
        
        // Fill current month days
        for (var i = 1; i <= currMonthDays; i++) {
            days.push({
                day: i,
                month: viewMonth,
                year: viewYear,
                isCurrentMonth: true
            });
        }
        
        // Fill next month days
        var nextMonthDaysNeeded = 42 - days.length;
        for (var i = 1; i <= nextMonthDaysNeeded; i++) {
            days.push({
                day: i,
                month: nextMonth,
                year: nextYear,
                isCurrentMonth: false
            });
        }
        
        root.calendarDays = days;
    }
}
