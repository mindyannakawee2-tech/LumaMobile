import QtQuick

Item {
    id: root

    property int currentIndex: 0
    property bool playing: false
    property real progress: 0

    property var songs: [
        ["Luma Sunrise", "Luma Artist"],
        ["Cola", "Luma Labs"],
        ["Kernel Dreams", "6.18"],
        ["Night Build", "LumaMobile"]
    ]

    Timer {
        interval: 500
        repeat: true
        running: root.playing

        onTriggered: {
            root.progress += 0.006

            if (root.progress >= 1)
                root.progress = 0
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "#F4F4F7"
    }

    Text {
        anchors {
            top: parent.top
            topMargin: 27
            left: parent.left
            leftMargin: 20
        }

        text: "Music"

        color: "#202026"

        font {
            pixelSize: 25
            weight: Font.DemiBold
        }
    }

    Rectangle {
        width: parent.width - 40
        height: 280

        anchors {
            top: parent.top
            topMargin: 80
            horizontalCenter: parent.horizontalCenter
        }

        radius: 34

        gradient: Gradient {
            GradientStop {
                position: 0
                color: "#D46D96"
            }

            GradientStop {
                position: 1
                color: "#765FDA"
            }
        }

        Text {
            anchors.centerIn: parent

            text: "♪"

            color: "white"
            font.pixelSize: 80
        }
    }

    Column {
        width: parent.width - 40

        anchors {
            top: parent.top
            topMargin: 390
            horizontalCenter: parent.horizontalCenter
        }

        spacing: 12

        Text {
            text: root.songs[root.currentIndex][0]

            color: "#202026"

            font {
                pixelSize: 23
                weight: Font.DemiBold
            }
        }

        Text {
            text: root.songs[root.currentIndex][1]

            color: "#7C7C86"
            font.pixelSize: 14
        }

        Rectangle {
            width: parent.width
            height: 8

            radius: 4
            color: "#DCDCE2"

            Rectangle {
                width: parent.width * root.progress
                height: parent.height

                radius: 4
                color: "#625FE7"
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 32

            Rectangle {
                width: 58
                height: 58
                radius: 29

                color: "#E3E3E9"

                Text {
                    anchors.centerIn: parent
                    text: "‹"

                    color: "#202026"
                    font.pixelSize: 24
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        root.currentIndex =
                            (
                                root.currentIndex -
                                1 +
                                root.songs.length
                            ) %
                            root.songs.length

                        root.progress = 0
                    }
                }
            }

            Rectangle {
                width: 74
                height: 74
                radius: 37

                color: "#202027"

                Text {
                    anchors.centerIn: parent

                    text: root.playing
                        ? "Ⅱ"
                        : "▶"

                    color: "white"
                    font.pixelSize: 24
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        root.playing =
                            !root.playing
                }
            }

            Rectangle {
                width: 58
                height: 58
                radius: 29

                color: "#E3E3E9"

                Text {
                    anchors.centerIn: parent
                    text: "›"

                    color: "#202026"
                    font.pixelSize: 24
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked: {
                        root.currentIndex =
                            (
                                root.currentIndex +
                                1
                            ) %
                            root.songs.length

                        root.progress = 0
                    }
                }
            }
        }
    }
}
