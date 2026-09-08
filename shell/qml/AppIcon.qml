import QtQuick


Item {

    id: root


    property string title:
        "App"

    property string glyph:
        "L"

    property color backgroundColor:
        "#62626A"

    property url iconSource:
        ""


    property bool editMode:
        false

    property bool dragHidden:
        false

    property bool showLabel:
        true


    property real tileSize:
        64

    property real tileRadius:
        20

    property real itemWidth:
        showLabel
            ? 76
            : tileSize

    property real itemHeight:
        showLabel
            ? 102
            : tileSize


    signal launched(
        real originX,
        real originY,
        real originWidth,
        real originHeight
    )


    signal editRequested()


    signal dragStarted(
        real x,
        real y
    )

    signal dragMoved(
        real x,
        real y
    )

    signal dragReleased(
        real x,
        real y
    )


    width:
        itemWidth

    height:
        itemHeight


    opacity:
        dragHidden
            ? 0.16
            : 1


    Behavior on opacity {

        NumberAnimation {
            duration: 100
        }
    }


    Rectangle {

        id: icon


        width:
            root.tileSize

        height:
            root.tileSize


        anchors {
            top: parent.top

            horizontalCenter:
                parent.horizontalCenter
        }


        radius:
            root.tileRadius


        color:
            root.backgroundColor


        scale:
            touch.pressed
                ? 0.86
                : 1


        Behavior on scale {

            NumberAnimation {
                duration: 100
                easing.type:
                    Easing.OutCubic
            }
        }


        Image {

            anchors.centerIn:
                parent


            width:
                root.tileSize * 0.55

            height:
                root.tileSize * 0.55


            source:
                root.iconSource


            visible:
                root.iconSource
                    .toString()
                    .length > 0


            fillMode:
                Image.PreserveAspectFit


            smooth: true
            mipmap: false
        }


        Text {

            anchors.centerIn:
                parent


            visible:
                root.iconSource
                    .toString()
                    .length === 0


            text:
                root.glyph


            color:
                "white"


            font {
                pixelSize:
                    root.tileSize * 0.38

                weight:
                    Font.DemiBold
            }
        }


        // Small edit indicator.

        Rectangle {

            visible:
                root.editMode &&
                root.showLabel


            width: 18
            height: 18


            anchors {
                right: parent.right
                top: parent.top

                rightMargin: -4
                topMargin: -4
            }


            radius: 9


            color:
                "#202026"


            Text {

                anchors.centerIn:
                    parent


                text:
                    "↕"


                color:
                    "white"


                font.pixelSize:
                    10
            }
        }


        MouseArea {

            id: touch


            anchors.fill:
                parent


            preventStealing:
                true


            pressAndHoldInterval:
                420


            property bool draggingNow:
                false


            property real lastGlobalX:
                0

            property real lastGlobalY:
                0


            function globalPoint(
                mouse
            ) {

                return mapToItem(
                    null,
                    mouse.x,
                    mouse.y
                )
            }


            onPressed: mouse => {

                if (
                    root.editMode
                ) {

                    const point =
                        globalPoint(
                            mouse
                        )


                    lastGlobalX =
                        point.x

                    lastGlobalY =
                        point.y


                    draggingNow =
                        true


                    root.dragStarted(
                        point.x,
                        point.y
                    )
                }
            }


            onPressAndHold: mouse => {

                if (
                    draggingNow
                )
                    return


                root.editRequested()


                const point =
                    globalPoint(
                        mouse
                    )


                lastGlobalX =
                    point.x

                lastGlobalY =
                    point.y


                draggingNow =
                    true


                root.dragStarted(
                    point.x,
                    point.y
                )
            }


            onPositionChanged: mouse => {

                if (
                    !draggingNow
                )
                    return


                const point =
                    globalPoint(
                        mouse
                    )


                lastGlobalX =
                    point.x

                lastGlobalY =
                    point.y


                root.dragMoved(
                    point.x,
                    point.y
                )
            }


            onReleased: mouse => {

                if (
                    !draggingNow
                )
                    return


                const point =
                    globalPoint(
                        mouse
                    )


                draggingNow =
                    false


                root.dragReleased(
                    point.x,
                    point.y
                )
            }


            onCanceled: {

                if (
                    !draggingNow
                )
                    return


                draggingNow =
                    false


                root.dragReleased(
                    lastGlobalX,
                    lastGlobalY
                )
            }


            onClicked: {

                if (
                    root.editMode
                )
                    return


                const point =
                    icon.mapToItem(
                        null,
                        0,
                        0
                    )


                root.launched(
                    point.x,
                    point.y,
                    icon.width,
                    icon.height
                )
            }
        }
    }


    Text {

        visible:
            root.showLabel


        anchors {
            top:
                icon.bottom

            topMargin: 8

            horizontalCenter:
                parent.horizontalCenter
        }


        width:
            78


        horizontalAlignment:
            Text.AlignHCenter


        elide:
            Text.ElideRight


        text:
            root.title


        color:
            "#29292F"


        font.pixelSize:
            12
    }


    SequentialAnimation {

        running:
            root.editMode &&
            !root.dragHidden


        loops:
            Animation.Infinite


        NumberAnimation {

            target:
                root

            property:
                "rotation"

            from: -0.9
            to: 0.9

            duration: 120
        }


        NumberAnimation {

            target:
                root

            property:
                "rotation"

            from: 0.9
            to: -0.9

            duration: 120
        }


        onStopped:
            root.rotation = 0
    }
}
