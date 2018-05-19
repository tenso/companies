#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QFont>
#include "DataManager.hpp"
#include "Log.hpp"
#include "Analysis.hpp"
#include "SqlModel.hpp"

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
    if (!analysis.init(data.getModel("financials"))) {
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
    data.getModel("companies")->addRelated("aId", analysis.model(), "id", "rebate");

    QApplication::setFont( QFont("Roboto") );

    QQmlApplicationEngine engine;
    if (!data.registerTableModels(engine.rootContext())) {
        logError() << "register models failed";
        return -1;
    }
    analysis.registerProperties(engine.rootContext());

    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
