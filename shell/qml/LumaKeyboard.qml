import QtQuick


Item {

    id: root


    property bool shifted: false
    property bool symbols: false


    height: 306


    function character(value) {

        let output =
            value


        if (
            root.shifted &&
            !root.symbols
        ) {
            output =
                value.toUpperCase()
        }


        LumaInput.typeText(
            output
        )


        if (
            root.shifted &&
            !root.symbols
        ) {
            root.shifted =
                false
        }
    }


    Rectangle {

        anchors.fill:
            parent

        radius: 24

        color:
            "#F4212128"

        border.width: 1

        border.color:
            "#30FFFFFF"
    }


    Column {

        anchors {
            fill: parent
            margins: 8
        }

        spacing: 5



        Row {

            width: parent.width
            height: 38

            spacing: 5


            Repeater {

                model:
                    root.symbols
                        ? [
                            "!", "@", "#", "$", "%",
                            "^", "&", "*", "(", ")"
                        ]
                        : [
                            "1", "2", "3", "4", "5",
                            "6", "7", "8", "9", "0"
                        ]


                KeyboardKey {

                    width:
                        (
                            parent.width -
                            45
                        ) / 10

                    height:
                        parent.height

                    label:
                        modelData


                    onActivated:
                        root.character(
                            modelData
                        )
                }
            }
        }


        Row {

            width: parent.width

            spacing: 5


            Repeater {

                model:
                    root.symbols
                        ? [
                            "+", "-", "=", "_", "/",
                            "\\", "[", "]", "{", "}"
                        ]
                        : [
                            "q", "w", "e", "r", "t",
                            "y", "u", "i", "o", "p"
                        ]


                KeyboardKey {

                    width:
                        (
                            parent.width -
                            45
                        ) / 10

                    label:
                        (
                            root.shifted &&
                            !root.symbols
                        )
                            ? modelData.toUpperCase()
                            : modelData


                    onActivated:
                        root.character(
                            modelData
                        )
                }
            }
        }


        Row {

            width: parent.width

            spacing: 5


            Item {
                width: 15
                height: 46
            }


            Repeater {

                model:
                    root.symbols
                        ? [
                            ":", ";", "\"", "'",
                            "<", ">", "?", "|", "~"
                        ]
                        : [
                            "a", "s", "d", "f", "g",
                            "h", "j", "k", "l"
                        ]


                KeyboardKey {

                    width:
                        (
                            parent.width -
                            70
                        ) / 9

                    label:
                        (
                            root.shifted &&
                            !root.symbols
                        )
                            ? modelData.toUpperCase()
                            : modelData


                    onActivated:
                        root.character(
                            modelData
                        )
                }
            }


            Item {
                width: 15
                height: 46
            }
        }


        Row {

            width: parent.width

            spacing: 5


            KeyboardKey {

                width: 48

                label:
                    root.shifted
                        ? "⇧"
                        : "↑"

                keyColor:
                    root.shifted
                        ? "#625FE7"
                        : "#474751"


                onActivated:
                    root.shifted =
                        !root.shifted
            }


            Repeater {

                model:
                    root.symbols
                        ? [
                            "`", "€", "£", "¥",
                            "•", "°", ","
                        ]
                        : [
                            "z", "x", "c", "v",
                            "b", "n", "m"
                        ]


                KeyboardKey {

                    width:
                        (
                            parent.width -
                            48 -
                            54 -
                            40
                        ) / 7

                    label:
                        (
                            root.shifted &&
                            !root.symbols
                        )
                            ? modelData.toUpperCase()
                            : modelData


                    onActivated:
                        root.character(
                            modelData
                        )
                }
            }


            KeyboardKey {

                width: 54

                label: "⌫"

                keyColor:
                    "#474751"


                onActivated:
                    LumaInput.backspace()
            }
        }


        Row {

            width: parent.width

            spacing: 5


            KeyboardKey {

                width: 55

                label:
                    root.symbols
                        ? "ABC"
                        : "?123"

                keyColor:
                    "#474751"


                onActivated: {

                    root.symbols =
                        !root.symbols

                    root.shifted =
                        false
                }
            }


            KeyboardKey {

                width: 39

                label: "←"

                keyColor:
                    "#474751"


                onActivated:
                    LumaInput.left()
            }


            KeyboardKey {

                width:
                    parent.width -
                    55 -
                    39 -
                    39 -
                    65 -
                    20

                label: "space"

                keyColor:
                    "#FAFAFB"

                textColor:
                    "#24242B"


                onActivated:
                    LumaInput.typeText(
                        " "
                    )
            }


            KeyboardKey {

                width: 39

                label: "→"

                keyColor:
                    "#474751"


                onActivated:
                    LumaInput.right()
            }


            KeyboardKey {

                width: 65

                label: "enter"

                keyColor:
                    "#625FE7"


                onActivated:
                    LumaInput.enter()
            }
        }


        Rectangle {

            width: 90
            height: 18

            anchors.horizontalCenter:
                parent.horizontalCenter

            radius: 9

            color:
                closeMouse.pressed
                    ? "#40FFFFFF"
                    : "transparent"


            Text {

                anchors.centerIn:
                    parent

                text: "⌄"

                color:
                    "#D0FFFFFF"

                font.pixelSize: 18
            }


            MouseArea {

                id: closeMouse

                anchors.fill:
                    parent


                onClicked:
                    LumaInput.hide()
            }
        }

    }
}
