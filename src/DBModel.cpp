#include "DBModel.hpp"
#include "Log.hpp"
#include <QDir>
#include <QSqlQuery>
#include <QSqlError>
#include "Log.hpp"

DBModel::DBModel(QObject *parent)
    : QAbstractListModel(parent)
{
    _roles[Roles::Row] = "row";
    _roles[Roles::Name] = "name";
    _roles[Roles::List] = "list";
    _roles[Roles::Watch] = "watch";
    _roles[Roles::Type] = "type";
}

bool DBModel::load(const QString &file)
{
    QString absoluteFile = QDir::currentPath() + "/" + file;
    if (!QFileInfo(absoluteFile).exists()) {
        logError() << "file does not exist" << absoluteFile;
        return false;
    }
    _db = QSqlDatabase::addDatabase("QSQLITE");
    _db.setDatabaseName( file );
    if (!_db.open()) {
        logError() << "failed to open db" << absoluteFile;
        return false;
    }
    logStatus() << "opened" << absoluteFile;
    readNumCompanies();
    return true;
}

QHash<int, QByteArray> DBModel::roleNames() const
{
    return _roles;
}

QVariant DBModel::headerData(int section, Qt::Orientation orientation, int role) const
{
    if (orientation == Qt::Orientation::Vertical) {
        return _roles[ role ];
    }
    return section;
}

bool DBModel::setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role)
{
    if (value != headerData(section, orientation, role)) {
        // FIXME: Implement me!
        emit headerDataChanged(orientation, section, section);
        return true;
    }
    return false;
}

int DBModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid())
        return 0;
    return _numCompanies;
}

QVariant DBModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    //FIXME: test-code; read to mem; cant expect id=1...num
    QSqlQuery query( _db );
    if (role == Roles::Row) {
        return index.row() + 1;
    }
    if (role == Roles::Name) {
        query.prepare("select name from companies where id=:id");
    }
    else if (role == Roles::List) {
        query.prepare("select list.name from list, companies where companies.lId=list.id and companies.id=:id");
    }
    else if (role == Roles::Watch) {
        query.prepare("select watch from companies where id=:id");
    }
    else if (role == Roles::Type) {
        query.prepare("select type.name from type, companies where companies.tId=type.id and companies.id=:id");
    }
    query.bindValue(":id", index.row() + 1 );
    query.exec();
    query.next();
    return query.value(0).toString();
}

bool DBModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (data(index, role) != value) {
        // FIXME: Implement me!
        emit dataChanged(index, index, QVector<int>() << role);
        return true;
    }
    return false;
}

Qt::ItemFlags DBModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::NoItemFlags;
    //return Qt::ItemIsEditable; // FIXME: Implement me!
}

void DBModel::readNumCompanies()
{
    QSqlQuery query( _db );
    query.prepare("select count(id) from companies");
    if (!query.exec()) {
        logError() << "query failed:" << query.lastError();
    }
    query.next();
    _numCompanies = query.value(0).toInt();
    logStatus() << "db has" << _numCompanies << "companies";
}
