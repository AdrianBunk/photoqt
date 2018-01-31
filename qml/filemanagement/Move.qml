import QtQuick 2.5
import PFileDialog 1.0
import "../handlestuff.js" as Handle

Item {

    x: 0
    y: (container.height-height-110)/2
    width: container.width-110
    height: container.height

    Text {
        width: parent.width
        height: parent.height
        verticalAlignment: Qt.AlignVCenter
        horizontalAlignment: Qt.AlignHCenter
        //: The destination location is a location on the computer to move a file to
        text: em.pty+qsTr("Use the file dialog to select a destination location.")
        color: colour.bg_label
        font.bold: true
        font.pointSize: 20
    }

    PFileDialog {
        id: filedialog
        onAccepted:
            moveFile(file)
        onRejected: {
            if(management_top.current == "mv")
            management_top.hide()
        }
    }

    Connections {
        target: container
        onItemShown:
            filedialog.getFilename(em.pty+qsTr("Move Image to..."), variables.currentDir + "/" +  variables.currentFile)
        onItemHidden:
            filedialog.close()
    }

    function moveFile(file) {
        verboseMessage("FileManagement/Move", "moveFile(): " + file)
        getanddostuff.moveImage(variables.currentDir + "/" + variables.currentFile, file)
        if(getanddostuff.removeFilenameFromPath(file) == variables.currentDir) {
            Handle.loadFile(file, variables.filter, true)
            management_top.hide()
        }
    }

}
