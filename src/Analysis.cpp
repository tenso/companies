#include "Analysis.hpp"
#include "Log.hpp"
#include "AnalysisDebug.hpp"
#include <QQmlContext>

#include "GlobalData.hpp"

Analysis::Analysis(QObject *parent) : QObject(parent)
{

}

bool Analysis::init(RamTableModel *financialsModel, bool autoReAnalyse)
{
    _financials = financialsModel;
    if (_financials == nullptr) {
        logError() << "financials null";
    }
    _autoReAnalyse = autoReAnalyse;

    if (!initModel(_model, "analysis")) {
        return false;
    }
    _model.addRelated("riskyCompany", GlobalData::getModel("yesno"), "id", "name");
    _model.addRelated("salesGrowthMode", GlobalData::getModel("modes"), "id", "name");
    _model.addRelated("ebitMarginMode", GlobalData::getModel("modes"), "id", "name");
    _model.addRelated("financialsMode", GlobalData::getModel("calcModes"), "id", "name");

    if (!initModel(_resultsModel, "analysisResults")) {
        return false;
    }

    if (!initModel(_magicModel, "magicFormula")) {
        return false;
    }
    _magicModel.addRelated("financialsMode", GlobalData::getModel("calcModes"), "id", "name");

    buildLookups();

    connect(&_model, SIGNAL(dataChanged(QModelIndex,QModelIndex,QVector<int>)),
            this, SLOT(dcfDataChanged(QModelIndex,QModelIndex,QVector<int>)));

    connect(&_magicModel, SIGNAL(dataChanged(QModelIndex,QModelIndex,QVector<int>)),
            this, SLOT(magicDataChanged(QModelIndex,QModelIndex,QVector<int>)));

    return true;
}

bool Analysis::registerProperties(QQmlContext *context)
{
    context->setContextProperty("analysisEngine", this);
    context->setContextProperty("analysisModel", &_model);
    context->setContextProperty("analysisResultsModel", &_resultsModel);
    context->setContextProperty("magicModel", &_magicModel);
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

RamTableModel *Analysis::model()
{
    return &_model;
}

RamTableModel *Analysis::resultsModel()
{
    return &_resultsModel;
}

RamTableModel *Analysis::magicModel()
{
    return &_magicModel;
}

int Analysis::newDCFAnalysis(bool empty)
{
    if (_cId < 0) {
        logError() << "no company selected, abort";
        return -1;
    }

    _changeUpdates = false;
    //DCF
    if (!_model.newRow("cId", _cId)) {
        logError() << "new analysis failed";
        _changeUpdates = true;
        return -1;
    }
    int aId = _model.get("id").toInt();

    if (empty) {
        logStatus() << "new analys (empty) for" << _cId;
        _changeUpdates = true;
        return aId;
    }

    logStatus() << "new analys (defaults) for" << _cId << "id" << aId;

    //defaults:
    set("tax", DefaultTaxRate);
    set("beta", DefaultBeta);
    set("marketPremium", DefaultMarketRiskPremium);
    set("riskFreeRate", DefaultRiskFree);
    setInt("growthYears", DefaultGrowthYears);
    double terminalGrowth = DefaultTerminalGrowth;
    set("terminalGrowth", terminalGrowth);
    setInt("salesGrowthMode", (int)Change::Linear);
    setInt("ebitMarginMode", (int)Change::Linear);
    setInt("financialsMode", (int)CalcMode::Means);
    setInt("riskyCompany", DefaultRisky);

    //from financials:
    QHash<QString, double> data = fetchData(CalcMode::Means);
    set("shares", data["shares"]);
    set("sharePrice", data["sharePrice"]);
    set("sales", data["sales"]);
    set("ebitMargin", data["ebitMargin"]);
    set("terminalEbitMargin", data["ebitMargin"]);
    set("salesGrowth", data["salesGrowth"]);
    set("salesPerCapital", data["salesPerCapital"]);

    if (!analyseDCF(aId)) {
        logError() << "failed to analyse" << aId;
    }

    _changeUpdates = true;
    return aId;
}

int Analysis::newMagicAnalysis()
{
    if (_cId < 0) {
        logError() << "no company selected, abort";
        return -1;
    }
    int aId = -1;
    _changeUpdates = false;
    if (!_magicModel.newRow("cId", _cId)) {
        logError() << "new magicforumla";
    }
    else {
        aId = _magicModel.get("id").toInt();

        //defaults
        setInt("financialsMode", (int)CalcMode::Means, &_magicModel);
        analyseMagic(aId);
    }
    _changeUpdates = true;
    return aId;
}

bool Analysis::submitAll()
{
    bool ok = true;
    ok &= _model.submitAll();
    ok &= _resultsModel.submitAll();
    ok &= _magicModel.submitAll();
    return ok;
}

void Analysis::revertAll()
{
    _model.revertAll();
    _resultsModel.revertAll();
    _magicModel.revertAll();
}

bool Analysis::delDCFAnalysis(int aId)
{
    _resultsModel.delAllRows("aId", aId);
    bool ok = _model.delRow(_model.idToRow(aId));
    return ok;
}

bool Analysis::delMagicAnalysis(int aId)
{
    bool ok = _magicModel.delRow(_magicModel.idToRow(aId));
    return ok;
}

bool Analysis::delAllAnalysis(int cId)
{
    bool ok = true;
    QList<int> toDelete;

    //DCF
    for(int i = 0; i < _model.rowCount(); i++) {
        if(_model.get(i, "cId") == cId) {
            toDelete.push_back(_model.rowToId(i));
        }
    }
    for(int i = 0; i < toDelete.size(); i++) {
        if (!delDCFAnalysis(toDelete.at(i))) {
            logError() << "failed to delete row";
            ok = false;
        }
    }

    //MAGIC
    toDelete.clear();
    for(int i = 0; i < _magicModel.rowCount(); i++) {
        if(_magicModel.get(i, "cId") == cId) {
            toDelete.push_back(_magicModel.rowToId(i));
        }
    }

    for(int i = 0; i < toDelete.size(); i++) {
        if (!delMagicAnalysis(toDelete.at(i))) {
            logError() << "failed to delete magic row";
            ok = false;
        }
    }

    if (!ok) {
        logError() << "delAllAnalysis failed" << cId;
    }
    return ok;

}

bool Analysis::analyseDCF(int aId)
{
    int row = _model.idToRow(aId);
    if (!_model.selectRow(row))  {
        logError() << "failed to select aId:" << aId;
        return false;
    }
    _changeUpdates = false;
    _resultsModel.delAllRows("aId", aId);

    //calc wacc
    CalcMode mode = (CalcMode)get("financialsMode");
    double defRate = 0;
    double equity = 0;
    QHash<QString, double> data = fetchData(mode);
    defRate = defaultRate(interestCoverage(data["ebit"], data["interestPayed"]));
    equity = data["equity"];

    double coe = coeCAPM(get("beta"), get("marketPremium"), get("riskFreeRate"));
    double cd = cod(defRate, get("riskFreeRate"));
    double r = wacc(equity, data["totalDebt"], coe, cd);
    double terminalGrowth = get("terminalGrowth");
    if (r <= terminalGrowth) {
        r = terminalGrowth + 0.001;
    }
    set("wacc", r);

    QString infoString = QString::asprintf
            ("wacc inputs:\n"
             "equity: %.1f\n"
             "coe: %.1f%%\n"
             "total debt: %.1f\n"
             "def rate: %.1f%%\n"
             "cod: %.1f%%\n", equity, coe * 100, data["totalDebt"], defRate * 100, cd * 100);
    logInfo(infoString);

    if (get("salesPerCapital") <= 0) {
        set("salesPerCapital", 1);
    }

    dcfEquityValue(get("sales"), get("ebitMargin"), get("terminalEbitMargin"), get("salesGrowth"),
                   get("salesPerCapital"), get("wacc"), get("terminalGrowth"), get("growthYears"),
                   get("tax"), (Change)get("salesGrowthMode"), (Change)get("ebitMarginMode"));


    //convenience data
    double shares = get("shares");
    double total = get("totalValue");
    double price = get("sharePrice");

    if (shares > 0) {
        double shareValue = total / shares;
        set("shareValue", shareValue);
        set("rebate", (shareValue / price) - 1.0);
    }
    else {
        set("shareValue", 0);
        set("rebate", 0);
    }

    _changeUpdates = true;
    return true;
}

bool Analysis::analyseMagic(int aId)
{
    int row = _magicModel.idToRow(aId);
    if (!_magicModel.selectRow(row))  {
        logError() << "(magic) failed to select aId:" << aId;
        return false;
    }
    _changeUpdates = false;

    CalcMode mode = (CalcMode)get("financialsMode", &_magicModel);
    QHash<QString, double> data = fetchData(mode);
    set("ebit", data["ebit"], &_magicModel);
    set("capitalEmployed", data["capitalEmployed"], &_magicModel);
    set("ev", data["ev"], &_magicModel);

    double ce = get("capitalEmployed", &_magicModel);
    double eV = get("ev", &_magicModel);
    double e = get("ebit", &_magicModel);
    double score = 0;
    double ok = false;
    if (ce != 0 && e != 0) {
        score = 0.5 * e / ce + 0.5 * e / eV;
        ok = true;
    }
    set("score", score, &_magicModel);

    _changeUpdates = true;
    return ok;
}

bool Analysis::selectCompany(int cId)
{
    _cId = cId;
    if (_financials) {
        _financials->filterColumn("cId", "=" + QString::number(cId));
        _financials->filterColumn("qId", "=0"); //only want FY entries
    }
    return true;
}

void Analysis::selectLatestYear()
{
    _financials->selectRow(0);
}

QHash<QString, double> Analysis::fetchData(CalcMode mode)
{
    QHash<QString, double> means;
    int entries = 0;
    if (_financials) {
        entries = _financials->rowCount();
    }
    if (mode == CalcMode::Last) {
        entries = 1;
    }
    means["sales"] = 0;
    means["ebit"] = 0;
    means["interestPayed"] = 0;
    means["ebitMargin"] = 0;
    means["salesGrowth"] = 0;
    means["salesPerCapital"] = 0;
    means["liabCurrInt"] = 0;
    means["liabLongInt"] = 0;
    means["capitalEmployed"] = 0;
    means["assetsCurrCash"] = 0;
    means["mcap"] = 0;
    means["ev"] = 0;
    means["shares"] = 0;
    means["sharePrice"] = 0;
    if (entries == 0) {
        return means;
    }

     //single data:
    _financials->selectRow(0);
    means["shares"] = fin("shares");
    means["sharePrice"] = fin("sharePrice");
    means["mcap"] = mcap(means["shares"], means["sharePrice"]);

    double lastSale = 0;
    double salesGrowth = 1; //calc geometric-mean; FIXME: make option?
    double newSale;

    //order is descending years
    for (int i = 0; i < entries; i++) {
        if (_financials) {
            _financials->selectRow(i);
        }

        //NOTE we calculated our COD without capitalized leases
        //def rate could chage as ebit changes!
        double defRate = defaultRate(interestCoverage(fin("ebit"), fin("interestPayed")));
        double cd = cod(defRate, get("riskFreeRate"));
        LeasesCapitalized leases = capLeases(cd, fin("leasingY"), fin("leasingY1"), fin("leasingY2Y5"), fin("leasingY5Up"));

        newSale = fin("sales");
        if (i > 0) {
            salesGrowth *= (lastSale / newSale) - 1.0;
        }
        lastSale = newSale;

        means["sales"] += newSale;
        means["ebit"] += fin("ebit") + leases.ebitAdd;
        means["equity"] += fin("equity");
        means["liabCurrInt"] += fin("liabCurrInt") + leases.debtAdd;
        means["liabLongInt"] += fin("liabLongInt");
        means["interestPayed"] += fin("interestPayed");
        means["assetsCurrCash"] += fin("assetsCurrCash");
        means["capitalEmployed"] += finCapEmployed(leases);
        means["salesPerCapital"] += salesPerCapital(newSale, finCapEmployed(leases));
    }

    means["sales"] /= (double)entries;
    means["ebit"] /= (double)entries;
    means["equity"] /= (double)entries;
    means["salesPerCapital"] /= (double)entries;
    means["interestPayed"] /= (double)entries;
    means["liabCurrInt"] /= (double)entries;
    means["liabLongInt"] /= (double)entries;
    means["capitalEmployed"] /= (double)entries;
    means["assetsCurrCash"] /= (double)entries;

    if (means["sales"] != 0) {
        means["ebitMargin"] = means["ebit"] / means["sales"];
    }
    means["salesGrowth"] = pow(salesGrowth, 1/(double)(entries - 1));

    means["ev"] = ev(means["mcap"], means["assetsCurrCash"], means["liabCurrInt"], means["liabLongInt"]);
    means["totalDebt"] = means["liabCurrInt"] + means["liabLongInt"];

    return means;
}

Analysis::LeasesCapitalized Analysis::capLeases(double cod, double yThis, double y1, double y2to4, double y5)
{
    LeasesCapitalized ret;

    double yX = y2to4 / 4.0;
    double asDebt = y1 / pow(1 + cod, 1) +
            yX / pow(1 + cod, 2) + yX / pow(1 + cod, 3) + yX / pow(1 + cod, 4) +
            y5 / pow(1 + cod, 5);
    double depriciation = asDebt / 5.0;
    ret.ebitAdd = yThis - depriciation;
    ret.debtAdd = asDebt;
    return ret;
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

double Analysis::wacc(double equity, double totalDebt, double coe, double cod, double taxRate)
{
    double assets = equity + totalDebt;
    if (assets == 0) {
        return 0;
    }
    return (equity / assets) * coe + (totalDebt / assets) * (1 - taxRate) * cod;
}

double Analysis::salesPerCapital(double sales, double capitalEmployed)
{
    if (capitalEmployed == 0) {
        return 0;
    }
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

double Analysis::mcap(double shares, double sharePrice)
{
    return shares * sharePrice;
}

double Analysis::ev(double mcap, double cash, double currentDebt, double longDebt)
{
    return mcap + currentDebt + longDebt - cash;
}

void Analysis::dcfDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
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
        //logStatus() << "auto reAnalyse:" << aId; //FIXME: remove but keep this a while, want to track when it happens
        analyseDCF(aId);
        _changeUpdates = true; //precautionary
        //logStatus() << "auto reAnalyse done";
    }
}

void Analysis::magicDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    if (!_changeUpdates) {
        return;
    }
    Q_UNUSED(bottomRight); //FIXME: only handlig topLeft for now

    if (roles.length() && _autoReAnalyse) {
        _changeUpdates = false; //precautionary
        int row = topLeft.row();
        int aId = _magicModel.rowToId(row);
        analyseMagic(aId);
        _changeUpdates = true; //precautionary
    }
}

double Analysis::dcfEquityValue(double sales, double ebitMargin, double terminalEbitMargin,
                                double salesGrowth, double salesPerCapital, double wacc,
                                double terminalGrowth, int growthYears, double tax,
                                Change salesGrowthChange, Change ebitMarginChange)
{
    if (salesPerCapital == 0) {
        AnalysisDebug::logNote("setting salesPerCapital=1");
        salesPerCapital = 1;
    }
    if (wacc <= terminalGrowth) {
        AnalysisDebug::logNote("setting wacc=terminalGrowth + 1%");
        wacc = terminalGrowth + 0.01;
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
    saveYear("initial", year, cSales, 0, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital); //y0

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
        saveYear(QString("+") +QString::number(year), year, cSales, cSalesGrowth, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital);

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
    cSalesGrowth = terminalGrowth;
    cEbitMargin = terminalEbitMargin;
    cCapital += reinvest;
    cSales *= 1.0 + cSalesGrowth;
    reinvest = cSales * cSalesGrowth / salesPerCapital;
    cEbit = cSales * terminalEbitMargin;
    fcf = cEbit * (1 - tax) - reinvest;
    dcf = fcf / pow(1.0 + wacc, year);
    AnalysisDebug::logYear();
    AnalysisDebug::logYear(year, cSales, cSalesGrowth, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital);
    saveYear("terminal", year, cSales, cSalesGrowth, cEbit, cEbitMargin, reinvest, fcf, dcf, cCapital);

    double terminalValue = fcf / (wacc - cSalesGrowth);
    int discountYear = year - 1;
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

    return total;
}

bool Analysis::initModel(RamTableModel& model, const QString &table)
{
    if (!model.init(table)) {
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
    if (_financials) {
        double val = _financials->get(role).toDouble();
        return val;
    }
    return 0;
}

double Analysis::finCapEmployed(LeasesCapitalized leases)
{
    double wc = workingCapital(fin("assetsCurr") + leases.debtAdd, fin("assetsCurrCash"),
                               fin("liabCurr") + leases.debtAdd, fin("liabCurrInt") + leases.debtAdd);

    return capitalEmployed(wc, fin("assetsFixedPpe"));
}

double Analysis::get(const QString &role, RamTableModel* model)
{
    if (model == nullptr) {
        model = &_model;
    }
    return model->get(role).toDouble();
}

bool Analysis::set(const QString &role, double val, RamTableModel* model)
{
    if (model == nullptr) {
        model = &_model;
    }
    if (fabs(val) <= 10) {
        return model->set(role, QString::number(val, 'f', SavePrecisionSmall));
    }
    else if (fabs(val) <= 100) {
        return model->set(role, QString::number(val, 'f', SavePrecisionLarge));
    }
    else {
        return model->set(role, QString::number(val, 'f', SavePrecisionHuge));
    }
}

bool Analysis::setInt(const QString &role, int val, RamTableModel *model)
{
    if (model == nullptr) {
        model = &_model;
    }
    return model->set(role, val);
}

bool Analysis::yearSet(const QString &role, double val)
{
    if (fabs(val) <= 10) {
        return _resultsModel.set(role, QString::number(val, 'f', SavePrecisionSmall));
    }
    else if (fabs(val) <= 100) {
        return _resultsModel.set(role, QString::number(val, 'f', SavePrecisionLarge));
    }
    else {
        return _resultsModel.set(role, QString::number(val, 'f', SavePrecisionHuge));
    }
}

bool Analysis::yearSet(const QString &role, int val)
{
    return _resultsModel.set(role, val);
}

bool Analysis::yearSet(const QString &role, const QString& val)
{
    return _resultsModel.set(role, val);
}

bool Analysis::saveYear(const QString& year, int step, double sales, double cSalesGrowth, double ebit, double cEbitMargin, double reinvest,
                        double fcf, double dcf, double investedCapital)
{
    if (!_resultsModel.newRow("aId", _model.rowToId(_model.selectedRow()))) {
        logError() << "new row failed";
        return false;
    }
    yearSet("type", 1);
    yearSet("step", step);
    yearSet("year", year);
    yearSet("sales", sales);
    yearSet("ebit", ebit);
    yearSet("ebitMargin", cEbitMargin);
    yearSet("salesGrowth", cSalesGrowth);
    yearSet("reinvestments", reinvest);
    yearSet("fcf", fcf);
    yearSet("dcf", dcf);
    yearSet("investedCapital", investedCapital);
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
