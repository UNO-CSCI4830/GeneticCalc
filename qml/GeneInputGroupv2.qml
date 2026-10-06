import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: group

    property string geneLabel: "Gene"
    property bool showInfoIcon: false
    property bool showRecombination: false
    property bool showRegulationArrow: false

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
                color: "#444444"
            }
            Text {
                visible: group.showInfoIcon
                text: "\u24D8"
                font.pixelSize: 11
                color: "#9aa0a6"
            }
            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 4
            ComboBox {
                Layout.fillWidth: true
                implicitHeight: 26
                model: ["Allele 1", "A", "a"]
            }
            ComboBox {
                Layout.fillWidth: true
                implicitHeight: 26
                model: ["Allele 2", "A", "a"]
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
                from: 0
                to: 50
                value: 0
                implicitHeight: 24
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
                implicitHeight: 24
                model: ["\u2192", "\u22A3"]
            }
        }
    }
}
