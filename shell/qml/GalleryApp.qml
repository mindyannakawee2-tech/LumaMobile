import QtQuick

Item {
    id: root

    property int selected: -1

    property var photos: [
        ["Sunset", "#EF8A6B"],
        ["Ocean", "#5AA6DF"],
        ["Forest", "#61A979"],
        ["City", "#81818D"],
        ["Night", "#4D527A"],
        ["Luma", "#7167E8"],
        ["Clouds", "#B3B9CA"],
        ["Flowers", "#D9789C"],
        ["Mountains", "#79939D"]
    ]

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

        text: "Gallery"

        color: "#202026"

        font {
            pixelSize: 25
            weight: Font.DemiBold
        }
    }

    Grid {
        visible: root.selected < 0

        anchors {
            top: parent.top
            topMargin: 80

            left: parent.left
            right: parent.right

            leftMargin: 14
            rightMargin: 14
        }

        columns: 3
        spacing: 8

        Repeater {
            model: root.photos

            Rectangle {
                width: (root.width - 44) / 3
                height: width * 1.15

                radius: 15
                color: modelData[1]

                Text {
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        margins: 10
                    }

                    text: modelData[0]

                    color: "white"

                    font {
                        pixelSize: 12
                        weight: Font.DemiBold
                    }
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        root.selected = index
                }
            }
        }
    }

    Rectangle {
        visible: root.selected >= 0

        anchors {
            fill: parent
            margins: 18

            topMargin: 80
            bottomMargin: 50
        }

        radius: 30

        color:
            root.selected >= 0
                ? root.photos[root.selected][1]
                : "transparent"

        Text {
            anchors.centerIn: parent

            text:
                root.selected >= 0
                    ? root.photos[root.selected][0]
                    : ""

            color: "white"

            font {
                pixelSize: 32
                weight: Font.DemiBold
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked:
                root.selected = -1
        }
    }
}
