#ifndef ANALYSIS_HPP
#define ANALYSIS_HPP

#include <limits>
#include <QObject>
#include <QList>
#include "SqlTableModel.hpp"

class Analysis : public QObject
{
    Q_OBJECT

public:
    enum class Change {Constant, Linear};
    static constexpr double DoubleMin = std::numeric_limits<double>::min();
    static constexpr double DoubleMax = std::numeric_limits<double>::max();
    static constexpr double DefaultRiskFree = 0.025;
    static constexpr double DefaultTerminalGrowth = DefaultRiskFree;
    static constexpr int    DefaultGrowthYears = 5;
    static constexpr double DefaultMarketRiskPremium = 0.10;
    static constexpr double DefaultTaxRate = 0.22;
    static constexpr double DefaultBeta = 1.0;
    static constexpr bool   DefaultRisky = false;

    explicit Analysis(QObject *parent = nullptr);
    bool init();
    bool test();

signals:

public slots:
    //returns id of new analysis or -1 on error
    //autofills from available data of not empty=true
    int newAnalysis(int cId, bool empty = false);

    //removes all results:
    bool delAnalysis(int aId);
    bool delAllAnalysis(int cId);

    //runs analysis on last used if aId=-1
    bool analyse(int aId = -1);

    bool selectCompany(int cId);
    QHash<QString, double> fetchMeans();

    //double bottomUpBeta();
    //double researchAsAssets();
    //double leasesAsDebt();

    //defaultRate and rating
    double interestCoverage(double ebit, double interestExpenses);
    double defaultRate(double interestCoverage, bool riskyCompany = DefaultRisky);
    QString rating(double interestCoverage, bool riskyCompany = DefaultRisky);

    //wacc
    double cod(double defaultRate, double riskFree = DefaultRiskFree);
    //NOTE: takes marketRiskPremium as defined: equityRiskPremium = marketRiskPremium - riskfreeRate
    double coeCAPM(double beta = DefaultBeta, double marketRiskPremium = DefaultMarketRiskPremium,
                   double riskFree = DefaultRiskFree);
    double wacc(double equity, double interestBearingLiab, double coe, double cod, double taxRate = DefaultTaxRate);

    //return on capital
    double salesPerCapital(double sales, double capitalEmployed);
    double workingCapital(double currentAssets, double cash, double currentLiabilities, double currentDebt);
    double capitalEmployed(double workingCapital, double ppe);

    //dcf
    double dcfEquityValue(double sales, double ebitMargin, double terminalEbitMargin,
                          double salesGrowth, double salesPerCapital, double wacc,
                          double terminalGrowth = DefaultTerminalGrowth,
                          int growthYears = DefaultGrowthYears,
                          double tax = DefaultTaxRate,
                          Change salesGrowthChange = Change::Linear,
                          Change ebitMarginChange = Change::Constant);

private:
    bool initModel(SqlTableModel &model, const QString& table);
    void buildLookups();
    double fin(const QString& role); //remember to run _financials.selectRow() before!
    double par(const QString& role); //remember to run _financials.selectRow() before!
    bool saveYear(int year, double sales, double cSalesGrowth, double ebit, double cEbitMargin,
                  double reinvest, double fcf, double dcf, double investedCapital);
    bool saveSingle(const QString& param, double val);

    class RatingLookup {
    public:
        RatingLookup(double from, double to, const QString& rating, double defaultSpread);
        bool match(double interestCoverage);

        double from;
        double to;
        QString rating;
        double defaultSpread;
    };
    QList<RatingLookup> _ratingStable;
    QList<RatingLookup> _ratingRisky;

    SqlTableModel _companies;
    SqlTableModel _financials;
    SqlTableModel _analysis;
    SqlTableModel _analysisResults;
};

#endif // ANALYSIS_HPP
