#include "RouteProvider.h"

#include <QDebug>
#include <QUrl>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>

#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>

RouteProvider::RouteProvider(QObject *parent) : QObject(parent)
{
    manager = new QNetworkAccessManager(this);

    m_routeJson["type"] = QString("geojson");
    m_routeJson["data"] = {};

    updateRoute();
}

void RouteProvider::updateRoute()
{
    QUrl url(QString("http://localhost:5000/route/v1/driving/%1,%2;%3,%4?geometries=geojson&overview=full")
             .arg(source().longitude())
             .arg(source().latitude())
             .arg(destination().longitude())
             .arg(destination().latitude())
             );
    QNetworkRequest req;
    req.setUrl(url);
    QNetworkReply* reply = manager->get(req);
    connect(reply, &QNetworkReply::finished, reply, [=]()
    {
        QJsonDocument json = QJsonDocument::fromJson(reply->readAll());
        if (json.isObject())
        {
            QJsonObject geometry = json.object()["routes"].toArray()[0].toObject();
            geometry["type"] = "Feature";
            geometry["properties"] = QJsonObject();
            QJsonDocument doc = QJsonDocument(geometry);
            m_routeJson["data"] = doc.toJson();
//            qDebug() << "RouteProvider" << doc;
        }
//        qDebug() << __FUNCTION__ << m_routeJson;

        emit routeJsonChanged(m_routeJson);
        reply->deleteLater();
    });

}
