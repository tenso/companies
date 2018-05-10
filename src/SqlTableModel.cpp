#include "SqlTableModel.hpp"
#include "Log.hpp"
#include <QSqlRecord>

SqlTableModel::SqlTableModel(const QString &table, QObject *parent)
    : QSqlRelationalTableModel(parent)
{
    setTable(table);
    setEditStrategy(EditStrategy::OnManualSubmit);
    select();

    _numColumns = record().count();
    for (int i = 0; i < _numColumns; i++) {
        QByteArray name = record().fieldName(i).toUtf8();
        if (name == "id") {
            _idColumn = i;
        }
        _roles[Qt::UserRole + i + 1] = name;
        _roleId[name] = Qt::UserRole + i + 1;
    }
}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    return _roles;
}

QVariant SqlTableModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation == Qt::Orientation::Horizontal) {
        return _roles[ role ]; //FIXME: offset
    }
    return section;
}

QVariant SqlTableModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (index.isValid()) {
        QModelIndex modelIndex = index;
        if (role >= Qt::UserRole) {
            int columnIdx = role - Qt::UserRole - 1;
            modelIndex = this->index(index.row(), columnIdx);
        }
        value = QSqlRelationalTableModel::data(modelIndex, Qt::DisplayRole);
    }
    return value;
}

bool SqlTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    QModelIndex modelIndex = index;
    //logStatus() << "setData:" << modelIndex << value;
    if (index.isValid() /*&& data(index, role) != value*/) {
        if (role >= Qt::UserRole) {
            int columnIdx = role - Qt::UserRole - 1;
            modelIndex = this->index(index.row(), columnIdx);
        }
        if (!QSqlRelationalTableModel::setData(modelIndex, value)) {
            logError() << "setData failed" << modelIndex << value;
            return false;
        }
        emit dataChanged(modelIndex, modelIndex, QVector<int>() << role);
        return true;
    }
    logError() << "setData: faulty index" << modelIndex << value;
    return false;
}

Qt::ItemFlags SqlTableModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

bool SqlTableModel::insertRows(int row, int count, const QModelIndex &parent)
{
    bool ok = false;
    if (row < 0) {
        row = rowCount();
    }
    beginInsertRows(parent, row, row + count - 1);
    ok = QSqlRelationalTableModel::insertRows(row, count);
    endInsertRows();
    if (!ok) {
        logError() << "insert failed:" << row << count;
    }
    return ok;
}

bool SqlTableModel::removeRows(int row, int count, const QModelIndex &parent)
{
    bool ok = false;
    if (row < 0 || row >= rowCount()) {
        logError() << "no such row:" << row;
        return ok;
    }
    beginRemoveRows(parent, row, row + count - 1);
    ok = QSqlRelationalTableModel::removeRows(row, count);

    endRemoveRows();
    return ok;
}

void SqlTableModel::addRelation(int col, const QSqlRelation &relation)
{
    _relations[col] = relation;
}

void SqlTableModel::applyRelations(bool empty)
{
    foreach(int col, _relations.keys()) {
        if (empty) {
            setRelation(col, QSqlRelation());
        }
        else {
            setRelation(col, _relations[col]);
        }
    }
    if (!select()) {
        logError() << tableName() << "select failed";
    }
}

bool SqlTableModel::fetchAll()
{
    while (canFetchMore()) {
        fetchMore();
    }
    return true;
}

int SqlTableModel::rowToId(int index) const
{
    if (_idColumn < 0) {
        logError() << "id column not found";
        return -1;
    }
    QModelIndex modelIndex = this->index(index, _idColumn);
    return QSqlRelationalTableModel::data(modelIndex, Qt::DisplayRole).toInt();
}

void SqlTableModel::filterColumn(int index, const QString &filter)
{
    int roleIndex = index + Qt::UserRole + 1;

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
    applyFilters();
}

void SqlTableModel::applyFilters(bool empty)
{
    if (empty) {
        setFilter("");
    }
    else {
        setFilter(_totalFilter);
    }

    if (!select()) {
        logError() << "select failed" << selectStatement();
    }
    fetchAll();
}

bool SqlTableModel::newRow(int col, const QVariant &value)
{
    applyRelations(true); //cant insert rows with relations; sqlite will not find related entries over 256!
    QSqlRecord rec = record();
    for (int i =0; i < _numColumns; i++) {
        if (i != _idColumn) {
            QVariant val;
            if (col == i) {
                val = value;
            }
            else {
                if (_relations.contains(i)) {
                    val = 1;
                }
            }
            rec.setValue(i, val);
        }
    }
    if (!insertRecord(-1, rec)) {
        logError() << "insert record failed";
        applyRelations(false);
        return false;
    }
    submitAll();
    applyRelations(false);
    return true;
}

bool SqlTableModel::delRow(int row)
{
    bool ok = removeRows(row, 1);
    if (ok) {
        if (submitAll()) {
            return true;
        }
    }
    revertAll();
    logError() << "delRow" << row << "failed";
    return false;
}

bool SqlTableModel::delAllRows()
{
    bool ok = removeRows(0, rowCount());
    if (ok) {
        if (submitAll()) {
            return true;
        }
    }
    revertAll();
    logError() << "delAllRows" << rowCount() << "failed";
    return false;
}


bool SqlTableModel::set(const int row, const QString &role, const QVariant &value)
{
    if (!haveRole(role)) {
        return false;
    }
    return setData(createIndex(row,0), value, _roleId[role]);
}

QVariant SqlTableModel::get(const int row, const QString &role)
{
    if (!haveRole(role)) {
        return QVariant();
    }
    return data(createIndex(row,0), _roleId[role]);
}

int SqlTableModel::roleId(const QString &role)
{
    if (!haveRole(role)) {
        logError() << "faulty role on" << tableName() << role;
        return -1;
    }
    return _roleId[role];
}

bool SqlTableModel::haveRole(const QString &role)
{
    return _roleId.contains(role);
}
