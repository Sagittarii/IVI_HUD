#ifndef ROUTEPROVIDER_H
#define ROUTEPROVIDER_H

#include <QObject>
#include <QVariantMap>
#include <QGeoCoordinate>

class QNetworkAccessManager;

class RouteProvider : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QVariantMap routeJson READ routeJson WRITE setRouteJson NOTIFY routeJsonChanged)
    Q_PROPERTY(QGeoCoordinate destination READ destination WRITE setDestination NOTIFY destinationChanged)
    Q_PROPERTY(QGeoCoordinate source READ source WRITE setSource NOTIFY sourceChanged)

public:
    explicit RouteProvider(QObject *parent = 0);

    QVariantMap routeJson() const
    {
        return m_routeJson;
    }

    QGeoCoordinate destination() const
    {
        return m_destination;
    }

    QGeoCoordinate source() const
    {
        return m_source;
    }

signals:

    void routeJsonChanged(QVariantMap routeJson);

    void destinationChanged(QGeoCoordinate destination);

    void sourceChanged(QGeoCoordinate source);

public slots:
    void setRouteJson(QVariantMap routeJson)
    {
        if (m_routeJson == routeJson)
            return;

        m_routeJson = routeJson;
        emit routeJsonChanged(routeJson);
    }


    void setDestination(QGeoCoordinate destination)
    {
        if (m_destination == destination)
            return;

        m_destination = destination;
        updateRoute();
        emit destinationChanged(destination);
    }

    void setSource(QGeoCoordinate source)
    {
        if (m_source == source)
            return;

        m_source = source;
        updateRoute();
        emit sourceChanged(source);
    }

private slots:
    void updateRoute();

private:
    QNetworkAccessManager* manager;
    QVariantMap m_routeJson;
    QGeoCoordinate m_source = QGeoCoordinate(45.770, 4.85);
    QGeoCoordinate m_destination = QGeoCoordinate(45.166672, 5.71667);
};

#endif // ROUTEPROVIDER_H
