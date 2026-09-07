import QtQuick

Item {
    id: root

    property var packages: []
    property string message: ""

    property bool canGoBack: false
    function goBack() {}


    function refresh() {
        packages =
            LumaSystem.listLpkPackages()
    }


    Component.onCompleted:
        refresh()


    Rectangle {
        anchors.fill: parent
        color: "#F4F4F7"
    }


    Text {
        anchors {
            top: parent.top
            topMargin: 26
            left: parent.left
            leftMargin: 18
        }

        text: "Luma Store"

        color: "#202026"

        font {
            pixelSize: 25
            weight: Font.DemiBold
        }
    }


    Text {
        anchors {
            top: parent.top
            topMargin: 61
            left: parent.left
            leftMargin: 18
        }

        text:
            "~/LumaMobile/packages"

        color: "#81818B"
        font.pixelSize: 11
    }


    Text {
        visible:
            root.packages.length === 0

        anchors.centerIn: parent

        text:
            "No .lpk packages found"

        color: "#85858F"
        font.pixelSize: 14
    }


    ListView {
        id: packageList

        anchors {
            top: parent.top
            topMargin: 92

            bottom: status.top
            bottomMargin: 10

            left: parent.left
            right: parent.right

            margins: 14
        }

        model:
            root.packages

        spacing: 9
        clip: true


        delegate: Rectangle {
            required property var modelData

            width:
                packageList.width

            height: 86

            radius: 24
            color: "white"


            Rectangle {
                width: 54
                height: 54

                anchors {
                    left: parent.left
                    leftMargin: 15
                    verticalCenter:
                        parent.verticalCenter
                }

                radius: 18
                color: "#675FDA"


                Text {
                    anchors.centerIn: parent

                    text: "L"

                    color: "white"

                    font {
                        pixelSize: 21
                        weight: Font.Bold
                    }
                }
            }


            Text {
                anchors {
                    left: parent.left
                    leftMargin: 84
                    right: install.left
                    rightMargin: 8
                    verticalCenter:
                        parent.verticalCenter
                }

                text:
                    modelData.name

                elide:
                    Text.ElideRight

                color: "#202026"

                font {
                    pixelSize: 14
                    weight: Font.DemiBold
                }
            }


            Rectangle {
                id: install

                width: 72
                height: 36

                anchors {
                    right: parent.right
                    rightMargin: 14
                    verticalCenter:
                        parent.verticalCenter
                }

                radius: 18
                color: "#625FE7"


                Text {
                    anchors.centerIn: parent

                    text: "Install"

                    color: "white"

                    font {
                        pixelSize: 11
                        weight: Font.DemiBold
                    }
                }


                MouseArea {
                    anchors.fill: parent

                    onClicked: {

                        const r =
                            LumaSystem.installLpk(
                                modelData.path
                            )

                        root.message =
                            r.message
                    }
                }
            }
        }
    }


    Text {
        id: status

        height: 48

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom

            leftMargin: 18
            rightMargin: 18
            bottomMargin: 10
        }

        text:
            root.message

        wrapMode:
            Text.WordWrap

        color: "#707079"
        font.pixelSize: 10
    }
}
