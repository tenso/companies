# companies

# TODO

#Prio#
* filters on financialModels need to reset when changeing pages as its shared
* SqlModel: delAllRows dont use filters, what else?
* shared data-pointers but own filters?
* remove DataMenu new/delete; put in respective page; kepp willDelete etc
* Super slow re-analysis as newRow for setYear will lock when qml has the same model?

* Analysis: really use means for equity and liab for default newAnalysis?
* Percent input/output
* Dropdown for growth modes

##goals
* Second detail: calculate fixed dcf.
* Third detail: compare companies; present analys in valulation-overview-page

##Possible-goals
* Calculate bottom up beta: levered/delevered beta

##issues
* REFACTOR: SqlModel: work with id or rows? must choose?.
* REFACTOR: if (!financialsModel.delAllRows()) in qml, move logic to c++
* proper data-dirs
* disable multiple same year entries
* sort year? if so handle re-select of current better
* disable Quarters data untill fixes
* Show number of financials on all rows in overview.
* Filter runs select 0> clears unsaved changes.
* Filter search will clear selectedItem => bugged details page.

