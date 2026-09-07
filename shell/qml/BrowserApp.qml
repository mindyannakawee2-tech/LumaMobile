import QtQuick
import QtQuick.Controls
import QtWebEngine


Item {

    id: root


    property bool canGoBack:
        web.canGoBack

    property string errorText: ""

    property string downloadText: ""


    function goBack() {

        if (web.canGoBack) {
            web.goBack()
        }
    }


    function normalizeAddress(text) {

        let value =
            text.trim()


        if (value.length === 0) {
            return "https://www.google.com"
        }


        if (
            value.indexOf(" ") >= 0
        ) {

            return (
                "https://www.google.com/search?q=" +
                encodeURIComponent(value)
            )
        }


        if (
            value.indexOf("://") >= 0
        ) {
            return value
        }


        if (
            value.indexOf(".") >= 0
        ) {
            return "https://" + value
        }


        return (
            "https://www.google.com/search?q=" +
            encodeURIComponent(value)
        )
    }


    function loadAddress() {

        const destination =
            normalizeAddress(
                address.text
            )


        address.text =
            destination


        web.url =
            destination


        web.forceActiveFocus()

        LumaInput.hide()
    }


    Rectangle {

        anchors.fill:
            parent

        color:
            "#F4F4F7"
    }


    // ========================================================
    // HEADER / URL BAR
    // ========================================================

    Rectangle {

        id: header

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: 82

        color:
            "#F8F8FA"


        Rectangle {

            anchors {
                left: parent.left
                right: parent.right

                leftMargin: 12
                rightMargin: 12

                bottom: parent.bottom
                bottomMargin: 8
            }

            height: 52

            radius: 20

            color:
                "#FFFFFF"

            border.width: 1

            border.color:
                address.activeFocus
                    ? "#625FE7"
                    : "#E0E0E5"


            TextField {

                id: address

                anchors {
                    left: parent.left
                    right: goButton.left

                    leftMargin: 15
                    rightMargin: 8

                    verticalCenter:
                        parent.verticalCenter
                }

                height: 42

                text:
                    web.url.toString()

                selectByMouse:
                    true

                font.pixelSize:
                    13

                background:
                    null


                onAccepted:
                    root.loadAddress()


                onActiveFocusChanged: {

                    if (activeFocus) {

                        selectAll()

                        LumaInput.show()
                    }
                }
            }


            Rectangle {

                id: goButton

                width: 45
                height: 38

                anchors {
                    right: parent.right
                    rightMargin: 7

                    verticalCenter:
                        parent.verticalCenter
                }

                radius: 15

                color:
                    goMouse.pressed
                        ? "#504DCB"
                        : "#625FE7"


                Text {

                    anchors.centerIn:
                        parent

                    text: "Go"

                    color: "white"

                    font {
                        pixelSize: 12
                        weight: Font.DemiBold
                    }
                }


                MouseArea {

                    id: goMouse

                    anchors.fill:
                        parent


                    onClicked:
                        root.loadAddress()
                }
            }
        }
    }


    // ========================================================
    // LOAD PROGRESS
    // ========================================================

    Rectangle {

        anchors {
            top: header.bottom
            left: parent.left
        }

        width:
            parent.width *
            (
                web.loading
                    ? web.loadProgress / 100
                    : 0
            )

        height: 3

        color:
            "#625FE7"

        visible:
            web.loading

        z: 50
    }


    // ========================================================
    // BROWSER PROFILE
    // ========================================================

    WebEngineProfile {

        id: browserProfile

        storageName:
            "LumaBrowser"

        persistentCookiesPolicy:
            WebEngineProfile.ForcePersistentCookies


        onDownloadRequested:
            function(download) {

                root.downloadText =
                    "Downloading " +
                    download.downloadFileName


                download.accept()

                downloadToast.restart()
            }
    }


    // ========================================================
    // WEB CONTENT
    // ========================================================

    WebEngineView {

        id: web

        anchors {
            top: header.bottom
            bottom: toolbar.top
            left: parent.left
            right: parent.right
        }


        url:
            "https://www.google.com"

        profile:
            browserProfile


        settings.javascriptEnabled:
            true

        settings.localStorageEnabled:
            true

        settings.errorPageEnabled:
            true

        settings.fullScreenSupportEnabled:
            true


        onUrlChanged: {

            if (
                !address.activeFocus
            ) {

                address.text =
                    url.toString()
            }
        }


        onLoadingChanged:
            function(info) {

                if (
                    info.status ===
                    WebEngineLoadingInfo.LoadFailedStatus
                ) {

                    root.errorText =
                        info.errorString

                } else {

                    root.errorText =
                        ""
                }
            }


        onNewWindowRequested:
            function(request) {

                request.openIn(
                    web
                )
            }
    }


    // ========================================================
    // ERROR MESSAGE
    // ========================================================

    Rectangle {

        visible:
            root.errorText.length > 0

        anchors {
            top: header.bottom

            horizontalCenter:
                parent.horizontalCenter

            topMargin: 14
        }

        width:
            Math.min(
                parent.width - 30,
                360
            )

        height: 44

        radius: 18

        color:
            "#E8C84747"

        z: 100


        Text {

            anchors {
                fill: parent
                margins: 10
            }

            text:
                root.errorText

            color:
                "white"

            verticalAlignment:
                Text.AlignVCenter

            horizontalAlignment:
                Text.AlignHCenter

            elide:
                Text.ElideRight

            font.pixelSize:
                11
        }
    }


    // ========================================================
    // DOWNLOAD TOAST
    // ========================================================

    Rectangle {

        visible:
            downloadToast.running

        anchors {
            horizontalCenter:
                parent.horizontalCenter

            bottom:
                toolbar.top

            bottomMargin: 12
        }

        width:
            Math.min(
                parent.width - 30,
                350
            )

        height: 44

        radius: 18

        color:
            "#EA202027"

        z: 100


        Text {

            anchors {
                fill: parent
                margins: 10
            }

            text:
                root.downloadText

            color:
                "white"

            verticalAlignment:
                Text.AlignVCenter

            horizontalAlignment:
                Text.AlignHCenter

            elide:
                Text.ElideRight

            font.pixelSize:
                12
        }
    }


    Timer {

        id: downloadToast

        interval: 3000

        repeat: false
    }


    // ========================================================
    // TOOLBAR
    // ========================================================

    Rectangle {

        id: toolbar

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: 76

        color:
            "#F8F8FA"

        border.width: 1

        border.color:
            "#E3E3E8"


        Row {

            anchors.centerIn:
                parent

            spacing: 13


            Rectangle {

                width: 52
                height: 46
                radius: 16

                color:
                    backMouse.pressed
                        ? "#E0E0E6"
                        : "#FFFFFF"

                opacity:
                    web.canGoBack
                        ? 1
                        : 0.35


                Text {
                    anchors.centerIn: parent
                    text: "‹"
                    color: "#202027"
                    font.pixelSize: 28
                }


                MouseArea {

                    id: backMouse

                    anchors.fill: parent

                    enabled:
                        web.canGoBack

                    onClicked:
                        web.goBack()
                }
            }


            Rectangle {

                width: 52
                height: 46
                radius: 16

                color:
                    forwardMouse.pressed
                        ? "#E0E0E6"
                        : "#FFFFFF"

                opacity:
                    web.canGoForward
                        ? 1
                        : 0.35


                Text {
                    anchors.centerIn: parent
                    text: "›"
                    color: "#202027"
                    font.pixelSize: 28
                }


                MouseArea {

                    id: forwardMouse

                    anchors.fill: parent

                    enabled:
                        web.canGoForward

                    onClicked:
                        web.goForward()
                }
            }


            Rectangle {

                width: 52
                height: 46
                radius: 16

                color:
                    reloadMouse.pressed
                        ? "#E0E0E6"
                        : "#FFFFFF"


                Text {

                    anchors.centerIn:
                        parent

                    text:
                        web.loading
                            ? "×"
                            : "↻"

                    color:
                        "#202027"

                    font.pixelSize:
                        22
                }


                MouseArea {

                    id: reloadMouse

                    anchors.fill:
                        parent


                    onClicked: {

                        if (web.loading)
                            web.stop()
                        else
                            web.reload()
                    }
                }
            }


            Rectangle {

                width: 52
                height: 46
                radius: 16

                color:
                    homeMouse.pressed
                        ? "#E0E0E6"
                        : "#FFFFFF"


                Text {
                    anchors.centerIn: parent
                    text: "⌂"
                    color: "#202027"
                    font.pixelSize: 20
                }


                MouseArea {

                    id: homeMouse

                    anchors.fill:
                        parent


                    onClicked:
                        web.url =
                            "https://www.google.com"
                }
            }


            Rectangle {

                width: 52
                height: 46
                radius: 16

                color:
                    keyboardMouse.pressed
                        ? "#E0E0E6"
                        : "#FFFFFF"


                Text {
                    anchors.centerIn: parent
                    text: "⌨"
                    color: "#202027"
                    font.pixelSize: 20
                }


                MouseArea {

                    id: keyboardMouse

                    anchors.fill:
                        parent


                    onClicked: {

                        /*
                         * Useful for webpage text boxes if the
                         * desktop host does not automatically
                         * request the software keyboard.
                         */

                        LumaInput.show()
                    }
                }
            }
        }
    }
}
