#include "SqlModel.hpp"
#include "Log.hpp"
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlError>

SqlModel::SqlModel(QObject *parent)
    : QAbstractListModel(parent)
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

    _numColumns = record().count();
    for (int i = 0; i < _numColumns; i++) {
        QByteArray name = record().fieldName(i).toUtf8();
        if (name == "id") {
            _idColumn = i;
        }
        _roles[Qt::UserRole + i + 1] = name;
        _colNames[i] = name;
        _roleInt[name] = Qt::UserRole + i + 1;
    }

    if (_idColumn < 0) {
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

QHash<int, QByteArray> SqlModel::roleNames() const
{
    return _roles;
}

QVariant SqlModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (index.isValid()) {
        int columnIdx = role;
        if (role >= Qt::UserRole) {
            columnIdx = role - Qt::UserRole - 1;
        }
        if (index.row() < _ramData.count()) {
            if (columnIdx < _ramData[index.row()].count()) {
                value = _ramData.at(index.row()).at(columnIdx);
            }
        }
    }
    if (value.isNull()) {
        return ""; //FIXME: for qml
    }
    return value;
}

bool SqlModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    //logStatus() << "setData:" << modelIndex << value;
    if (index.isValid()) {
        if (data(index, role) != value) { //this is very important, dont update; will trigger heavy stuff like reAnalyse etc
            int columnIdx = role;
            if (role >= Qt::UserRole) {
                columnIdx = role - Qt::UserRole - 1;
            }
            if (index.row() < _ramData.count()) {
                if (columnIdx < _ramData[index.row()].count()) {
                    _ramData[index.row()][columnIdx] = value;
                    _ramDataChanged[index.row()][columnIdx] = RowChange::Update;
                    emit dataChanged(index, index, QVector<int>() << role);
                    return true;
                }
            }
        }
        else {
            return true;
        }
    }
    logError() << "setData: faulty index";
    return false;
}

Qt::ItemFlags SqlModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

bool SqlModel::insertRows(int row, int count, const QModelIndex &parent)
{
    bool ok = true;
    if (row < 0) {
        row = rowCount();
    }
    beginInsertRows(parent, row, row + count - 1);
    for (int i = 0; i < count; i++) {
        _ramData.insert(row + i, QVector<QVariant>());
        _ramDataChanged.insert(row + i, QVector<RowChange>());
        for (int i = 0; i < _numColumns; i++) {
            if (i == _idColumn) {
                _ramData.last().append(_nextPrimary++);
            }
            else {
                _ramData.last().append(QVariant());
            }
            _ramDataChanged.last().append(RowChange::Insert);
        }
    }
    endInsertRows();
    if (!ok) {
        logError() << "insert failed:" << row << count;
    }
    return ok;
}

bool SqlModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row < 0 || row +count >= rowCount()) {
        logError() << "oob" << row;
        return false;
    }
    beginRemoveRows(parent, row, row + count - 1);

    for (int i = 0; i < count; i++) {
        _ramDataRemoved.push_back(_ramData[row][_idColumn].toString());
        _ramData.removeAt(row);
        _ramDataChanged.removeAt(row);
    }

    endRemoveRows();
    return true;
}

void SqlModel::setSort(int col, Qt::SortOrder order)
{
    //QSqlRelationalTableModel::setSort(col, order);
}

void SqlModel::setSort(const QString &role, Qt::SortOrder order)
{
    //QSqlRelationalTableModel::setSort(roleColumn(role), order);
}

bool SqlModel::addRelation(const QString &role, const QSqlRelation &relation)
{
    //return addRelation(roleColumn(role), relation);
}

bool SqlModel::addRelation(int col, const QSqlRelation &relation)
{
    /*if (col < 0) {
        logError() << "col oob:" << col;
        return false;
    }
    _relations[col] = relation;*/
    return true;
}

bool SqlModel::applyAll()
{
    return applyRelations();
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
        logStatus() << s;
    }

    for (int row = 0; row < _ramData.count(); row++) {

        if (_ramDataChanged[row][_idColumn] == RowChange::Insert) {
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
            logStatus() << s;
            for (int col = 0; col< _ramData[row].count(); col++) {
                _ramDataChanged[row][col] = RowChange::None;
            }
        }
        else {
            for (int col = 0; col< _ramData[row].count(); col++) {
                if (col != _idColumn) {
                    if (_ramDataChanged[row][col] != RowChange::None) {
                        if (_ramDataChanged[row][col] == RowChange::Update) {
                            QString s = QString("UPDATE ") + tableName() +
                                    " SET " + _colNames[col] + "='" + _ramData[row][col].toString() +
                                    "' WHERE id=" + _ramData[row][_idColumn].toString();
                            QSqlQuery q;
                            q.prepare(s);
                            if (!q.exec()) {
                                logError() << q.lastError();
                            }
                            logStatus() << s;
                        }
                    }
                }
            }
        }
    }
    return true;
}

bool SqlModel::revertAll()
{
    return select();
}

bool SqlModel::selectRow(int row)
{
    if (row < 0) {
        return false;
    }
    _selectedRow = row;
    return true;
}

bool SqlModel::applyRelations(bool empty, bool skipSelect)
{
    /*if (_relations.size() == 0) {
        return true;
    }
    foreach(int col, _relations.keys()) {
        if (empty) {
            setRelation(col, QSqlRelation());
        }
        else {
            setRelation(col, _relations[col]);
        }
    }
    if (!skipSelect && !select()) {
        logError() << tableName() << "select failed";
        return false;
    }
    */
    return true;
}


int SqlModel::rowToId(int row) const
{
    if (_idColumn < 0) {
        logError() << "id column not found";
        return -1;
    }
    return get(row, "id").toInt();
}

int SqlModel::idToRow(int id)
{
    if (_idColumn < 0) {
        logError() << "id column not found";
        return -1;
    }

    //FIXME: better way?
    for(int i = 0; i < rowCount(); i++) {
        if (get(i, "id").toInt() == id) {
            return i;
        }
    }
    logError() << "id not found:" << id;
    return -1;
}

int SqlModel::rowCount(const QModelIndex &parent) const
{
    return _ramData.count();
}

void SqlModel::filterColumn(int column, const QString &filter)
{
    /*int roleIndex = column + Qt::UserRole + 1;

    if (filter.size()) {
        QString role =  _roles[roleIndex];
        QString filterString = tableName() + "." + role + " " + filter;
        _filters[roleIndex] = filterString;
    }
    else {
        _filters.remove(roleIndex);
    }
    _totalFilter = QString();
    foreach(const QString& entry, _filters.values()) {
        _totalFilter += entry + " and ";
    }
    _totalFilter.chop(5); //remove last " and "
    applyFilters();*/
}

QString SqlModel::columnFilter(int column)
{
    /*if (_filters.contains(column)) {
        return _filters[column];
    }
    return "";*/
}

QSqlQuery SqlModel::query()
{
    return QSqlQuery(_db);
}

QSqlRecord SqlModel::record()
{
    return _db.record(_table);
}

void SqlModel::setTable(const QString &table)
{
    _table = table;
}

QString SqlModel::tableName() const
{
    return _table;
}

bool SqlModel::select()
{
    beginResetModel();
    _ramData.clear();
    _ramDataChanged.clear();
    _ramDataRemoved.clear();
    QSqlQuery q = query();
    q.prepare("select * from " + tableName());
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

void SqlModel::filterColumn(const QString &role, const QString &filter)
{
    //return filterColumn(roleColumn(role), filter);
}

QString SqlModel::columnFilter(const QString &role)
{
    //return columnFilter(roleColumn(role));
}

void SqlModel::applyFilters(bool empty)
{
    /*if (empty) {
        setFilter("");
    }
    else {
        setFilter(_totalFilter);
    }

    if (!select()) {
        logError() << "select failed" << selectStatement();
    }
    */
}

bool SqlModel::newRow(int col, const QVariant &value)
{
    int row = rowCount();
    insertRows(row, 1);
    if (col >= 0) {
        set(row, columnRole(col), value);
    }
    _selectedRow = row;
    return true;

}

bool SqlModel::newRow(const QString &role, const QVariant &value)
{
    if (!role.length()) {
        return newRow();
    }
    return newRow(roleColumn(role), value);
}

int SqlModel::selectedRow()
{
    return _selectedRow;
}

bool SqlModel::delRow(int row)
{
    bool ok = removeRows(row, 1);

    if (!ok) {
        logError() << "delRow" << row << "failed";
    }
    return ok;
}

bool SqlModel::delAllRows()
{
    if (rowCount() == 0) {
        return true;
    }
    bool ok = removeRows(0, rowCount());
    if (!ok) {
        logError() << "delAllRows" << rowCount() << "failed";
    }
    return ok;
}

bool SqlModel::delAllRows(const QString &role, const QVariant &value)
{
    bool ok = true;
    QList<int> toDelete;
    for(int i = 0; i < rowCount(); i++) {
        if(get(i, role) == value) {
            toDelete.push_back(i);
        }
    }

    for(int i = 0; i < toDelete.size(); i++) {
        if (!delRow(toDelete.at(i))) {
            ok = false;
        }
    }

    if (!ok) {
        logError() << "del all rows failed:" << role << "=" << value;
    }
    return ok;
}


bool SqlModel::set(const int row, const QString &role, const QVariant &value)
{
    if (!haveRole(role)) {
        logError() << "SqlModel::set failed" << row << role << value;
        return false;
    }
    return setData(createIndex(row,0), value, _roleInt[role]);
}

bool SqlModel::set(const QString &role, const QVariant &value)
{
    return set(_selectedRow, role, value);
}

QVariant SqlModel::get(const int row, const QString &role) const
{
    if (!haveRole(role)) {
        return QVariant();
    }
    return data(createIndex(row,0), _roleInt[role]);
}

QVariant SqlModel::get(const QString &role) const
{
    return get(_selectedRow, role);
}

int SqlModel::roleId(const QString &role) const
{
    if (!haveRole(role)) {
        logError() << "faulty role on" << tableName() << role;
        return -1;
    }
    return _roleInt[role];
}

int SqlModel::roleColumn(const QString &role) const
{
    int qtIndex = roleId(role);
    if (qtIndex < 0) {
        return qtIndex;
    }
    return (qtIndex - Qt::UserRole - 1);
}

QString SqlModel::columnRole(int column) const
{
    if (!_roles.contains(column + Qt::UserRole + 1)) {
        logError() << "no such column role" << column;
        return "";
    }
    return _roles[column + Qt::UserRole + 1];
}

bool SqlModel::haveRole(const QString &role) const
{
    return _roleInt.contains(role);
}

QString SqlModel::roleName(int id)
{
    if (_roles.contains(id)) {
        return _roles[id];
    }
    return "";
}
