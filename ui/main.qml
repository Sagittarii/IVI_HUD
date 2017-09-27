import QtQuick 2.6
import QtQuick.Controls 1.0
import QtQuick.Window 2.2
import QtPositioning 5.3

import QQuickItemMapboxGL 1.0
import RouteProvider 1.0

Window {
    visible: true
    width: 640
    height: 480
    title: "IVI_HUD"
    visibility: Window.FullScreen

    RouteProvider {
        id: routeProvider

        onRouteJsonChanged: {
            console.log("json changed : " + routeJson)
            var routeSource = routeJson
            map.updateSource("route", routeSource)
        }

        onSourceChanged: {
            map.updateSourcePoint("location", source)
        }
    }

    MapboxMap {
        id: map
        anchors.fill: parent

        center: routeProvider.source //QtPositioning.coordinate(60.170448, 24.942046) // Helsinki
        zoomLevel: 18
        minimumZoomLevel: 0
        maximumZoomLevel: 20
        pixelRatio: 1.5

        bearing: 0 //bearingSlider.value
        pitch: 60 //pitchSlider.value

        cacheDatabaseMaximalSize: 20*1024*1024
        cacheDatabasePath: "/tmp/mbgl-cache.db"


//        styleUrl: "mapbox://styles/mapbox/streets-v10"
        styleUrl: "mapbox://styles/zetasagittarii/cj7xfvq1f4wvp2rp9h2cal3qa" // custom minimal dark style

        Behavior on zoomLevel {
            NumberAnimation { duration: 1000 }
        }

        Behavior on pitch {
            NumberAnimation { duration: 1000 }
        }

        onReplyCoordinateForPixel: {
            if(tag === true)
            {
                console.log("ReplyCoordinateForPixel Source : " + geocoordinate + tag)
                routeProvider.setSource(geocoordinate);
            }
            else
            {
                console.log("ReplyCoordinateForPixel Destination : " + geocoordinate + tag)
                routeProvider.setDestination(geocoordinate);
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property var lastX: 0
            property var lastY: 0

            onWheel: {
                map.setZoomLevel( map.zoomLevel + 0.2 * wheel.angleDelta.y / 120, Qt.point(wheel.x, wheel.y) )
            }

            onPressed: {
                lastX = mouse.x
                lastY = mouse.y
            }

            onPositionChanged: {
                map.pan(mouse.x - lastX, mouse.y - lastY)

                lastX = mouse.x
                lastY = mouse.y
            }

            onDoubleClicked: {
                console.log("Clicked")
                map.queryCoordinateForPixel(Qt.point(mouse.x, mouse.y), mouse.button == Qt.RightButton)
           }
        }

        Component.onCompleted: {
            console.log("onCompleted")
            var routeSource = {
                "type": "geojson",
                "data": '{
                    "type": "Feature",
                    "properties": {},
                    "geometry": {
                        "type": "LineString",
                        "coordinates": []
                        }
                    }'}
            map.addSource("route", routeSource)
            map.addLayer("routeCase", { "type": "line", "source": "route" }, "waterway-label")
            map.setLayoutProperty("routeCase", "line-join", "round");
            map.setLayoutProperty("routeCase", "line-cap", "round");
            map.setPaintProperty("routeCase", "line-color", "green");
            map.setPaintProperty("routeCase", "line-width", 15.0);

            /// Location support
            map.addSourcePoint("location", routeProvider.source )

            map.addLayer("location-uncertainty", {"type": "circle", "source": "location"}, "waterway-label")
            map.setPaintProperty("location-uncertainty", "circle-radius", 20)
            map.setPaintProperty("location-uncertainty", "circle-color", "#87cefa")
            map.setPaintProperty("location-uncertainty", "circle-opacity", 0.25)

            map.addLayer("location-case", {"type": "circle", "source": "location"}, "waterway-label")
            map.setPaintProperty("location-case", "circle-radius", 10)
            map.setPaintProperty("location-case", "circle-color", "white")

            map.addLayer("location", {"type": "circle", "source": "location"}, "waterway-label")
            map.setPaintProperty("location", "circle-radius", 5)
            map.setPaintProperty("location", "circle-color", "blue")
        }

        Connections {
            target: map
            onReplySourceExists: {
                console.log("Source: " + id + " " + exists)
            }

            onReplyLayerExists: console.log("Layer: " + id + " " + exists)

        }
    }

    Button {
        id: overview
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        width : 100
        height : 100
        checkable: true

        text: checked ? "Navigation" : "Overview"

        onCheckedChanged: {
            if (checked)
            {
                map.setMargins(0, 0, 0, 0); /// \todo need to add a Behavior on margins, or a manual animation
                map.pitch = 0
                map.zoomLevel = 10
            }
            else
            {
                map.setMargins(0, 0.4, 0, 0); /// \todo need to add a Behavior on margins, or a manual animation
                map.pitch = 60
                map.zoomLevel = 18
            }

        }

    }
}
