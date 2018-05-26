#ifndef SqlModel_HPP
#define SqlModel_HPP

#include "RamTableModel.hpp"
#include <QSqlRelation>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlDatabase>

class SqlModel : public RamTableModel
{
    Q_OBJECT

public:
    explicit SqlModel(QObject *parent = nullptr);
    virtual ~SqlModel();
    virtual bool init(const QString& table) override;

public slots:
    virtual bool select() override;
    virtual bool submitAll() override;

    QSqlQuery query();
    QSqlRecord record();

private:
    QSqlDatabase _db;
    bool _printSql {false};

};

#endif // SqlModel_HPP
