#include "RamTableModel.hpp"

#include "RamTableModel.hpp"
#include "Log.hpp"
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlError>
#include <QRegExp>

RamTableModel::RamTableModel(QObject *parent)
    : QAbstractItemModel(parent)
{
}

RamTableModel::~RamTableModel()
{
}

QHash<int, QByteArray> RamTableModel::roleNames() const
{
    return _roles;
}

QModelIndex RamTableModel::index(int row, int column, const QModelIndex &parent) const
{
    if (parent.isValid()) {
        return QModelIndex();
    }
    return createIndex(row, column);
}

QModelIndex RamTableModel::parent(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return QModelIndex();
}

QVariant RamTableModel::data(const QModelIndex &index, int role) const
{
    QVariant value;

    if (index.isValid()) {
        int col = role;
        if (role >= Qt::UserRole) {
            col = role - Qt::UserRole - 1;
        }
        int row = index.row();
        if (row < rowCount()) {
            int aRow = actualRow(row);
            return dataNoFilter(aRow, col);
        }
    }
    return value;
}

QVariant RamTableModel::dataNoFilter(int row, int col) const
{
    QVariant value;
    if (row < 0 || row >= _ramData.count()) {
        return QVariant();
    }
    if (col < 0 || col >= _ramData[row].count()) {
        return QVariant();
    }
    value = _ramData.at(row).at(col);

    if (!value.isNull()) {
        if (_related.contains(col)) {
            RamTableModel* model = _related[col].model;
            bool prevFilt = model->filtersEnabled(); //dont lookup related with any filtering
            model->setFiltersEnabled(false);
            int relatedRow = model->findRow(_related[col].relatedRole, value);
            int relatedCol = model->roleColumn(_related[col].displayRole);
            //logStatus() << tableName() << row << relatedRow << relatedCol;
            if (relatedRow >= 0 && relatedCol >= 0) {
                //logStatus() << "rel:" << row << col << value << _related[col].relatedRole << _related[col].displayRole << relatedRow << relatedCol;
                value = model->get(relatedRow, relatedCol);
                //logStatus() << value;
            }
            else {
                //logError() << "did not find related value" << _related[col].relatedRole << _related[col].displayRole;
                value = "";
            }
            model->setFiltersEnabled(prevFilt);
        }
    }
    if (value.isNull()) {
        return ""; //FIXME: for qml
    }
    return value;
}

bool RamTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    //logStatus() << "setData:" << modelIndex << value;
    if (_virtualRoles.contains(role)) {
        logError() << "setting value on virtual role not allowed";
        return false;
    }
    if (index.isValid()) {
        //dont update if not needed; will trigger heavy stuff like reAnalyse etc:
        if (data(index, role) != value) {
            int columnIdx = role;
            if (role >= Qt::UserRole) {
                columnIdx = role - Qt::UserRole - 1;
            }
            int row = index.row();
            if (row < rowCount()) {
                int aRow = actualRow(row);
                if (columnIdx < _ramData[aRow].count()) {
                    _ramData[aRow][columnIdx] = value;
                    _ramDataChanged[aRow][columnIdx] = RowChange::Update;
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

Qt::ItemFlags RamTableModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

bool RamTableModel::insertRows(int row, int count, const QModelIndex &parent)
{
    if (count <= 0) {
        return false;
    }
    bool ok = true;
    int aRow = row;
    if (aRow < 0) {
        aRow = actualRowCount();
    }
    if (row < 0) {
        row = rowCount();
    }

    if (_filtersEnabled && _removedByFilter.count() && aRow < actualRowCount()) {
        logError() << "adding below actualRowCount() not allowed when filters active";
        return false;
    }

    beginInsertRows(parent, row, row + count - 1);
    for (int i = 0; i < count; i++) {
        _ramData.insert(aRow, QVector<QVariant>());
        _ramDataChanged.insert(aRow, QVector<RowChange>());
        for (int col = 0; col < columnCount(); col++) {
            if (col == _idColumn) {
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

bool RamTableModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if (row < 0 || row + count > rowCount()) {
        logError() << "oob" << row;
        return false;
    }
    beginRemoveRows(parent, row, row + count - 1);

    for (int i = 0; i < count; i++) {
        int aRow = actualRow(row);
        _ramDataRemoved.push_back(_ramData[aRow][_idColumn].toString());
        _ramData.removeAt(aRow);
        _ramDataChanged.removeAt(aRow);
    }
    endRemoveRows();

    //as we are now re-ording actual rows we must re-filter...
    applyFilters();

    return true;
}

void RamTableModel::addRole(const QString &role, bool isId)
{
    if (isId) {
        _idColumn = _numColumns;
    }
    QByteArray name = role.toUtf8();
    _roles[_nextRole] = name;
    _colNames[_numColumns] = name;
    _roleInt[name] = _nextRole;
    _nextRole++;
    _numColumns++;
}

bool RamTableModel::select()
{
    return true;
}

bool RamTableModel::submitAll()
{
    return true;
}

bool RamTableModel::revertAll()
{
    return select();
}

bool RamTableModel::selectRow(int row)
{
    if (row < 0) {
        logError() << "select row:" << row << "failed";
        return false;
    }
    _selectedRow = row;
    return true;
}

int RamTableModel::selectedRow()
{
    return _selectedRow;
}

void RamTableModel::setTable(const QString &table)
{
    _table = table;
}

QString RamTableModel::tableName() const
{
    return _table;
}

int RamTableModel::columnToRoleId(int column) const
{
    return column + Qt::UserRole + 1;
}

int RamTableModel::roleId(const QString &role) const
{
    if (!haveRole(role)) {
        logError() << "faulty role on" << tableName() << role;
        return -1;
    }
    return _roleInt[role];
}

int RamTableModel::roleColumn(const QString &role) const
{
    int qtIndex = roleId(role);
    if (qtIndex < 0) {
        return qtIndex;
    }
    return (qtIndex - Qt::UserRole - 1);
}

QString RamTableModel::columnRole(int column) const
{
    if (!_roles.contains(columnToRoleId(column))) {
        logError() << "no such column role" << column;
        return "";
    }
    return _roles[columnToRoleId(column)];
}

bool RamTableModel::haveRole(const QString &role) const
{
    return _roleInt.contains(role);
}

QString RamTableModel::roleName(int id)
{
    if (_roles.contains(id)) {
        return _roles[id];
    }
    return "";
}

int RamTableModel::rowToId(int row) const
{
    if (_idColumn < 0) {
        logError() << "id column not found";
        return -1;
    }
    return get(row, "id").toInt();
}

int RamTableModel::idToRow(int id)
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

int RamTableModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);

    if (!_filtersEnabled) {
        return actualRowCount();
    }
    return _ramData.count() - _removedByFilter.count();
}

int RamTableModel::columnCount(const QModelIndex &parent) const
{
    return _roles.count();
}

bool RamTableModel::newRow(int col, const QVariant &value)
{
    if (insertRows(-1, 1)) {
        int row = rowCount() - 1;
        if (col >= 0) {
            if (!set(row, columnRole(col), value)) {
                return false;
            }
        }
        _selectedRow = row;
        return true;
    }
    return false;
}

bool RamTableModel::newRow(const QString &role, const QVariant &value)
{
    if (!role.length()) {
        return newRow();
    }
    return newRow(roleColumn(role), value);
}

bool RamTableModel::delRow(int row)
{
    bool ok = removeRows(row, 1);

    if (!ok) {
        logError() << "delRow" << row << "failed";
    }
    return ok;
}

bool RamTableModel::delId(int id)
{
    bool ok = false;
    int row = idToRow(id);
    if (row >= 0) {
        ok = removeRows(row, 1);
    }
    if (!ok) {
        logError() << "delId" << id<< "failed";
    }
    return ok;
}

bool RamTableModel::delAllRows()
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

bool RamTableModel::delAllRows(const QString &role, const QVariant &value)
{
    bool ok = true;
    QList<int> toDelete;
    int col = roleColumn(role);
    if (col >= 0) {
        for(int i = 0; i < rowCount(); i++) {
            if(_ramData[i][col] == value) {
                toDelete.push_back(get(i, "id").toInt());
            }
        }
        for(int i = 0; i < toDelete.count(); i++) {
            if (!delId(toDelete.at(i))) {
                ok = false;
            }
        }
    }
    else {
        ok = false;
    }
    if (!ok) {
        logError() << "del all rows failed:" << role << "=" << value;
    }
    return ok;
}

bool RamTableModel::set(const QString &role, const QVariant &value)
{
    return set(_selectedRow, role, value);
}

bool RamTableModel::set(const int row, const QString &role, const QVariant &value)
{
    if (!haveRole(role)) {
        logError() << "RamTableModel::set failed" << row << role << value;
        return false;
    }
    return setData(createIndex(row, 0), value, _roleInt[role]);
}

QVariant RamTableModel::get(const QString &role) const
{
    return get(_selectedRow, role);
}

QVariant RamTableModel::get(const int row, const QString &role) const
{
    if (!haveRole(role)) {
        logError()  << "dont have role:" << role;
        return QVariant();
    }
    int col = roleColumn(role);
    return get(row, col);
}

QVariant RamTableModel::get(const int row, const int col) const
{
    if (row >= rowCount()) {
        logError()  << tableName() << "row out oob:" << row << "col:" << col;
        return QVariant();
    }

    QVariant value;
    int aRow = actualRow(row);
    if (col >= 0 && col < _ramData[aRow].count()) {
        value = _ramData.at(aRow).at(col);
    }
    if (value.isNull()) {
        return ""; //FIXME: for qml
    }

    return value;
}

int RamTableModel::findRow(const QString &role, const QVariant &value)
{
    int col = roleColumn(role);
    for (int i = 0; i < rowCount(); i++) {
        QVariant val = get(i, col);
        if (val == value) {
            return i;
        }
    }
    return -1;
}

void RamTableModel::setSort(int col, Qt::SortOrder order)
{
    _sorts[col] = order;
    select();
}

void RamTableModel::setSort(const QString &role, Qt::SortOrder order)
{
    setSort(roleColumn(role), order);
}


bool RamTableModel::addRelated(const QString &role, RamTableModel *model, const QString &relatedRole, const QString &displayRole)
{
    bool ok = true;
    beginResetModel();

    if (!_roleInt.contains(role)) {
        logStatus() << "added virtual relation on" << role;
        _roles[_nextRole] = role.toUtf8();
        _virtualRoles[_nextRole] = role.toUtf8();
        _nextRole++;
    }

    RamTableModelRelation rel;
    rel.model = model;
    rel.role = role;
    rel.relatedRole = relatedRole;
    rel.displayRole = displayRole;
    int col = roleColumn(role);
    if (col >= 0) {
        _related[col] = rel;
    }
    else {
        logError() << "failed to add relation";
        ok = false;
    }
    connect(rel.model, SIGNAL(dataChanged(QModelIndex,QModelIndex,QVector<int>)),
            this, SLOT(relatedDataChanged(QModelIndex,QModelIndex,QVector<int>)));
    endResetModel();
    return ok;
}

void RamTableModel::setFiltersEnabled(bool enabled)
{
    _filtersEnabled = enabled;
}

bool RamTableModel::filtersEnabled() const
{
    return _filtersEnabled;
}


void RamTableModel::clearFilters()
{
    beginResetModel();
    _filters.clear();
    _removedByFilter.clear();
    endResetModel();
}

void RamTableModel::filterColumn(const QString &role, const QString &filter)
{
    return filterColumn(roleColumn(role), filter);
}

void RamTableModel::filterColumn(int column, const QString &filter)
{
    if (filter.count()) {
        _filters[column] = filter;
    }
    else {
        _filters.remove(column);
    }
    applyFilters();
}

QString RamTableModel::columnFilter(const QString &role)
{
    return columnFilter(roleColumn(role));
}

QString RamTableModel::columnFilter(int column)
{
    if (_filters.contains(column)) {
        return _filters[column];
    }
    return "";
}

//FIXME: there is better way to do this:
int RamTableModel::actualRow(int filteredRow) const
{
    if (!_filtersEnabled) {
        return filteredRow;
    }

    if (!_removedByFilter.count()) {
        return filteredRow;
    }
    if (filteredRow >= rowCount()) {
        return filteredRow;
    }

    int i;
    for (i = 0; i < actualRowCount(); i++) {
        if (!_removedByFilter.contains(i)) {
            filteredRow--;
        }
        if (filteredRow < 0) {
            break;
        }
    }
    return i;
}

int RamTableModel::idColumn() const
{
    return _idColumn;
}

void RamTableModel::relatedDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles)
{
    //FIXME: this will update all rows in model... (only affected roles though)

    QList<RamTableModelRelation> relations = _related.values();
    foreach(const RamTableModelRelation& rel, relations) {
        if (rel.model == sender()) {
            foreach(int id, roles) {
                QString changedRole = rel.model->roleName(id);
                if (rel.displayRole == changedRole) {
                    int col = roleColumn(rel.role);
                    QModelIndex left = createIndex(0, col);
                    QModelIndex right = createIndex(rowCount(), col);
                    //logStatus() << "data change:" << left << right << rel.role;
                    emit dataChanged(left, right, QVector<int>() << roleId(rel.role));
                }
            }
        }
    }
}

void RamTableModel::applyFilters()
{
    beginResetModel();
    _removedByFilter.clear();

    //loop through rows and filter data
    //FIXME: fix filters
    for (int column = 0; column < columnCount(); column++) {
        if (!_filters.contains(column)) {
            continue;
        }
        QString filter = _filters[column];
        bool followRelation = false;
        if (filter.startsWith("&")) {
            followRelation = true;
            filter = filter.mid(1);
        }

        for (int row = 0; row < actualRowCount(); row++) {
            QVariant value;
            if (followRelation) {
                value = dataNoFilter(row, column);
            }
            else {
                 value = _ramData[row][column];
            }

            if (filter.startsWith("=")) {
                if (value != filter.mid(1)) {
                    _removedByFilter.push_back(row);
                }
            }
            else if (filter.startsWith("!=")) {
                if (value == filter.mid(2)) {
                    _removedByFilter.push_back(row);
                }
            }
            else if (filter.startsWith("<")) {
                if (value.toDouble() >= filter.mid(1).toDouble()) {
                    _removedByFilter.push_back(row);
                }
            }
            else if (filter.startsWith(">")) {
                if (value.toDouble() <= filter.mid(1).toDouble()) {
                    _removedByFilter.push_back(row);
                }
            }

            QRegExp rx("like '%(.*)%'");
            rx.setCaseSensitivity(Qt::CaseInsensitive);
            if (rx.indexIn(filter) >= 0) {
                if (!value.toString().contains(rx.cap(1), Qt::CaseInsensitive)) {
                    _removedByFilter.push_back(row);
                }
            }
        }
    }
    //logStatus() << "actual rows removed by filter:" << _removedByFilter;

    endResetModel();
}

int RamTableModel::actualRowCount() const
{
    return _ramData.count();
}
