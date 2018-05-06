import QtQuick 2.9

FocusScope {
    id: scope
    property string role: ""
    property variant model

    property variant prevFocus: null
    property string roleSelector: ""
    KeyNavigation.left: prevFocus
    KeyNavigation.backtab: prevFocus

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
                    break;
                }
                nextParent = nextParent.parent;
            }
        }
    }
}
