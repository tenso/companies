#ifndef DATAMANAGER_HPP
#define DATAMANAGER_HPP

#include <QObject>
#include <QVector>

class SqlModel;
class QQmlContext;

class DataManager : public QObject
{
    Q_OBJECT
public:
    DataManager();

    bool init(const QString& dataPath);
    bool registerTableModels(QQmlContext* context);
    SqlModel* getModel(const QString& name);
protected:
    bool setupDataStore(const QString &path);
    bool loadDB(const QString &file);
    void loadFonts();
    bool setupTableModels();
    bool addModel(const QString& table);
    QVector<SqlModel*> _tableModels;
};

#endif // DATAMANAGER_HPP
