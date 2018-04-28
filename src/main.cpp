#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include "DBModel.hpp"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QGuiApplication app(argc, argv);

    DBModel dbModel;
    if (!dbModel.load( "../data/data.db" )) {
        return -1;
    }
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("companiesModel", &dbModel );
    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
