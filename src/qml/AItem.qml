import QtQuick 2.9

FocusScope {
    id: scope
    property string role: ""
    property variant model

    property variant nextFocus: null
    property string roleSelector: ""
    KeyNavigation.right: nextFocus
    KeyNavigation.tab: nextFocus

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
