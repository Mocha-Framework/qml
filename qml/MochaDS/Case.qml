import QtQuick 2.15

Item {
    readonly property bool isCase: true
    property var value: null
    property bool isDefault: false
    default property alias contentData: caseContent.data
    visible: false

    implicitWidth: caseContent.childrenRect.width
    implicitHeight: caseContent.childrenRect.height
    width: implicitWidth
    height: implicitHeight

    Item {
        id: caseContent
        width: childrenRect.width
        height: childrenRect.height
    }
}
