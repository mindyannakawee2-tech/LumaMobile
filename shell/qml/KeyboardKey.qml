import QtQuick


Rectangle {

    id: root


    property string label: ""

    property color keyColor:
        "#36363F"

    property color textColor:
        "#FFFFFF"


    signal activated()


    height: 46

    radius: 11


    color:
        mouse.pressed
            ? Qt.lighter(
                root.keyColor,
                1.24
            )
            : root.keyColor


    Text {

        anchors.centerIn:
            parent

        text:
            root.label

        color:
            root.textColor


        font {
            pixelSize: 16
            weight: Font.Medium
        }
    }


    MouseArea {

        id: mouse

        anchors.fill:
            parent

        preventStealing: true


        onClicked:
            root.activated()
    }
}
