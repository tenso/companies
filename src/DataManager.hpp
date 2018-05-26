#ifndef DATAMANAGER_HPP
#define DATAMANAGER_HPP

#include <QObject>
#include <QVector>

class RamTableModel;
class IdValueModel;
class QQmlContext;

class DataManager : public QObject
{
    Q_OBJECT
public:
    DataManager();

    bool init(const QString& dataPath);
    bool registerTableModels(QQmlContext* context);
    RamTableModel* getModel(const QString& name);
protected:
    bool setupDataStore(const QString &path);
    bool loadDB(const QString &file);
    void loadFonts();
    bool setupTableModels();
    RamTableModel *addSqlModel(const QString& table);
    IdValueModel *addRamModel(const QString& table);
    QVector<RamTableModel*> _tableModels;
};

#endif // DATAMANAGER_HPP
