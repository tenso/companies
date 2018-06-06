#include "SqlModel.hpp"
#include "Log.hpp"
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlError>
#include <QRegExp>

SqlModel::SqlModel(QObject *parent)
    : RamTableModel(parent)
{
}

SqlModel::~SqlModel()
{
}

bool SqlModel::init(const QString &table)
{
    _db = QSqlDatabase::database();

    setTable(table);

    if (!select()) {
        logError() << "table init failed:" << tableName();
        return false;
    }

    int numColumns = record().count();
    for (int i = 0; i < numColumns; i++) {
        QString name = record().fieldName(i);
        bool isId = (name == "id");
        addRole(name, isId);
    }

    if (idColumn() < 0) {
        logError() << "id column not found, cant use table";
        return false;
    }

    QSqlQuery q = query();
    q.prepare("SELECT MAX(id) FROM " + tableName());
    if (!q.exec()) {
        logError() << "failed to get next primary";
        return false;
    }
    if (q.next()) {
        _nextPrimary = q.value(0).toInt() + 1;
    }
    else {
        logError() << "failed to get next primary (2)";
        return false;
    }
    /*
    logStatus() << tableName() << _roles << "next PK" << _nextPrimary;
    logStatus() << "----------------------";
    logStatus() << _ramData;*/
    return true;
}

bool SqlModel::select()
{
    beginResetModel();
    _ramData.clear();
    _ramDataChanged.clear();
    _ramDataRemoved.clear();

    QString s = "SELECT * FROM " + tableName();
    if (_printSql) {
        logStatus() << s;
    }
    QSqlQuery q = query();
    q.prepare(s);
    if (!q.exec()) {
        return false;
    }
    while (q.next()) {
        QSqlRecord r = q.record();
        _ramData.append(QVector<QVariant>());
        _ramDataChanged.append(QVector<RowChange>());
        for(int i = 0; i < r.count(); i++) {
            _ramData.last().append(r.value(i));
            _ramDataChanged.last().append(RowChange::None);
        }
    }
    endResetModel();
    return true;
}

bool SqlModel::submitAll()
{
    for (int row = 0; row < _ramDataRemoved.count(); row++) {
        QString s = QString("DELETE FROM ") + tableName() +
                " WHERE id=" + _ramDataRemoved[row];
        QSqlQuery q;
        q.prepare(s);
        if (!q.exec()) {
            logError() << q.lastError();
        }
        if (_printSql) {
            logStatus() << s;
        }
    }

    for (int row = 0; row < actualRowCount(); row++) {

        if (_ramDataChanged[row][idColumn()] == RowChange::Insert) {
            QString values;
            for (int i = 0; i < _ramData[row].count(); i++) {
                if (_ramData[row][i].isNull()) {
                    values += "null,";
                }
                else {
                    values += "'" + _ramData[row][i].toString() + "',";
                }
            }
            values.chop(1); //remove last ','

            QString s = QString("INSERT INTO ") + tableName() +
                    " VALUES (" + values + ")";

            QSqlQuery q;
            q.prepare(s);
            if (!q.exec()) {
                logError() << q.lastError();
            }
            if (_printSql) {
                logStatus() << s;
            }
            for (int col = 0; col< _ramData[row].count(); col++) {
                _ramDataChanged[row][col] = RowChange::None;
            }
        }
        else {
            for (int col = 0; col< _ramData[row].count(); col++) {
                if (col != idColumn()) {
                    if (_ramDataChanged[row][col] != RowChange::None) {
                        if (_ramDataChanged[row][col] == RowChange::Update) {
                            QString s = QString("UPDATE ") + tableName() +
                                    " SET " + columnRole(col) + "='" + _ramData[row][col].toString() +
                                    "' WHERE id=" + _ramData[row][idColumn()].toString();
                            QSqlQuery q;
                            q.prepare(s);
                            if (!q.exec()) {
                                logError() << q.lastError();
                            }
                            if (_printSql) {
                                logStatus() << s;
                            }
                        }
                    }
                }
            }
        }
    }
    return true;
}

QSqlQuery SqlModel::query()
{
    return QSqlQuery(_db);
}

QSqlRecord SqlModel::record()
{
    return _db.record(tableName());
}
