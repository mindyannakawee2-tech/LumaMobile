import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string currentUrl:
        "https://example.com"

    Rectangle {
        anchors.fill: parent
        color: "#F4F4F7"
    }

    Rectangle {
        width: parent.width - 24
        height: 54

        anchors {
            top: parent.top
            topMargin: 20
            horizontalCenter: parent.horizontalCenter
        }

        radius: 22
        color: "#FFFFFF"

        TextField {
            id: address

            anchors {
                left: parent.left
                right: go.left

                leftMargin: 14
                rightMargin: 8

                verticalCenter: parent.verticalCenter
            }

            text: root.currentUrl

            background: null

            onAccepted:
                go.load()
        }

        Rectangle {
            id: go

            width: 46
            height: 38
            radius: 15

            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }

            color: "#625FE7"

            function load() {
                root.currentUrl = address.text
            }

            Text {
                anchors.centerIn: parent

                text: "Go"
                color: "white"

                font {
                    pixelSize: 12
                    weight: Font.DemiBold
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: go.load()
            }
        }
    }

    Rectangle {
        anchors {
            top: parent.top
            topMargin: 90

            bottom: controls.top
            bottomMargin: 15

            left: parent.left
            right: parent.right

            margins: 16
        }

        radius: 28
        color: "#FFFFFF"

        Column {
            anchors.centerIn: parent

            spacing: 12

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "Luma Browser"

                color: "#202026"

                font {
                    pixelSize: 24
                    weight: Font.DemiBold
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                width: 280

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap

                text: root.currentUrl

                color: "#777781"
                font.pixelSize: 13
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter

                text: "Qt WebEngine integration comes next."

                color: "#A0A0AA"
                font.pixelSize: 11
            }
        }
    }

    Rectangle {
        id: controls

        height: 62

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            margins: 16
            bottomMargin: 22
        }

        radius: 24
        color: "#202027"

        Text {
            anchors.centerIn: parent

            text: "Open in system browser"

            color: "white"

            font {
                pixelSize: 14
                weight: Font.DemiBold
            }
        }

        MouseArea {
            anchors.fill: parent

            onClicked:
                Qt.openUrlExternally(
                    root.currentUrl
                )
        }
    }
}
