# companies

# TODO

## Prio ##

* display mode i for yeasrs etc.
* New analysis with two or more empty financials: NaN
* drop-down for fin mode on magicformula (fix all dropdowns)
* capitalize leases: increase ebit and coc, need to decrease ROIC (add to current-assets, current liab+int.current.liab)
* aId and maId related in companies gets set to 1 on adding new rows
* sales/capital really on capital-employed: add dropdown mode.
* add stats like return-on-capital-employed in financials view

## goals ##
* re-work overview or add financialoverview with list of companies and their mcap/sales/.../metrics
** sort on rebate etc
* assumptions sensitivity analysis (margins etc)
* Calculate bottom up beta: levered/delevered beta

## issues ##
* capitalize r&d
* remove DataMenu new/delete; put in respective page; keep willDelete etc
* CompanyAnalysisDeligate and MagicFormulaDeligate shares base
* dont use database for "modes" and such!
* overview loses item focus on leave!
* company row: can tab into read-only green fields
* Check: Virtual relation to get data to qml
* showEdit vs enabled
* Analysis: really use means for equity and liab for default newAnalysis?
* shared data-pointers but own filters?
* REFACTOR: if (!financialsModel.delAllRows()) in qml, move logic to c++
* proper data-dirs
* disable multiple same year entries
* Show number of financials on all rows in overview.
* dont dataChanged on all rows in model if related value changes
