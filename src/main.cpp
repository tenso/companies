#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>
#include <QDir>
#include <QFontDatabase>

#include "Log.hpp"
#include "SqlTableModel.hpp"

bool loadDB(const QString &file)
{
    QSqlDatabase db;
    QString absoluteFile = QDir::currentPath() + "/" + file;
    if (!QFileInfo(absoluteFile).exists()) {
        logError() << "file does not exist" << absoluteFile;
        return false;
    }
    db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName( file );
    if (!db.open()) {
        logError() << "failed to open db" << absoluteFile;
        return false;
    }
    logStatus() << "opened" << absoluteFile;
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
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    loadFonts();
    QGuiApplication::setFont( QFont("Roboto") );

    if (!loadDB( "../data/data.db" )) {
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
    }

    SqlTableModel listsModel("lists");
    listsModel.setSort(1, Qt::AscendingOrder);
    if (!listsModel.select()) {
        logError() << "lists: select failed";
    }

    SqlTableModel financialsModel("financials");
    financialsModel.addRelation(1, QSqlRelation("companies", "id", "name"));
    financialsModel.addRelation(3, QSqlRelation("quarters", "id", "name"));
    financialsModel.applyRelations();

    SqlTableModel quartersModel("quarters");
    if (!quartersModel.select()) {
        logError() << "quarters: select failed";
    }

    SqlTableModel tagsModel("tags");
    if (!tagsModel.select()) {
        logError() << "tags: select failed";
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
