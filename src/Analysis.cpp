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
    if (!_financials.init("financials")) {
        logError() << "Analysis::init financials failed";
        return false;
    }
    _financials.filterColumn("qId", "=1"); //only want FY entries
    _financials.setSort("year", Qt::DescendingOrder);
    return true;
}

bool Analysis::dcf(int cId)
{
    Q_UNUSED(cId);
    return true;
}
