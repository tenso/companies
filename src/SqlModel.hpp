#ifndef SqlModel_HPP
#define SqlModel_HPP

#include <QAbstractListModel>
#include <QSqlRelation>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlDatabase>
#include <QList>
#include <QVector>

class SqlModel : public QAbstractListModel
{
    Q_OBJECT

    static const int DefaultRelationId = 1;

public:
    explicit SqlModel(QObject *parent = nullptr);
    virtual ~SqlModel();
    bool init(const QString& table);
    virtual QHash<int, QByteArray> roleNames() const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;

    void setSort(const QString& role, Qt::SortOrder order); //will re-select
    bool addRelation(const QString& role, const QSqlRelation& relation);

public slots:
    bool submitAll();
    bool revertAll();
    bool selectRow(int row);
    int rowToId(int row) const;
    int idToRow(int id);
    int rowCount(const QModelIndex &parent = QModelIndex()) const;

    //remember: filters will make new rowCount and all operations have new row meaning (filtered)
    void filterColumn(const QString& role, const QString& filter = QString());
    void filterColumn(int column, const QString& filter);
    int actualRow(int filteredRow) const;
    QString columnFilter(const QString& role);
    QString columnFilter(int column);

    bool newRow(int col = -1, const QVariant &value = QVariant()); //NOTE: selects new row
    bool newRow(const QString& role, const QVariant &value = QVariant()); //NOTE: selects new row
    int selectedRow();
    bool delRow(int row);
    bool delAllRows();
    bool delAllRows(const QString& role, const QVariant& value); //removes all rows where role=value
    bool set(const int row, const QString& role, const QVariant &value);
    bool set(const QString& role, const QVariant &value); //uses last setRow
    QVariant get(const int row, const QString& role) const;
    QVariant get(const QString& role) const; //uses last setRow
    int roleId(const QString& role) const;
    int roleColumn(const QString& role) const;
    QString columnRole(int column) const;
    bool haveRole(const QString& role) const;
    QString roleName(int id);
    QString tableName() const;
    bool select();
    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    void setSort(int col, Qt::SortOrder order);
    bool addRelation(int col, const QSqlRelation& relation);
    QSqlQuery query();
    QSqlRecord record();
    void setTable(const QString& table);

private:
    void applyFilters();
    int actualRowCount() const;
    int _idColumn { -1 };
    int _numColumns { 0 };
    QHash<int, QByteArray> _roles;
    QHash<int, QByteArray> _colNames;
    QHash<QString, int> _roleInt; //for simple reverse-lookup
    QHash<int, QString> _filters;
    QHash<int, Qt::SortOrder> _sorts;
    QHash<int, QSqlRelation> _relations;
    QString _totalFilter;
    int _selectedRow { 0 };
    int _nextPrimary { 0 };
    QSqlDatabase _db;
    QString _table;

    QList<QVector<QVariant>> _ramData;
    QList<int> _removedByFilter;

    enum class RowChange{None, Update, Insert, Remove};
    QList<QVector<RowChange>> _ramDataChanged;
    QList<QString> _ramDataRemoved;
    bool _printSql { false };
};

#endif // SqlModel_HPP
