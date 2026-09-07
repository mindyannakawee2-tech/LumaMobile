import QtQuick
import QtQuick.Window

Window {
    id: window

    width: 430
    height: 932

    minimumWidth: 390
    minimumHeight: 780

    visible: true

    title: "LumaMobile"

    color: "#F3F3F7"


    property string currentTime:
        Qt.formatTime(
            new Date(),
            "hh:mm"
        )


    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: {

            window.currentTime =
                Qt.formatTime(
                    new Date(),
                    "hh:mm"
                )
        }
    }


    // ========================================================
    // App components
    // ========================================================

    Component {
        id: settingsComponent

        SettingsApp {
        }
    }


    Component {
        id: placeholderComponent

        PlaceholderApp {
            appTitle:
                appSurface.appTitle

            appGlyph:
                appSurface.appGlyph

            accent:
                appSurface.appAccent
        }
    }


    Component {
        id: phoneComponent
        PhoneApp {}
    }

    Component {
        id: messagesComponent
        MessagesApp {}
    }

    Component {
        id: galleryComponent
        GalleryApp {}
    }

    Component {
        id: filesComponent
        FilesApp {}
    }

    Component {
        id: browserComponent
        BrowserApp {}
    }

    Component {
        id: musicComponent
        MusicApp {}
    }

    Component {
        id: storeComponent
        StoreApp {}
    }


    // ========================================================
    // Wallpaper
    // ========================================================

    Rectangle {
        anchors.fill: parent


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
        width: 360
        height: 360

        x: -160
        y: 120

        radius:
            width / 2

        color: "#185D5AE6"
    }


    Rectangle {
        width: 320
        height: 320

        x: 270
        y: 400

        radius:
            width / 2

        color: "#147AA9FF"
    }


    // ========================================================
    // Status bar
    // ========================================================

    Item {
        id: statusBar

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        height: 56


        Text {
            anchors {
                left: parent.left
                leftMargin: 24
                verticalCenter:
                    parent.verticalCenter
            }

            text:
                window.currentTime

            color: "#202026"

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
                text: "●"

                color: "#202026"

                font.pixelSize: 10
            }


            Text {
                text: "Wi-Fi"

                color: "#202026"

                font.pixelSize: 12
            }


            Text {
                text: "87%"

                color: "#202026"

                font.pixelSize: 12
            }
        }
    }


    // ========================================================
    // Home
    // ========================================================

    Flickable {
        id: home

        anchors {
            top: statusBar.bottom
            left: parent.left
            right: parent.right
            bottom: dock.top
        }

        clip: true

        contentHeight:
            content.height + 30

        boundsBehavior:
            Flickable.StopAtBounds


        Column {
            id: content

            width:
                parent.width - 36

            x: 18

            spacing: 18


            Column {
                width: parent.width

                spacing: 3


                Text {
                    text:
                        "Good evening"

                    color: "#202026"

                    font {
                        pixelSize: 34
                        weight: Font.DemiBold
                    }
                }


                Text {
                    text:
                        "Welcome back to Luma"

                    color: "#75757F"

                    font.pixelSize: 16
                }
            }


            LumaCard {
                width: parent.width
                height: 178


                gradient: Gradient {

                    GradientStop {
                        position: 0
                        color: "#685FEA"
                    }

                    GradientStop {
                        position: 1
                        color: "#8A7EF4"
                    }
                }


                Column {
                    anchors {
                        left: parent.left
                        top: parent.top
                        margins: 24
                    }

                    spacing: 6


                    Text {
                        text: "LumaMobile"

                        color: "white"

                        font {
                            pixelSize: 16
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        text:
                            "Everything is ready."

                        color: "white"

                        font {
                            pixelSize: 27
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        text:
                            "Framework 2  •  LMS online"

                        color: "#DFFFFFFF"

                        font.pixelSize: 13
                    }
                }


                Rectangle {
                    width: 58
                    height: 58

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        rightMargin: 22
                        bottomMargin: 20
                    }

                    radius: 20

                    color: "#25FFFFFF"


                    Text {
                        anchors.centerIn:
                            parent

                        text: "L"

                        color: "white"

                        font {
                            pixelSize: 25
                            weight: Font.Bold
                        }
                    }
                }
            }


            Row {
                spacing: 12


                LumaCard {
                    width:
                        (content.width - 12) / 2

                    height: 150


                    Column {
                        anchors {
                            fill: parent
                            margins: 19
                        }

                        spacing: 5


                        Text {
                            text: "31°"

                            color: "#202026"

                            font {
                                pixelSize: 38
                                weight: Font.Medium
                            }
                        }


                        Text {
                            text: "Bangkok"

                            color: "#202026"

                            font {
                                pixelSize: 16
                                weight: Font.DemiBold
                            }
                        }


                        Text {
                            text:
                                "Partly cloudy"

                            color: "#777781"

                            font.pixelSize: 12
                        }
                    }
                }


                LumaCard {
                    width:
                        (content.width - 12) / 2

                    height: 150


                    Column {
                        anchors {
                            fill: parent
                            margins: 19
                        }

                        spacing: 7


                        Text {
                            text: "Battery"

                            color: "#777781"

                            font.pixelSize: 13
                        }


                        Text {
                            text: "87%"

                            color: "#202026"

                            font {
                                pixelSize: 34
                                weight: Font.Medium
                            }
                        }


                        Rectangle {
                            width: parent.width
                            height: 8

                            radius: 4

                            color: "#E2E2E7"


                            Rectangle {
                                width:
                                    parent.width * 0.87

                                height:
                                    parent.height

                                radius: 4

                                color: "#44B971"
                            }
                        }
                    }
                }
            }


            Text {
                text: "Apps"

                color: "#202026"

                font {
                    pixelSize: 20
                    weight: Font.DemiBold
                }
            }


            Grid {
                width: parent.width

                columns: 4

                columnSpacing:
                    (width - 304) / 3

                rowSpacing: 12


                AppIcon {
                    title: "Phone"
                    glyph: "P"

                    backgroundColor:
                        "#55BC76"

                    onLaunched:
                        function(x, y, w, h) {

                            appSurface.launch(
                                phoneComponent,
                                "com.luma.phone",
                                "Phone",
                                "P",
                                "#55BC76",
                                x,
                                y,
                                w,
                                h
                            )
                        }
                }


                AppIcon {
                    title: "Messages"
                    glyph: "M"

                    backgroundColor:
                        "#53A7F5"

                    onLaunched:
                        function(x, y, w, h) {

                            appSurface.launch(
                                messagesComponent,
                                "com.luma.messages",
                                "Messages",
                                "M",
                                "#53A7F5",
                                x,
                                y,
                                w,
                                h
                            )
                        }
                }


                AppIcon {
                    title: "Gallery"
                    glyph: "G"

                    backgroundColor:
                        "#EF8673"

                    onLaunched:
                        function(x, y, w, h) {

                            appSurface.launch(
                                galleryComponent,
                                "com.luma.gallery",
                                "Gallery",
                                "G",
                                "#EF8673",
                                x,
                                y,
                                w,
                                h
                            )
                        }
                }


                AppIcon {
                    title: "Files"
                    glyph: "F"

                    backgroundColor:
                        "#E0A947"

                    onLaunched:
                        function(x, y, w, h) {

                            appSurface.launch(
                                filesComponent,
                                "com.luma.files",
                                "Files",
                                "F",
                                "#E0A947",
                                x,
                                y,
                                w,
                                h
                            )
                        }
                }


                AppIcon {
                    title: "Browser"
                    glyph: "B"

                    backgroundColor:
                        "#648FE9"

                    onLaunched:
                        function(x, y, w, h) {

                            appSurface.launch(
                                browserComponent,
                                "com.luma.browser",
                                "Browser",
                                "B",
                                "#648FE9",
                                x,
                                y,
                                w,
                                h
                            )
                        }
                }


                AppIcon {
                    title: "Music"
                    glyph: "M"

                    backgroundColor:
                        "#D46D96"

                    onLaunched:
                        function(x, y, w, h) {

                            appSurface.launch(
                                musicComponent,
                                "com.luma.music",
                                "Music",
                                "M",
                                "#D46D96",
                                x,
                                y,
                                w,
                                h
                            )
                        }
                }


                AppIcon {
                    title: "Store"
                    glyph: "S"

                    backgroundColor:
                        "#675FDA"

                    onLaunched:
                        function(x, y, w, h) {

                            appSurface.launch(
                                storeComponent,
                                "com.luma.store",
                                "Luma Store",
                                "S",
                                "#675FDA",
                                x,
                                y,
                                w,
                                h
                            )
                        }
                }


                AppIcon {
                    title: "Settings"
                    glyph: "S"

                    backgroundColor:
                        "#777781"

                    onLaunched:
                        function(x, y, w, h) {

                            appSurface.launch(
                                settingsComponent,
                                "com.luma.settings",
                                "Settings",
                                "S",
                                "#777781",
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


    // ========================================================
    // Dock
    // ========================================================

    Rectangle {
        id: dock

        width: 312
        height: 82

        anchors {
            bottom: parent.bottom
            horizontalCenter:
                parent.horizontalCenter
            bottomMargin: 18
        }

        radius: 31

        color: "#E827272F"

        border.width: 1
        border.color: "#20FFFFFF"


        Row {
            anchors.centerIn:
                parent

            spacing: 18


            Repeater {
                model: [
                    {
                        id: "com.luma.phone",
                        title: "Phone",
                        glyph: "P",
                        icon: "assets/icons/phone.svg",
                        color: "#55BC76"
                    },

                    {
                        id: "com.luma.messages",
                        title: "Messages",
                        glyph: "M",
                        icon: "assets/icons/messages.svg",
                        color: "#53A7F5"
                    },

                    {
                        id: "com.luma.gallery",
                        title: "Gallery",
                        glyph: "G",
                        icon: "assets/icons/gallery.svg",
                        color: "#EF8673"
                    },

                    {
                        id: "com.luma.settings",
                        title: "Settings",
                        glyph: "S",
                        icon: "assets/icons/settings.svg",
                        color: "#777781"
                    }
                ]


                Rectangle {
                    id: dockIcon

                    width: 56
                    height: 56

                    radius: 18

                    color:
                        modelData.color

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
                            Qt.resolvedUrl(
                                modelData.icon
                            )

                        fillMode:
                            Image.PreserveAspectFit

                        smooth: true
                        mipmap: false
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


                            let component =
                                placeholderComponent

                            if (modelData.id === "com.luma.phone")
                                component = phoneComponent
                            else if (modelData.id === "com.luma.messages")
                                component = messagesComponent
                            else if (modelData.id === "com.luma.gallery")
                                component = galleryComponent
                            else if (modelData.id === "com.luma.settings")
                                component = settingsComponent


                            appSurface.launch(
                                component,
                                modelData.id,
                                modelData.title,
                                modelData.glyph,
                                modelData.color,
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


    // ========================================================
    // Luma App Window Manager
    // ========================================================

    AppSurface {
        id: appSurface

        width: parent.width
        height: parent.height
    }


    // ========================================================
    // Control Center
    // ========================================================

    ControlCenter {
        id: controlCenter

        anchors.fill: parent

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

            bottom: parent.bottom
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
    //
    // Bottom-edge swipe up:
    // app shrinks back into its launch icon.
    // ========================================================

    MouseArea {
        id: homeGesture

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        height: 42

        z: 3900

        preventStealing: true

        property real startY: 0
        property real startX: 0
        property bool triggered: false


        onPressed: mouse => {

            startY = mouse.y
            startX = mouse.x

            triggered = false
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

                triggered = true

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
    //
    // Left-edge swipe right:
    //
    // App moves WITH your finger.
    // Release far enough -> app flies off-screen.
    // Release early -> app snaps back.
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

        preventStealing: true

        property real startX: 0
        property real startY: 0
        property real lastDistance: 0


        onPressed: mouse => {

            startX = mouse.x
            startY = mouse.y

            lastDistance = 0

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

                lastDistance = dx

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
    // CONTROL CENTER
    //
    // Gesture only.
    // No battery/status icon click.
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

        preventStealing: true

        property real startX: 0
        property real startY: 0
        property bool triggered: false


        onPressed: mouse => {

            startX = mouse.x
            startY = mouse.y

            triggered = false
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

                triggered = true

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
    // Luma on-screen keyboard
    // ========================================================

    // LUMA_KEYBOARD_01

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
