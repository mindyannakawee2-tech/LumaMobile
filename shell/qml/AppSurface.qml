import QtQuick

Item {
    id: root

    // ========================================================
    // Luma Back Router
    // ========================================================

    function lumaPerformBack() {

        const app =
            loader.item

        //
        // Internal application navigation has priority.
        //

        if (
            app
            && app.canGoBack === true
            && typeof app.goBack === "function"
        ) {

            console.log(
                "[LumaNav] internal app Back"
            )

            app.goBack()

            return
        }


        //
        // At application root, Back means HOME.
        //
        // We intentionally have NO cross-app history.
        //

        console.log(
            "[LumaNav] app root -> Home"
        )

        root.goHome()
    }



    property bool active: false

    property bool instant: false
    property bool draggingBack: false

    property real originX: 0
    property real originY: 0
    property real originWidth: 64
    property real originHeight: 64

    property real cornerRadius: 0

    property string appId: ""
    property string appTitle: ""
    property string appGlyph: "L"

    property color appAccent: "#625FE7"

    signal appClosed(string appId)


    visible:
        active ||
        opacity > 0.01

    enabled: active

    z: 1500

    opacity: 0


    // ========================================================
    // Animations
    // ========================================================

    Behavior on x {
        enabled:
            !root.instant &&
            !root.draggingBack

        NumberAnimation {
            duration: 185
            easing.type: Easing.OutCubic
        }
    }


    Behavior on y {
        enabled:
            !root.instant &&
            !root.draggingBack

        NumberAnimation {
            duration: 185
            easing.type: Easing.OutCubic
        }
    }


    Behavior on width {
        enabled:
            !root.instant &&
            !root.draggingBack

        NumberAnimation {
            duration: 185
            easing.type: Easing.OutCubic
        }
    }


    Behavior on height {
        enabled:
            !root.instant &&
            !root.draggingBack

        NumberAnimation {
            duration: 185
            easing.type: Easing.OutCubic
        }
    }


    Behavior on opacity {
        enabled:
            !root.instant &&
            !root.draggingBack

        NumberAnimation {
            duration: 140
            easing.type: Easing.OutCubic
        }
    }


    Behavior on cornerRadius {
        enabled:
            !root.instant &&
            !root.draggingBack

        NumberAnimation {
            duration: 185
            easing.type: Easing.OutCubic
        }
    }


    // ========================================================
    // Launch app
    // ========================================================

    function launch(
        component,
        id,
        title,
        glyph,
        accent,
        ox,
        oy,
        ow,
        oh
    ) {

        appId = id
        appTitle = title
        appGlyph = glyph
        appAccent = accent

        originX = ox
        originY = oy
        originWidth = ow
        originHeight = oh

        loader.sourceComponent = component


        // Start exactly where the icon lives.

        instant = true
        draggingBack = false

        active = true

        x = originX
        y = originY

        width = originWidth
        height = originHeight

        cornerRadius = 22

        opacity = 0.35


        // Next frame:
        // expand into a full-screen app.

        Qt.callLater(
            function() {

                instant = false

                x = 0
                y = 0

                width = parent.width
                height = parent.height

                cornerRadius = 0

                opacity = 1
            }
        )
    }


    // ========================================================
    // Launch dynamically discovered application
    // ========================================================

    function launchUrl(
        sourceUrl,
        id,
        title,
        glyph,
        accent,
        ox,
        oy,
        ow,
        oh
    ) {

        appId = id
        appTitle = title
        appGlyph = glyph
        appAccent = accent

        originX = ox
        originY = oy
        originWidth = ow
        originHeight = oh


        loader.sourceComponent = null
        loader.source = sourceUrl


        instant = true
        draggingBack = false

        active = true

        x = originX
        y = originY

        width = originWidth
        height = originHeight

        cornerRadius = 22

        opacity = 0.35


        Qt.callLater(
            function() {

                instant = false

                x = 0
                y = 0

                width = parent.width
                height = parent.height

                cornerRadius = 0

                opacity = 1
            }
        )
    }



    // ========================================================
    // HOME
    //
    // Shrink the application back into its original icon.
    // ========================================================

    function goHome() {

        if (!active)
            return


        draggingBack = false
        instant = false

        x = originX
        y = originY

        width = originWidth
        height = originHeight

        cornerRadius = 22

        opacity = 0

        closeTimer.restart()
    }


    // ========================================================
    // Interactive BACK
    // ========================================================

    function beginBack() {

        if (!active)
            return

        draggingBack = true
        instant = true
    }


    function updateBack(distance) {

        if (!active)
            return


        const d =
            Math.max(
                0,
                distance
            )


        // linuxfb + VNC dislikes fractional animated edges.
        // Keep the app on exact framebuffer pixels.
        x = Math.round(d)

        // Do NOT fade during an interactive swipe.
        // Sliding + alpha blending caused visible edge trails.
        opacity = 1
    }


    function finishBack(distance) {

        if (!active)
            return


        draggingBack = false
        instant = false


        const threshold =
            parent.width * 0.23


        if (
            distance >
            threshold
        ) {

            const app =
                loader.item


            // ================================================
            // INTERNAL APP BACK HAS PRIORITY
            //
            // Browser:
            //
            // page 3 -> page 2 -> page 1 -> Home
            //
            // Settings:
            //
            // Wi-Fi -> Settings -> Home
            //
            // There is deliberately NO cross-app history.
            // ================================================

            if (
                app &&
                app.canGoBack === true &&
                typeof app.goBack === "function"
            ) {

                console.log(
                    "[LumaNav] swipe -> internal app Back"
                )


                // Return the app surface to its normal position.
                //
                // Do NOT throw the application away.

                x = 0
                opacity = 1


                app.goBack()

                return
            }


            // ================================================
            // APP ROOT
            //
            // There is nothing left inside this application
            // to go back to.
            //
            // Back therefore means HOME.
            // ================================================

            console.log(
                "[LumaNav] swipe -> app root -> Home"
            )


            x =
                Math.ceil(
                    parent.width
                ) + 2

            opacity = 1


            backCloseTimer.restart()

        } else {

            // ================================================
            // GESTURE CANCELLED
            // ================================================

            x = 0
            opacity = 1
        }
    }



    // ========================================================
    // Final cleanup
    // ========================================================

    function finishClose() {

        const oldId =
            appId


        active = false

        loader.source =
            ""

        loader.sourceComponent =
            null


        instant = true

        x = 0
        y = 0

        width = parent.width
        height = parent.height

        cornerRadius = 0

        opacity = 0


        Qt.callLater(
            function() {
                instant = false
            }
        )


        appClosed(
            oldId
        )
    }


    Timer {
        id: closeTimer

        interval: 205

        repeat: false

        onTriggered:
            root.finishClose()
    }


    Timer {
        id: backCloseTimer

        interval: 200

        repeat: false

        onTriggered:
            root.finishClose()
    }


    // ========================================================
    // Window surface
    // ========================================================

    Rectangle {
        id: frame

        anchors.fill: parent

        radius:
            root.cornerRadius

        clip: true

        // Prevent the moving edge from producing a
        // 1px translucent seam in software rendering.
        antialiasing: false

        color: "#F3F3F7"


        Loader {
            id: loader

            anchors.fill: parent
        }
    }
}
