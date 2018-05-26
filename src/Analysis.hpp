#ifndef ANALYSIS_HPP
#define ANALYSIS_HPP

#include <limits>
#include <QObject>
#include <QList>
#include "SqlModel.hpp"
#include "RamTableModel.hpp"

class QQmlContext;

/* Nomenclature:
 * debt: interest bearing liablities
 * total debt = short term ibl + long term ibl
 */

class Analysis : public QObject
{
    Q_OBJECT

public:

    static constexpr int    SavePrecisionSmall = 3;
    static constexpr int    SavePrecisionLarge = 1;
    static constexpr int    SavePrecisionHuge = 0;

    enum class Change {Constant, Linear};
    enum class CalcMode {Means, Last};
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
    bool init(RamTableModel* financialsModel, bool autoReanalyse = true);
    bool registerProperties(QQmlContext *context);
    bool test();
    RamTableModel* model();
    RamTableModel* resultsModel();
    RamTableModel* magicModel();

signals:
    void logInfo(const QString& text);

public slots:
    //returns id of new analysis or -1 on error
    //autofills from available data of not empty=true
    int newDCFAnalysis(int cId, bool empty = false);
    int newMagicAnalysis(int cId);
    bool submitAll();
    void revertAll();
    //removes all results:
    bool delDCFAnalysis(int aId);
    bool delMagicAnalysis(int aId);
    bool delAllAnalysis(int cId);

    bool analyseDCF(int aId);
    bool analyseMagic(int aId);

    bool selectCompany(int cId);
    void selectLatestYear();
    QHash<QString, double> fetchData(CalcMode mode);

public:
    //double bottomUpBeta();
    //double researchAsAssets();

    class LeasesCapitalized {
    public:
        double ebitAdd;
        double debtAdd;
    };
    LeasesCapitalized leasesAsDebt(double cod, double yThis, double y1, double y2to4, double y5);


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
    double mcap(double shares, double sharePrice);
    double ev(double mcap, double cash, double currentDebt, double longDebt); //FIXME: needs more terms

private slots:
    void dcfDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>());
    void magicDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>());

private:
    //dcf
    double dcfEquityValue(double sales, double ebitMargin, double terminalEbitMargin,
                          double salesGrowth, double salesPerCapital, double wacc,
                          double terminalGrowth = DefaultTerminalGrowth,
                          int growthYears = DefaultGrowthYears,
                          double tax = DefaultTaxRate,
                          Change salesGrowthChange = Change::Linear,
                          Change ebitMarginChange = Change::Constant);


    bool initModel(RamTableModel &model, const QString& table);
    void buildLookups();
    double fin(const QString& role); //remember to run _financials.selectRow() before!
    double finCapEmployed();
    double get(const QString& role, RamTableModel *model = nullptr); //remember to run _financials.selectRow() before!
    bool set(const QString& role, double val, RamTableModel *model = nullptr);
    bool setInt(const QString& role, int val, RamTableModel *model = nullptr);


    bool yearSet(const QString &role, double val);
    bool yearSet(const QString &role, int val);
    bool yearSet(const QString &role, const QString& val);
    bool saveYear(const QString &year, int step, double sales, double cSalesGrowth, double ebit, double cEbitMargin,
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
    SqlModel _model;
    SqlModel _resultsModel;
    SqlModel _magicModel;

    //not owned data; only lookup, dont share will set own filters,sort etc
    RamTableModel* _financials {nullptr};
    bool _changeUpdates { true };
    bool _autoReAnalyse{ false };
};

#endif // ANALYSIS_HPP
