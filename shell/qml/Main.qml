import QtQuick
import QtQuick.Window


Window {

    id: window


    width: 430
    height: 932


    minimumWidth: 390
    minimumHeight: 780


    visible: true


    title:
        "LumaMobile"


    color:
        "#F3F3F7"


    // ========================================================
    // Runtime Home
    // ========================================================

    HomeScreen {

        id: homeScreen


        anchors.fill:
            parent


        appsModel:
            LumaApps.apps


        onLaunchRequested:
            function(
                app,
                x,
                y,
                w,
                h
            ) {

                appSurface.launchUrl(
                    app.entryUrl,
                    app.id,
                    app.title,
                    app.glyph,
                    app.accent,
                    x,
                    y,
                    w,
                    h
                )
            }
    }


    // ========================================================
    // Luma App Window Manager
    // ========================================================

    AppSurface {

        id: appSurface


        width:
            parent.width


        height:
            parent.height
    }


    // ========================================================
    // Control Center
    // ========================================================

    ControlCenter {

        id: controlCenter


        anchors.fill:
            parent


        z: 2500
    }


    // ========================================================
    // Gesture navigation indicator
    // ========================================================

    Rectangle {

        id: gesturePill


        width: 116
        height: 5


        anchors {

            horizontalCenter:
                parent.horizontalCenter


            bottom:
                parent.bottom


            bottomMargin: 7
        }


        radius:
            height / 2


        color:
            appSurface.active
                ? "#D0FFFFFF"
                : "#B8202026"


        z: 4000
    }


    // ========================================================
    // HOME GESTURE
    // ========================================================

    MouseArea {

        id: homeGesture


        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }


        height: 42


        enabled:
            appSurface.active


        z: 3900


        preventStealing:
            true


        property real startY: 0
        property real startX: 0

        property bool triggered:
            false


        onPressed: mouse => {

            startY =
                mouse.y

            startX =
                mouse.x

            triggered =
                false
        }


        onPositionChanged: mouse => {

            if (
                !pressed ||
                triggered
            )
                return


            const dy =
                mouse.y -
                startY


            const dx =
                Math.abs(
                    mouse.x -
                    startX
                )


            if (
                dy < -65 &&
                Math.abs(dy) > dx
            ) {

                triggered =
                    true


                controlCenter.opened =
                    false


                if (
                    appSurface.active
                ) {

                    appSurface.goHome()
                }
            }
        }


        onReleased: mouse => {

            if (triggered)
                return


            const dy =
                mouse.y -
                startY


            const dx =
                Math.abs(
                    mouse.x -
                    startX
                )


            if (
                dy < -55 &&
                Math.abs(dy) > dx
            ) {

                controlCenter.opened =
                    false


                if (
                    appSurface.active
                ) {

                    appSurface.goHome()
                }
            }
        }
    }


    // ========================================================
    // BACK GESTURE
    // ========================================================

    MouseArea {

        id: backGesture


        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }


        width: 26


        visible:
            appSurface.active &&
            !controlCenter.opened


        z: 3800


        preventStealing:
            true


        property real startX: 0
        property real startY: 0

        property real lastDistance:
            0


        onPressed: mouse => {

            startX =
                mouse.x

            startY =
                mouse.y

            lastDistance =
                0


            appSurface.beginBack()
        }


        onPositionChanged: mouse => {

            if (!pressed)
                return


            const dx =
                mouse.x -
                startX


            const dy =
                Math.abs(
                    mouse.y -
                    startY
                )


            if (
                dx > 0 &&
                dx > dy
            ) {

                lastDistance =
                    dx


                appSurface.updateBack(
                    dx
                )
            }
        }


        onReleased: mouse => {

            const dx =
                Math.max(
                    0,
                    mouse.x -
                    startX
                )


            appSurface.finishBack(
                Math.max(
                    dx,
                    lastDistance
                )
            )
        }


        onCanceled: {

            appSurface.finishBack(
                0
            )
        }
    }


    // ========================================================
    // CONTROL CENTER GESTURE
    // ========================================================

    MouseArea {

        id: topGesture


        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }


        height: 42


        z: 4100


        preventStealing:
            true


        property real startX: 0
        property real startY: 0

        property bool triggered:
            false


        onPressed: mouse => {

            startX =
                mouse.x

            startY =
                mouse.y

            triggered =
                false
        }


        onPositionChanged: mouse => {

            if (
                !pressed ||
                triggered
            )
                return


            const dy =
                mouse.y -
                startY


            const dx =
                Math.abs(
                    mouse.x -
                    startX
                )


            if (
                dy > 65 &&
                dy > dx
            ) {

                triggered =
                    true


                controlCenter.opened =
                    true
            }
        }


        onReleased: mouse => {

            if (triggered)
                return


            const dy =
                mouse.y -
                startY


            const dx =
                Math.abs(
                    mouse.x -
                    startX
                )


            if (
                dy > 55 &&
                dy > dx
            ) {

                controlCenter.opened =
                    true
            }
        }
    }


    // ========================================================
    // Luma Keyboard
    // ========================================================

    LumaKeyboard {

        id: lumaKeyboard


        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }


        z: 5000


        visible:
            LumaInput.inputActive
    }
}
