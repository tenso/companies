# companies

# Prio
* Make a View class into table model so many can exist to same underlying data.
  qml pages can then use own views.
* make a central model for save/load etc.
* segfault when changing DCF years: dont know more...
* feedback on analysis and stock price! (FeedbackPage).

# Prio 2
* when having sorted list and change DCF value it will not re-sort list
* select company and filter more central (not in specifi qml pages)?
* reorder companies (viewOrder in table)
* New analysis with two or more empty financials: NaN
* move list and description to details page add insider ownage to company overview
* break-up Analysis to own classes

# goals
* enable quarter data.
* show insider trend in graph
* capitalize r&d
* re-work overview or add financialoverview with list of companies and their mcap/sales/.../metrics
* re-order companies
* assumptions sensitivity analysis (margins etc)
* Calculate bottom up beta: levered/delevered beta
* add stats like return-on-capital-employed, coe, roe
* a way to set marketpremium and riskfree globaly as a setting (change current and default)
* sector(rename type) + sub-sector dropdowns

# questions
* dont use sales/capital based on capital-employed, qouata to high?
  inwido: got 5 should have been about 3 (if using total book get .95 though!)
  nobia got 3.9 should have been about 1.5

# issues
* fix spelling on Deligate->Delegate
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
* slow and awkward applySort implementation
