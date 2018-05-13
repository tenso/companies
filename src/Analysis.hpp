#ifndef ANALYSIS_HPP
#define ANALYSIS_HPP

#include <limits>
#include <QObject>
#include <QList>
#include "SqlTableModel.hpp"

class QQmlContext;

class Analysis : public QObject
{
    Q_OBJECT

public:

    static constexpr int    SavePrecision = 3;

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
    bool init(bool autoReanalyse = true);
    bool registerProperties(QQmlContext *context);
    bool test();

signals:

public slots:
    //returns id of new analysis or -1 on error
    //autofills from available data of not empty=true
    int newAnalysis(int cId, bool empty = false);

    //removes all results:
    bool delAnalysis(int aId);
    bool delAllAnalysis(int cId);

    bool analyse(int aId);

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

private slots:
    void dataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>());

private:
    //dcf
    double dcfEquityValue(double sales, double ebitMargin, double terminalEbitMargin,
                          double salesGrowth, double salesPerCapital, double wacc,
                          double terminalGrowth = DefaultTerminalGrowth,
                          int growthYears = DefaultGrowthYears,
                          double tax = DefaultTaxRate,
                          Change salesGrowthChange = Change::Linear,
                          Change ebitMarginChange = Change::Constant);


    bool initModel(SqlTableModel &model, const QString& table);
    void buildLookups();
    double fin(const QString& role); //remember to run _financials.selectRow() before!
    double get(const QString& role); //remember to run _financials.selectRow() before!
    bool set(const QString& role, double val);


    bool yearSet(const QString &role, double val);
    bool yearSet(const QString &role, int val);
    bool saveYear(int year, double sales, double cSalesGrowth, double ebit, double cEbitMargin,
                  double reinvest, double fcf, double dcf, double investedCapital);

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

    //this class owns data:
    SqlTableModel _model;
    SqlTableModel _resultsModel;

    //not owned data; only lookup, dont share will set own filters,sort etc
    SqlTableModel _companiesRO;
    SqlTableModel _financialsRO;
    bool _changeUpdates { true };
    bool _autoReAnalyse{ false };
};

#endif // ANALYSIS_HPP
