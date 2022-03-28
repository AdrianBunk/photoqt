/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
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
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import "../elements"

Window {

    id: advancedsort_window

    //: Window title
    title: em.pty+qsTranslate("advancedsort", "Advanced Image Sort")

    Component.onCompleted: {
        advancedsort_window.setX(windowgeometry.advancedSortWindowGeometry.x)
        advancedsort_window.setY(windowgeometry.advancedSortWindowGeometry.y)
        advancedsort_window.setWidth(windowgeometry.advancedSortWindowGeometry.width)
        advancedsort_window.setHeight(windowgeometry.advancedSortWindowGeometry.height)
    }

    minimumWidth: 200
    minimumHeight: 300

    modality: Qt.ApplicationModal

    objectName: "advancedsortpopout"

    onClosing: {
        storeGeometry()
        if(variables.visibleItem == "advancedsort")
            variables.visibleItem = ""
    }

    visible: PQSettings.interfacePopoutAdvancedSort&&curloader.item.opacity==1
    flags: Qt.WindowStaysOnTopHint

    Connections {
        target: PQSettings
        onInterfacePopoutAdvancedSortChanged: {
            if(!PQSettings.interfacePopoutAdvancedSort)
                advancedsort_window.visible = Qt.binding(function() { return PQSettings.interfacePopoutAdvancedSort&&curloader.item.opacity==1; })
        }
    }

    color: "#88000000"

    Loader {
        id: curloader
        source: "PQAdvancedSort.qml"
        onStatusChanged:
            if(status == Loader.Ready) {
                item.parentWidth = Qt.binding(function() { return advancedsort_window.width })
                item.parentHeight = Qt.binding(function() { return advancedsort_window.height })
            }
    }

    // get the memory address of this window for shortcut processing
    // this info is used in PQSingleInstance::notify()
    Timer {
        interval: 100
        repeat: false
        running: true
        onTriggered:
            handlingGeneral.storeQmlWindowMemoryAddress(advancedsort_window.objectName)
    }

    function storeGeometry() {
        windowgeometry.advancedSortWindowGeometry = Qt.rect(advancedsort_window.x, advancedsort_window.y, advancedsort_window.width, advancedsort_window.height)
        windowgeometry.advancedSortWindowMaximized = (advancedsort_window.visibility==Window.Maximized)
    }

}