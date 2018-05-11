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
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;

    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    void setSort(const QString& role, Qt::SortOrder order);
    bool addRelation(const QString& role, const QSqlRelation& relation);
    bool applyAll();

public slots:
    bool fetchAll();
    int rowToId(int index) const;
    void filterColumn(const QString& role, const QString& filter);
    bool newRow(int col = -1, const QVariant &value = QVariant());
    bool delRow(int row);
    bool delAllRows();
    bool set(const int row, const QString& role, const QVariant &value);
    QVariant get(const int row, const QString& role);
    int roleId(const QString& role);
    int roleColumn(const QString& role);
    bool haveRole(const QString& role);

private:
    bool applyRelations(bool empty = false);
    void applyFilters(bool empty = false);

    //not private per se (just use role instead):
    void setSort(int col, Qt::SortOrder order);
    bool addRelation(int col, const QSqlRelation& relation);
    void filterColumn(int index, const QString& filter);

    int _idColumn { -1 };
    int _numColumns { 0 };
    QHash<int, QByteArray> _roles;
    QHash<QString, int> _roleInt; //for simple reverse-lookup
    QHash<int, QString> _filters;
    QHash<int, QSqlRelation> _relations;
    QString _totalFilter;
};

#endif // SQLTABLEMODEL_HPP
