import QtQuick 2.15
import QtCharts

Item {
    width: 100
    height: 100
    ChartView {
        anchors.fill: parent
    }
    Component.onCompleted: {
        console.log("QtCharts is available")
        Qt.quit()
    }
}
