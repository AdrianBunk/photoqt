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
import QtQuick.Window 2.2
import "../elements"

Item {

    id: resetview_top

    x: (parent.width-width)/2
    y: -height

    Behavior on y { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

    width: resetimg.width+10
    height: resetimg.height+10

    visible: y>-height&&PQSettings.imageviewResetViewShow

    opacity: 0.5
    Behavior on opacity { NumberAnimation { duration: 200 } }

    PQBlurBackground {
        thisis: resetview
        reacttoxy: resetview_top
        radius: parent.width/2
        opacity: 0.5
    }

    RotationAnimation {
        id: rotani
        target: resetview_top
        from: 360
        to: 0
        duration: 1000
        loops: Animation.Infinite
        direction: RotationAnimation.Counterclockwise
    }

    Image {
        id: resetimg
        x: 5
        y: 5
        width: 30
        height: 30
        mipmap: true
        sourceSize: Qt.size(width, height)
        source: "/mainwindow/reset.svg"
    }

    PQMouseArea {
        id: resetmouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: {
            rotani.from = resetview_top.rotation
            rotani.to = rotani.from-360
            rotani.start()
            parent.opacity = 1
        }
        onExited: {
            rotani.stop()
            parent.opacity = 0.5
        }
        onClicked: {
            imageitem.zoomReset()
            imageitem.rotateReset()
            imageitem.mirrorReset()
            imageitem.restartAnim()
            resetview_top.y = -height
        }
    }

    Timer {
        id: hideagain
        interval: 500 + PQSettings.imageviewResetViewAutoHideTimeout
        repeat: false
        running: false
        onTriggered: {
            if(!resetmouse.containsMouse)
                resetview_top.y = -height
        }
    }

    Connections {
        target: variables
        onMousePosChanged: {
            if(PQSettings.imageviewResetViewShow && variables.viewChanged) {
                resetview_top.y = 20
                hideagain.restart()
            }
        }
    }

}
