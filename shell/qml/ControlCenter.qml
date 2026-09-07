import QtQuick

Item {
    id: root

    property bool opened: false

    anchors.fill: parent

    visible:
        opened ||
        opacity > 0.01

    enabled: opened

    opacity:
        opened
            ? 1
            : 0


    Behavior on opacity {
        NumberAnimation {
            duration: 180
        }
    }


    Rectangle {
        anchors.fill: parent

        color: "#66000000"


        MouseArea {
            anchors.fill: parent

            onClicked:
                root.opened = false
        }
    }


    Rectangle {
        id: panel

        width:
            parent.width - 28

        height: 500

        x: 14

        y:
            root.opened
                ? 54
                : -height - 30

        radius: 36

        color: "#F7F7FA"


        Behavior on y {
            NumberAnimation {
                duration: 320
                easing.type: Easing.OutCubic
            }
        }


        MouseArea {
            anchors.fill: parent
        }


        Column {
            anchors {
                fill: parent
                margins: 24
            }

            spacing: 18


            Row {
                width: parent.width


                Text {
                    text:
                        "Control Center"

                    color: "#1D1D22"

                    font {
                        pixelSize: 25
                        weight: Font.DemiBold
                    }
                }
            }


            Row {
                spacing: 12


                QuickToggle {
                    title: "Wi-Fi"
                    subtitle: "LumaNet"

                    glyph: "W"

                    active: true
                }


                QuickToggle {
                    title: "Bluetooth"
                    subtitle: "On"

                    glyph: "B"

                    active: true
                }
            }


            Row {
                spacing: 12


                QuickToggle {
                    title: "Airplane"
                    subtitle: "Off"

                    glyph: "A"
                }


                QuickToggle {
                    title: "Focus"
                    subtitle: "Off"

                    glyph: "F"
                }
            }


            Rectangle {
                width: parent.width
                height: 92

                radius: 24

                color: "#ECECF2"


                Column {
                    anchors {
                        fill: parent
                        margins: 17
                    }

                    spacing: 10


                    Text {
                        text: "Brightness"

                        color: "#27272C"

                        font.pixelSize: 13
                    }


                    Rectangle {
                        width: parent.width
                        height: 13

                        radius: 7

                        color: "#D5D5DC"


                        Rectangle {
                            width:
                                parent.width * 0.72

                            height:
                                parent.height

                            radius: 7

                            color: "#625FE7"
                        }
                    }
                }
            }


            Rectangle {
                width: parent.width
                height: 112

                radius: 24

                color: "#202027"


                Row {
                    anchors {
                        fill: parent
                        margins: 18
                    }

                    spacing: 16


                    Rectangle {
                        width: 72
                        height: 72

                        radius: 20

                        color: "#363640"


                        Text {
                            anchors.centerIn:
                                parent

                            text: "M"

                            color: "white"

                            font.pixelSize: 25
                        }
                    }


                    Column {
                        anchors.verticalCenter:
                            parent.verticalCenter

                        spacing: 4


                        Text {
                            text: "Luma Music"

                            color: "white"

                            font {
                                pixelSize: 18
                                weight: Font.DemiBold
                            }
                        }


                        Text {
                            text:
                                "Nothing playing"

                            color: "#AFAFB8"

                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
