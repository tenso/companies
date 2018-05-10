#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QDir>
#include <QFile>
#include <QFontDatabase>

#include "Log.hpp"
#include "SqlTableModel.hpp"

bool setupDataStore(const QString& path)
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

bool loadDB(const QString &file)
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

void loadFonts()
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

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    loadFonts();
    QApplication::setFont( QFont("Roboto") );

    //FIXME: make registry paths:
    QString dataPath = QDir::currentPath() + "/../data/";
    if (!setupDataStore( dataPath )) {
        return -1;
    }
    if (!loadDB( dataPath + "data.db" )) {
        return -1;
    }

    SqlTableModel companyModel("companies");
    companyModel.addRelation(2, QSqlRelation("lists", "id", "name"));
    companyModel.addRelation(3, QSqlRelation("types", "id", "name"));
    companyModel.applyRelations();

    SqlTableModel typesModel("types");
    typesModel.setSort(1, Qt::AscendingOrder);
    if (!typesModel.select()) {
        logError() << "types: select failed";
        return -1;
    }

    SqlTableModel listsModel("lists");
    listsModel.setSort(1, Qt::AscendingOrder);
    if (!listsModel.select()) {
        logError() << "lists: select failed";
        return -1;
    }

    SqlTableModel financialsModel("financials");
    financialsModel.setSort(2, Qt::DescendingOrder); //FIXME: no magic number 2="year"
    financialsModel.addRelation(1, QSqlRelation("companies", "id", "name"));
    financialsModel.addRelation(3, QSqlRelation("quarters", "id", "name"));
    financialsModel.applyRelations();

    SqlTableModel quartersModel("quarters");
    if (!quartersModel.select()) {
        logError() << "quarters: select failed";
        return -1;
    }

    SqlTableModel tagsModel("tags");
    if (!tagsModel.select()) {
        logError() << "tags: select failed";
        return -1;
    }

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("companiesModel", &companyModel );
    engine.rootContext()->setContextProperty("typesModel", &typesModel );
    engine.rootContext()->setContextProperty("listsModel", &listsModel );
    engine.rootContext()->setContextProperty("financialsModel", &financialsModel );
    engine.rootContext()->setContextProperty("quartersModel", &quartersModel );
    engine.rootContext()->setContextProperty("tagsModel", &tagsModel );
    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
