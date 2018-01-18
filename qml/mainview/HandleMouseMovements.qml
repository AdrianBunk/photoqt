import QtQuick 2.5
import "../shortcuts/mouseshortcuts.js" as AnalyseMouse

MouseArea {

    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton|Qt.MiddleButton|Qt.RightButton

    drag.target: (settings.leftButtonMouseClickAndMove&&!variables.imageItemBlocked&&buttonID==Qt.LeftButton) ? imageitem.returnImageContainer() : undefined

    property point pressedPosStart: Qt.point(-1,-1)
    property point pressedPosEnd: Qt.point(-1,-1)

    property int buttonID: Qt.LeftButton

    onPositionChanged:
        handleMousePositionChange(mouse.x, mouse.y)
    onPressed: {
        buttonID = mouse.button
        pressedPosStart = Qt.point(mouse.x, mouse.y)
        variables.shorcutsMouseGesturePointIntermediate = Qt.point(-1,-1)
    }
    onReleased: {
        pressedPosEnd = Qt.point(mouse.x, mouse.y)
        pressedPosStart = Qt.point(-1,-1)
        shortcuts.analyseMouseEvent(pressedPosStart, mouse)
    }

    onWheel: shortcuts.analyseWheelEvent(wheel)

    function handleMousePositionChange(xPos, yPos) {

        if(pressedPosStart.x != -1 || pressedPosStart.y != -1) {
            var before = variables.shorcutsMouseGesturePointIntermediate
            if(variables.shorcutsMouseGesturePointIntermediate.x == -1 || variables.shorcutsMouseGesturePointIntermediate.y == -1)
                before = pressedPosStart
            AnalyseMouse.analyseMouseGestureUpdate(xPos, yPos, before)
        }

        var w = settings.hotEdgeWidth*5

        if(xPos > mainwindow.width-w && !variables.slideshowRunning)
            mainmenu.show()
        else
            mainmenu.hide()

        if(xPos < w && !variables.slideshowRunning && settings.metadataEnableHotEdge) {
            if((variables.filter != "" && yPos > quickinfo.x+quickinfo.height+25) || variables.filter == "")
                metadata.show()
        } else
            metadata.hide()

        if(settings.thumbnailPosition=="Bottom") {
            if(yPos > mainwindow.height-w && !variables.slideshowRunning && !settings.thumbnailDisable)
                call.show("thumbnails")
            else if((!settings.thumbnailKeepVisible && !settings.thumbnailKeepVisibleWhenNotZoomedIn) || (settings.thumbnailKeepVisibleWhenNotZoomedIn && imageitem.isZoomedIn()))
                call.hide("thumbnails")
        } else {
            if(yPos < w && !variables.slideshowRunning && !settings.thumbnailDisable)
                call.show("thumbnails")
            else if((!settings.thumbnailKeepVisible && !settings.thumbnailKeepVisibleWhenNotZoomedIn) || (settings.thumbnailKeepVisibleWhenNotZoomedIn && imageitem.isZoomedIn()))
                call.hide("thumbnails")
        }

        if(yPos < w)
            call.show("slideshowbar")
        else
            call.hide("slideshowbar")

    }

}
