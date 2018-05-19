#include "DataManager.hpp"
#include "Log.hpp"
#include "SqlModel.hpp"

#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QFile>
#include <QFontDatabase>
#include <QQmlContext>

DataManager::DataManager()
{

}

bool DataManager::init(const QString &dataPath)
{
    if (!setupDataStore( dataPath )) {
        return false;
    }
    if (!loadDB( dataPath + "data.db" )) {
        return false;
    }
    if (!setupTableModels()) {
        return false;
    }
    loadFonts();
    return true;
}

bool DataManager::setupDataStore(const QString& path)
{
    QString dataDir = QFileInfo(path).absolutePath();
    QDir dataPath(dataDir);
    if (!dataPath.exists()) {
        if (!dataPath.mkpath(dataDir)) {
            logError() << "failed to create data dir" << dataDir;
            return false;
        }
        logStatus() << "created datadir:" << dataDir;
    }
    else {
        logStatus() << "datadir is:" << dataDir;
    }
    return true;
}


bool DataManager::loadDB(const QString &file)
{
    bool populateDb = false;
    QSqlDatabase db;
    if (!QFileInfo(file).exists()) {
        populateDb = true;
    }

    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName( file );
    if (!db.open()) {
        logError() << "failed to open db" << file;
        return false;
    }
    logStatus() << "opened" << file;

    if (populateDb) {
        logStatus() << "popuplating db from scratch";
        QFile sqlDb(":/assets/db/data.db.sql");
        if (!sqlDb.open(QIODevice::ReadOnly)) {
            logError() << "failed to open scratch data";
            return false;
        }

        QString statement;
        while(!sqlDb.atEnd()) {
            QString line = sqlDb.readLine();
            statement += line;
            if (statement.contains(";")) {
                QSqlError error = db.exec(statement).lastError();

                if (error.isValid()) {
                    logError() << "creating db failed:" << error;
                    logError() << line;
                    db.close();
                    if (!QFile(file).remove()) {
                        logError() << "cleanup failed";
                    }
                    else {
                        logStatus() << "cleanup ok";
                    }
                    return false;
                }
                statement.clear();
            }
        }
    }
    else {
        logStatus() << "found existing db";
    }

    return true;
}


void DataManager::loadFonts()
{
    QDir fonts(":/assets/fonts/");
    fonts.setNameFilters(QStringList() << "*.ttf");
    int loaded = 0;
    foreach(const QString& file, fonts.entryList(QDir::Files | QDir::NoDotAndDotDot)) {
        int id = QFontDatabase::addApplicationFont(fonts.absoluteFilePath(file));
        if(id >= 0) {
            //logStatus() << QFontDatabase::applicationFontFamilies(id);
            loaded++;
        }
    }
    logStatus() << "loaded" << loaded << "fonts";
}

bool DataManager::setupTableModels()
{

    SqlModel* model = new SqlModel(this);
    if (!model->init("companies")) {
        return false;
    }
    model->addRelation("lId", QSqlRelation("lists", "id", "name"));
    model->addRelation("tId", QSqlRelation("types", "id", "name"));

    _tableModels.push_back(model);

    model = new SqlModel(this);
    if (!model->init("types")) {
        return false;
    }
    model->setSort("name", Qt::AscendingOrder);
    _tableModels.push_back(model);

    model = new SqlModel(this);
    if (!model->init("lists")) {
        return false;
    }
    model->setSort("name", Qt::AscendingOrder);
    _tableModels.push_back(model);

    model = new SqlModel(this);
    if (!model->init("financials")) {
        return false;
    }
    model->setSort("year", Qt::DescendingOrder);
    model->addRelation("cId", QSqlRelation("companies", "id", "name"));
    model->addRelation("qId", QSqlRelation("quarters", "id", "name"));
    _tableModels.push_back(model);

    //"simple" models
    if (!addModel("quarters")) {
        return false;
    }
    if (!addModel("modes")) {
        return false;
    }

    return true;
}

bool DataManager::addModel(const QString &table)
{
    SqlModel* model = new SqlModel(this);
    if (!model->init(table)) {
        return false;
    }
    _tableModels.push_back(model);
    return true;
}

bool DataManager::registerTableModels(QQmlContext *context)
{
    if (!_tableModels.length()) {
        return false;
    }
    for(int i = 0; i < _tableModels.length(); i++) {
        context->setContextProperty(_tableModels[i]->tableName() + "Model", _tableModels[i]);
    }
    return true;
}

SqlModel *DataManager::getModel(const QString &name)
{
    for(int i = 0; i < _tableModels.length(); i++) {
        if (_tableModels[i]->tableName() == name) {
            return _tableModels[i];
        }
    }
    logError() << "failed to find model" << name;
    return nullptr;
}
