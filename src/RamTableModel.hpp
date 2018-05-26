#ifndef RAMTABLEMODEL_HPP
#define RAMTABLEMODEL_HPP

#include <QAbstractItemModel>
#include <QSqlRelation>
#include <QSqlRecord>
#include <QSqlQuery>
#include <QSqlDatabase>
#include <QList>
#include <QVector>

/* NOTES
 * FILTERS: affects every operation unless explicitly stated in function name that it does not
 *          this incldues rowCount, set/get data.
 *
 * RELATIONS: only a display feature i.e. does not affect functions more than data()
 *            get() a value will return the key, setting a value will set the key.
 *            filters can be made to look on the related value though.
 *
 * SORT: affects underlying data order (everything). no issues.
 *
 */

class RamTableModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit RamTableModel(QObject *parent = nullptr);
    virtual ~RamTableModel();

    virtual bool init(const QString& table) = 0;

    virtual QHash<int, QByteArray> roleNames() const;

    QModelIndex index(int row, int column,
                      const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &index) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QVariant dataNoFilter(int row, int col) const;

    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;

    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    void addRole(const QString& role, bool isId);

public slots:
    //implement if model fetches submits and reverts:
    virtual bool select();
    virtual bool submitAll();

    virtual bool revertAll();

    bool selectRow(int row);
    int selectedRow();

    void setTable(const QString& table);
    QString tableName() const;

    int columnToRoleId(int column) const;
    int roleId(const QString& role) const;
    int roleColumn(const QString& role) const;
    QString columnRole(int column) const;
    bool haveRole(const QString& role) const;
    QString roleName(int id);
    int rowToId(int row) const;
    int idToRow(int id);
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    int columnCount(const QModelIndex &parent = QModelIndex()) const override;

    bool newRow(int col = -1, const QVariant &value = QVariant()); //NOTE: selects new row
    bool newRow(const QString& role, const QVariant &value = QVariant()); //NOTE: selects new row
    bool delRow(int row);
    bool delId(int id);
    bool delAllRows(); //note: uses filter
    bool delAllRows(const QString& role, const QVariant& value); //uses filter, removes all rows where role=value

    bool set(const QString& role, const QVariant &value); //uses last setRow
    bool set(const int row, const QString& role, const QVariant &value);
    QVariant get(const QString& role) const; //uses last setRow
    QVariant get(const int row, const QString& role) const;
    QVariant get(const int row, const int col) const;
    int findRow(const QString& role, const QVariant& value);

    void setSort(const QString& role, Qt::SortOrder order); //will re-select
    void setSort(int col, Qt::SortOrder order);

    //will add 'role' as virtual if it does not exist as a real db-column
    bool addRelated(const QString& role, RamTableModel* model, const QString& relatedRole, const QString& displayRole);

    //NOTE: filters will make new rowCount and all operations have new row meaning (filtered)
    //NOTE: start filter with & to make it filter on the related value and not the "key" e.g. "&rebate<1.0"

    void setFiltersEnabled(bool enabled);
    bool filtersEnabled() const;
    void clearFilters();
    void filterColumn(const QString& role, const QString& filter = QString());
    void filterColumn(int column, const QString& filter);
    QString columnFilter(const QString& role);
    QString columnFilter(int column);
    int actualRow(int filteredRow) const;
    int idColumn() const;

private slots:
    void relatedDataChanged(const QModelIndex &topLeft, const QModelIndex &bottomRight, const QVector<int> &roles = QVector<int>());

protected:
    int actualRowCount() const;

    int _nextPrimary {0};

    enum class RowChange{None, Update, Insert, Remove};
    QList<QVector<QVariant>> _ramData;
    QList<QVector<RowChange>> _ramDataChanged;
    QList<QString> _ramDataRemoved;
    QHash<int, Qt::SortOrder> _sorts;

private:

    class RamTableModelRelation {
    public:
        RamTableModel* model;
        QString role;
        QString relatedRole;
        QString displayRole;
    };
    QHash<int, RamTableModelRelation> _related;

    void applyFilters();

    QHash<int, QByteArray> _roles;
    QHash<int, QByteArray> _virtualRoles;
    QHash<int, QByteArray> _colNames;
    QHash<QString, int> _roleInt; //for simple reverse-lookup
    QHash<int, QString> _filters;

    QString _totalFilter;
    int _selectedRow {0};
    QString _table;

    int _idColumn {-1};
    int _nextRole {Qt::UserRole + 1};
    int _numColumns{0};

    QList<int> _removedByFilter;
    bool _filtersEnabled { true };
};

#endif // RAMTABLEMODEL_HPP
