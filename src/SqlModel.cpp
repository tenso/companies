#include "SqlModel.hpp"
#include "Log.hpp"
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlError>
#include <QRegExp>

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
        int col = role;
        if (role >= Qt::UserRole) {
            col = role - Qt::UserRole - 1;
        }
        int row = index.row();
        if (row < rowCount()) {
            int aRow = actualRow(row);
            if (col >= 0 && col < _ramData[aRow].count()) {
                if (_relations.contains(col)) {
                    QSqlQuery q;
                    QSqlRelation rel = _relations[col];
                    QString s = QString("SELECT ") + rel.displayColumn() +
                            " FROM " + rel.tableName() +
                            " WHERE " + rel.indexColumn()
                            + "=" + _ramData.at(aRow).at(col).toString();

                    q.prepare(s);
                    if (!q.exec()) {
                        logError() << QString("relation") << s << "failed:" << q.lastError();
                    }
                    if (q.next()) {
                        value = q.value(0);
                    }
                }
                else {
                    value = _ramData.at(aRow).at(col);
                }
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

Qt::ItemFlags SqlModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable; // FIXME: Implement me!
}

bool SqlModel::insertRows(int row, int count, const QModelIndex &parent)
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

    if (_removedByFilter.count() && aRow < actualRowCount()) {
        logError() << "adding below actualRowCount() not allowed when filters active";
        return false;
    }

    beginInsertRows(parent, row, row + count - 1);
    for (int i = 0; i < count; i++) {
        _ramData.insert(aRow, QVector<QVariant>());
        _ramDataChanged.insert(aRow, QVector<RowChange>());
        for (int col = 0; col < _numColumns; col++) {
            if (col == _idColumn) {
                _ramData.last().append(_nextPrimary++);
            }
            else {
                if (_relations.contains(col)) {
                    _ramData.last().append(DefaultRelationId);
                }
                else {
                    _ramData.last().append(QVariant());
                }
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

bool SqlModel::select()
{
    beginResetModel();
    _ramData.clear();
    _ramDataChanged.clear();
    _ramDataRemoved.clear();

    QString sortString;
    if (_sorts.count()) {
        sortString = " ORDER BY ";
        foreach(int col, _sorts.keys()) {
            sortString += columnRole(col) +  (_sorts[col] == Qt::SortOrder::AscendingOrder ? " ASC" : " DESC") + ",";
        }
        sortString.chop(1); //remove last ','
    }

    QString s = "SELECT * FROM " + tableName() + sortString;
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
            if (_printSql) {
                logStatus() << s;
            }
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

bool SqlModel::revertAll()
{
    return select();
}

bool SqlModel::selectRow(int row)
{
    if (row < 0) {
        return false;
    }
    _selectedRow = actualRow(row);
    return true;
}

int SqlModel::selectedRow()
{
    return _selectedRow;
}

void SqlModel::setTable(const QString &table)
{
    _table = table;
}

QString SqlModel::tableName() const
{
    return _table;
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
    Q_UNUSED(parent);
    return _ramData.count() - _removedByFilter.count();
}

bool SqlModel::newRow(int col, const QVariant &value)
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

bool SqlModel::newRow(const QString &role, const QVariant &value)
{
    if (!role.length()) {
        return newRow();
    }
    return newRow(roleColumn(role), value);
}

bool SqlModel::delRow(int row)
{
    bool ok = removeRows(row, 1);

    if (!ok) {
        logError() << "delRow" << row << "failed";
    }
    return ok;
}

bool SqlModel::delId(int id)
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

bool SqlModel::set(const QString &role, const QVariant &value)
{
    return set(_selectedRow, role, value);
}

bool SqlModel::set(const int row, const QString &role, const QVariant &value)
{
    if (!haveRole(role)) {
        logError() << "SqlModel::set failed" << row << role << value;
        return false;
    }
    return setData(createIndex(row, 0), value, _roleInt[role]);
}

QVariant SqlModel::get(const QString &role) const
{
    return get(_selectedRow, role);
}

QVariant SqlModel::get(const int row, const QString &role) const
{
    if (!haveRole(role)) {
        logError()  << "dont have role:" << role;
        return QVariant();
    }
    if (row >= rowCount()) {
        logError()  << "row out oob:" << row << role;
        return QVariant();
    }

    QVariant value;
    int col = roleColumn(role);
    int aRow = actualRow(row);
    if (col >= 0 && col < _ramData[aRow].count()) {
        value = _ramData.at(aRow).at(col);
    }
    if (value.isNull()) {
        return ""; //FIXME: for qml
    }
    return value;
}

void SqlModel::setSort(int col, Qt::SortOrder order)
{
    _sorts[col] = order;
    select();
}

void SqlModel::setSort(const QString &role, Qt::SortOrder order)
{
    setSort(roleColumn(role), order);
}

bool SqlModel::addRelation(const QString &role, const QSqlRelation &relation)
{
    return addRelation(roleColumn(role), relation);
}

bool SqlModel::addRelation(int col, const QSqlRelation &relation)
{
    if (col < 0) {
        logError() << "col oob:" << col;
        return false;
    }
    _relations[col] = relation;
    return true;
}


void SqlModel::clearFilters()
{
    beginResetModel();
    _filters.clear();
    _removedByFilter.clear();
    endResetModel();
}

void SqlModel::filterColumn(const QString &role, const QString &filter)
{
    return filterColumn(roleColumn(role), filter);
}

void SqlModel::filterColumn(int column, const QString &filter)
{
    if (filter.count()) {
        _filters[column] = filter;
    }
    else {
        _filters.remove(column);
    }
    applyFilters();
}

QString SqlModel::columnFilter(const QString &role)
{
    return columnFilter(roleColumn(role));
}

QString SqlModel::columnFilter(int column)
{
    if (_filters.contains(column)) {
        return _filters[column];
    }
    return "";
}

//FIXME: there is better way to do this:
int SqlModel::actualRow(int filteredRow) const
{
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

QSqlQuery SqlModel::query()
{
    return QSqlQuery(_db);
}

QSqlRecord SqlModel::record()
{
    return _db.record(_table);
}

void SqlModel::applyFilters()
{
    beginResetModel();
    _removedByFilter.clear();

    //loop through rows and filter data
    //FIXME: fix filters
    for (int column = 0; column < _numColumns; column++) {
        if (!_filters.contains(column)) {
            continue;
        }
        QString filter = _filters[column];

        for (int row = 0; row < actualRowCount(); row++) {
            if (filter.startsWith("=")) {
                if (_ramData.at(row).at(column) != filter.mid(1)) {
                    _removedByFilter.push_back(row);
                }
            }
            else if (filter.startsWith("!=")) {
                if (_ramData.at(row).at(column) == filter.mid(2)) {
                    _removedByFilter.push_back(row);
                }
            }
            else if (filter.startsWith("<")) {
                if (_ramData.at(row).at(column).toDouble() >= filter.mid(1).toDouble()) {
                    _removedByFilter.push_back(row);
                }
            }
            else if (filter.startsWith(">")) {
                if (_ramData.at(row).at(column).toDouble() <= filter.mid(1).toDouble()) {
                    _removedByFilter.push_back(row);
                }
            }

            QRegExp rx("like '%(.*)%'");
            rx.setCaseSensitivity(Qt::CaseInsensitive);
            if (rx.indexIn(filter) >= 0) {
                if (!_ramData.at(row).at(column).toString().contains(rx.cap(1), Qt::CaseInsensitive)) {
                    _removedByFilter.push_back(row);
                }
            }
        }
    }
    //logStatus() << "actual rows removed by filter:" << _removedByFilter;

    endResetModel();
}

int SqlModel::actualRowCount() const
{
    return _ramData.count();
}
