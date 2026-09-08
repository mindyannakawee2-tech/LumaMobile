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


    // ========================================================
    // EDIT / DRAG STATE
    // ========================================================

    property bool editMode:
        false

    property bool dragging:
        false


    property string dragSource:
        ""

    property int dragIndex:
        -1


    property var dragApp:
        null


    property real dragX:
        0

    property real dragY:
        0


    property bool overHome:
        false

    property bool overDock:
        false


    property int homeTargetIndex:
        -1

    property int dockTargetIndex:
        -1


    signal launchRequested(
        var app,
        real x,
        real y,
        real width,
        real height
    )


    // ========================================================
    // LOCAL ORDER MODELS
    // ========================================================

    ListModel {
        id: homeModel
    }


    ListModel {
        id: dockModel
    }


    function appendApp(
        model,
        app
    ) {

        model.append({
            "appId":
                app.id,

            "title":
                app.title,

            "glyph":
                app.glyph,

            "accent":
                app.accent,

            "iconUrl":
                app.iconUrl,

            "entryUrl":
                app.entryUrl
        })
    }


    function syncModels() {

        if (
            root.dragging
        )
            return


        homeModel.clear()
        dockModel.clear()


        const homeApps =
            LumaApps.homeApps


        for (
            let i = 0;
            i < homeApps.length;
            ++i
        ) {

            appendApp(
                homeModel,
                homeApps[i]
            )
        }


        const dockApps =
            LumaApps.dockApps


        for (
            let i = 0;
            i < dockApps.length;
            ++i
        ) {

            appendApp(
                dockModel,
                dockApps[i]
            )
        }
    }


    function idsForModel(
        model
    ) {

        let result = []


        for (
            let i = 0;
            i < model.count;
            ++i
        ) {

            result.push(
                model
                    .get(i)
                    .appId
            )
        }


        return result
    }


    function modelApp(
        model,
        index
    ) {

        const item =
            model.get(index)


        return {
            "id":
                item.appId,

            "title":
                item.title,

            "glyph":
                item.glyph,

            "accent":
                item.accent,

            "iconUrl":
                item.iconUrl,

            "entryUrl":
                item.entryUrl
        }
    }


    // ========================================================
    // CLOCK / SYSTEM
    // ========================================================

    function greeting() {

        const hour =
            new Date()
                .getHours()


        if (
            hour < 12
        )
            return "Good morning"


        if (
            hour < 18
        )
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
        syncModels()
    }


    Connections {

        target:
            LumaApps


        function onAppsChanged() {

            root.syncModels()
        }


        function onLayoutChanged() {

            root.syncModels()
        }
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
    // DRAG HELPERS
    // ========================================================

    function pointInside(
        item,
        x,
        y
    ) {

        const point =
            item.mapFromItem(
                root,
                x,
                y
            )


        return (
            point.x >= 0 &&
            point.y >= 0 &&
            point.x <= item.width &&
            point.y <= item.height
        )
    }


    function gridTarget(
        x,
        y,
        allowEnd
    ) {

        const point =
            appGrid.mapFromItem(
                root,
                x,
                y
            )


        if (
            point.x < -20 ||
            point.x > appGrid.width + 20 ||
            point.y < -30 ||
            point.y > appGrid.height + 45
        ) {

            return -1
        }


        const horizontalSpacing =
            (
                appGrid.width -
                304
            ) / 3


        const pitchX =
            76 +
            horizontalSpacing


        const pitchY =
            114


        let column =
            Math.floor(
                point.x /
                pitchX
            )


        column =
            Math.max(
                0,
                Math.min(
                    3,
                    column
                )
            )


        let row =
            Math.floor(
                Math.max(
                    0,
                    point.y
                ) /
                pitchY
            )


        let index =
            row * 4 +
            column


        const maximum =
            allowEnd
                ? homeModel.count
                : Math.max(
                      0,
                      homeModel.count - 1
                  )


        index =
            Math.max(
                0,
                Math.min(
                    maximum,
                    index
                )
            )


        return index
    }


    function dockTarget(
        x,
        y
    ) {

        const point =
            dock.mapFromItem(
                root,
                x,
                y
            )


        if (
            point.x < 0 ||
            point.y < 0 ||
            point.x > dock.width ||
            point.y > dock.height
        ) {

            return -1
        }


        if (
            dockModel.count === 0
        ) {

            return 0
        }


        const slotWidth =
            dock.width /
            dockModel.count


        let index =
            Math.floor(
                point.x /
                slotWidth
            )


        if (
            root.dragSource === "home" &&
            dockModel.count < 4
        ) {

            index =
                Math.max(
                    0,
                    Math.min(
                        dockModel.count,
                        index
                    )
                )

        } else {

            index =
                Math.max(
                    0,
                    Math.min(
                        dockModel.count - 1,
                        index
                    )
                )
        }


        return index
    }


    function startDrag(
        source,
        index,
        app,
        x,
        y
    ) {

        root.editMode =
            true


        root.dragging =
            true


        root.dragSource =
            source


        root.dragIndex =
            index


        root.dragApp =
            app


        root.dragX =
            x

        root.dragY =
            y


        root.overHome =
            false

        root.overDock =
            false


        updateDrag(
            x,
            y
        )
    }


    function updateDrag(
        x,
        y
    ) {

        if (
            !root.dragging
        )
            return


        root.dragX =
            x

        root.dragY =
            y


        const dockIndex =
            dockTarget(
                x,
                y
            )


        if (
            dockIndex >= 0
        ) {

            root.overDock =
                true

            root.overHome =
                false

            root.dockTargetIndex =
                dockIndex

            root.homeTargetIndex =
                -1


            // Reorder live while dragging
            // an existing dock item.

            if (
                root.dragSource === "dock" &&
                dockIndex !== root.dragIndex &&
                dockIndex < dockModel.count
            ) {

                dockModel.move(
                    root.dragIndex,
                    dockIndex,
                    1
                )


                root.dragIndex =
                    dockIndex
            }


            return
        }


        const target =
            gridTarget(
                x,
                y,
                root.dragSource === "dock"
            )


        if (
            target >= 0
        ) {

            root.overHome =
                true

            root.overDock =
                false

            root.homeTargetIndex =
                target

            root.dockTargetIndex =
                -1


            // Reorder live while dragging
            // an existing Home item.

            if (
                root.dragSource === "home" &&
                target !== root.dragIndex &&
                target < homeModel.count
            ) {

                homeModel.move(
                    root.dragIndex,
                    target,
                    1
                )


                root.dragIndex =
                    target
            }


            return
        }


        root.overHome =
            false

        root.overDock =
            false

        root.homeTargetIndex =
            -1

        root.dockTargetIndex =
            -1
    }


    function finishDrag(
        x,
        y
    ) {

        if (
            !root.dragging
        )
            return


        updateDrag(
            x,
            y
        )


        const source =
            root.dragSource


        const appId =
            root.dragApp
                ? root.dragApp.id
                : ""


        const wasHome =
            root.overHome


        const wasDock =
            root.overDock


        const homeIndex =
            root.homeTargetIndex


        const dockIndex =
            root.dockTargetIndex


        root.dragging =
            false


        root.dragSource =
            ""

        root.dragIndex =
            -1


        root.overHome =
            false

        root.overDock =
            false


        // ----------------------------------------------------
        // HOME -> DOCK
        // ----------------------------------------------------

        if (
            source === "home" &&
            wasDock
        ) {

            LumaApps.moveAppToDock(
                appId,
                Math.max(
                    0,
                    dockIndex
                )
            )


            root.syncModels()

            return
        }


        // ----------------------------------------------------
        // DOCK -> HOME
        // ----------------------------------------------------

        if (
            source === "dock" &&
            wasHome
        ) {

            LumaApps.moveAppToHome(
                appId,
                Math.max(
                    0,
                    homeIndex
                )
            )


            root.syncModels()

            return
        }


        // ----------------------------------------------------
        // HOME reorder
        // ----------------------------------------------------

        if (
            source === "home" &&
            wasHome
        ) {

            LumaApps.setHomeOrder(
                idsForModel(
                    homeModel
                )
            )


            root.syncModels()

            return
        }


        // ----------------------------------------------------
        // DOCK reorder
        // ----------------------------------------------------

        if (
            source === "dock" &&
            wasDock
        ) {

            LumaApps.setDockOrder(
                idsForModel(
                    dockModel
                )
            )


            root.syncModels()

            return
        }


        // Dropped somewhere invalid:
        // restore saved layout.

        root.syncModels()
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
    // EDIT MODE HEADER
    // ========================================================

    Rectangle {

        visible:
            root.editMode


        anchors {
            top:
                statusBar.bottom

            left:
                parent.left

            right:
                parent.right

            leftMargin: 14
            rightMargin: 14
        }


        height: 46


        radius: 19


        color:
            "#ECFFFFFF"


        border.width:
            1


        border.color:
            "#30625FE7"


        z: 500


        Text {

            anchors {
                left: parent.left
                leftMargin: 15

                verticalCenter:
                    parent.verticalCenter
            }


            text:
                root.dragging
                    ? (
                        root.overDock
                            ? (
                                dockModel.count >= 4 &&
                                root.dragSource === "home"
                                    ? "Release to swap dock app"
                                    : "Release to add to Dock"
                              )
                            : root.overHome
                                ? "Release to place"
                                : "Drag an app"
                      )
                    : "Drag apps to arrange"


            color:
                "#373741"


            font.pixelSize:
                12
        }


        Rectangle {

            width: 64
            height: 32


            anchors {
                right: parent.right
                rightMargin: 7

                verticalCenter:
                    parent.verticalCenter
            }


            radius: 14


            color:
                doneMouse.pressed
                    ? "#504DCB"
                    : "#625FE7"


            Text {

                anchors.centerIn:
                    parent


                text:
                    "Done"


                color:
                    "white"


                font {
                    pixelSize: 12
                    weight: Font.DemiBold
                }
            }


            MouseArea {

                id: doneMouse


                anchors.fill:
                    parent


                enabled:
                    !root.dragging


                onClicked:
                    root.editMode = false
            }
        }
    }


    // ========================================================
    // HOME CONTENT
    // ========================================================

    Flickable {

        id: home


        anchors {
            top:
                root.editMode
                    ? editHeaderBottom.bottom
                    : statusBar.bottom

            left:
                parent.left

            right:
                parent.right

            bottom:
                dock.top
        }


        // Dummy anchor helper is defined below.
        // editHeaderBottom tracks the edit header.

        clip:
            true


        interactive:
            !root.dragging


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


            Column {

                visible:
                    !root.editMode


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


            LumaCard {

                visible:
                    !root.editMode


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


            Row {

                width:
                    parent.width


                Text {

                    text:
                        root.editMode
                            ? "Arrange Apps"
                            : "Apps"


                    color:
                        "#202026"


                    font {
                        pixelSize: 20
                        weight: Font.DemiBold
                    }
                }


                Item {
                    width: 1
                    height: 1
                }
            }


            Rectangle {

                width:
                    parent.width


                height:
                    Math.max(
                        114,
                        Math.ceil(
                            homeModel.count / 4
                        ) * 114
                    )


                radius:
                    root.editMode
                        ? 26
                        : 0


                color:
                    root.editMode
                        ? "#28FFFFFF"
                        : "transparent"


                border.width:
                    root.editMode
                        ? 1
                        : 0


                border.color:
                    root.dragging &&
                    root.overHome
                        ? "#80625FE7"
                        : "#20FFFFFF"


                Grid {

                    id: appGrid


                    anchors {
                        fill: parent
                        margins:
                            root.editMode
                                ? 8
                                : 0
                    }


                    columns: 4


                    columnSpacing:
                        (
                            width -
                            304
                        ) / 3


                    rowSpacing:
                        12


                    Repeater {

                        model:
                            homeModel


                        AppIcon {

                            title:
                                model.title


                            glyph:
                                model.glyph


                            backgroundColor:
                                model.accent


                            iconSource:
                                model.iconUrl


                            editMode:
                                root.editMode


                            dragHidden:
                                root.dragging &&
                                root.dragSource === "home" &&
                                root.dragApp &&
                                root.dragApp.id === model.appId


                            onEditRequested:
                                root.editMode = true


                            onDragStarted:
                                function(
                                    x,
                                    y
                                ) {

                                    root.startDrag(
                                        "home",
                                        index,
                                        root.modelApp(
                                            homeModel,
                                            index
                                        ),
                                        x,
                                        y
                                    )
                                }


                            onDragMoved:
                                function(
                                    x,
                                    y
                                ) {

                                    root.updateDrag(
                                        x,
                                        y
                                    )
                                }


                            onDragReleased:
                                function(
                                    x,
                                    y
                                ) {

                                    root.finishDrag(
                                        x,
                                        y
                                    )
                                }


                            onLaunched:
                                function(
                                    x,
                                    y,
                                    w,
                                    h
                                ) {

                                    root.launchRequested(
                                        root.modelApp(
                                            homeModel,
                                            index
                                        ),
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
    }


    // Helper to give Flickable a valid anchor target
    // when edit mode is active.

    Item {

        id: editHeaderBottom


        anchors {
            top:
                statusBar.bottom

            left:
                parent.left
        }


        height:
            root.editMode
                ? 54
                : 0


        width: 1
    }


    // ========================================================
    // DOCK
    // ========================================================

    Rectangle {

        id: dock


        visible:
            root.editMode ||
            dockModel.count > 0


        width:
            root.editMode
                ? 330
                : Math.min(
                      312,
                      36
                      +
                      dockModel.count * 56
                      +
                      Math.max(
                          0,
                          dockModel.count - 1
                      ) * 18
                  )


        height: 82


        anchors {
            bottom:
                parent.bottom

            horizontalCenter:
                parent.horizontalCenter

            bottomMargin: 18
        }


        radius: 31


        color:
            root.dragging &&
            root.overDock
                ? "#F03B355E"
                : "#E827272F"


        border.width:
            root.editMode
                ? 2
                : 1


        border.color:
            root.dragging &&
            root.overDock
                ? "#9C9AFF"
                : root.editMode
                    ? "#50625FE7"
                    : "#20FFFFFF"


        z: 300


        Text {

            visible:
                root.editMode &&
                dockModel.count === 0


            anchors.centerIn:
                parent


            text:
                "Drop apps here"


            color:
                "#BFFFFFFF"


            font.pixelSize:
                12
        }


        Row {

            anchors.centerIn:
                parent


            spacing: 18


            Repeater {

                model:
                    dockModel


                AppIcon {

                    showLabel:
                        false


                    tileSize:
                        56


                    tileRadius:
                        18


                    itemWidth:
                        56

                    itemHeight:
                        56


                    title:
                        model.title


                    glyph:
                        model.glyph


                    backgroundColor:
                        model.accent


                    iconSource:
                        model.iconUrl


                    editMode:
                        root.editMode


                    dragHidden:
                        root.dragging &&
                        root.dragSource === "dock" &&
                        root.dragApp &&
                        root.dragApp.id === model.appId


                    onEditRequested:
                        root.editMode = true


                    onDragStarted:
                        function(
                            x,
                            y
                        ) {

                            root.startDrag(
                                "dock",
                                index,
                                root.modelApp(
                                    dockModel,
                                    index
                                ),
                                x,
                                y
                            )
                        }


                    onDragMoved:
                        function(
                            x,
                            y
                        ) {

                            root.updateDrag(
                                x,
                                y
                            )
                        }


                    onDragReleased:
                        function(
                            x,
                            y
                        ) {

                            root.finishDrag(
                                x,
                                y
                            )
                        }


                    onLaunched:
                        function(
                            x,
                            y,
                            w,
                            h
                        ) {

                            root.launchRequested(
                                root.modelApp(
                                    dockModel,
                                    index
                                ),
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
    // DRAG GHOST
    // ========================================================

    Item {

        visible:
            root.dragging &&
            root.dragApp


        width: 82
        height: 108


        x:
            root.dragX -
            width / 2


        y:
            root.dragY -
            38


        z: 2000


        Rectangle {

            width: 68
            height: 68


            anchors {
                top: parent.top

                horizontalCenter:
                    parent.horizontalCenter
            }


            radius: 22


            color:
                root.dragApp
                    ? root.dragApp.accent
                    : "#625FE7"


            scale: 1.08


            border.width: 2


            border.color:
                "#70FFFFFF"


            Image {

                anchors.centerIn:
                    parent


                width: 37
                height: 37


                source:
                    root.dragApp
                        ? root.dragApp.iconUrl
                        : ""


                visible:
                    root.dragApp &&
                    root.dragApp.iconUrl.length > 0


                fillMode:
                    Image.PreserveAspectFit
            }


            Text {

                anchors.centerIn:
                    parent


                visible:
                    !root.dragApp ||
                    root.dragApp.iconUrl.length === 0


                text:
                    root.dragApp
                        ? root.dragApp.glyph
                        : "L"


                color:
                    "white"


                font {
                    pixelSize: 25
                    weight: Font.DemiBold
                }
            }
        }


        Text {

            anchors {
                top: parent.top
                topMargin: 77

                horizontalCenter:
                    parent.horizontalCenter
            }


            width: 110


            horizontalAlignment:
                Text.AlignHCenter


            text:
                root.dragApp
                    ? root.dragApp.title
                    : ""


            color:
                "#202026"


            font {
                pixelSize: 12
                weight: Font.DemiBold
            }
        }
    }
}
