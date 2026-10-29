import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: group

    property string geneLabel: "Gene"
    property string geneLetter: "A"
    property bool showInfoIcon: false
    property bool showRecombination: false
    property bool showRegulationArrow: false

    property bool showToggle: false        // show the on/off switch in the header
    property bool toggleAvailable: true    // false = switch itself is greyed out (when previous gene is off)
    property bool toggleChecked: false     // current on/off state, owned by root file
    signal toggleRequested(bool checked)   // when user flips switch

    // false = allele boxes / spinbox / regulation box can't be interacted with
    property bool geneEnabled: true


    readonly property string genotype: {
        if (!geneEnabled)
            return ""
        return (allele1.currentIndex > 0 ? allele1.currentText : "")
             + (allele2.currentIndex > 0 ? allele2.currentText : "")
    }

    // reset to default state
    function reset() {
        allele1.currentIndex = 0
        allele2.currentIndex = 0
        recombinationBox.value = 0
        regulationBox.currentIndex = 0
    }

    implicitHeight: content.implicitHeight + 12
    color: "#fafbfc"
    radius: 3
    border.color: "#e0e2e5"

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 6
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: group.geneLabel
                font.pixelSize: 11
                font.bold: true
                color: group.geneEnabled ? "#444444" : "#aaaaaa"
            }
            Text {
                visible: group.showInfoIcon
                text: "\u24D8"
                font.pixelSize: 11
                color: "#9aa0a6"
            }
            Item { Layout.fillWidth: true }
            Switch {
                id: geneSwitch
                visible: group.showToggle
                enabled: group.toggleAvailable
                padding: 0
                topPadding: 0
                bottomPadding: 0
                onToggled: group.toggleRequested(checked)
            }

            Binding {
                target: geneSwitch
                property: "checked"
                value: group.toggleChecked
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            ComboBox {
                id: allele1
                Layout.fillWidth: true
                implicitHeight: 26
                enabled: group.geneEnabled
                model: ["Allele 1", group.geneLetter.toUpperCase(), group.geneLetter.toLowerCase()]
            }
            ComboBox {
                id: allele2
                Layout.fillWidth: true
                implicitHeight: 26
                enabled: group.geneEnabled
                model: ["Allele 2", group.geneLetter.toUpperCase(), group.geneLetter.toLowerCase()]
            }
        }

        RowLayout {
            visible: group.showRecombination
            Layout.fillWidth: true
            Text {
                text: "Recombination"
                font.pixelSize: 10
                color: "#777777"
            }
            Item { Layout.fillWidth: true }
            SpinBox {
                id: recombinationBox
                from: 0
                to: 50
                value: 0
                implicitHeight: 24
                enabled: group.geneEnabled
            }
        }

        RowLayout {
            visible: group.showRegulationArrow
            Layout.fillWidth: true
            Text {
                text: "Regulation"
                font.pixelSize: 10
                color: "#777777"
            }
            Item { Layout.fillWidth: true }
            ComboBox {
                id: regulationBox
                implicitHeight: 24
                enabled: group.geneEnabled
                model: ["\u2192", "\u22A3"]
            }
        }
    }
}
