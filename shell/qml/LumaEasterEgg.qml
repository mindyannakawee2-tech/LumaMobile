import QtQuick


Item {

    id: root

    clip: true


    property int charge: 0

    property bool awakened:
        charge >= 7


    property real burstX:
        width / 2

    property real burstY:
        height / 2

    property int burstSerial: 0


    // ========================================================
    // SPACE
    // ========================================================

    Rectangle {

        anchors.fill:
            parent

        radius: 30


        gradient: Gradient {

            GradientStop {
                position: 0
                color: "#090812"
            }

            GradientStop {
                position: 0.48
                color: "#17122C"
            }

            GradientStop {
                position: 1
                color: "#08070E"
            }
        }
    }


    // ========================================================
    // BACKGROUND GLOW
    // ========================================================

    Rectangle {

        width: 410
        height: 410

        anchors.centerIn:
            parent

        radius:
            width / 2

        color:
            root.awakened
                ? "#246E63FF"
                : "#125E55D9"

        scale:
            root.awakened
                ? 1.1
                : 0.8


        Behavior on color {

            ColorAnimation {
                duration: 700
            }
        }


        Behavior on scale {

            NumberAnimation {
                duration: 700
                easing.type:
                    Easing.OutCubic
            }
        }
    }


    // ========================================================
    // STARFIELD
    // ========================================================

    Repeater {

        model: 38


        Rectangle {

            required property int index


            width:
                1 + (index % 3)

            height:
                width


            x:
                (
                    (
                        index * 83 +
                        19
                    ) % 397
                ) / 397
                * Math.max(
                    1,
                    root.width - width
                )


            y:
                (
                    (
                        index * 149 +
                        37
                    ) % 743
                ) / 743
                * Math.max(
                    1,
                    root.height - height
                )


            radius:
                width / 2


            color:
                index % 5 === 0
                    ? "#BCAEFF"
                    : "#FFFFFF"


            opacity:
                0.25 +
                (
                    index % 6
                ) * 0.09


            SequentialAnimation on opacity {

                running: root.visible

                loops:
                    Animation.Infinite


                NumberAnimation {

                    to:
                        0.18

                    duration:
                        900 +
                        (
                            index % 5
                        ) * 180
                }


                NumberAnimation {

                    to:
                        0.85

                    duration:
                        1000 +
                        (
                            index % 7
                        ) * 150
                }
            }
        }
    }


    // ========================================================
    // PHOTON TAP FIELD
    // ========================================================

    MouseArea {

        anchors.fill:
            parent

        enabled:
            root.awakened

        z: 10


        onClicked: mouse => {

            root.burstX =
                mouse.x

            root.burstY =
                mouse.y

            root.burstSerial += 1
        }
    }


    // ========================================================
    // PHOTON BURST
    // ========================================================

    Item {

        id: burst

        z: 15


        property real distance: 0


        x:
            root.burstX

        y:
            root.burstY


        opacity: 0


        Repeater {

            model: 10


            Rectangle {

                required property int index


                width:
                    6

                height:
                    6

                radius:
                    3


                property real angle:
                    (
                        index /
                        10
                    ) *
                    Math.PI *
                    2


                x:
                    Math.cos(
                        angle
                    ) *
                    burst.distance -
                    width / 2


                y:
                    Math.sin(
                        angle
                    ) *
                    burst.distance -
                    height / 2


                color:
                    index % 2 === 0
                        ? "#A99CFF"
                        : "#FFFFFF"
            }
        }
    }


    Rectangle {

        id: burstRing

        z: 14


        width: 50
        height: 50

        x:
            root.burstX -
            width / 2

        y:
            root.burstY -
            height / 2


        radius:
            width / 2


        color:
            "transparent"

        border.width:
            2

        border.color:
            "#C8BFFF"

        opacity: 0
    }


    onBurstSerialChanged: {

        burstAnimation.restart()
    }


    ParallelAnimation {

        id: burstAnimation


        PropertyAction {

            target:
                burst

            property:
                "distance"

            value:
                0
        }


        PropertyAction {

            target:
                burst

            property:
                "opacity"

            value:
                1
        }


        PropertyAction {

            target:
                burstRing

            property:
                "scale"

            value:
                0.25
        }


        PropertyAction {

            target:
                burstRing

            property:
                "opacity"

            value:
                0.85
        }


        NumberAnimation {

            target:
                burst

            property:
                "distance"

            from: 0
            to: 110

            duration: 500

            easing.type:
                Easing.OutCubic
        }


        NumberAnimation {

            target:
                burst

            property:
                "opacity"

            from: 1
            to: 0

            duration: 520
        }


        NumberAnimation {

            target:
                burstRing

            property:
                "scale"

            from: 0.25
            to: 3.3

            duration: 520

            easing.type:
                Easing.OutCubic
        }


        NumberAnimation {

            target:
                burstRing

            property:
                "opacity"

            from: 0.85
            to: 0

            duration: 520
        }
    }


    // ========================================================
    // LUMA CORE
    // ========================================================

    Item {

        id: core


        width: 190
        height: 190


        anchors {
            horizontalCenter:
                parent.horizontalCenter

            verticalCenter:
                parent.verticalCenter

            verticalCenterOffset:
                -32
        }


        z: 30


        scale:
            root.awakened
                ? 1.13
                : 1


        Behavior on scale {

            NumberAnimation {

                duration: 500

                easing.type:
                    Easing.OutBack
            }
        }


        // Outer orbit

        Rectangle {

            anchors.fill:
                parent

            radius:
                width / 2

            color:
                "transparent"

            border.width:
                2

            border.color:
                root.awakened
                    ? "#8878FF"
                    : "#3B355B"


            RotationAnimation on rotation {

                running:
                    root.awakened

                from: 0
                to: 360

                duration: 9000

                loops:
                    Animation.Infinite
            }


            Rectangle {

                width: 13
                height: 13

                radius:
                    width / 2

                anchors {
                    top: parent.top
                    horizontalCenter:
                        parent.horizontalCenter
                }

                color:
                    "#FFFFFF"
            }
        }


        // Inner orbit

        Rectangle {

            width: 145
            height: 145

            anchors.centerIn:
                parent

            radius:
                width / 2

            color:
                "transparent"

            border.width:
                1

            border.color:
                root.awakened
                    ? "#90BDAEFF"
                    : "#343044"


            RotationAnimation on rotation {

                running:
                    root.awakened

                from: 360
                to: 0

                duration: 6000

                loops:
                    Animation.Infinite
            }


            Rectangle {

                width: 9
                height: 9

                radius:
                    width / 2

                anchors {
                    bottom: parent.bottom
                    horizontalCenter:
                        parent.horizontalCenter
                }

                color:
                    "#A99CFF"
            }
        }


        // Glow

        Rectangle {

            width: 126
            height: 126

            anchors.centerIn:
                parent

            radius:
                width / 2


            color:
                root.awakened
                    ? "#7063EE"
                    : "#4C438F"


            SequentialAnimation on scale {

                running:
                    root.awakened

                loops:
                    Animation.Infinite


                NumberAnimation {
                    from: 0.94
                    to: 1.06
                    duration: 700
                    easing.type:
                        Easing.InOutSine
                }

                NumberAnimation {
                    from: 1.06
                    to: 0.94
                    duration: 700
                    easing.type:
                        Easing.InOutSine
                }
            }
        }


        Rectangle {

            width: 92
            height: 92

            anchors.centerIn:
                parent

            radius:
                width / 2


            gradient: Gradient {

                GradientStop {

                    position: 0

                    color:
                        root.awakened
                            ? "#C8C0FF"
                            : "#8378D8"
                }


                GradientStop {

                    position: 1

                    color:
                        root.awakened
                            ? "#6758E7"
                            : "#514895"
                }
            }


            Text {

                anchors.centerIn:
                    parent


                text:
                    "L"


                color:
                    "white"


                font {
                    pixelSize: 46
                    weight: Font.Bold
                }
            }
        }


        MouseArea {

            anchors.fill:
                parent


            onClicked: {

                if (
                    root.charge < 7
                ) {

                    root.charge += 1


                    core.scale =
                        0.9


                    coreBounce.restart()


                } else {

                    root.burstX =
                        core.x +
                        core.width / 2

                    root.burstY =
                        core.y +
                        core.height / 2

                    root.burstSerial += 1
                }
            }
        }


        SequentialAnimation {

            id: coreBounce


            NumberAnimation {

                target:
                    core

                property:
                    "scale"

                to:
                    1.12

                duration: 130

                easing.type:
                    Easing.OutBack
            }


            NumberAnimation {

                target:
                    core

                property:
                    "scale"

                to:
                    root.awakened
                        ? 1.13
                        : 1

                duration: 170
            }
        }
    }


    // ========================================================
    // TITLE
    // ========================================================

    Column {

        anchors {
            top: parent.top
            topMargin: 54

            horizontalCenter:
                parent.horizontalCenter
        }


        spacing: 5


        Text {

            anchors.horizontalCenter:
                parent.horizontalCenter


            text:
                root.awakened
                    ? "PHOTON MODE"
                    : "LUMA CORE"


            color:
                "white"


            font {
                pixelSize: 26
                weight: Font.DemiBold
                letterSpacing: 2
            }
        }


        Text {

            anchors.horizontalCenter:
                parent.horizontalCenter


            text:
                root.awakened
                    ? "The light is awake."
                    : "Something is sleeping here."


            color:
                "#A9A4BD"


            font.pixelSize:
                12
        }
    }


    // ========================================================
    // STATUS
    // ========================================================

    Column {

        anchors {
            bottom: parent.bottom
            bottomMargin: 50

            horizontalCenter:
                parent.horizontalCenter
        }


        spacing: 8


        Text {

            anchors.horizontalCenter:
                parent.horizontalCenter


            text:
                root.awakened
                    ? "✦  LumaMobile 0.1  ✦"
                    : (
                        "CORE CHARGE  " +
                        root.charge +
                        " / 7"
                    )


            color:
                root.awakened
                    ? "#C9C1FF"
                    : "#8F89A5"


            font {
                pixelSize: 13
                weight: Font.DemiBold
            }
        }


        Text {

            anchors.horizontalCenter:
                parent.horizontalCenter


            text:
                root.awakened
                    ? "Tap space to release photons"
                    : "Tap the core"


            color:
                "#706B80"


            font.pixelSize:
                11
        }


        Text {

            visible:
                root.awakened


            anchors.horizontalCenter:
                parent.horizontalCenter


            text:
                "You found the light."


            color:
                "#FFFFFF"


            font {
                pixelSize: 16
                weight: Font.Medium
            }
        }
    }
}
