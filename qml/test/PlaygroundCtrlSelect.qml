import QtQuick 2.15
import MochaDS as DS

Column {
    id: ctrlBase
    property string label: ""
    property alias model: sel.options
    property int currentIndex: 0
    spacing: DS.Theme.spacing.xs
    width: parent.width

    onCurrentIndexChanged: {
        updateSelectFromIndex();
    }

    onModelChanged: {
        updateSelectFromIndex();
    }

    function updateSelectFromIndex() {
        if (sel.options && currentIndex >= 0 && currentIndex < sel.options.length) {
            var opt = sel.options[currentIndex];
            if (typeof opt === 'object' && opt !== null) {
                sel.selectedValue = opt.value;
                sel.selectedLabel = opt.label;
            } else {
                sel.selectedValue = opt;
                sel.selectedLabel = String(opt);
            }
        }
    }

    Text {
        text: ctrlBase.label
        font.family: DS.Theme.typography.familyMedium
        font.pixelSize: DS.Theme.typography.sizeSm
        color: DS.Theme.colors.subtext0
    }

    DS.Select {
        id: sel
        width: parent.width
        height: 40
        
        onValueChanged: {
            if (options) {
                for (var i = 0; i < options.length; i++) {
                    var opt = options[i];
                    var val = (typeof opt === 'object' && opt !== null) ? opt.value : opt;
                    if (val === sel.selectedValue) {
                        if (ctrlBase.currentIndex !== i) {
                            ctrlBase.currentIndex = i;
                        }
                        break;
                    }
                }
            }
        }
    }
}
