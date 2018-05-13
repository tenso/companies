#include "SqlTableModel.hpp"
#include "Log.hpp"
#include <QSqlRecord>

SqlTableModel::SqlTableModel(QObject *parent)
    : QSqlRelationalTableModel(parent)
{
}

SqlTableModel::~SqlTableModel()
{
    //logStatus() << "free:" << tableName();
}

bool SqlTableModel::init(const QString &table)
{
    setTable(table);
    setEditStrategy(EditStrategy::OnManualSubmit);
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
        _roleInt[name] = Qt::UserRole + i + 1;
    }
    return true;
}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    return _roles;
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
    if (index.isValid()) {
        if (data(index, role) != value) { //this is very important, dont update; will trigger heavy stuff like reAnalyse etc
            if (role >= Qt::UserRole) {
                int columnIdx = role - Qt::UserRole - 1;
                modelIndex = this->index(index.row(), columnIdx);
            }
            if (!QSqlRelationalTableModel::setData(modelIndex, value)) {
                logError() << "setData failed" << modelIndex << value;
                return false;
            }
            emit dataChanged(modelIndex, modelIndex, QVector<int>() << role);
        }
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

void SqlTableModel::setSort(int col, Qt::SortOrder order)
{
    QSqlRelationalTableModel::setSort(col, order);
}

void SqlTableModel::setSort(const QString &role, Qt::SortOrder order)
{
    QSqlRelationalTableModel::setSort(roleColumn(role), order);
}

bool SqlTableModel::addRelation(const QString &role, const QSqlRelation &relation)
{
    return addRelation(roleColumn(role), relation);
}

bool SqlTableModel::addRelation(int col, const QSqlRelation &relation)
{
    if (col < 0) {
        logError() << "col oob:" << col;
        return false;
    }
    _relations[col] = relation;
    return true;
}

bool SqlTableModel::applyAll()
{
    return applyRelations();
}

bool SqlTableModel::selectRow(int row)
{
    if (row < 0) {
        return false;
    }
    _selectedRow = row;
    return true;
}

bool SqlTableModel::applyRelations(bool empty)
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
        return false;
    }
    fetchAll();
    return true;
}

bool SqlTableModel::fetchAll()
{
    while (canFetchMore()) {
        fetchMore();
    }
    return true;
}

int SqlTableModel::rowToId(int row) const
{
    if (_idColumn < 0) {
        logError() << "id column not found";
        return -1;
    }
    QModelIndex modelIndex = this->index(row, _idColumn);
    return QSqlRelationalTableModel::data(modelIndex, Qt::DisplayRole).toInt();
}

int SqlTableModel::idToRow(int id) const
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

void SqlTableModel::filterColumn(int column, const QString &filter)
{
    int roleIndex = column + Qt::UserRole + 1;

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

QString SqlTableModel::columnFilter(int column)
{
    if (_filters.contains(column)) {
        return _filters[column];
    }
    return "";
}

void SqlTableModel::filterColumn(const QString &role, const QString &filter)
{
    return filterColumn(roleColumn(role), filter);
}

QString SqlTableModel::columnFilter(const QString &role)
{
    return columnFilter(roleColumn(role));
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
    _selectedRow = rowCount() - 1;
    return true;
}

bool SqlTableModel::newRow(const QString &role, const QVariant &value)
{
    return newRow(roleColumn(role), value);
}

int SqlTableModel::selectedRow()
{
    return _selectedRow;
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
    if (rowCount() == 0) {
        return true;
    }
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

bool SqlTableModel::delAllRows(const QString &role, const QVariant &value)
{
    QString prevFilter = columnFilter(role);
    filterColumn(role, "=" + value.toString());
    bool ok = delAllRows();
    filterColumn(role, prevFilter);
    return ok;
}


bool SqlTableModel::set(const int row, const QString &role, const QVariant &value)
{
    if (!haveRole(role)) {
        logError() << "SqlTableModel::set failed" << row << role << value;
        return false;
    }
    return setData(createIndex(row,0), value, _roleInt[role]);
}

bool SqlTableModel::set(const QString &role, const QVariant &value)
{
    return set(_selectedRow, role, value);
}

QVariant SqlTableModel::get(const int row, const QString &role) const
{
    if (!haveRole(role)) {
        return QVariant();
    }
    return data(createIndex(row,0), _roleInt[role]);
}

QVariant SqlTableModel::get(const QString &role) const
{
    return get(_selectedRow, role);
}

int SqlTableModel::roleId(const QString &role) const
{
    if (!haveRole(role)) {
        logError() << "faulty role on" << tableName() << role;
        return -1;
    }
    return _roleInt[role];
}

int SqlTableModel::roleColumn(const QString &role) const
{
    int qtIndex = roleId(role);
    if (qtIndex < 0) {
        return qtIndex;
    }
    return (qtIndex - Qt::UserRole - 1);
}

bool SqlTableModel::haveRole(const QString &role) const
{
    return _roleInt.contains(role);
}

QString SqlTableModel::roleName(int id)
{
    if (_roles.contains(id)) {
        return _roles[id];
    }
    return "";
}
