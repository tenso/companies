#include "AnalysisDebug.hpp"

#define EntryColor Black
#define HeadColor Cyan
#define TitleColor Magenta
#define SumColor Green
enum Color {Reset, Black, White, Green, Red, Blue, Yellow, Cyan, Magenta};
void color(Color color)
{
    static const char* colors[] = { //'bright;fg;bgm'
        "\u001b[0m", "\u001b[1;30m", "\u001b[1;37m", "\u001b[1;32m", "\u001b[1;31m", "\u001b[1;34m",
        "\u001b[1;33m", "\u001b[1;36m", "\u001b[1;35m"
    };

    printf("%s", colors[color]);
}

void AnalysisDebug::logTitle(const QString& title)
{
    color(TitleColor); printf("\n----%s----\n", title.toStdString().c_str()); color(Reset);
}

void AnalysisDebug::logYear(int year, double sales, double ebit, double reinvest, double fcf, double dcf, double investedCapital)
{
    if (year < 0) {
        color(HeadColor);
        printf("year|   sales|  ebit| capex|   fcf|   dcf| capital|\n");
        color(Reset);
    }
    else {
        color(EntryColor);
        printf("%4d|%8.1f|%6.1f|%6.1f|%6.1f|%6.1f|%8.1f|\n", year, sales, ebit, reinvest, fcf, dcf, investedCapital);
        color(Reset);
    }
}

void AnalysisDebug::logTerminal(int year, double terminalEbitMargin, double fcf, double terminalGrowth,
                 double value, int discountYear, double discountedValue)
{
    color(HeadColor);
    printf("year|margin|   fcf|growth|   value|discount year|discount value|\n");
    color(EntryColor);
    printf(" %1d->|%5.1f%%|%6.1f|%5.1f%%|%8.1f|%13d|%14.1f|\n",
           year, terminalEbitMargin * 100, fcf, terminalGrowth * 100,
           value, discountYear, discountedValue);
    color(Reset);
}

void AnalysisDebug::logInitial(double sales, double ebitMargin, double salesGrowth,
                int growthYears, double salesPerCapital, double wacc, double tax)
{
    color(HeadColor);
    printf("sales   |margin|growth|years|sales/cap| wacc|tax|\n");
    color(EntryColor);
    printf("%8.1f|%5.1f%%|%5.1f%%|%5d|%9.1f|%4.1f%%|%2.0f%%|\n\n",
           sales, ebitMargin * 100, salesGrowth * 100,
           growthYears, salesPerCapital, wacc * 100, tax * 100);
    color(Reset);
}

void AnalysisDebug::logResult(double result)
{
    color(SumColor); printf("\nequity value: [%5.1f]\n\n", result); color(Reset);
}

void AnalysisDebug::logSumYear(double sum)
{
    color(SumColor); printf("sum |        |      |      |%6.1f|      |        |\n", sum); color(Reset);
}
