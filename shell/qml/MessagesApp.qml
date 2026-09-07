import QtQuick
import QtQuick.Controls

Item {
    id: root

    property bool canGoBack: false
    function goBack() {}

    property string resultText:
        LumaSystem.cellularAvailable()
            ? "Cellular ready"
            : "No cellular modem"


    Rectangle {
        anchors.fill: parent
        color: "#F4F4F7"
    }


    Text {
        anchors {
            top: parent.top
            topMargin: 27
            horizontalCenter:
                parent.horizontalCenter
        }

        text: "Messages"

        color: "#202026"

        font {
            pixelSize: 21
            weight: Font.DemiBold
        }
    }


    Column {
        width: parent.width - 32

        anchors {
            top: parent.top
            topMargin: 90
            horizontalCenter:
                parent.horizontalCenter
        }

        spacing: 12


        TextField {
            id: number

            width: parent.width

            placeholderText:
                "Phone number"
        }


        TextArea {
            id: message

            width: parent.width
            height: 180

            placeholderText:
                "Message"

            wrapMode:
                TextEdit.Wrap
        }


        Rectangle {
            width: parent.width
            height: 54
            radius: 22
            color: "#625FE7"


            Text {
                anchors.centerIn: parent

                text: "Send SMS"

                color: "white"

                font {
                    pixelSize: 14
                    weight: Font.DemiBold
                }
            }


            MouseArea {
                anchors.fill: parent

                onClicked: {

                    const r =
                        LumaSystem.sendSms(
                            number.text,
                            message.text
                        )

                    root.resultText =
                        r.message

                    if (r.ok)
                        message.text = ""
                }
            }
        }


        Text {
            width: parent.width

            text:
                root.resultText

            wrapMode:
                Text.WordWrap

            color: "#777781"
            font.pixelSize: 12
        }
    }
}
