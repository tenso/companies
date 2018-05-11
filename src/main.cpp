#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFont>
#include "DataManager.hpp"
#include "Log.hpp"


int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    DataManager data;
    if (!data.init(QDir::currentPath() + "/../data/")) { //FIXME: make registry paths:
        logError() << "data.init failed";
        return -1;
    }

    QApplication::setFont( QFont("Roboto") );

    QQmlApplicationEngine engine;
    if (!data.registerTableModels(engine.rootContext())) {
        logError() << "register models failed";
        return -1;
    }

    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
