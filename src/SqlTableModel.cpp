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
        _roles.insert(Qt::UserRole + i + 1, name);
    }
}

QHash<int, QByteArray> SqlTableModel::roleNames() const
{
    return _roles;
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
        QString filterString = "companies." + role + " " + filter;
        _filters[roleIndex] = filterString;
    }
    else {
        _filters.remove(roleIndex);
    }
    QString totalFilter;
    foreach(const QString& entry, _filters.values()) {
        totalFilter += entry + " and ";
    }
    totalFilter.chop(5); //remove last " and "
    setFilter(totalFilter);

    if (!select()) {
        logError() << "select failed" << selectStatement();
    }
    fetchAll();
}

bool SqlTableModel::newRow()
{
    int rowNum = rowCount();
    logStatus() << "newRow:" << tableName() << rowNum; //FIXME: remove
    if (insertRows(rowNum, 1)) {
        submitAll();
        for (int i =0; i < _numColumns; i++) {
            if (i != _idColumn) {
                if (!setData(QSqlRelationalTableModel::index(rowNum, i), QVariant())) {
                    logError() << "setData failed on new row" << rowNum;
                }
            }
        }
    }
    submitAll();
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
        if (role < Qt::UserRole) {
            value = QSqlRelationalTableModel::data(index, role);
        } else {
            int columnIdx = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnIdx);
            value = QSqlRelationalTableModel::data(modelIndex, Qt::DisplayRole);
        }
    }
    return value;
}

bool SqlTableModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    QModelIndex modelIndex = index;
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
    beginRemoveRows(parent, row, row + count - 1);
    // FIXME: Implement me!
    endRemoveRows();
    return false;
}

bool SqlTableModel::fetchAll()
{
    while (canFetchMore()) {
        fetchMore();
    }
    return true;
}
