#ifndef ANALYSISDEBUG_HPP
#define ANALYSISDEBUG_HPP

#include <QString>


class AnalysisDebug
{
public:
    static void logTitle(const QString& title);

    static void logYear(int year, double sales, double ebit, double reinvest, double fcf, double dcf, double investedCapital);
    static void logSumYear(double sum);

    static void logTerminal(int year, double terminalEbitMargin, double fcf, double terminalGrowth,
                            double value, int discountYear, double discountedValue);

    static void logInitial(double sales, double ebitMargin,
                    double salesGrowth, int growthYears,
                    double salesPerCapital, double wacc, double tax);

    static void logResult(double result);
};

#endif // ANALYSISDEBUG_HPP
