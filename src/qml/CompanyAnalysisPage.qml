import QtQuick 2.9
import QtQuick.Controls 2.2

APage {
    id: page
    SelectedCompany {
        id: head
        selectedData: page.selectedData
        colW: page.colW

        onSelectionChanged: {
        }
    }
}
