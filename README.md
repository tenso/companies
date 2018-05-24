# companies

# TODO

## Prio ##

* sales/capital really on capital-employed!?!

* aId and maId related in companies gets set to 1 on adding new rows
* CompanyAnalysisDeligate and MagicFormulaDeligate shares base
* remove DataMenu new/delete; put in respective page; keep willDelete etc

## goals ##
* re-work overview or add financialoverview with list of companies and their mcap/sales/.../metrics
* assumptions sensitivity analysis (margins etc)
* detail: compare companies; present analys in valulation-overview-page
* Calculate bottom up beta: levered/delevered beta

## issues ##
* dont use database for "modes" and such!
* overview loses item focus on leave!
* company row: can tab into read-only green fields
* capitalize leases
* capitalize r&d
* dont use means for ev!
* Check: Virtual relation to get data to qml
* showEdit vs enabled
* Analysis: really use means for equity and liab for default newAnalysis?
* shared data-pointers but own filters?
* REFACTOR: if (!financialsModel.delAllRows()) in qml, move logic to c++
* proper data-dirs
* disable multiple same year entries
* Show number of financials on all rows in overview.
* dont dataChanged on all rows in model if related value changes
