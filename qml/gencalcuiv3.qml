import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Rectangle {
    id: root
    width: 1024
    height: 559
    color: "#eef0f2"

    property var geneNames: ["A", "B", "C", "D", "E"]
    property var outcomeColumns: ["Genotype", "Frequency (%)", "Count (Expected)"]
    property var phenotypeColumns: ["Phenotype", "Frequency (%)"]


    // one on/off value per gene. Gene A is always on, B-E start off
    // Clear sets it back to  default
    readonly property var defaultToggles: [true, false, false, false, false]
    property var geneToggles: [true, false, false, false, false]

    //gene is usable only if its own toggle and every toggle before it are on
    property var activeGenes: {
        var result = []
        var allPreviousOn = true
        for (var i = 0; i < geneNames.length; i++) {
            allPreviousOn = allPreviousOn && geneToggles[i] === true
            result.push(allPreviousOn)
        }
        return result
    }

    //Results
    property var genotypeData: []
    property var phenotypeData: []
    property string messageText: ""
    property bool messageIsError: false

    function setGeneToggle(i, checked) {
        if (i === 0)
            return
        var t = geneToggles.slice()
        t[i] = checked
        if (!checked) {
            for (var j = i + 1; j < t.length; j++)
                t[j] = false
        }
        geneToggles = t
    }

    function collectGenotypes(repeater) {
        var out = []
        for (var i = 0; i < repeater.count; i++)
            out.push(repeater.itemAt(i).genotype)
        return out
    }

    function showMessage(text, isError) {
        messageText = text
        messageIsError = isError
    }

    function calculateCross() {
        showMessage("", false)
        if (typeof backend === "undefined") {
            showMessage("Backend not connected. Run the app through main.py.", true)
            return
        }
        backend.calculate(collectGenotypes(p1Repeater), collectGenotypes(p2Repeater), geneNames)
    }

    function clearAll() {
        geneToggles = defaultToggles.slice()
        for (var i = 0; i < p1Repeater.count; i++)
            p1Repeater.itemAt(i).reset()
        for (var j = 0; j < p2Repeater.count; j++)
            p2Repeater.itemAt(j).reset()
        genotypeData = []
        phenotypeData = []
        showMessage("", false)
        if (typeof backend !== "undefined")
            backend.clear()
    }

    function exportCsv() {
        if (genotypeData.length === 0) {
            showMessage("Nothing to export yet. Run Calculate Cross first.", true)
            return
        }
        showMessage("", false)
        exportDialog.open()
    }

    Connections {
        target: typeof backend !== "undefined" ? backend : null

        function onResultsReady(genotypeRows, phenotypeRows) {
            root.genotypeData = genotypeRows
            root.phenotypeData = phenotypeRows
            root.showMessage("", false)
        }
        function onErrorOccurred(message) {
            root.showMessage(message, true)
        }
        function onExportFinished(path) {
            root.showMessage("Saved: " + path, false)
        }
    }

    FileDialog {
        id: exportDialog
        title: "Export results to CSV"
        fileMode: FileDialog.SaveFile
        nameFilters: ["CSV files (*.csv)"]
        defaultSuffix: "csv"
        onAccepted: backend.exportCsv(selectedFile.toString())
    }

    Rectangle {
        id: titleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 26
        color: "#ffffff"
        border.color: "#d8dadd"

        Text {
            anchors.centerIn: parent
            text: "Genetic Cross Calculator V0.2"
            font.pixelSize: 11
            color: "#777777"
        }
    }

    RowLayout {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        spacing: 8

        Rectangle {
            id: parentInputsPanel
            Layout.preferredWidth: 480
            Layout.fillHeight: true
            color: "#ffffff"
            radius: 3
            border.color: "#d8dadd"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 6

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Parent Inputs"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#333333"
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e3e5e8"
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ColumnLayout {
                            width: parentInputsPanel.width / 2 - 24
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true
                                height: 22
                                radius: 3
                                color: "#f4f5f7"
                                border.color: "#e0e2e5"
                                Text {
                                    anchors.centerIn: parent
                                    text: "Parent 1"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#555555"
                                }
                            }

                            Repeater {
                                id: p1Repeater
                                model: root.geneNames
                                delegate: GeneInputGroupv3 {
                                    Layout.fillWidth: true
                                    geneLabel: "Gene " + modelData
                                    geneLetter: modelData
                                    showInfoIcon: index === 0
                                    showRecombination: true

                                    showToggle: index > 0
                                    toggleChecked: root.geneToggles[index]
                                    toggleAvailable: index === 0 || root.activeGenes[index - 1]
                                    geneEnabled: root.activeGenes[index]
                                    onToggleRequested: function(checked) {
                                        root.setGeneToggle(index, checked)
                                    }
                                }
                            }
                        }
                    }

                    //Parent 2 column
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        ColumnLayout {
                            width: parentInputsPanel.width / 2 - 24
                            spacing: 4

                            Rectangle {
                                Layout.fillWidth: true
                                height: 22
                                radius: 3
                                color: "#f4f5f7"
                                border.color: "#e0e2e5"
                                Text {
                                    anchors.centerIn: parent
                                    text: "Parent 2"
                                    font.pixelSize: 11
                                    font.bold: true
                                    color: "#555555"
                                }
                            }

                            Repeater {
                                id: p2Repeater
                                model: root.geneNames
                                delegate: GeneInputGroupv3 {
                                    Layout.fillWidth: true
                                    geneLabel: "Gene " + modelData
                                    geneLetter: modelData
                                    showInfoIcon: index === 0
                                    showRecombination: true


                                    geneEnabled: root.activeGenes[index]
                                }
                            }
                        }
                    }
                }

                // Error / status line
                Text {
                    Layout.fillWidth: true
                    visible: root.messageText !== ""
                    text: root.messageText
                    wrapMode: Text.WordWrap
                    font.pixelSize: 10
                    color: root.messageIsError ? "#c0392b" : "#2e7d32"
                }

                //Button row: Clear | Calculate Cross  | Export to CSV
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4

                    Button {
                        text: "Clear"
                        Layout.preferredWidth: 110
                        onClicked: root.clearAll()
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Calculate Cross"
                        highlighted: true
                        Layout.preferredWidth: 160
                        onClicked: root.calculateCross()
                    }

                    Item { Layout.fillWidth: true }

                    Button {
                        text: "Export to CSV"
                        Layout.preferredWidth: 110
                        onClicked: root.exportCsv()
                    }
                }

                // Placeholders for future buttons? no function yet
                // RowLayout {
                //     Layout.fillWidth: true
                //
                //     Button {
                //         text: "Punnett Square"
                //         // onClicked: (not implemented)
                //     }
                //     Button {
                //         text: "Recombination Map"
                //         // onClicked: (not implemented)
                //     }
                // }
            }
        }

        //Calculation Results
        Rectangle {
            id: resultsPanel
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#ffffff"
            radius: 3
            border.color: "#d8dadd"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: "Calculation Results"
                        font.pixelSize: 13
                        font.bold: true
                        color: "#333333"
                    }
                    Item {
                        Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: "#e3e5e8"
                }

                //Genotypic Outcomes
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 1
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "Genotypic Outcomes"
                            font.pixelSize: 12
                            font.bold: true
                            color: "#333333"
                        }
                        Item {
                            Layout.fillWidth: true
                        }
                        Text {
                            text: "\u24D8"
                            font.pixelSize: 11
                            color: "#9aa0a6"
                        }
                    }

                    // Table header
                    Rectangle {
                        Layout.fillWidth: true
                        height: 24
                        color: "#f4f5f7"
                        border.color: "#e3e5e8"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            Repeater {
                                model: root.outcomeColumns
                                delegate: Text {
                                    text: modelData
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#555555"
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                }
                            }
                        }
                    }

                    // Table body
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#ffffff"
                        border.color: "#e3e5e8"
                        clip: true

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 1
                            clip: true
                            model: root.genotypeData
                            ScrollBar.vertical: ScrollBar {}
                            delegate: RowLayout {
                                width: ListView.view.width
                                height: 22
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.leftMargin: 6
                                    text: modelData.genotype
                                    font.pixelSize: 10
                                    color: "#333333"
                                }
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    text: modelData.percent
                                    font.pixelSize: 10
                                    color: "#333333"
                                }
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.rightMargin: 6
                                    text: modelData.count
                                    font.pixelSize: 10
                                    color: "#333333"
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.genotypeData.length === 0
                            text: "No data"
                            font.pixelSize: 10
                            color: "#bbbbbb"
                        }
                    }
                }

                // --- Phenotypic Outcomes ---
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: 1
                    spacing: 4

                    Text {
                        text: "Phenotypic Outcomes"
                        font.pixelSize: 12
                        font.bold: true
                        color: "#333333"
                    }

                    // Table header
                    Rectangle {
                        Layout.fillWidth: true
                        height: 24
                        color: "#f4f5f7"
                        border.color: "#e3e5e8"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            Repeater {
                                model: root.phenotypeColumns
                                delegate: Text {
                                    text: modelData
                                    font.pixelSize: 10
                                    font.bold: true
                                    color: "#555555"
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                }
                            }
                        }
                    }

                    // Table body
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#ffffff"
                        border.color: "#e3e5e8"
                        clip: true

                        ListView {
                            anchors.fill: parent
                            anchors.margins: 1
                            clip: true
                            model: root.phenotypeData
                            ScrollBar.vertical: ScrollBar {}
                            delegate: RowLayout {
                                width: ListView.view.width
                                height: 22
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.leftMargin: 6
                                    text: modelData.phenotype
                                    elide: Text.ElideRight
                                    font.pixelSize: 10
                                    color: "#333333"
                                }
                                Text {
                                    Layout.fillWidth: true
                                    Layout.preferredWidth: 1
                                    Layout.rightMargin: 6
                                    text: modelData.percent
                                    font.pixelSize: 10
                                    color: "#333333"
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: root.phenotypeData.length === 0
                            text: "No data"
                            font.pixelSize: 10
                            color: "#bbbbbb"
                        }
                    }
                }

                //Future results sections?
                // Punnett square, Recombination Map, Phenotypes chart.
                // ColumnLayout {
                //     Layout.fillWidth: true
                //     Layout.fillHeight: true
                //     spacing: 8
                //     // Punnett square
                //     // Recombination map
                //     // Phenotypes chart
                // }
            }
        }
    }
}
