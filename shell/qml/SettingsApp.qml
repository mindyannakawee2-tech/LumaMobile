import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string page: "root"
    property var system:
        LumaSystem.status()

    property bool canGoBack:
        page !== "root"


    function refresh() {
        system =
            LumaSystem.status()
    }


    function goBack() {
        page = "root"
        refresh()
    }


    function openPage(name) {
        page = name
        refresh()
    }


    Timer {
        interval: 3000
        repeat: true
        running: true

        onTriggered:
            root.refresh()
    }


    Rectangle {
        anchors.fill: parent
        color: "#F3F3F7"
    }


    Text {
        anchors {
            top: parent.top
            topMargin: 25
            horizontalCenter:
                parent.horizontalCenter
        }

        text: {
            switch (root.page) {
            case "wifi":
                return "Wi-Fi"

            case "bluetooth":
                return "Bluetooth"

            case "mobile":
                return "Mobile Network"

            case "display":
                return "Display & Brightness"

            case "sound":
                return "Sound & Haptics"

            case "battery":
                return "Battery"

            case "storage":
                return "Storage"

            case "applications":
                return "Applications"

            case "notifications":
                return "Notifications"

            case "privacy":
                return "Privacy & Security"

            case "permissions":
                return "Permissions"

            case "about":
                return "About LumaMobile"

            default:
                return "Settings"
            }
        }

        color: "#202026"

        font {
            pixelSize: 20
            weight: Font.DemiBold
        }
    }


    Flickable {
        visible:
            root.page === "root"

        anchors {
            top: parent.top
            topMargin: 72

            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        clip: true

        contentHeight:
            settingsColumn.height + 50


        Column {
            id: settingsColumn

            width:
                parent.width - 32

            x: 16

            spacing: 11


            Rectangle {
                width: parent.width
                height: 122
                radius: 30

                gradient: Gradient {
                    GradientStop {
                        position: 0
                        color: "#625FE7"
                    }

                    GradientStop {
                        position: 1
                        color: "#847AF2"
                    }
                }


                Rectangle {
                    width: 68
                    height: 68

                    anchors {
                        left: parent.left
                        leftMargin: 20
                        verticalCenter:
                            parent.verticalCenter
                    }

                    radius: 23
                    color: "#28FFFFFF"

                    Text {
                        anchors.centerIn: parent

                        text: "L"

                        color: "white"

                        font {
                            pixelSize: 30
                            weight: Font.Bold
                        }
                    }
                }


                Column {
                    anchors {
                        left: parent.left
                        leftMargin: 108
                        verticalCenter:
                            parent.verticalCenter
                    }

                    spacing: 3


                    Text {
                        text: "LumaMobile"

                        color: "white"

                        font {
                            pixelSize: 20
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        text: "Linux 6.18.49 LTS"

                        color: "#DFFFFFFF"
                        font.pixelSize: 12
                    }


                    Text {
                        text: "Framework 2.0"

                        color: "#CFFFFFFF"
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        root.openPage(
                            "about"
                        )
                }
            }


            Text {
                text: "Connections"

                leftPadding: 8
                topPadding: 7

                color: "#707079"

                font {
                    pixelSize: 13
                    weight: Font.DemiBold
                }
            }


            SettingsRow {
                title: "Wi-Fi"

                subtitle:
                    root.system.wifiEnabled
                        ? "On"
                        : "Off"

                glyph: "W"

                onActivated:
                    root.openPage(
                        "wifi"
                    )
            }


            SettingsRow {
                title: "Bluetooth"

                subtitle:
                    root.system.bluetoothEnabled
                        ? "On"
                        : "Off"

                glyph: "B"

                onActivated:
                    root.openPage(
                        "bluetooth"
                    )
            }


            SettingsRow {
                title: "Mobile Network"

                subtitle:
                    root.system.cellularAvailable
                        ? "Modem connected"
                        : "No modem"

                glyph: "N"

                onActivated:
                    root.openPage(
                        "mobile"
                    )
            }


            Text {
                text: "Device"

                leftPadding: 8
                topPadding: 7

                color: "#707079"

                font {
                    pixelSize: 13
                    weight: Font.DemiBold
                }
            }


            SettingsRow {
                title:
                    "Display & Brightness"

                subtitle:
                    root.system.brightnessPercent >= 0
                        ? root.system.brightnessPercent + "%"
                        : "Unavailable"

                glyph: "D"

                onActivated:
                    root.openPage(
                        "display"
                    )
            }


            SettingsRow {
                title:
                    "Sound & Haptics"

                subtitle:
                    root.system.volumePercent >= 0
                        ? root.system.volumePercent + "%"
                        : "Unavailable"

                glyph: "S"

                onActivated:
                    root.openPage(
                        "sound"
                    )
            }


            SettingsRow {
                title: "Battery"

                subtitle:
                    root.system.batteryPercent >= 0
                        ? root.system.batteryPercent + "%"
                        : "No battery"

                glyph: "%"

                onActivated:
                    root.openPage(
                        "battery"
                    )
            }


            SettingsRow {
                title: "Storage"

                subtitle:
                    root.system.storage.usedHuman
                    + " used"

                glyph: "F"

                onActivated:
                    root.openPage(
                        "storage"
                    )
            }


            Text {
                text: "Apps & Privacy"

                leftPadding: 8
                topPadding: 7

                color: "#707079"

                font {
                    pixelSize: 13
                    weight: Font.DemiBold
                }
            }


            SettingsRow {
                title: "Applications"

                subtitle: "LPK applications"

                glyph: "A"

                onActivated:
                    root.openPage(
                        "applications"
                    )
            }


            SettingsRow {
                title: "Notifications"

                glyph: "N"

                onActivated:
                    root.openPage(
                        "notifications"
                    )
            }


            SettingsRow {
                title: "Privacy & Security"

                glyph: "P"

                onActivated:
                    root.openPage(
                        "privacy"
                    )
            }


            SettingsRow {
                title: "Permissions"

                glyph: "K"

                onActivated:
                    root.openPage(
                        "permissions"
                    )
            }


            Item {
                width: 1
                height: 30
            }
        }
    }


    Item {
        visible:
            root.page !== "root"

        anchors {
            top: parent.top
            topMargin: 76

            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }


        Column {
            width:
                parent.width - 32

            anchors {
                top: parent.top
                horizontalCenter:
                    parent.horizontalCenter
            }

            spacing: 14


            Rectangle {
                visible:
                    root.page === "wifi"

                width: parent.width
                height: 130
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 16


                    Text {
                        text: "Wi-Fi Radio"

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Switch {
                        checked:
                            root.system.wifiEnabled

                        text:
                            checked
                                ? "Enabled"
                                : "Disabled"

                        onToggled: {
                            LumaSystem.setWifiEnabled(
                                checked
                            )

                            root.refresh()
                        }
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "bluetooth"

                width: parent.width
                height: 130
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 16


                    Text {
                        text: "Bluetooth Radio"

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Switch {
                        checked:
                            root.system.bluetoothEnabled

                        text:
                            checked
                                ? "Enabled"
                                : "Disabled"

                        onToggled: {
                            LumaSystem.setBluetoothEnabled(
                                checked
                            )

                            root.refresh()
                        }
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "mobile"

                width: parent.width
                height: 150
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 12


                    Text {
                        text:
                            root.system.cellularAvailable
                                ? "Cellular modem connected"
                                : "No cellular modem detected"

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        width: parent.width

                        wrapMode:
                            Text.WordWrap

                        text:
                            "LumaMobile currently uses ModemManager as the development telephony backend."

                        color: "#777781"
                        font.pixelSize: 13
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "display"

                width: parent.width
                height: 170
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 15


                    Text {
                        text:
                            "Brightness  "
                            + (
                                root.system.brightnessPercent >= 0
                                    ? root.system.brightnessPercent + "%"
                                    : "Unavailable"
                              )

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Slider {
                        width: parent.width

                        from: 1
                        to: 100

                        value:
                            root.system.brightnessPercent >= 0
                                ? root.system.brightnessPercent
                                : 50

                        enabled:
                            root.system.brightnessPercent >= 0

                        onMoved: {
                            LumaSystem.setBrightnessPercent(
                                Math.round(value)
                            )

                            root.refresh()
                        }
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "sound"

                width: parent.width
                height: 170
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 15


                    Text {
                        text:
                            "Volume  "
                            + (
                                root.system.volumePercent >= 0
                                    ? root.system.volumePercent + "%"
                                    : "Unavailable"
                              )

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Slider {
                        width: parent.width

                        from: 0
                        to: 100

                        value:
                            root.system.volumePercent >= 0
                                ? root.system.volumePercent
                                : 50

                        enabled:
                            root.system.volumePercent >= 0

                        onMoved: {
                            LumaSystem.setVolumePercent(
                                Math.round(value)
                            )

                            root.refresh()
                        }
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "battery"

                width: parent.width
                height: 170
                radius: 28
                color: "white"


                Column {
                    anchors.centerIn: parent
                    spacing: 7


                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text:
                            root.system.batteryPercent >= 0
                                ? root.system.batteryPercent + "%"
                                : "Desktop"

                        color: "#202026"

                        font {
                            pixelSize: 44
                            weight: Font.Medium
                        }
                    }


                    Text {
                        anchors.horizontalCenter:
                            parent.horizontalCenter

                        text:
                            root.system.batteryPercent >= 0
                                ? "Battery remaining"
                                : "No battery detected"

                        color: "#777781"
                        font.pixelSize: 13
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "storage"

                width: parent.width
                height: 190
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 12


                    Text {
                        text: "Device Storage"

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        text:
                            root.system.storage.usedHuman
                            + " used of "
                            + root.system.storage.totalHuman

                        color: "#777781"
                        font.pixelSize: 13
                    }


                    Rectangle {
                        width: parent.width
                        height: 12
                        radius: 6
                        color: "#E4E4EA"


                        Rectangle {
                            width:
                                parent.width *
                                root.system.storage.usedPercent /
                                100

                            height: parent.height
                            radius: 6
                            color: "#625FE7"
                        }
                    }


                    Text {
                        text:
                            root.system.storage.freeHuman
                            + " available"

                        color: "#777781"
                        font.pixelSize: 12
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "applications"

                width: parent.width
                height: 180
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 10


                    Text {
                        text: "LPK Applications"

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        text:
                            LumaSystem.listLpkPackages().length
                            + " package(s) found in ~/LumaMobile/packages"

                        width: parent.width

                        wrapMode:
                            Text.WordWrap

                        color: "#777781"
                        font.pixelSize: 13
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "notifications"

                width: parent.width
                height: 150
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 10


                    Text {
                        text: "Notifications"

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        text:
                            "Notification delivery will be provided by LMS. This page is ready for the LMS notification permission API."

                        width: parent.width
                        wrapMode: Text.WordWrap

                        color: "#777781"
                        font.pixelSize: 13
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "privacy" ||
                    root.page === "permissions"

                width: parent.width
                height: 160
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 10


                    Text {
                        text:
                            root.page === "privacy"
                                ? "Privacy & Security"
                                : "App Permissions"

                        color: "#202026"

                        font {
                            pixelSize: 18
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        width: parent.width
                        wrapMode: Text.WordWrap

                        text:
                            "The UI is active, but permission enforcement belongs in Luma Framework. We should not fake security controls before the sandbox exists."

                        color: "#777781"
                        font.pixelSize: 13
                    }
                }
            }


            Rectangle {
                visible:
                    root.page === "about"

                width: parent.width
                height: 250
                radius: 28
                color: "white"


                Column {
                    anchors {
                        fill: parent
                        margins: 20
                    }

                    spacing: 10


                    Text {
                        text: "LumaMobile"

                        color: "#202026"

                        font {
                            pixelSize: 22
                            weight: Font.DemiBold
                        }
                    }


                    Text {
                        text: "Linux 6.18.49 LTS"
                        color: "#777781"
                        font.pixelSize: 13
                    }


                    Text {
                        text: "Luma Framework 2.0.0"
                        color: "#777781"
                        font.pixelSize: 13
                    }


                    Text {
                        text: "LMS 0.1.0"
                        color: "#777781"
                        font.pixelSize: 13
                    }


                    Text {
                        text: "Luma SDK 0.1"
                        color: "#777781"
                        font.pixelSize: 13
                    }


                    Text {
                        text: "LPK Application Platform"
                        color: "#625FE7"

                        font {
                            pixelSize: 13
                            weight: Font.DemiBold
                        }
                    }
                }
            }
        }
    }
}
