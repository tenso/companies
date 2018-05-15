#ifndef SqlModel_HPP
#define SqlModel_HPP

#include <QAbstractListModel>
#include <QSqlRelation>
#include <QSqlQuery>
#include <QSqlDatabase>
#include <QList>
#include <QVector>

class SqlModel : public QAbstractListModel
{
    Q_OBJECT

public:
    explicit SqlModel(QObject *parent = nullptr);
    virtual ~SqlModel();
    bool init(const QString& table);
    virtual QHash<int, QByteArray> roleNames() const;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;

    void setSort(const QString& role, Qt::SortOrder order);
    bool addRelation(const QString& role, const QSqlRelation& relation);
    bool applyAll();

public slots:
    bool submitAll();
    bool selectRow(int row);
    int rowToId(int row) const;
    int idToRow(int id);
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    void filterColumn(const QString& role, const QString& filter = QString());
    QString columnFilter(const QString& role);
    bool newRow(int col = -1, const QVariant &value = QVariant()); //NOTE: re-writes setRow to added
    bool newRow(const QString& role, const QVariant &value = QVariant()); //NOTE: re-writes setRow to added
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

private:
    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool applyRelations(bool empty = false, bool skipSelect = false);
    void applyFilters(bool empty = false);

    //not private per se (just use role instead):
    void setSort(int col, Qt::SortOrder order);
    bool addRelation(int col, const QSqlRelation& relation);
    void filterColumn(int column, const QString& filter);
    QString columnFilter(int column);

    QSqlQuery query();
    QSqlRecord record();
    void setTable(const QString& table);
    bool select();

    int _idColumn { -1 };
    int _numColumns { 0 };
    QHash<int, QByteArray> _roles;
    QHash<int, QByteArray> _colNames;
    QHash<QString, int> _roleInt; //for simple reverse-lookup
    QHash<int, QString> _filters;
    QHash<int, QSqlRelation> _relations;
    QString _totalFilter;
    int _selectedRow { 0 };
    int _nextPrimary { 0 };
    QSqlDatabase _db;
    QString _table;
    QList<QVector<QVariant>> _ramData;

    enum class RowChange{None, Update, Insert, Remove};
    QList<QVector<RowChange>> _ramDataChanged;
};

#endif // SqlModel_HPP
