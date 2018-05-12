#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFont>
#include "DataManager.hpp"
#include "Log.hpp"
#include "Analysis.hpp"

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    DataManager data;
    if (!data.init(QDir::currentPath() + "/../data/")) { //FIXME: make registry paths:
        logError() << "data.init failed";
        return -1;
    }

    Analysis analysis;
    if (!analysis.init()) {
        logError() << "Analysis::init failed";
        return -1;
    }
    else {
        logStatus() << "Analysis engine loaded";
    }
    if (!analysis.test()) {
        logError() << "Analysis: unit tests failed";
        return -1;
    }
    analysis.dcfEquityValue(1000, 0.1, 0.05, 0.1, 0.02, 5, 2, 0.1, Analysis::DefaultTaxRate,
                            Analysis::Change::Linear,
                            Analysis::Change::Linear);
    return 0;

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
