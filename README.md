# companies

# TODO

## Prio ##

* dont use sales/capital based on capital-employed, qouata to high!
  inwido: got 5 should have been about 3 (if using total book get .95 though!)
  nobia got 3.9 should have been about 1.5
* New analysis with two or more empty financials: NaN


## goals ##
* re-work overview or add financialoverview with list of companies and their mcap/sales/.../metrics
* re-order companies
* sort on rebate etc
* assumptions sensitivity analysis (margins etc)
* Calculate bottom up beta: levered/delevered beta
* add stats like return-on-capital-employed in financials view

## issues ##
* capitalize r&d
* remove DataMenu new/delete; put in respective page; keep willDelete etc
* CompanyAnalysisDeligate and MagicFormulaDeligate shares base
* overview loses item focus on leave!
* company row: can tab into read-only green fields
* Check: Virtual relation to get data to qml
* showEdit vs enabled
* Analysis: really use means for equity and liab for default newAnalysis?
* REFACTOR: if (!financialsModel.delAllRows()) in qml, move logic to c++
* proper data-dirs
* disable multiple same year entries
* dont dataChanged on all rows in model if related value changes
* set max length of status-text-scroll
