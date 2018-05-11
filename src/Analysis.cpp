#include "Analysis.hpp"
#include "Log.hpp"

Analysis::Analysis(QObject *parent) : QObject(parent)
{

}

bool Analysis::init()
{
    if (!_companies.init("companies")) {
        logError() << "Analysis::init companies failed";
        return false;
    }
    if (!_companies.applyAll()) {
        logError() << "Analysis::init companies failed";
        return false;
    }
    if (!_financials.init("financials")) {
        logError() << "Analysis::init financials failed";
        return false;
    }
    _financials.filterColumn("qId", "=1"); //only want FY entries
    _financials.setSort("year", Qt::DescendingOrder);
    if (!_financials.applyAll()) {
        logError() << "Analysis::init financials failed";
        return false;
    }

    buildLookups();

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

bool Analysis::analyse(int row)
{
    logStatus() << "dcf on" << _companies.get(row, "name");
    QString cId = _companies.get(row, "id").toString();
    _financials.filterColumn("cId", "=" + cId);
    _financials.applyAll();
    for (int i = 0; i < _financials.rowCount(); i++) {
        logStatus() << _financials.get(i, "sales");
        logStatus() << _financials.get(i, "ebit");
    }
    return true;
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

double Analysis::wacc(double equity, double debt, double coe, double cod, double taxRate)
{
    double assets = equity + debt;
    return (equity/assets) * coe + (debt/assets) * (1 - taxRate) * cod;
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

void logYear(int year, double sales, double ebit, double fcf, double capex, double investedCapital)
{
    if (year < 0) {
        printf("year|  sales| ebit|  fcf|capex|capital|\n");
    }
    else {
        printf("   %1d|%7.1f|%5.1f|%5.1f|%5.1f|%7.1f|\n", year, sales, ebit, fcf, capex, investedCapital);
    }
}

double Analysis::dcfEquityValue(double sales, double ebitMargin, double terminalEbitMargin,
                                double salesGrowth, double terminalSalesGrowth, int growthYears,
                                double salesPerCapital, double wacc, double tax)
{
    logYear(-1, 0, 0, 0, 0, 0);

    double cSales = sales;
    double cCapital = cSales / salesPerCapital;
    double reinvest = cSales * salesGrowth / salesPerCapital;
    double cEbit = cSales * ebitMargin;
    double fcf = cEbit * (1 - tax) - reinvest;

    for (int year = 0; year < growthYears; year++) {
        logYear(year, cSales, cEbit, fcf, reinvest, cCapital);

        cCapital += reinvest;
        cSales *= 1.0 + salesGrowth;
        reinvest = cSales * salesGrowth / salesPerCapital;
        cEbit = cSales * ebitMargin;
        fcf = cEbit * (1 - tax) - reinvest;
    }
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
