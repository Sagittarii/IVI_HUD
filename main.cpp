#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <qquickitemmapboxgl.h>
#include <RouteProvider.h>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    qmlRegisterType<QQuickItemMapboxGL>("QQuickItemMapboxGL", 1, 0, "MapboxMap");
    qmlRegisterType<RouteProvider>("RouteProvider", 1, 0, "RouteProvider");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
