#ifndef DBMODEL_HPP
#define DBMODEL_HPP

#include <QAbstractListModel>
#include <QtSql/QSqlDatabase>

class DBModel : public QAbstractListModel
{
    Q_OBJECT
    enum Roles {Row, Name, List};
public:
    explicit DBModel(QObject *parent = nullptr);
    bool load( const QString& file );
    virtual QHash<int, QByteArray> roleNames() const;


    // Header:
    QVariant headerData(int section, Qt::Orientation orientation, int role = Qt::DisplayRole) const override;

    bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role = Qt::EditRole) override;

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

    // Editable:
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
