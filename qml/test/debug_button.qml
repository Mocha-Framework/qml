import QtQuick 2.15

Item {
    Component {
        id: comp
        PlaygroundButton {}
    }
    Component.onCompleted: {
        var obj = comp.createObject(null)
        if (obj === null) {
            console.error("Error creating PlaygroundButton:", comp.errorString())
        } else {
            console.log("PlaygroundButton created successfully")
        }
        Qt.quit()
    }
}
