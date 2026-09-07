import QtQuick

Item {
    id: root

    property string appTitle:
        "Luma App"

    property string appGlyph:
        "L"

    property color accent:
        "#625FE7"


    Rectangle {
        anchors.fill: parent

        color: "#F3F3F7"
    }


    Rectangle {
        width: parent.width
        height: 250

        color: root.accent


        Rectangle {
            width: 82
            height: 82

            anchors {
                left: parent.left
                leftMargin: 28
                bottom: parent.bottom
                bottomMargin: 30
            }

            radius: 27

            color: "#28FFFFFF"


            Text {
                anchors.centerIn:
                    parent

                text:
                    root.appGlyph

                color: "white"

                font {
                    pixelSize: 34
                    weight: Font.Bold
                }
            }
        }


        Text {
            anchors {
                left: parent.left
                leftMargin: 126
                bottom: parent.bottom
                bottomMargin: 62
            }

            text:
                root.appTitle

            color: "white"

            font {
                pixelSize: 27
                weight: Font.DemiBold
            }
        }


        Text {
            anchors {
                left: parent.left
                leftMargin: 126
                bottom: parent.bottom
                bottomMargin: 39
            }

            text:
                "Luma Native App"

            color: "#DFFFFFFF"

            font.pixelSize: 13
        }
    }


    Column {
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            topMargin: 285
            margins: 22
        }

        spacing: 16


        Rectangle {
            width: parent.width
            height: 110

            radius: 28

            color: "white"


            Column {
                anchors {
                    fill: parent
                    margins: 20
                }

                spacing: 8


                Text {
                    text:
                        "Welcome to " +
                        root.appTitle

                    color: "#202026"

                    font {
                        pixelSize: 18
                        weight: Font.DemiBold
                    }
                }


                Text {
                    text:
                        "This app is running inside the Luma App Surface."

                    width:
                        parent.width

                    wrapMode:
                        Text.WordWrap

                    color: "#777781"

                    font.pixelSize: 13
                }
            }
        }


        Rectangle {
            width: parent.width
            height: 105

            radius: 28

            color: "white"


            Column {
                anchors {
                    fill: parent
                    margins: 20
                }

                spacing: 6


                Text {
                    text:
                        "Gesture Navigation"

                    color: "#202026"

                    font {
                        pixelSize: 16
                        weight: Font.DemiBold
                    }
                }


                Text {
                    text:
                        "Swipe from the left edge to go back."

                    color: "#777781"

                    font.pixelSize: 12
                }


                Text {
                    text:
                        "Swipe up from the bottom to go Home."

                    color: "#777781"

                    font.pixelSize: 12
                }
            }
        }
    }
}
