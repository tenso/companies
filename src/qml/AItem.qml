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
    KeyNavigation.left: prevFocus
    KeyNavigation.backtab: prevFocus

    signal select(int index)

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
        enabled: !showEdit
        onClicked: {
            root.select(index);
        }
    }
}
