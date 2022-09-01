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
import "../elements"

Item {

    id: status_top

    x: 40
    y: (PQSettings.thumbnailsEdge == "Top") ? (20 + thumbnails.height+thumbnails.y) : 20

    width: col.width
    height: col.height

    visible: !(variables.slideShowActive&&PQSettings.slideshowHideLabels) &&
                 (filefoldermodel.current>-1 || filefoldermodel.filterCurrentlyActive) &&
                 (filefoldermodel.countMainView>0 || filefoldermodel.filterCurrentlyActive) &&
                 !variables.faceTaggingActive && info.length>0


    // possible values: counter, filename, filepathname, resolution, zoom, rotation
    property var info: PQSettings.interfaceStatusInfoList

    Column {

        id: col

        spacing: 10

        Item {

            width: view.width+40
            height: view.height+20

            visible: PQSettings.interfaceStatusInfoShow

            Rectangle {
                anchors.fill: parent
                color: "#dd2f2f2f"
                radius: 5
            }

            ListView {

                id: view

                property var allheights: []

                x: 20
                y: 10
                width: childrenRect.width
                height: allheights.length > 0 ? Math.max.apply(Math, allheights.slice(allheights.length-info.length)) : 0

                model: info.length

                orientation: ListView.Horizontal
                interactive: false

                spacing: PQSettings.interfaceStatusInfoFontSize

                delegate:

                    Item {

                        id: deleg

                        width: childrenRect.width
                        height: childrenRect.height

                        Row {
                            spacing: PQSettings.interfaceStatusInfoFontSize

                            Loader {
                                id: ldr
                                property string t: info[index]
                                sourceComponent: t=="counter" ?
                                                     rectCounter :
                                                     t=="filename" ?
                                                         rectFilename :
                                                         t=="filepathname" ?
                                                             rectFilepath :
                                                             t=="resolution" ?
                                                                 rectResolution :
                                                                 t=="zoom" ?
                                                                     rectZoom :
                                                                     t=="rotation" ?
                                                                         rectRotation :
                                                                         t=="filesize" ?
                                                                             rectFilesize :
                                                                             rectDummy
                            }

                            Component {
                                id: rectCounter
                                Text {
                                    color: "white"
                                    font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                    text: (filefoldermodel.current+1) + "/" + filefoldermodel.countMainView
                                }
                            }

                            Component {
                                id: rectFilename
                                Text {
                                    color: "white"
                                    font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                    text: handlingFileDir.getFileNameFromFullPath(filefoldermodel.currentFilePath)
                                }
                            }

                            Component {
                                id: rectFilepath
                                Text {
                                    color: "white"
                                    font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                    text: filefoldermodel.currentFilePath
                                }
                            }

                            Component {
                                id: rectZoom
                                Text {
                                    color: "white"
                                    font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                    text: Math.round(variables.currentZoomLevel)+"%"
                                }
                            }

                            Component {
                                id: rectRotation
                                Text {
                                    color: "white"
                                    font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                    text: (Math.round(variables.currentRotationAngle)%360+360)%360 + "°"
                                }
                            }

                            Component {
                                id: rectResolution
                                Row {
                                    spacing: 2
                                    Text {
                                        color: "white"
                                        font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                        text: variables.currentImageResolution.width
                                    }
                                    Text {
                                        color: "white"
                                        font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                        opacity: 0.7
                                        text: "x"
                                    }
                                    Text {
                                        color: "white"
                                        font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                        text: variables.currentImageResolution.height
                                    }
                                }
                            }

                            Component {
                                id: rectFilesize
                                Text {
                                    color: "white"
                                    font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                    text: handlingGeneral.convertBytesToHumanReadable(cppmetadata.fileSize)
                                }
                            }

                            Component {
                                id: rectDummy
                                Text {
                                    color: "white"
                                    font.pointSize: PQSettings.interfaceStatusInfoFontSize
                                    text: "[unknown]"
                                }
                            }

                            Rectangle {
                                visible: index < info.length-1
                                width: 1
                                height: ldr.height
                                color: "white"
                            }

                        }

                        onHeightChanged: {
                            view.allheights.push(height)
                            view.allheightsChanged()
                        }

                    }

            }

            PQMouseArea {

                anchors.fill: parent

                hoverEnabled: true

                drag.target: PQSettings.interfaceStatusInfoManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : status_top
                drag.minimumX: 0
                drag.maximumX: toplevel.width-parent.width
                drag.minimumY: 0
                drag.maximumY: toplevel.height-parent.height

                drag.onActiveChanged: {
                    var tmp = status_top.y
                    status_top.y = tmp
                }

                doubleClickThreshold: 250

                tooltip: em.pty+qsTranslate("quickinfo", "Some information about the current image and directory")
                acceptedButtons: Qt.LeftButton|Qt.RightButton

                property point clickPos: Qt.point(0,0)
                property bool isPressed: false
                onPressed: {
                    if(toplevel.visibility != Window.Maximized) {
                        isPressed = true
                        clickPos = Qt.point(mouse.x, mouse.y)
                    }
                }
                onPositionChanged: {
                    if(PQSettings.interfaceStatusInfoManageWindow && isPressed) {
                        if(toplevel.visibility == Window.Maximized)
                            toplevel.visibility = Window.Windowed
                        var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                        toplevel.x += delta.x;
                        toplevel.y += delta.y;
                    }
                }
                onReleased: {
                    isPressed = false
                }
                onDoubleClicked: {
                    if(!PQSettings.interfaceStatusInfoManageWindow)
                        return
                    if(toplevel.visibility == Window.Maximized)
                        toplevel.visibility = Window.Windowed
                    else if(toplevel.visibility == Window.Windowed)
                        toplevel.visibility = Window.Maximized
                    else if(toplevel.visibility == Window.FullScreen)
                        toplevel.visibility = Window.Maximized
                }
            }

        }

        Row {

            spacing: 10

            Image {
                width: filterrow.height+20
                height: filterrow.height+20
                visible: variables.chromecastConnected
                source: "/streaming/chromecastactive.svg"
                sourceSize: Qt.size(width, height)
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    //: This is followed by the name of the Chromecast streaming device currently connected to
                    tooltip: em.pty+qsTranslate("quickinfo", "Connected to:") + " " + variables.chromecastName
                    cursorShape: Qt.PointingHandCursor
                    onClicked:
                        loader.show("chromecast")
                }
            }

            Rectangle {
                id: filterremove_cont
                visible: filefoldermodel.filterCurrentlyActive
                width: visible ? filterrow.width : 0
                height: visible ? filterrow.height+20 : 0
                color: "#dd2f2f2f"
                radius: 5
                PQMouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    drag.target: PQSettings.interfaceStatusInfoManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : status_top
                    drag.minimumX: 0
                    drag.maximumX: toplevel.width-parent.width
                    drag.minimumY: 0
                    drag.maximumY: toplevel.height-parent.height
                }

                Row {
                    id: filterrow
                    spacing: 10
                    y: 10
                    Item {
                        width: 1
                        height: 1
                    }
                    Text {
                        id: filterremove
                        color: "#999999"
                        text: "x"
                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            tooltip: em.pty+qsTranslate("quickinfo", "Click to remove filter")
                            onPressed:
                                loader.passOn("filter", "removeFilter", undefined)
                        }
                    }
                    Text {
                        id: filtertext
                        color: "white"
                        property string txt: filefoldermodel.filenameFilters.join(" ") + (filefoldermodel.nameFilters.length==0 ? "" : " ." + filefoldermodel.nameFilters.join(" ."))
                        property string res: (filefoldermodel.imageResolutionFilter.width != 0 || filefoldermodel.imageResolutionFilter.height != 0) ?
                                                 ((filefoldermodel.imageResolutionFilter.width<0||filefoldermodel.imageResolutionFilter.height<0 ? "< " : "> ") + Math.abs(filefoldermodel.imageResolutionFilter.width)+"x"+Math.abs(filefoldermodel.imageResolutionFilter.height)) :
                                                 ""
                        property string siz: filefoldermodel.fileSizeFilter!=0 ? ((filefoldermodel.fileSizeFilter<0 ? "< " : "> ") + variables.filterExactFileSizeSet) : ""
                        text: "<b>" + em.pty+qsTranslate("quickinfo", "Filter:") + "</b> " + txt + (txt!=""&&res!="" ? "; " : "") + res + (siz!=""&&(txt!=""||res!="") ? "; " : "") + siz
                    }
                    Item {
                        width: 1
                        height: 1
                    }
                }

            }

        }

        Rectangle {

            id: viewermode

            width: 50
            height: width
            color: "#dd2f2f2f"
            radius: 5

            visible: (imageproperties.isPopplerDocument(filefoldermodel.currentFilePath)
                            &&(imageproperties.getDocumentPages(filefoldermodel.currentFilePath)>1 || filefoldermodel.isPQT))
                        || (imageproperties.isArchive(filefoldermodel.currentFilePath))

            Image {
                anchors.fill: parent
                anchors.margins: 5
                sourceSize: Qt.size(width, height)
                source: (filefoldermodel.isPQT || filefoldermodel.isARC) ? "/image/noviewermode.svg" : "/image/viewermode.svg"
                mipmap: true
            }

            PQMouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor

                drag.target: PQSettings.interfaceStatusInfoManageWindow&&toplevel.visibility!=Window.FullScreen ? undefined : status_top
                drag.minimumX: 0
                drag.maximumX: toplevel.width-parent.width
                drag.minimumY: 0
                drag.maximumY: toplevel.height-parent.height

                tooltip: (filefoldermodel.isPQT || filefoldermodel.isARC) ?
                             em.pty+qsTranslate("quickinfo", "Click here to exit viewer mode") :
                             em.pty+qsTranslate("quickinfo", "Click here to enter viewer mode")

                onClicked: {
                    if(filefoldermodel.isPQT || filefoldermodel.isARC)
                        exitViewerMode()
                    else
                        enterViewerMode()
                }
            }

        }

    }



    Image {

        x: parent.width-width+5
        y: -5
        width: 20
        height: 20

        source: "/other/close.svg"
        sourceSize: Qt.size(width, height)

        opacity: closemouse.containsMouse ? 0.8 : 0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        PQMouseArea {
            id: closemouse
            anchors.fill: parent
            visible: PQSettings.interfaceStatusInfoShow
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onClicked:
                PQSettings.interfaceStatusInfoShow = false
        }

    }

    function enterViewerMode() {
        console.log("entering")
        if(imageproperties.isPopplerDocument(filefoldermodel.currentFilePath)) {
            filefoldermodel.readDocumentOnly = true
            filefoldermodel.setFileNameOnceReloaded = "0::PQT::" + filefoldermodel.currentFilePath
            filefoldermodel.fileInFolderMainView = filefoldermodel.currentFilePath
        } else {
            filefoldermodel.readArchiveOnly = true
            filefoldermodel.setFileNameOnceReloaded = "---"
            filefoldermodel.fileInFolderMainView = filefoldermodel.currentFilePath
        }
        filefoldermodel.forceReloadMainView()
    }

    function exitViewerMode() {
        console.log("exiting")
        if(filefoldermodel.isPQT)
            filefoldermodel.setFileNameOnceReloaded = filefoldermodel.pqtName
        else
            filefoldermodel.setFileNameOnceReloaded = filefoldermodel.arcName
        filefoldermodel.fileInFolderMainView = filefoldermodel.setFileNameOnceReloaded
        filefoldermodel.forceReloadMainView()
    }

    function toggleViewerMode() {
        if(filefoldermodel.isPQT || filefoldermodel.isARC)
            exitViewerMode()
        else
            enterViewerMode()
    }

}