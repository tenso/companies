#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSqlDatabase>
#include <QDir>

#include "Log.hpp"
#include "DBModel.hpp"

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

    QQmlApplicationEngine engine;
    DBModel dbModel;
    engine.rootContext()->setContextProperty("companiesModel", &dbModel );
    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
