import QtQuick 2.9

FocusScope {
    id: root
    property variant itemData
    property string role: ""
    property bool showEdit: false
    property string selectedRole: ""
    property string roleSelector: ""
    property string focusRole: ""
    property variant prevFocus: null
    property string inputMode: ""
    property variant colorMode
    property color fontColor: tm.editFg(root.showEdit)
    KeyNavigation.left: prevFocus
    KeyNavigation.backtab: prevFocus

    signal select(int index)

    function getColor() {
        var val = 0;
        var i = 0;
        if (colorMode) {
            if (colorMode.limits) {
                val = itemData ? itemData[role] : 0;
                if (val <= colorMode.limits[0]) {
                    return colorMode.colors[0];
                }
                if (val >= colorMode.limits[1]) {
                    return colorMode.colors[2];
                }
                return colorMode.colors[1];
            }
        }
        return tm.editBg(root.showEdit)
    }

    function formatIn(text) {
        if (inputMode === "%" && text !== "") {
            return (parseFloat(text) * 100).toFixed(2) + "%";
        }
        return text;
    }

    function formatOut(text) {
        if (inputMode === "%" && text !== "") {
            return (parseFloat(text) / 100);
        }
        return text;
    }

    onRoleSelectorChanged: {
        if (role !== "" && roleSelector === role) {
            forceActiveFocus();
        }
    }

    onActiveFocusChanged: {
        if (role !== "" && activeFocus) {
            var nextParent = parent;
            while (nextParent) {
                if (typeof(nextParent.selectedRole) !== "undefined") {
                    nextParent.selectedRole = role;
                }
                if (typeof(nextParent.__aListParent) !== "undefined") {
                    break;
                }
                nextParent = nextParent.parent;
            }
        }
    }
    MouseArea {
        anchors.fill: parent
        enabled: !root.showEdit
        onClicked: {
            root.select(index);
        }
    }
}
