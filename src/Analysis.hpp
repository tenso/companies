#ifndef ANALYSIS_HPP
#define ANALYSIS_HPP

#include <QObject>
#include "SqlTableModel.hpp"

class Analysis : public QObject
{
    Q_OBJECT
public:
    explicit Analysis(QObject *parent = nullptr);
    bool init();

signals:

public slots:
    bool dcf(int cId);

private:
    SqlTableModel _companies;
    SqlTableModel _financials;
};

#endif // ANALYSIS_HPP
