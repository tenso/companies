#ifndef SQLTABLEMODEL_HPP
#define SQLTABLEMODEL_HPP

#include <QSqlRelationalTableModel>

class SqlTableModel : public QSqlRelationalTableModel
{
    Q_OBJECT

public:
    explicit SqlTableModel(const QString& table, QObject *parent = nullptr);

    virtual QHash<int, QByteArray> roleNames() const;
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;

    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    void addRelation(int col, const QSqlRelation& relation);
    void applyRelations(bool empty = false);
    void applyFilters(bool empty = false);

public slots:
    bool fetchAll();
    int rowToId(int index) const;
    void filterColumn(int index, const QString& filter);
    bool newRow(int col, const QVariant &value);
    bool delRow(int row);
    bool set(const int row, const QString& role, const QVariant &value);
    QVariant get(const int row, const QString& role);
    int roleId(const QString& role);
    bool haveRole(const QString& role);
    QVariant min(const QString& role);
    QVariant max(const QString& role);

private:
    int _idColumn { -1 };
    int _numColumns { 0 };
    QHash<int, QByteArray> _roles;
    QHash<QString, int> _roleId; //for simple reverse-lookup
    QHash<int, QString> _filters;
    QHash<int, QSqlRelation> _relations;
    QString _totalFilter;
};

#endif // SQLTABLEMODEL_HPP
