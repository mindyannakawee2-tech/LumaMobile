import QtQuick

Rectangle {
    id: root

    property string title: "Toggle"
    property string subtitle: ""
    property string glyph: "L"

    property bool active: false

    signal toggled(bool state)

    width: 158
    height: 78

    radius: 23

    color:
        active
            ? "#625FE7"
            : "#ECECF2"


    Behavior on color {
        ColorAnimation {
            duration: 180
        }
    }


    Row {
        anchors {
            fill: parent
            margins: 14
        }

        spacing: 11


        Rectangle {
            width: 46
            height: 46

            anchors.verticalCenter:
                parent.verticalCenter

            radius: 16

            color:
                root.active
                    ? "#30FFFFFF"
                    : "#FFFFFF"


            Text {
                anchors.centerIn: parent

                text: root.glyph

                color:
                    root.active
                        ? "white"
                        : "#3E3E45"

                font {
                    pixelSize: 17
                    weight: Font.DemiBold
                }
            }
        }


        Column {
            anchors.verticalCenter:
                parent.verticalCenter

            spacing: 2


            Text {
                text: root.title

                color:
                    root.active
                        ? "white"
                        : "#202026"

                font {
                    pixelSize: 13
                    weight: Font.DemiBold
                }
            }


            Text {
                text: root.subtitle

                color:
                    root.active
                        ? "#D0FFFFFF"
                        : "#767680"

                font.pixelSize: 10
            }
        }
    }


    MouseArea {
        anchors.fill: parent

        onClicked: {
            root.active =
                !root.active

            root.toggled(
                root.active
            )
        }
    }
}
