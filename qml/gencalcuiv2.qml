import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    width: 1024
    height: 559
    color: "#eef0f2"

    property var geneNames: ["A", "B", "C", "D", "E"]
    property var outcomeColumns: ["Genotype", "Frequency (%)", "Count (Expected)"]
    property var phenotypeColumns: ["Phenotype", "Frequency (%)"]

    // ================= Title bar =================
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
            text: "SAMPLE Genetic Cross Calculator (subject to change) "
            font.pixelSize: 11
            color: "#777777"
        }
    }

    // ================= Content =================
    RowLayout {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 8
        spacing: 8

        // ------------- Left Panel: Parent Inputs -------------
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

                    // ---- Parent 1 column ----
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
                                model: root.geneNames
                                delegate: GeneInputGroupv2 {
                                    Layout.fillWidth: true
                                    geneLabel: "Gene " + modelData
                                    showInfoIcon: index === 0
                                    showRecombination: index < 4
                                }
                            }
                        }
                    }

                    // ---- Parent 2 column ----
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
                                model: root.geneNames
                                delegate: GeneInputGroupv2 {
                                    Layout.fillWidth: true
                                    geneLabel: "Gene " + modelData
                                    showInfoIcon: index === 0
                                    showRecombination: index < 4
                                    showRegulationArrow: index === 4
                                }
                            }
                        }
                    }
                }

                Button {
                    text: "Calculate Cross"
                    highlighted: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 160
                    Layout.topMargin: 4
                    Layout.bottomMargin: 4
                }
            }
        }

        // ------------- Right Panel: Calculation Results -------------
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

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    // ===== Left column of results: Genotypic Outcomes + Phenotypic Outcomes =====
                    ColumnLayout {
                        Layout.preferredWidth: resultsPanel.width * 0.42
                        Layout.fillHeight: true
                        spacing: 8

                        // --- Genotypic Outcomes ---
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
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
                                        }
                                    }
                                }
                            }

                            // Empty table body
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                color: "#ffffff"
                                border.color: "#e3e5e8"
                                Text {
                                    anchors.centerIn: parent
                                    text: "No data"
                                    font.pixelSize: 10
                                    color: "#bbbbbb"
                                }
                            }
                        }

                        // --- Phenotypic Outcomes ---
                    }

                    // ===== Right column of results: Punnett square, Recombination Map, Phenotypes chart =====
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8

                        // --- Phenotypes chart ---
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Item {
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
