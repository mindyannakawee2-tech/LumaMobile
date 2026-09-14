import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    height: 340

    signal closeRequested()

    property int languageIndex: 0
    property bool symbols: false
    property bool shifted: false

    property var languages: [
        {
            code: "EN",
            name: "English",
            rows: [
                ["q","w","e","r","t","y","u","i","o","p"],
                ["a","s","d","f","g","h","j","k","l"],
                ["z","x","c","v","b","n","m"]
            ]
        },
        {
            code: "TH",
            name: "ไทย",
            rows: [
                ["ๆ","ไ","ำ","พ","ะ","ั","ี","ร","น","ย","บ","ล"],
                ["ฟ","ห","ก","ด","เ","้","่","า","ส","ว","ง"],
                ["ผ","ป","แ","อ","ิ","ื","ท","ม","ใ","ฝ"]
            ]
        },
        {
            code: "ES",
            name: "Español",
            rows: [
                ["q","w","e","r","t","y","u","i","o","p"],
                ["a","s","d","f","g","h","j","k","l","ñ"],
                ["z","x","c","v","b","n","m"]
            ]
        },
        {
            code: "FR",
            name: "Français",
            rows: [
                ["a","z","e","r","t","y","u","i","o","p"],
                ["q","s","d","f","g","h","j","k","l","m"],
                ["w","x","c","v","b","n","é","è","à","ç"]
            ]
        },
        {
            code: "DE",
            name: "Deutsch",
            rows: [
                ["q","w","e","r","t","z","u","i","o","p"],
                ["a","s","d","f","g","h","j","k","l","ö","ä"],
                ["y","x","c","v","b","n","m","ü","ß"]
            ]
        },
        {
            code: "IT",
            name: "Italiano",
            rows: [
                ["q","w","e","r","t","y","u","i","o","p"],
                ["a","s","d","f","g","h","j","k","l"],
                ["z","x","c","v","b","n","m","à","è"]
            ]
        },
        {
            code: "PT",
            name: "Português",
            rows: [
                ["q","w","e","r","t","y","u","i","o","p"],
                ["a","s","d","f","g","h","j","k","l","ç"],
                ["z","x","c","v","b","n","m","ã","õ"]
            ]
        },
        {
            code: "RU",
            name: "Русский",
            rows: [
                ["й","ц","у","к","е","н","г","ш","щ","з","х"],
                ["ф","ы","в","а","п","р","о","л","д","ж","э"],
                ["я","ч","с","м","и","т","ь","б","ю"]
            ]
        },
        {
            code: "EL",
            name: "Ελληνικά",
            rows: [
                ["ς","ε","ρ","τ","υ","θ","ι","ο","π"],
                ["α","σ","δ","φ","γ","η","ξ","κ","λ"],
                ["ζ","χ","ψ","ω","β","ν","μ"]
            ]
        },
        {
            code: "AR",
            name: "العربية",
            rows: [
                ["ض","ص","ث","ق","ف","غ","ع","ه","خ","ح"],
                ["ش","س","ي","ب","ل","ا","ت","ن","م","ك"],
                ["ئ","ء","ؤ","ر","ى","ة","و","ز","ظ"]
            ]
        },
        {
            code: "HE",
            name: "עברית",
            rows: [
                ["ק","ר","א","ט","ו","ן","ם","פ"],
                ["ש","ד","ג","כ","ע","י","ח","ל","ך"],
                ["ז","ס","ב","ה","נ","מ","צ","ת","ץ"]
            ]
        }
    ]

    property var symbolRows: [
        ["1","2","3","4","5","6","7","8","9","0"],
        ["@","#","฿","%","&","*","-","+","="],
        [".",",","?","!","'","\"",":",";","/"]
    ]


    property var thaiNormalRows: [
        ["ๅ","/","-","ภ","ถ","ุ","ึ","ค","ต","จ","ข","ช"],
        ["ๆ","ไ","ำ","พ","ะ","ั","ี","ร","น","ย","บ","ล"],
        ["ฟ","ห","ก","ด","เ","้","่","า","ส","ว","ง","ฅ"],
        ["ผ","ป","แ","อ","ิ","ื","ท","ม","ใ","ฝ"]
    ]

    property var thaiShiftRows: [
        ["+","๑","๒","๓","๔","ู","฿","๕","๖","๗","๘","๙"],
        ["๐","\"","ฎ","ฑ","ธ","ํ","๊","ณ","ฯ","ญ","ฐ",","],
        ["ฤ","ฆ","ฏ","โ","ฌ","็","๋","ษ","ศ","ซ",".","ฃ"],
        ["(",")","ฉ","ฮ","ฺ","์","?","ฒ","ฬ","ฦ"]
    ]

    property var currentLanguage: languages[languageIndex]

    function previousLanguage() {
        languageIndex--

        if (languageIndex < 0)
            languageIndex = languages.length - 1

        symbols = false
        shifted = false
    }

    function nextLanguage() {
        languageIndex++

        if (languageIndex >= languages.length)
            languageIndex = 0

        symbols = false
        shifted = false
    }

    function currentRows() {

        if (symbols)
            return symbolRows

        if (currentLanguage.code === "TH") {
            if (shifted)
                return thaiShiftRows

            return thaiNormalRows
        }

        return currentLanguage.rows
    }


    function displayKey(value) {

        var combining = [
            "ั",
            "ิ",
            "ี",
            "ึ",
            "ื",
            "ุ",
            "ู",
            "ฺ",
            "็",
            "่",
            "้",
            "๊",
            "๋",
            "์",
            "ํ"
        ]

        if (combining.indexOf(value) >= 0)
            return "◌" + value

        return value
    }


function sendText(value) {
        if (shifted &&
            currentLanguage.code === "EN") {
            value = value.toUpperCase()
            shifted = false
        }

        LumaInput.typeText(value)
    }


    Rectangle {
        anchors.fill: parent
        radius: 20
        color: "#F21C2027"
        border.color: "#35FFFFFF"
    }


    Column {
        anchors.fill: parent
        anchors.margins: 7
        spacing: 5


        // ----------------------------------------------------
        // ALWAYS VISIBLE LANGUAGE SELECTOR
        // ----------------------------------------------------

        Rectangle {
            width: parent.width
            height: 38
            radius: 10
            color: "#343943"

            Row {
                anchors.fill: parent

                Rectangle {
                    width: 50
                    height: parent.height
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "‹"
                        color: "white"
                        font.pixelSize: 27
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.previousLanguage()
                    }
                }

                Text {
                    width: parent.width - 100
                    height: parent.height

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    text:
                        root.currentLanguage.name +
                        "  (" +
                        root.currentLanguage.code +
                        ")"

                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                }

                Rectangle {
                    width: 50
                    height: parent.height
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "›"
                        color: "white"
                        font.pixelSize: 27
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.nextLanguage()
                    }
                }
            }
        }


        // ----------------------------------------------------
        // KEY ROWS
        // ----------------------------------------------------

        Repeater {
            model: root.currentRows()

            delegate: Row {
                required property var modelData

                width: parent.width
                height:
                    root.currentLanguage.code === "TH" && root.symbols === false
                    ? 51
                    : 63
                spacing: 4

                property var keys: modelData

                Repeater {
                    model: parent.keys

                    delegate: Rectangle {
                        required property string modelData

                        width:
                            (parent.width -
                             ((parent.keys.length - 1) * parent.spacing))
                             / parent.keys.length

                        height: parent.height

                        radius: 8
                        color: keyMouse.pressed
                               ? "#666D79"
                               : "#3A404A"

                        Text {
                            anchors.centerIn: parent
                            text: root.displayKey(modelData)
                            color: "white"
                            font.pixelSize: 17
                        }

                        MouseArea {
                            id: keyMouse
                            anchors.fill: parent

                            onClicked:
                                root.sendText(parent.modelData)
                        }
                    }
                }
            }
        }


        // ----------------------------------------------------
        // CONTROL ROW
        // ----------------------------------------------------

        Row {
            width: parent.width
            height: 47
            spacing: 4

            Rectangle {
                width: 52
                height: parent.height
                radius: 8
                color: "#444A55"

                Text {
                    anchors.centerIn: parent
                    text: root.symbols ? "ABC" : "123"
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        root.symbols = !root.symbols
                }
            }


            Rectangle {
                width: 48
                height: parent.height
                radius: 8
                color: "#444A55"

                Text {
                    anchors.centerIn: parent
                    text: "⇧"
                    color: "white"
                    font.pixelSize: 20
                }

                MouseArea {
                    anchors.fill: parent

                    onClicked:
                        root.shifted = !root.shifted
                }
            }


            Rectangle {
                width:
                    parent.width -
                    52 - 48 - 48 - 48 - 43 -
                    (parent.spacing * 4)

                height: parent.height

                radius: 8
                color: "#444A55"

                Text {
                    anchors.centerIn: parent
                    text: "space"
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: LumaInput.typeText(" ")
                }
            }


            Rectangle {
                width: 48
                height: parent.height
                radius: 8
                color: "#444A55"

                Text {
                    anchors.centerIn: parent
                    text: "⌫"
                    color: "white"
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: LumaInput.backspace()
                }
            }


            Rectangle {
                width: 48
                height: parent.height
                radius: 8
                color: "#444A55"

                Text {
                    anchors.centerIn: parent
                    text: "↵"
                    color: "white"
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: LumaInput.enter()
                }
            }


            Rectangle {
                width: 43
                height: parent.height
                radius: 8
                color: "#444A55"

                Text {
                    anchors.centerIn: parent
                    text: "⌄"
                    color: "white"
                    font.pixelSize: 18
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.closeRequested()
                }
            }
        }
    }
}
