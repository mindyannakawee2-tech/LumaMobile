import QtQuick

Item {
    id: root

    property string title: "App"
    property string glyph: "L"

    property color backgroundColor: "#62626A"

    // Automatically resolve built-in Luma app icons.
    property url iconSource: {
        switch (title) {
        case "Phone":
            return Qt.resolvedUrl("assets/icons/phone.svg")
        case "Messages":
            return Qt.resolvedUrl("assets/icons/messages.svg")
        case "Gallery":
            return Qt.resolvedUrl("assets/icons/gallery.svg")
        case "Files":
            return Qt.resolvedUrl("assets/icons/files.svg")
        case "Browser":
            return Qt.resolvedUrl("assets/icons/browser.svg")
        case "Music":
            return Qt.resolvedUrl("assets/icons/music.svg")
        case "Store":
        case "Luma Store":
            return Qt.resolvedUrl("assets/icons/store.svg")
        case "Settings":
            return Qt.resolvedUrl("assets/icons/settings.svg")
        default:
            return ""
        }
    }

    signal launched(
        real originX,
        real originY,
        real originWidth,
        real originHeight
    )

    width: 76
    height: 102


    Rectangle {
        id: icon

        width: 64
        height: 64

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }

        radius: 20
        color: root.backgroundColor

        scale: touch.pressed ? 0.84 : 1.0

        Behavior on scale {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }


        Image {
            anchors.centerIn: parent

            width: 35
            height: 35

            source: root.iconSource

            visible:
                root.iconSource.toString() !== ""

            fillMode: Image.PreserveAspectFit

            smooth: true
            mipmap: false
        }


        // Fallback for apps without an icon yet.
        Text {
            anchors.centerIn: parent

            visible:
                root.iconSource.toString() === ""

            text: root.glyph

            color: "white"

            font {
                pixelSize: 24
                weight: Font.DemiBold
            }
        }


        MouseArea {
            id: touch

            anchors.fill: parent

            onClicked: {
                const point =
                    icon.mapToItem(
                        null,
                        0,
                        0
                    )

                root.launched(
                    point.x,
                    point.y,
                    icon.width,
                    icon.height
                )
            }
        }
    }


    Text {
        anchors {
            top: icon.bottom
            topMargin: 8
            horizontalCenter: parent.horizontalCenter
        }

        text: root.title

        color: "#29292F"
        font.pixelSize: 12
    }
}
