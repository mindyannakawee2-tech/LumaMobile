import QtQuick

Rectangle {
    id: root

    property string title: "Setting"
    property string subtitle: ""
    property string glyph: "L"

    property bool toggleable: false
    property bool toggled: false

    signal activated()

    width:
        parent
            ? parent.width
            : 360

    height:
        subtitle === ""
            ? 68
            : 78

    radius: 22

    color: "#FFFFFF"

    scale:
        pressArea.pressed
            ? 0.985
            : 1.0


    Behavior on scale {
        NumberAnimation {
            duration: 100
        }
    }


    Rectangle {
        id: icon

        width: 44
        height: 44

        anchors {
            left: parent.left
            leftMargin: 14
            verticalCenter: parent.verticalCenter
        }

        radius: 15

        color: "#EEEFFD"


        Text {
            anchors.centerIn: parent

            text: root.glyph

            color: "#625FE7"

            font {
                pixelSize: 17
                weight: Font.DemiBold
            }
        }
    }


    Column {
        anchors {
            left: icon.right
            leftMargin: 14

            right: action.left
            rightMargin: 8

            verticalCenter:
                parent.verticalCenter
        }

        spacing: 2


        Text {
            text: root.title

            color: "#202026"

            font {
                pixelSize: 15
                weight: Font.DemiBold
            }
        }


        Text {
            visible:
                root.subtitle !== ""

            text: root.subtitle

            color: "#7A7A84"

            font.pixelSize: 11
        }
    }


    Item {
        id: action

        width: 64
        height: parent.height

        anchors.right:
            parent.right


        Rectangle {
            visible:
                root.toggleable

            width: 48
            height: 29

            anchors.centerIn:
                parent

            radius: 15

            color:
                root.toggled
                    ? "#625FE7"
                    : "#D6D6DD"


            Behavior on color {
                ColorAnimation {
                    duration: 160
                }
            }


            Rectangle {
                width: 23
                height: 23

                y: 3

                x:
                    root.toggled
                        ? parent.width - width - 3
                        : 3

                radius:
                    width / 2

                color: "white"


                Behavior on x {
                    NumberAnimation {
                        duration: 180
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }


        Text {
            visible:
                !root.toggleable

            anchors.centerIn:
                parent

            text: ">"

            color: "#A3A3AB"

            font.pixelSize: 19
        }
    }


    MouseArea {
        id: pressArea

        anchors.fill: parent

        onClicked: {

            if (
                root.toggleable
            ) {
                root.toggled =
                    !root.toggled
            }

            root.activated()
        }
    }
}
