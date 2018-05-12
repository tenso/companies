#ifndef ANALYSISDEBUG_HPP
#define ANALYSISDEBUG_HPP

#include <QString>


class AnalysisDebug
{
public:
    static void logTitle(const QString& title);
    static void logNote(const QString& title);

    static void logYear(int year = -1, double sales = 0, double cSalesGrowth = 0, double ebit = 0,
                        double cEbitMargin = 0, double reinvest = 0, double fcf = 0,
                        double dcf = 0, double investedCapital = 0);

    static void logTerminal(int year, double terminalEbitMargin, double fcf, double terminalGrowth,
                            double value, int discountYear, double discountedValue);

    static void logInitial(double sales, double ebitMargin,
                    double salesGrowth, int growthYears,
                    double salesPerCapital, double wacc, double tax);

    static void logResult(double result);
};

#endif // ANALYSISDEBUG_HPP
