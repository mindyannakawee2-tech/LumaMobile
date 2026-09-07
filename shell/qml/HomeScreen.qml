import QtQuick


Item {

    id: root


    property var appsModel:
        []


    property var system:
        ({
            "wifiEnabled": false,
            "batteryPercent": -1,
            "storage": {
                "freeHuman": "..."
            }
        })


    property string currentTime:
        ""


    property string currentDate:
        ""


    property var homeApps: {

        let result = []

        const list =
            root.appsModel || []


        for (
            let i = 0;
            i < list.length;
            ++i
        ) {

            if (
                list[i].home
            ) {
                result.push(
                    list[i]
                )
            }
        }


        return result
    }


    property var dockApps: {

        let result = []

        const list =
            root.appsModel || []


        for (
            let i = 0;
            i < list.length;
            ++i
        ) {

            if (
                list[i].dock &&
                result.length < 4
            ) {

                result.push(
                    list[i]
                )
            }
        }


        return result
    }


    signal launchRequested(
        var app,
        real x,
        real y,
        real width,
        real height
    )


    function greeting() {

        const hour =
            new Date()
                .getHours()


        if (hour < 12)
            return "Good morning"

        if (hour < 18)
            return "Good afternoon"


        return "Good evening"
    }


    function refreshClock() {

        const now =
            new Date()


        root.currentTime =
            Qt.formatTime(
                now,
                "hh:mm"
            )


        root.currentDate =
            Qt.formatDate(
                now,
                "dddd, MMMM d"
            )
    }


    function refreshSystem() {

        root.system =
            LumaSystem.status()
    }


    Component.onCompleted: {

        refreshClock()
        refreshSystem()
    }


    Timer {

        interval: 1000

        repeat: true
        running: true


        onTriggered:
            root.refreshClock()
    }


    Timer {

        interval: 10000

        repeat: true
        running: true


        onTriggered:
            root.refreshSystem()
    }


    // ========================================================
    // WALLPAPER
    // ========================================================

    Rectangle {

        anchors.fill:
            parent


        gradient: Gradient {

            GradientStop {
                position: 0
                color: "#ECEAFB"
            }

            GradientStop {
                position: 0.48
                color: "#F5F4F8"
            }

            GradientStop {
                position: 1
                color: "#E9EEF6"
            }
        }
    }


    Rectangle {

        width: 370
        height: 370

        x: -170
        y: 145

        radius:
            width / 2

        color:
            "#185D5AE6"
    }


    Rectangle {

        width: 330
        height: 330

        x: 275
        y: 475

        radius:
            width / 2

        color:
            "#147AA9FF"
    }


    // ========================================================
    // STATUS BAR
    // ========================================================

    Item {

        id: statusBar


        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }


        height: 55


        Text {

            anchors {
                left: parent.left
                leftMargin: 24

                verticalCenter:
                    parent.verticalCenter
            }


            text:
                root.currentTime


            color:
                "#202026"


            font {
                pixelSize: 15
                weight: Font.DemiBold
            }
        }


        Row {

            anchors {
                right: parent.right
                rightMargin: 22

                verticalCenter:
                    parent.verticalCenter
            }


            spacing: 9


            Text {

                text:
                    root.system.wifiEnabled
                        ? "Wi-Fi"
                        : "—"


                color:
                    "#202026"


                font.pixelSize:
                    12
            }


            Text {

                text:
                    root.system.batteryPercent >= 0
                        ? root.system.batteryPercent + "%"
                        : "AC"


                color:
                    "#202026"


                font.pixelSize:
                    12
            }
        }
    }


    // ========================================================
    // HOME CONTENT
    // ========================================================

    Flickable {

        id: home


        anchors {
            top: statusBar.bottom
            left: parent.left
            right: parent.right

            bottom:
                dock.top
        }


        clip: true


        boundsBehavior:
            Flickable.StopAtBounds


        contentHeight:
            content.height + 35


        Column {

            id: content


            width:
                parent.width - 36


            x: 18


            spacing: 18


            // ------------------------------------------------
            // Clock / greeting
            // ------------------------------------------------

            Column {

                width:
                    parent.width


                spacing: 1


                Text {

                    text:
                        root.currentTime


                    color:
                        "#202026"


                    font {
                        pixelSize: 54
                        weight: Font.Medium
                    }
                }


                Text {

                    text:
                        root.currentDate


                    color:
                        "#696973"


                    font.pixelSize:
                        14
                }


                Text {

                    topPadding: 7


                    text:
                        root.greeting()


                    color:
                        "#202026"


                    font {
                        pixelSize: 22
                        weight: Font.DemiBold
                    }
                }
            }


            // ------------------------------------------------
            // Real system card
            // ------------------------------------------------

            LumaCard {

                width:
                    parent.width


                height: 118


                gradient: Gradient {

                    GradientStop {
                        position: 0
                        color: "#685FEA"
                    }

                    GradientStop {
                        position: 1
                        color: "#887CF1"
                    }
                }


                Column {

                    anchors {
                        left: parent.left
                        top: parent.top
                        margins: 20
                    }


                    spacing: 5


                    Text {

                        text:
                            "LumaMobile"


                        color:
                            "white"


                        font {
                            pixelSize: 20
                            weight: Font.DemiBold
                        }
                    }


                    Text {

                        text:
                            root.appsModel.length
                            + " apps installed"


                        color:
                            "#E8E5FF"


                        font.pixelSize:
                            13
                    }


                    Text {

                        text:
                            root.system.storage &&
                            root.system.storage.freeHuman
                                ? root.system.storage.freeHuman
                                  + " available"
                                : "Storage ready"


                        color:
                            "#D2CFF5"


                        font.pixelSize:
                            12
                    }
                }


                Rectangle {

                    width: 52
                    height: 52


                    anchors {
                        right: parent.right
                        rightMargin: 18

                        verticalCenter:
                            parent.verticalCenter
                    }


                    radius: 18


                    color:
                        "#28FFFFFF"


                    Text {

                        anchors.centerIn:
                            parent


                        text:
                            "L"


                        color:
                            "white"


                        font {
                            pixelSize: 24
                            weight: Font.Bold
                        }
                    }
                }
            }


            // ------------------------------------------------
            // Apps
            // ------------------------------------------------

            Text {

                text:
                    "Apps"


                color:
                    "#202026"


                font {
                    pixelSize: 20
                    weight: Font.DemiBold
                }
            }


            Grid {

                id: appGrid


                width:
                    parent.width


                height:
                    Math.ceil(
                        root.homeApps.length /
                        4
                    ) * 114


                columns: 4


                columnSpacing:
                    (width - 304) / 3


                rowSpacing:
                    12


                Repeater {

                    model:
                        root.homeApps


                    AppIcon {

                        title:
                            modelData.title


                        glyph:
                            modelData.glyph


                        backgroundColor:
                            modelData.accent


                        iconSource:
                            modelData.iconUrl


                        onLaunched:
                            function(
                                x,
                                y,
                                w,
                                h
                            ) {

                                root.launchRequested(
                                    modelData,
                                    x,
                                    y,
                                    w,
                                    h
                                )
                            }
                    }
                }
            }
        }
    }


    // ========================================================
    // DYNAMIC DOCK
    // ========================================================

    Rectangle {

        id: dock


        visible:
            root.dockApps.length > 0


        width:
            Math.min(
                312,
                36
                +
                root.dockApps.length * 56
                +
                Math.max(
                    0,
                    root.dockApps.length - 1
                ) * 18
            )


        height: 82


        anchors {
            bottom: parent.bottom

            horizontalCenter:
                parent.horizontalCenter

            bottomMargin: 18
        }


        radius: 31


        color:
            "#E827272F"


        border.width:
            1


        border.color:
            "#20FFFFFF"


        Row {

            anchors.centerIn:
                parent


            spacing: 18


            Repeater {

                model:
                    root.dockApps


                Rectangle {

                    id: dockIcon


                    width: 56
                    height: 56


                    radius: 18


                    color:
                        modelData.accent


                    scale:
                        dockMouse.pressed
                            ? 0.84
                            : 1


                    Behavior on scale {

                        NumberAnimation {
                            duration: 120
                        }
                    }


                    Image {

                        anchors.centerIn:
                            parent


                        width: 30
                        height: 30


                        source:
                            modelData.iconUrl


                        visible:
                            modelData.iconUrl.length > 0


                        fillMode:
                            Image.PreserveAspectFit


                        smooth: true
                        mipmap: false
                    }


                    Text {

                        anchors.centerIn:
                            parent


                        visible:
                            modelData.iconUrl.length === 0


                        text:
                            modelData.glyph


                        color:
                            "white"


                        font {
                            pixelSize: 22
                            weight: Font.DemiBold
                        }
                    }


                    MouseArea {

                        id: dockMouse


                        anchors.fill:
                            parent


                        onClicked: {

                            const point =
                                dockIcon.mapToItem(
                                    null,
                                    0,
                                    0
                                )


                            root.launchRequested(
                                modelData,
                                point.x,
                                point.y,
                                dockIcon.width,
                                dockIcon.height
                            )
                        }
                    }
                }
            }
        }
    }
}
