#include "SqlTableModel.hpp"
#include "Log.hpp"
#include <QSqlRecord>
#include <QSqlQuery>

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

    QSqlQuery q = query();
    q.prepare("select MAX(id) from " + tableName());
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
    //logStatus() << tableName() << "next PK" << _nextPrimary;
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
        logError() << "removeRows() no such row:" << row;
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

bool SqlTableModel::submitAll()
{
    bool ok = QSqlRelationalTableModel::submitAll();
    fetchAll();
    return ok;
}

bool SqlTableModel::selectRow(int row)
{
    if (row < 0) {
        return false;
    }
    _selectedRow = row;
    return true;
}

bool SqlTableModel::applyRelations(bool empty, bool skipSelect)
{
    if (_relations.size() == 0) {
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
    return get(row, "id").toInt();
}

int SqlTableModel::idToRow(int id)
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

int SqlTableModel::rowCount(const QModelIndex &parent)
{
    fetchAll();
    return QSqlRelationalTableModel::rowCount(parent);
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
    //cant insert rows with relations; sqlite will not find related entries over 256!
    //make sure not to run select() as it would undo all un-submitted changes
    applyRelations(true, true);
    QSqlRecord rec = record();
    for (int i =0; i < _numColumns; i++) {
        QVariant val;
        if (i == _idColumn) {
            val = _nextPrimary++;
        }
        else {
            if (col == i) {
                val = value;
            }
            else if (_relations.contains(i)) {
                val = 1;
            }
        }
        rec.setValue(i, val);
    }

    if (!insertRecord(-1, rec)) {
        logError() << "insert record failed";
        applyRelations(false, true);
        return false;
    }
    applyRelations(false, true);
    _selectedRow = rowCount() - 1;
    return true;

}

bool SqlTableModel::newRow(const QString &role, const QVariant &value)
{
    if (!role.length()) {
        return newRow();
    }
    return newRow(roleColumn(role), value);
}

int SqlTableModel::selectedRow()
{
    return _selectedRow;
}

bool SqlTableModel::delRow(int row)
{
    bool ok = removeRows(row, 1);

    if (!ok) {
        logError() << "delRow" << row << "failed";
    }
    return ok;
}

bool SqlTableModel::delAllRows()
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

bool SqlTableModel::delAllRows(const QString &role, const QVariant &value)
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

QString SqlTableModel::columnRole(int column) const
{
    if (!_roles.contains(column + Qt::UserRole + 1)) {
        logError() << "no such column role" << column;
        return "";
    }
    return _roles[column + Qt::UserRole + 1];
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
