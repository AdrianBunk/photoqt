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
//import PQMPVObject 1.0
import QmlVlc 0.1
import QtMultimedia 5.9
import "../../elements"

// for better control on fillMode we embed it inside an item
Item {

    id: elem

    x: 0 // offset taking care of in container
    y: PQSettings.imageviewMargin
    width: container.width-2*PQSettings.imageviewMargin
    height: container.height-2*PQSettings.imageviewMargin

    VlcPlayer {

        id: mediaplayer

        mrl: "file://" + src

    }

    // video element
    VideoOutput {

        id: videoelem

        source: mediaplayer

        anchors.centerIn: parent;
        width: parent.width / 2;
        height: parent.height / 2;
        opacity: 0.9;

    }

    function restorePosZoomRotationMirror() {
    }

    function storePosRotZoomMirror() {
    }


}
