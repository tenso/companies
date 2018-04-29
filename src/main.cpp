#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>
#include <QDir>

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

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    if (!loadDB( "../data/data.db" )) {
        return -1;
    }

    SqlTableModel companyModel("companies");
    companyModel.setRelation(2, QSqlRelation("lists", "id", "name"));
    companyModel.setRelation(3, QSqlRelation("types", "id", "name"));
    companyModel.select();
    SqlTableModel typesModel("types");
    SqlTableModel listsModel("lists");

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("companiesModel", &companyModel );
    engine.rootContext()->setContextProperty("typesModel", &typesModel );
    engine.rootContext()->setContextProperty("listsModel", &listsModel );
    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
