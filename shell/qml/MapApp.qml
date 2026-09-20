import QtQuick
import QtWebEngine


Item {

    id: root


    property bool canGoBack:
        map.canGoBack


    function goBack() {

        if (map.canGoBack)
            map.goBack()
    }


    Rectangle {

        anchors.fill:
            parent

        color:
            "#E8E8EA"
    }


    WebEngineProfile {

        id: mapProfile

        storageName:
            "LumaMap"

        persistentCookiesPolicy:
            WebEngineProfile.ForcePersistentCookies
    }


    WebEngineView {

        id: map

        anchors.fill:
            parent

        profile:
            mapProfile


        url:
            "https://www.openstreetmap.org/export/embed.html?bbox=-180%2C-75%2C180%2C75&layer=mapnik"


        settings.javascriptEnabled:
            true

        settings.localStorageEnabled:
            true

        settings.errorPageEnabled:
            true


        onNewWindowRequested:
            function(request) {

                request.openIn(
                    map
                )
            }
    }


    Rectangle {

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height:
            map.loading
                ? 3
                : 0

        color:
            "#4FA477"

        z: 20


        Rectangle {

            width:
                parent.width *
                map.loadProgress / 100

            height:
                parent.height

            color:
                "#276847"
        }
    }
}
