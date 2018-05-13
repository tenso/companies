#ifndef SQLTABLEMODEL_HPP
#define SQLTABLEMODEL_HPP

#include <QSqlRelationalTableModel>

class SqlTableModel : public QSqlRelationalTableModel
{
    Q_OBJECT

public:
    explicit SqlTableModel(QObject *parent = nullptr);
    virtual ~SqlTableModel();
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
    bool selectRow(int row);
    bool fetchAll();
    int rowToId(int row) const;
    int idToRow(int id) const;
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
    bool haveRole(const QString& role) const;

private:
    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool applyRelations(bool empty = false);
    void applyFilters(bool empty = false);

    //not private per se (just use role instead):
    void setSort(int col, Qt::SortOrder order);
    bool addRelation(int col, const QSqlRelation& relation);
    void filterColumn(int column, const QString& filter);
    QString columnFilter(int column);

    int _idColumn { -1 };
    int _numColumns { 0 };
    QHash<int, QByteArray> _roles;
    QHash<QString, int> _roleInt; //for simple reverse-lookup
    QHash<int, QString> _filters;
    QHash<int, QSqlRelation> _relations;
    QString _totalFilter;
    int _selectedRow { 0 };
};

#endif // SQLTABLEMODEL_HPP
