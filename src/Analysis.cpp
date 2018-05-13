#include "Analysis.hpp"
#include "Log.hpp"
#include "AnalysisDebug.hpp"
#include <QQmlContext>

Analysis::Analysis(QObject *parent) : QObject(parent)
{

}

bool Analysis::init(bool autoReAnalyse)
{
    _autoReAnalyse = autoReAnalyse;

    if (!initModel(_companiesRO, "companies")) {
        return false;
    }
    if (!initModel(_model, "analysis")) {
        return false;
    }
    if (!initModel(_resultsModel, "analysisResults")) {
        return false;
    }

    if (!_financialsRO.init("financials")) {
        logError() << "Analysis::init financials failed";
        return false;
    }
    _financialsRO.filterColumn("qId", "=1"); //only want FY entries
    _financialsRO.setSort("year", Qt::DescendingOrder);
    if (!_financialsRO.applyAll()) {
        logError() << "Analysis::init financials failed";
        return false;
    }

    buildLookups();

    connect(&_model, SIGNAL(dataChanged(QModelIndex,QModelIndex,QVector<int>)),
            this, SLOT(dataChanged(QModelIndex,QModelIndex,QVector<int>)));

    return true;
}

bool Analysis::registerProperties(QQmlContext *context)
{
    context->setContextProperty("analysisEngine", this);
    context->setContextProperty("analysisModel", &_model);
    context->setContextProperty("analysisResultsModel", &_resultsModel);
    return true;
}

#define VERIFY(a, b) {\
    if ( a != b) { \
        logError() << "TEST FAILED:" << __PRETTY_FUNCTION__ << "line:" << __LINE__ << ":" << a << "!=" << b; \
        return false; \
    } \
}

#define VERIFYD(a, b) {\
    if ( (a - b)*(a - b) >= 0.0000001) { \
        logError() << "TEST FAILED:" << __PRETTY_FUNCTION__ << "line:" << __LINE__ << ":" << a << "!=" << b; \
        return false; \
    } \
}

bool Analysis::test()
{
    //test lookups
    VERIFYD(defaultRate(100000000, true), 0.0054);
    VERIFY(rating(100000000, false), "AAA");
    VERIFYD(defaultRate(-100000000, false), 1);
    VERIFY(rating(-100000000, true), "D");
    VERIFYD(defaultRate(4.3, false), 0.0099);
    return true;
}

int Analysis::newAnalysis(int cId, bool empty)
{
    _changeUpdates = false;
    if (!_model.newRow(_model.roleColumn("cId"), cId)) {
        logError() << "new analysis failed";
        _changeUpdates = true;
        return -1;
    }
    int aId = _model.get("id").toInt();
    if (empty) {
        logStatus() << "new analys (empty) for" << _companiesRO.get("name").toString();
        _changeUpdates = true;
        return aId;
    }

    if (!selectCompany(cId)) {
        logError() << "failed to select company";
        _changeUpdates = true;
        return -1;
    }
    logStatus() << "new analys (defaults) for" << _companiesRO.get("name").toString();

    //defaults:
    set("tax", DefaultTaxRate);
    set("beta", DefaultBeta);
    set("marketPremium", DefaultMarketRiskPremium);
    set("riskFreeRate", DefaultRiskFree);
    set("growthYears", DefaultGrowthYears);
    set("terminalGrowth", DefaultTerminalGrowth);
    set("salesGrowthMode", (int)Change::Linear);
    set("ebitMarginMode", (int)Change::Linear);
    set("riskyCompany", DefaultRisky);

    //from company means
    QHash<QString, double> means = fetchMeans();
    set("sales", means["sales"]);
    set("ebitMargin", means["ebitMargin"]);
    set("terminalEbitMargin", means["ebitMargin"]);
    set("salesGrowth", means["salesGrowth"]);
    set("salesPerCapital", means["salesPerCapital"]);

     //FIXME: use means for: equity, liab, DONT forget to run selectRow to last year if using fin()
    double interestDebt = means["liabCurrInt"] + means["liabLongInt"];
    double defRate = defaultRate(interestCoverage(means["ebit"], means["interestPayed"]));
    double r = wacc(means["equity"], interestDebt, coeCAPM(),cod(defRate));
    set("wacc", r);

    _model.submitAll();
    _changeUpdates = true;
    return aId;
}

bool Analysis::delAnalysis(int aId)
{
    _resultsModel.delAllRows("aId", aId);
    return _model.delRow(_model.idToRow(aId));
}

bool Analysis::delAllAnalysis(int cId)
{
    if (!selectCompany(cId)) {
        logError() << "failed to select company" << cId;
        return false;
    }
    bool ok = true;
    int maxIter = _model.rowCount();
    while (maxIter > 0 && _model.rowCount()) {
        int aId = _model.rowToId(0);
        if (!delAnalysis(aId)) {
            logError() << "failed to delete row";
            ok = false;
        }
        maxIter--;
    }
    return ok;
}

bool Analysis::analyse(int aId)
{
    if (!_model.selectRow(_model.idToRow(aId)))  {
        logError() << "failed to select aId:" << aId;
        return false;
    }
    _changeUpdates = false;
    dcfEquityValue(get("sales"), get("ebitMargin"), get("terminalEbitMargin"), get("salesGrowth"),
                   get("salesPerCapital"), get("wacc"), get("terminalGrowth"), get("growthYears"),
                   get("tax"), (Change)get("salesGrowthMode"), (Change)get("ebitMarginMode"));
    _changeUpdates = true;
    return true;
}

bool Analysis::selectCompany(int cId)
{
    if (!_companiesRO.selectRow(_companiesRO.idToRow(cId))) {
        logError() << "failed to select company";
        return false;
    }
    _financialsRO.filterColumn("cId", "=" + QString::number(cId));
    if (!_financialsRO.applyAll()) {
        logError() << "failed to select finacials";
        return false;
    }
    return true;
}

QHash<QString, double> Analysis::fetchMeans()
{
    QHash<QString, double> means;
    int entries = _financialsRO.rowCount();
    means["sales"] = 0;
    means["ebit"] = 0;
    means["interestPayed"] = 0;
    means["ebitMargin"] = 0;
    means["salesGrowth"] = 0;
    means["salesPerCapital"] = 0;
    means["liabCurrInt"] = 0;
    means["liabLongInt"] = 0;

    if (entries == 0) {
        return means;
    }

    double lastSale = 0;
    double salesGrowth = 1; //calc geometric-mean; FIXME: make option?
    double newSale;

    //order is descending years
    for (int i = 0; i < entries; i++) {
        _financialsRO.selectRow(i);

        newSale = fin("sales");
        if (i > 0) {
            salesGrowth *= (lastSale / newSale) - 1.0;
        }
        lastSale = newSale;

        means["sales"] += newSale;
        means["ebit"] += fin("ebit");
        means["equity"] += fin("equity");
        means["liabCurrInt"] += fin("liabCurrInt");
        means["liabLongInt"] += fin("liabLongInt");
        means["interestPayed"] += fin("interestPayed");
        double wc = workingCapital(fin("assetsCurr"), fin("assetsCurrCash"),
                                   fin("liabCurr"), fin("liabCurrInt"));

        double capEmployed = capitalEmployed(wc, fin("assetsFixedPpe"));
        means["salesPerCapital"] += salesPerCapital(newSale, capEmployed);
    }

    means["sales"] /= (double)entries;
    means["ebit"] /= (double)entries;
    means["equity"] /= (double)entries;
    means["salesPerCapital"] /= (double)entries;
    means["interestPayed"] /= (double)entries;
    means["liabCurrInt"] /= (double)entries;
    means["liabLongInt"] /= (double)entries;

    if (means["sales"] != 0) {
        means["ebitMargin"] = means["ebit"] / means["sales"];
    }
    means["salesGrowth"] = pow(salesGrowth, 1/(double)(entries - 1));
    return means;
}

double Analysis::interestCoverage(double ebit, double interestExpenses)
{
    if (interestExpenses == 0) {
        return DoubleMax;
    }
    return ebit / interestExpenses;
}

double Analysis::defaultRate(double interestCoverage, bool riskyCompany)
{
    foreach (RatingLookup e, riskyCompany ? _ratingRisky : _ratingStable) {
        if (e.match(interestCoverage)) {
            return e.defaultSpread;
        }
    }
    return 1.0;
}

QString Analysis::rating(double interestCoverage, bool riskyCompany)
{
    foreach (RatingLookup e, riskyCompany ? _ratingRisky : _ratingStable) {
        if (e.match(interestCoverage)) {
            return e.rating;
        }
    }
    return "D";
}

double Analysis::cod(double defaultRate, double riskFree)
{
    return riskFree + defaultRate;
}

double Analysis::coeCAPM(double beta, double marketRiskPremium, double riskFree)
{
    if (marketRiskPremium < riskFree) {
        logError() << "Analysis::coe riskPremium < riskFree";
        return riskFree;
    }
    return riskFree + beta * (marketRiskPremium - riskFree);
}

double Analysis::wacc(double equity, double interestBearingLiab, double coe, double cod, double taxRate)
{
    double assets = equity + interestBearingLiab;
    if (assets == 0) {
        return 0;
    }
    return (equity/assets) * coe + (interestBearingLiab/assets) * (1 - taxRate) * cod;
}

double Analysis::salesPerCapital(double sales, double capitalEmployed)
{
    return sales / capitalEmployed;
}

double Analysis::workingCapital(double currentAssets, double cash,
                                double currentLiabilities, double currentDebt)
{
    return (currentAssets - cash) - (currentLiabilities - currentDebt);
}

double Analysis::capitalEmployed(double workingCapital, double ppe)
{
    return workingCapital + ppe;
}

void Analysis::dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    if (!_changeUpdates) {
        return;
    }
    Q_UNUSED(bottomRight); //FIXME: only handlig topLeft for now

    /*foreach(int roleId, roles) {
        int row = topLeft.row();
        logStatus() << row << _model.roleName(roleId);
    }*/

    if (roles.length() && _autoReAnalyse) {
        _changeUpdates = false; //precautionary
        int row = topLeft.row();
        int aId = _model.rowToId(row);
        logStatus() << "auto reAnalyse:" << aId; //FIXME: remove but keep this a while, want to track when it happens
        analyse(aId);
        _changeUpdates = true; //precautionary
    }
}

double Analysis::dcfEquityValue(double sales, double ebitMargin, double terminalEbitMargin,
                                double salesGrowth, double salesPerCapital, double wacc,
                                double terminalGrowth, int growthYears, double tax,
                                Change salesGrowthChange, Change ebitMarginChange)
{

    if (salesPerCapital == 0) {
        salesPerCapital = 1;
    }

    double cSalesGrowth = salesGrowth;
    double cEbitMargin = ebitMargin;
    AnalysisDebug::logTitle("----Year 0----");
    AnalysisDebug::logInitial(sales, cEbitMargin, cSalesGrowth, growthYears, salesPerCapital, wacc, tax);
    AnalysisDebug::logYear(); //header

    int year = 0;

    double cSales = sales;
    double cCapital = cSales / salesPerCapital;
    double reinvest = cSales * cSalesGrowth / salesPerCapital; //need to reinvest this year to have projected sales next
        cCapital += reinvest;
    double cEbit = cSales * cEbitMargin;
    double fcf = cEbit * (1 - tax) - reinvest;
    double dcf = fcf;
    AnalysisDebug::logYear(year, cSales, 0, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital); //y0
    saveYear(year, cSales, 0, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital); //y0

    AnalysisDebug::logTitle(QString("Growth Years, sales:") + (salesGrowthChange == Change::Constant ? "Constant" : "Linear")
                            + " ebit:" + (ebitMarginChange == Change::Constant ? "Constant" : "Linear"));
    AnalysisDebug::logYear();
    year++;
    double growthDiscounted = 0;
    for (; year <= growthYears; year++) {
        cSales *= 1.0 + cSalesGrowth;
        reinvest = cSales * cSalesGrowth / salesPerCapital;
        cCapital += reinvest;
        cEbit = cSales * cEbitMargin;
        fcf = cEbit * (1 - tax) - reinvest;

        dcf = fcf / pow(1.0 + wacc, year);
        growthDiscounted += dcf;
        AnalysisDebug::logYear(year, cSales, cSalesGrowth, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital);
        saveYear(year, cSales, cSalesGrowth, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital);

        double pos = (growthYears - year) / (double)growthYears;
        //update sales growth for next year
        if (salesGrowthChange == Change::Linear) {
            cSalesGrowth = terminalGrowth + (salesGrowth - terminalGrowth) * pos;
        }
        //update ebit margin for next year
        if (ebitMarginChange == Change::Linear) {
            cEbitMargin = terminalEbitMargin + (ebitMargin - terminalEbitMargin) * pos;
        }
    }
    AnalysisDebug::logResult(growthDiscounted);
    set("growthValueDiscounted", growthDiscounted);

    AnalysisDebug::logTitle("Terminal");
    cCapital += reinvest;
    cSales *= 1.0 + cSalesGrowth;
    reinvest = cSales * terminalGrowth / salesPerCapital;
    cEbit = cSales * terminalEbitMargin;
    fcf = cEbit * (1 - tax) - reinvest;
    dcf = fcf / pow(1.0 + wacc, year);
    AnalysisDebug::logYear();
    AnalysisDebug::logYear(year, cSales, cSalesGrowth, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital);
    saveYear(year, cSales, cSalesGrowth, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital);

    double terminalValue = fcf / (wacc - terminalGrowth);
    int discountYear = year -1;
    double terminalDiscounted = terminalValue / pow(1 + wacc, discountYear);
    AnalysisDebug::logTerminal(year, terminalEbitMargin, fcf, terminalGrowth, terminalValue, discountYear, terminalDiscounted);
    AnalysisDebug::logResult(terminalDiscounted);
    set("terminalValueDiscounted", terminalDiscounted);
    double total = growthDiscounted + terminalDiscounted;

    AnalysisDebug::logTitle("Result");
    AnalysisDebug::logResult(total);
    set("totalValue", total);

    if (terminalDiscounted >= total * 0.75) {
        AnalysisDebug::logNote("terminal is more than 75% of total");
    }

    _model.submitAll();
    _resultsModel.submitAll();
    return total;
}

bool Analysis::initModel(SqlTableModel& model, const QString &table)
{
    if (!model.init(table)) {
        logError() << "Analysis::initModel" << table << "failed";
        return false;
    }
    if (!model.applyAll()) {
        logError() << "Analysis::initModel" << table << "failed";
        return false;
    }
    return true;
}

void Analysis::buildLookups()
{
    //FIXME: this should be read from db?
    _ratingStable.append(RatingLookup(DoubleMin, 0.199999,  "D",   0.1860));
    _ratingStable.append(RatingLookup(0.2,       0.649999,  "C",   0.1395));
    _ratingStable.append(RatingLookup(0.65,      0.799999,  "CC",  0.1063));
    _ratingStable.append(RatingLookup(0.8,       1.249999,  "CCC", 0.0864));
    _ratingStable.append(RatingLookup(1.25,      1.499999,  "B-",  0.0437));
    _ratingStable.append(RatingLookup(1.5,       1.749999,  "B",   0.0357));
    _ratingStable.append(RatingLookup(1.75,      1.999999,  "B+",  0.0298));
    _ratingStable.append(RatingLookup(2,         2.2499999, "BB",  0.0238));
    _ratingStable.append(RatingLookup(2.25,      2.49999,   "BB+", 0.0198));
    _ratingStable.append(RatingLookup(2.5,       2.999999,  "BBB", 0.0127));
    _ratingStable.append(RatingLookup(3,         4.249999,  "A-",  0.0113));
    _ratingStable.append(RatingLookup(4.25,      5.499999,  "A",   0.0099));
    _ratingStable.append(RatingLookup(5.5,       6.499999,  "A+",  0.0090));
    _ratingStable.append(RatingLookup(6.5,       8.499999,  "AA",  0.0072));
    _ratingStable.append(RatingLookup(8.50,      DoubleMax, "AAA", 0.0054));

    _ratingRisky.append(RatingLookup(DoubleMin, 0.499999,  "D",   0.1860));
    _ratingRisky.append(RatingLookup(0.5,       0.799999,  "C",   0.1395));
    _ratingRisky.append(RatingLookup(0.8,       1.249999,  "CC",  0.1063));
    _ratingRisky.append(RatingLookup(1.25,      1.499999,  "CCC", 0.0864));
    _ratingRisky.append(RatingLookup(1.5,       1.999999,  "B-",  0.0437));
    _ratingRisky.append(RatingLookup(2,         2.499999,  "B",   0.0357));
    _ratingRisky.append(RatingLookup(2.5,       2.999999,  "B+",  0.0298));
    _ratingRisky.append(RatingLookup(3,         3.499999,  "BB",  0.0238));
    _ratingRisky.append(RatingLookup(3.5,       3.9999999, "BB+", 0.0198));
    _ratingRisky.append(RatingLookup(4,         4.499999,  "BBB", 0.0127));
    _ratingRisky.append(RatingLookup(4.5,       5.999999,  "A-",  0.0113));
    _ratingRisky.append(RatingLookup(6,         7.499999,  "A",   0.0099));
    _ratingRisky.append(RatingLookup(7.5,       9.499999,  "A+",  0.0090));
    _ratingRisky.append(RatingLookup(9.5,       12.499999, "AA",  0.0072));
    _ratingRisky.append(RatingLookup(12.5,      DoubleMax, "AAA", 0.0054));
}

double Analysis::fin(const QString &role)
{
    return _financialsRO.get(role).toDouble();
}

double Analysis::get(const QString &role)
{
    return _model.get(role).toDouble();
}

bool Analysis::set(const QString &role, double val)
{
    return _model.set(role, QString::number(val, 'f', SavePrecision));
}

bool Analysis::yearSet(const QString &role, double val)
{
    return _resultsModel.set(role, QString::number(val, 'f', SavePrecision));
}

bool Analysis::yearSet(const QString &role, int val)
{
    return _resultsModel.set(role, val);
}


bool Analysis::saveYear(int year, double sales, double cSalesGrowth, double ebit, double cEbitMargin, double reinvest,
                        double fcf, double dcf, double investedCapital)
{
    if (!_resultsModel.newRow("aId", _model.rowToId(_model.selectedRow()))) {
        logError() << "new row failed";
        return false;
    }
    yearSet("type", 1);
    yearSet("step", year);
    yearSet("sales", sales);
    yearSet("ebit", ebit);
    yearSet("ebitMargin", cEbitMargin);
    yearSet("salesGrowth", cSalesGrowth);
    yearSet("reinvestments", reinvest);
    yearSet("fcf", fcf);
    yearSet("dcf", dcf);
    yearSet("investedCapital", investedCapital);
    _resultsModel.submitAll();
    return true;
}


Analysis::RatingLookup::RatingLookup(double from, double to, const QString &rating, double defaultSpread)
{
    this->from = from;
    this->to = to;
    this->rating = rating;
    this->defaultSpread = defaultSpread;
}

bool Analysis::RatingLookup::match(double interestCoverage)
{
    return (interestCoverage >= from && interestCoverage <= to);
}
