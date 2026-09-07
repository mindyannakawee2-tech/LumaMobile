import QtQuick

Item {
    id: root

    property string number: ""
    property string status:
        LumaSystem.cellularAvailable()
            ? "Cellular ready"
            : "No cellular modem"

    property bool calling: false
    property bool canGoBack: false

    function goBack() {}


    Rectangle {
        anchors.fill: parent
        color: "#F4F4F7"
    }


    Column {
        width: parent.width - 40

        anchors {
            top: parent.top
            topMargin: 52
            horizontalCenter:
                parent.horizontalCenter
        }

        spacing: 18


        Text {
            anchors.horizontalCenter:
                parent.horizontalCenter

            text: "Phone"

            color: "#202026"

            font {
                pixelSize: 24
                weight: Font.DemiBold
            }
        }


        Text {
            width: parent.width
            height: 48

            horizontalAlignment:
                Text.AlignHCenter

            verticalAlignment:
                Text.AlignVCenter

            text:
                root.number === ""
                    ? "Enter a number"
                    : root.number

            color:
                root.number === ""
                    ? "#9999A2"
                    : "#202026"

            font.pixelSize: 28
        }


        Text {
            width: parent.width

            horizontalAlignment:
                Text.AlignHCenter

            text: root.status

            color: "#777781"
            font.pixelSize: 12
        }


        Grid {
            anchors.horizontalCenter:
                parent.horizontalCenter

            columns: 3
            spacing: 14


            Repeater {
                model: [
                    "1", "2", "3",
                    "4", "5", "6",
                    "7", "8", "9",
                    "*", "0", "#"
                ]


                Rectangle {
                    width: 78
                    height: 78
                    radius: 39

                    color:
                        key.pressed
                            ? "#DDDEE4"
                            : "#FFFFFF"


                    Text {
                        anchors.centerIn: parent

                        text: modelData

                        color: "#202026"
                        font.pixelSize: 27
                    }


                    MouseArea {
                        id: key

                        anchors.fill: parent

                        enabled:
                            !root.calling

                        onClicked:
                            root.number +=
                                modelData
                    }
                }
            }
        }


        Row {
            anchors.horizontalCenter:
                parent.horizontalCenter

            spacing: 18


            Rectangle {
                width: 76
                height: 76
                radius: 38

                color:
                    root.calling
                        ? "#EF5D55"
                        : "#4DBD73"


                Text {
                    anchors.centerIn: parent

                    text:
                        root.calling
                            ? "End"
                            : "Call"

                    color: "white"

                    font {
                        pixelSize: 14
                        weight: Font.DemiBold
                    }
                }


                MouseArea {
                    anchors.fill: parent

                    onClicked: {

                        if (root.calling) {

                            const r =
                                LumaSystem.hangupCall()

                            root.status =
                                r.message

                            if (r.ok)
                                root.calling = false

                            return
                        }


                        if (
                            root.number === ""
                        )
                            return


                        const r =
                            LumaSystem.dial(
                                root.number
                            )

                        root.status =
                            r.message

                        root.calling =
                            r.ok
                    }
                }
            }


            Rectangle {
                width: 76
                height: 76
                radius: 38
                color: "#E2E2E8"


                Text {
                    anchors.centerIn: parent

                    text: "⌫"

                    color: "#202026"
                    font.pixelSize: 22
                }


                MouseArea {
                    anchors.fill: parent

                    enabled:
                        !root.calling

                    onClicked: {
                        if (
                            root.number.length > 0
                        ) {
                            root.number =
                                root.number.slice(
                                    0,
                                    -1
                                )
                        }
                    }
                }
            }
        }
    }
}
