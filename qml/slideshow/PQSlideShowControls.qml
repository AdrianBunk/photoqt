/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 **                                                                      **
 ** PhotoQt is free software: you can redistribute it and/or modify      **
 ** it under the terms of the GNU General Public License as published by **
 ** the Free Software Foundation, either version 2 of the License, or    **
 ** (at your option) any later version.                                  **
 **                                                                      **
 ** PhotoQt is distributed in the hope that it will be useful,           **
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of       **
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        **
 ** GNU General Public License for more details.                         **
 **                                                                      **
 ** You should have received a copy of the GNU General Public License    **
 ** along with PhotoQt. If not, see <http://www.gnu.org/licenses/>.      **
 **                                                                      **
 **************************************************************************/

import QtQuick 2.9
import QtMultimedia 5.5
import "../elements"

Item {

    id: controls_top

    x: PQSettings.interfacePopoutSlideShowControls ? 0 : ((parentWidth-width)/2)
    y: PQSettings.interfacePopoutSlideShowControls ? 0 : (parentHeight-height-50)
    width: PQSettings.interfacePopoutSlideShowControls ? parentWidth : playplausenextprev.width
    height: PQSettings.interfacePopoutSlideShowControls ? parentHeight : 80

    property int parentWidth: toplevel.width
    property int parentHeight: toplevel.height

    opacity: !variables.slideShowActive ? 0 : (PQSettings.interfacePopoutSlideShowControls ? 1 : ((showForeground||slideshowPaused||mouseOver) ? (mouseOver ? opacityMouseOver : opacityForeground) : opacityBackground))
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }
    visible: (opacity != 0)
    enabled: visible

    property real opacityMouseOver: 0.75
    property real opacityForeground: 0.5
    property real opacityBackground: 0.1
    property bool showForeground: true
    property bool slideshowPaused: false
    property bool mouseOver: false
    property int mouseOverId: 0

    property string backupAnimType: ""
    property var backupAllImagesInFolder: []

    Timer {
        id: resetMouseOver
        interval: 100
        property int oldId
        onTriggered: {
            if(oldId === mouseOverId)
                mouseOver = false
        }
    }

    MouseArea {
        id: controlsbgmousearea
        anchors.fill: parent
        hoverEnabled: true
        drag.target: controls_top
        property int myId: 0
        onEntered: {
            resetMouseOver.stop()
            if(myId == 0) myId = handlingGeneral.getUniqueId()
            mouseOverId = myId
            controls_top.mouseOver = true
        }
        onExited: {
            resetMouseOver.oldId = myId
            resetMouseOver.restart()
        }
    }

    property bool running: false
    onRunningChanged: {
        if(running) {
            controls_top.slideshowPaused = false
            imageitem.playAnim()
            switcher.restart()
            hideBarAfterTimeout.restart()
            if(slideshowmusic.source != "")
                slideshowmusic.play()
        } else {
            imageitem.pauseAnim()
            controls_top.slideshowPaused = true
            slideshowmusic.pause()
        }
    }

    property var shuffledIndices: []
    property int shuffledCurrentIndex: -1

    Item {

        id: playplausenextprev

        x: PQSettings.interfacePopoutSlideShowControls ? (parent.width-width)/2 : 10
        y: PQSettings.interfacePopoutSlideShowControls ? 20 : 0

        width: childrenRect.width
        height: childrenRect.height

        Row {

            spacing: 5

            Image {

                id: prev

                y: 20
                width: PQSettings.interfacePopoutSlideShowControls ? 80 : controls_top.height-2*y
                height: PQSettings.interfacePopoutSlideShowControls ? 80 : controls_top.height-2*y

                source: "/slideshow/prev.svg"

                sourceSize: Qt.size(width, height)

                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    tooltip: em.pty+qsTranslate("slideshow", "Click to go to the previous image")
                    onClicked: {
                        if(controls_top.running)
                            switcher.restart()
                        loadPrevImage()
                    }
                    drag.target: controls_top
                    property int myId: 0
                    onEntered: {
                        resetMouseOver.stop()
                        if(myId == 0) myId = handlingGeneral.getUniqueId()
                        mouseOverId = myId
                        controls_top.mouseOver = true
                    }
                    onExited: {
                        resetMouseOver.oldId = myId
                        resetMouseOver.restart()
                    }
                }

            }

            Image {

                id: playpause

                y: 20
                width: PQSettings.interfacePopoutSlideShowControls ? 80 : controls_top.height-2*y
                height: PQSettings.interfacePopoutSlideShowControls ? 80 : controls_top.height-2*y

                source: (controls_top.running ? "/slideshow/pause.svg" : "/slideshow/play.svg")

                sourceSize: Qt.size(width, height)

                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    tooltip: (controls_top.running ?
                                  em.pty+qsTranslate("slideshow", "Click to pause slideshow") :
                                  em.pty+qsTranslate("slideshow", "Click to play slideshow"))
                    onClicked:
                        controls_top.running = !controls_top.running
                    drag.target: controls_top
                    property int myId: 0
                    onEntered: {
                        resetMouseOver.stop()
                        if(myId == 0) myId = handlingGeneral.getUniqueId()
                        mouseOverId = myId
                        controls_top.mouseOver = true
                    }
                    onExited: {
                        resetMouseOver.oldId = myId
                        resetMouseOver.restart()
                    }
                }

            }

            Image {

                id: next

                y: 20
                width: PQSettings.interfacePopoutSlideShowControls ? 80 : controls_top.height-2*y
                height: PQSettings.interfacePopoutSlideShowControls ? 80 : controls_top.height-2*y

                source: "/slideshow/next.svg"

                sourceSize: Qt.size(width, height)

                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    tooltip: em.pty+qsTranslate("slideshow", "Click to go to the next image")
                    onClicked: {
                        if(controls_top.running)
                            switcher.restart()
                        loadNextImage()
                    }
                    drag.target: controls_top
                    property int myId: 0
                    onEntered: {
                        resetMouseOver.stop()
                        if(myId == 0) myId = handlingGeneral.getUniqueId()
                        mouseOverId = myId
                        controls_top.mouseOver = true
                    }
                    onExited: {
                        resetMouseOver.oldId = myId
                        resetMouseOver.restart()
                    }
                }

            }

            Image {

                id: exit

                y: 20
                width: PQSettings.interfacePopoutSlideShowControls ? 80 : controls_top.height-2*y
                height: PQSettings.interfacePopoutSlideShowControls ? 80 : controls_top.height-2*y

                source: "/slideshow/exit.svg"
                sourceSize: Qt.size(width, height)

                PQMouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    tooltip: em.pty+qsTranslate("slideshow", "Click to exit slideshow")
                    onClicked: {
                        quitSlideShow()
                    }
                    drag.target: controls_top
                    property int myId: 0
                    onEntered: {
                        resetMouseOver.stop()
                        if(myId == 0) myId = handlingGeneral.getUniqueId()
                        mouseOverId = myId
                        controls_top.mouseOver = true
                    }
                    onExited: {
                        resetMouseOver.oldId = myId
                        resetMouseOver.restart()
                    }
                }

            }

            Item {
                width: volumeicon.visible ? 25 : 10
                height: 1
            }

            Image {

                id: volumeicon

                visible: slideshowmusic.source!=""

                y: exit.y + (exit.height-height)/2
                width: visible ? 40 : 0
                height: 40

                sourceSize: Qt.size(width, height)

                source: volumeslider.value==0 ?
                            "/slideshow/speaker_mute.svg" :
                            (volumeslider.value <= 40 ?
                                 "/slideshow/speaker_low.svg" :
                                 (volumeslider.value <= 80 ?
                                      "/slideshow/speaker_medium.svg" :
                                      "/slideshow/speaker_high.svg"))

            }

            PQSlider {

                id: volumeslider

                visible: slideshowmusic.source!=""

                y: exit.y + (exit.height-height)/2
                width: visible? 200 : 0
                height: 20

                toolTipPrefix: em.pty+qsTranslate("slideshow", "Sound volume:") + " "
                toolTipSuffix: "%"

                value: 80

                from: 0
                to: 100

                onHoveredChanged:
                    controls_top.mouseOver = hovered

            }

            Item {
                width: volumeslider.visible? 20 : 0
                height: 1
            }

        }

    }

    // Audio element
    Audio {
        id: slideshowmusic
        volume: volumeslider.value/100.0
        onError: console.error("AUDIO ERROR:",errorString,"-",source)
        loops: Audio.Infinite
    }

    Connections {
        target: loader
        onSlideshowControlsPassOn: {

            if(what == "start")
                startSlideShow()

            else if(what == "quit")
                quitSlideShow()

            else if(what == "keyevent") {

                if(param[0] == Qt.Key_Space || param[0] == Qt.Key_Enter || param[0] == Qt.Key_Return)
                    controls_top.running = !controls_top.running

                else if(param[0] == Qt.Key_Right) {

                    loadNextImage()
                    if(controls_top.running)
                        switcher.restart()

                } else if(param[0] == Qt.Key_Left) {

                    loadPrevImage()
                    if(controls_top.running)
                        switcher.restart()

                } else if(param[0] == Qt.Key_Minus) {

                    var val = 1
                    if(param[1] & Qt.AltModifier)
                        val = 5

                    volumeslider.value = Math.max(0, volumeslider.value-val)

                }else if(param[0] == Qt.Key_Plus || param[0] == Qt.Key_Equal) {

                    var val = 1
                    if(param[1] & Qt.AltModifier)
                        val = 5

                    volumeslider.value = Math.min(100, volumeslider.value+val)

                } else if(param[0] == Qt.Key_Escape || param[0] == Qt.Key_Q)
                    quitSlideShow()

            }
        }
    }

    Timer {
        id: hideBarAfterTimeout
        interval: 3000
        repeat: false
        onTriggered: {
            controls_top.showForeground = false
        }
    }

    Timer {
        id: switcher
        interval: imageitem.getCurrentVideoLength()==-1 ? Math.max(1000, Math.min(300*1000, PQSettings.slideshowTime*1000)) : imageitem.getCurrentVideoLength()
        repeat: true
        running: variables.slideShowActive&&controls_top.running
        onTriggered: loadNextImage()
    }

    Component.onDestruction: {
        if(variables.slideShowActive = true)
            quitSlideShow()
    }

    function startSlideShow() {

        variables.visibleItem = "slideshowcontrols"
        variables.slideShowActive = true

        controls_top.showForeground = true

        imageitem.zoomReset()
        imageitem.rotateReset()

        backupAnimType = PQSettings.imageviewAnimationType
        PQSettings.imageviewAnimationType = PQSettings.slideshowTypeAnimation

        var sortby = 1
        if(PQSettings.imageviewSortImagesBy == "name")
            sortby = 0
        else if(PQSettings.imageviewSortImagesBy == "time")
            sortby = 2
        else if(PQSettings.imageviewSortImagesBy == "size")
            sortby = 3
        else if(PQSettings.imageviewSortImagesBy == "type")
            sortby = 4

        if(PQSettings.slideshowIncludeSubFolders) {
            filefoldermodel.includeFilesInSubFolders = true
            filefoldermodel.forceReloadMainView()
        }

        if(PQSettings.slideshowShuffle) {

            controls_top.shuffledIndices = []
            for(var k = 0; k < filefoldermodel.countMainView; ++k)
                if(k !== filefoldermodel.current) {
                    controls_top.shuffledIndices.push(k)
                }
            shuffle(controls_top.shuffledIndices)
            controls_top.shuffledIndices.push(filefoldermodel.current)
            controls_top.shuffledCurrentIndex = -1

        }

        controls_top.running = true
        imageitem.restartAnim()

        if(PQSettings.interfacePopoutSlideShowControls)
            slideshowcontrols_window.visible = true

        hideBarAfterTimeout.start()

        if(PQSettings.slideshowMusicFile != "") {
            slideshowmusic.source = "file:///" + PQSettings.slideshowMusicFile
            slideshowmusic.play()
        } else
            slideshowmusic.source = ""

    }

    function quitSlideShow() {

        slideshowmusic.stop()

        PQSettings.imageviewAnimationType = backupAnimType

        if(PQSettings.slideshowIncludeSubFolders)
            filefoldermodel.includeFilesInSubFolders = false

        variables.visibleItem = ""
        variables.slideShowActive = false
        if(PQSettings.interfacePopoutSlideShowControls)
            slideshowcontrols_window.visible = false

    }

    function loadNextImage() {

        if(!PQSettings.slideshowShuffle) {
            if(filefoldermodel.current < filefoldermodel.countMainView-1)
                ++filefoldermodel.current
            else if(PQSettings.slideshowLoop)
                filefoldermodel.current = 0
            else
                quitSlideShow()
        } else {
            if(controls_top.shuffledCurrentIndex < controls_top.shuffledIndices.length-1) {
                ++controls_top.shuffledCurrentIndex
                filefoldermodel.current = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
            } else if(PQSettings.slideshowLoop) {
                controls_top.shuffledCurrentIndex = 0
                filefoldermodel.current = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
            } else
                quitSlideShow()

        }

    }

    function loadPrevImage() {

        if(!PQSettings.slideshowShuffle) {
            if(filefoldermodel.current > 0) {
                --filefoldermodel.current
            } else if(PQSettings.slideshowLoop) {
                filefoldermodel.current = filefoldermodel.countMainView-1
            }
        } else {
            if(controls_top.shuffledCurrentIndex > 0) {
                --controls_top.shuffledCurrentIndex
                filefoldermodel.current = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
            } else if(PQSettings.slideshowLoop) {
                controls_top.shuffledCurrentIndex = controls_top.shuffledIndices.length-1
                filefoldermodel.current = controls_top.shuffledIndices[controls_top.shuffledCurrentIndex]
            }
        }

    }

    /***************************************/
    // The Fisher–Yates shuffle algorithm
    // Code found at http://stackoverflow.com/questions/6274339/how-can-i-shuffle-an-array-in-javascript
    // (adapted from http://bost.ocks.org/mike/shuffle/)
    function shuffle(array) {
        var counter = array.length, temp, index;

        // While there are elements in the array
        while (counter > 0) {
            // Pick a random index
            index = Math.floor(Math.random() * counter);

            // Decrease counter by 1
            counter--;

            // And swap the last element with it
            temp = array[counter];
            array[counter] = array[index];
            array[index] = temp;
        }

        return array;
    }

}
