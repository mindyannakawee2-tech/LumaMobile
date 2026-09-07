import QtQuick
import QtQuick.Controls

Item {
    id: root

    property string currentPath:
        LumaSystem.homePath()

    property var history: []
    property var entries: []

    property bool canGoBack:
        history.length > 0

    property string message: ""


    function refresh() {
        entries =
            LumaSystem.listDirectory(
                currentPath
            )
    }


    function enter(path) {
        history =
            history.concat(
                [currentPath]
            )

        currentPath = path

        refresh()
    }


    function goBack() {
        if (history.length === 0)
            return

        currentPath =
            history[
                history.length - 1
            ]

        history =
            history.slice(
                0,
                history.length - 1
            )

        refresh()
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
            topMargin: 24
            left: parent.left
            leftMargin: 18
        }

        text: "Files"

        color: "#202026"

        font {
            pixelSize: 25
            weight: Font.DemiBold
        }
    }


    Text {
        anchors {
            top: parent.top
            topMargin: 57
            left: parent.left
            right: parent.right

            leftMargin: 18
            rightMargin: 18
        }

        text: root.currentPath

        elide: Text.ElideMiddle

        color: "#7C7C86"
        font.pixelSize: 11
    }


    Row {
        anchors {
            top: parent.top
            topMargin: 82

            left: parent.left
            right: parent.right

            leftMargin: 16
            rightMargin: 16
        }

        spacing: 8


        Rectangle {
            width: 92
            height: 38
            radius: 17
            color: "#FFFFFF"

            Text {
                anchors.centerIn: parent

                text: "Home"

                color: "#202026"
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.history = []
                    root.currentPath =
                        LumaSystem.homePath()

                    root.refresh()
                }
            }
        }


        Rectangle {
            width: 105
            height: 38
            radius: 17
            color: "#FFFFFF"

            Text {
                anchors.centerIn: parent

                text: "Downloads"

                color: "#202026"
                font.pixelSize: 12
            }

            MouseArea {
                anchors.fill: parent

                onClicked:
                    root.enter(
                        LumaSystem.downloadsPath()
                    )
            }
        }


        TextField {
            id: folderName

            width: 120
            height: 38

            placeholderText:
                "New folder"
        }


        Rectangle {
            width: 42
            height: 38
            radius: 17
            color: "#625FE7"

            Text {
                anchors.centerIn: parent

                text: "+"

                color: "white"
                font.pixelSize: 21
            }

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    const r =
                        LumaSystem.createFolder(
                            root.currentPath,
                            folderName.text
                        )

                    root.message =
                        r.message

                    if (r.ok)
                        folderName.text = ""

                    root.refresh()
                }
            }
        }
    }


    ListView {
        id: fileList

        anchors {
            top: parent.top
            topMargin: 136

            bottom: status.top
            bottomMargin: 8

            left: parent.left
            right: parent.right

            margins: 14
        }

        spacing: 8
        clip: true

        model:
            root.entries


        delegate: Rectangle {
            required property var modelData

            width:
                fileList.width

            height: 70

            radius: 21
            color: "#FFFFFF"


            Rectangle {
                width: 44
                height: 44

                anchors {
                    left: parent.left
                    leftMargin: 13
                    verticalCenter:
                        parent.verticalCenter
                }

                radius: 14

                color:
                    modelData.isDir
                        ? "#EEEFFD"
                        : "#F1F1F4"


                Text {
                    anchors.centerIn: parent

                    text:
                        modelData.isDir
                            ? "F"
                            : "•"

                    color:
                        modelData.isDir
                            ? "#625FE7"
                            : "#6C6C76"

                    font {
                        pixelSize: 16
                        weight: Font.DemiBold
                    }
                }
            }


            Column {
                anchors {
                    left: parent.left
                    leftMargin: 70
                    right: parent.right
                    rightMargin: 15
                    verticalCenter:
                        parent.verticalCenter
                }

                spacing: 2


                Text {
                    width: parent.width

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


                Text {
                    text:
                        modelData.isDir
                            ? "Folder"
                            : modelData.suffix.toUpperCase()

                    color: "#85858F"
                    font.pixelSize: 10
                }
            }


            MouseArea {
                anchors.fill: parent

                onClicked: {
                    if (modelData.isDir) {

                        root.enter(
                            modelData.path
                        )

                    } else {

                        const ok =
                            LumaSystem.openPath(
                                modelData.path
                            )

                        root.message =
                            ok
                                ? "Opened " + modelData.name
                                : "Could not open file"
                    }
                }
            }
        }
    }


    Text {
        id: status

        height: 35

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right

            leftMargin: 18
            rightMargin: 18
            bottomMargin: 12
        }

        text:
            root.message

        color: "#707079"
        font.pixelSize: 11
    }
}
