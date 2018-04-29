#ifndef DBMODEL_HPP
#define DBMODEL_HPP

#include <QAbstractListModel>
#include <QSqlDatabase>

class DBModel : public QAbstractListModel
{
    Q_OBJECT
    enum Roles {Row, Name, List, Watch, Type};
public:
    explicit DBModel(QObject *parent = nullptr);

    virtual QHash<int, QByteArray> roleNames() const;

    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;
    bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role = Qt::EditRole) override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    bool setData(const QModelIndex &index, const QVariant &value,
                 int role = Qt::EditRole) override;
    Qt::ItemFlags flags(const QModelIndex& index) const override;

private:
    void readNumCompanies();
    QHash<int, QByteArray> _roles;
    QSqlDatabase _db;
    uint32_t _numCompanies { 0 };
};

#endif // DBMODEL_HPP
