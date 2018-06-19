#include "DataManager.hpp"
#include "Log.hpp"
#include "RamTableModel.hpp"
#include "SqlModel.hpp"
#include "IdValueModel.hpp"
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
    RamTableModel* model = nullptr;
    IdValueModel* idValue = nullptr;

    if (!(idValue = addRamModel("quarters"))) {
        return false;
    }
    idValue->addPair(0, "FY");
    idValue->addPair(1, "Q1");
    idValue->addPair(2, "Q2");
    idValue->addPair(3, "Q3");
    idValue->addPair(4, "Q4");

    if (!(idValue = addRamModel("modes"))) {
        return false;
    }
    idValue->addPair(0, "Constant");
    idValue->addPair(1, "Linear");

    if (!(idValue = addRamModel("calcModes"))) {
        return false;
    }
    idValue->addPair(0, "Means");
    idValue->addPair(1, "Last");

    if (!(idValue = addRamModel("calcModesMan"))) {
        return false;
    }
    idValue->addPair(0, "Means");
    idValue->addPair(1, "Last");
    idValue->addPair(2, "Manual");

    if (!(idValue = addRamModel("yesno"))) {
        return false;
    }
    idValue->addPair(0, "No");
    idValue->addPair(1, "Yes");

    if (!(model = addSqlModel("types"))) {
        return false;
    }
    model->setSort("name", Qt::AscendingOrder);
    model->applySort();

    if (!(model = addSqlModel("lists"))) {
        return false;
    }
    model->setSort("name", Qt::AscendingOrder);
    model->applySort();

    //COMPANIES
    if (!(model = addSqlModel("companies"))) {
        return false;
    }
    model->addRelated("lId", getModel("lists"), "id", "name");
    model->addRelated("tId", getModel("types"), "id", "name");

    //FINANCIALS
    if (!(model = addSqlModel("financials"))) {
        return false;
    }
    model->setSort("year", Qt::DescendingOrder);
    model->applySort();
    model->addRelated("cId", getModel("companies"), "id", "name");
    model->addRelated("qId", getModel("quarters"), "id", "name");
    connect(model, SIGNAL(dataSet(RamTableModel*,int,QString,QVariant)),
            this, SLOT(financialsDataSet(RamTableModel*,int,QString,QVariant)));
    return true;
}

RamTableModel* DataManager::addSqlModel(const QString &table)
{
    RamTableModel* model = new SqlModel(this);
    if (!model->init(table)) {
        return nullptr;
    }
    _tableModels.push_back(model);
    return model;
}

IdValueModel *DataManager::addRamModel(const QString &table)
{
    IdValueModel* model = new IdValueModel(this);
    if (!model->init(table)) {
        return nullptr;
    }
    _tableModels.push_back(model);
    return model;
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

RamTableModel *DataManager::getModel(const QString &name)
{
    for(int i = 0; i < _tableModels.length(); i++) {
        if (_tableModels[i]->tableName() == name) {
            return _tableModels[i];
        }
    }
    logError() << "failed to find model" << name;
    return nullptr;
}

void DataManager::financialsDataSet(RamTableModel *model, const int row, const QString &role, const QVariant &value)
{
    if (role == "sharesInsider") {
        int shares = model->get(row, "shares").toDouble();
        double insiderPercent = 0;
        if (shares != 0) {
            insiderPercent = value.toDouble() / shares;
        }
        model->set(row, "insidersOwn", QString::number(insiderPercent, 'f', 2));
    }
}
