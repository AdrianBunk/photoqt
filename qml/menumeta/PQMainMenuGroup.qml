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
import QtQuick.Controls 2.2
import "../elements"
import "../shortcuts/handleshortcuts.js" as HandleShortcuts

Column {

    width: parent.width

    property string title: ""
    property var leftcol: []
    property var rightcol: []
    property bool external: false
    property bool rightcolNormal: false
    property bool rightcolCenter: false
    property bool noSpacingAtTop: false

    Item {
        width: 1
        height: noSpacingAtTop ? 0 : 25
    }

    PQTextL {
        visible: text!=""
        font.weight: baselook.boldweight
        text: parent.title
    }

    Item {
        visible: parent.title!=""
        width: parent.width
        height: 1
    }

    Item {
        width: 1
        height: 10
    }

    Row {

        spacing: 10

        width: parent.width

        Column {

            id: nav_col

            spacing: 10

            width: rightcol.length==0 ? flick.width : (flick.width/2)

            Repeater {
                model: leftcol.length

                Row {
                    id: row
                    spacing: 10
                    property int outerIndex: index
                    property bool mouseOver: false
                    property int mouseOverId: 0

                    Timer {
                        id: resetMouseOver
                        interval: 100
                        property int oldId
                        onTriggered: {
                            if(oldId === row.mouseOverId)
                                row.mouseOver = false
                        }
                    }

                    Repeater {
                        model: leftcol[outerIndex].length

                        Item {

                            y: (parent.height-height)/2

                            width: childrenRect.width
                            height: childrenRect.height

                            visible: leftcol[outerIndex][index][2]!="__showMapExplorer" || handlingGeneral.isLocationSupportEnabled()

                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: leftcol[outerIndex][index][4] && filefoldermodel.current==-1
                                tooltip: em.pty+qsTranslate("MainMenu", "You need to load an image first.")
                            }

                            Image {
                                enabled: !leftcol[outerIndex][index][4] || filefoldermodel.current!=-1

                                y: 0.2*height
                                visible: leftcol[outerIndex][index][0] == "img"
                                source: !visible ? ""
                                                 : ((leftcol[outerIndex][index][1].match("^icn:")=="icn:") ?
                                                        (leftcol[outerIndex][index][1].slice(4)=="" ? "/settingsmanager/interface/application.svg" : ("data:image/png;base64,"+leftcol[outerIndex][index][1].slice(4))) :
                                                        ("/mainmenu/" + leftcol[outerIndex][index][1]))
                                height: visible ? (txt.height*0.8) : 0
                                width: height
                                mipmap: true
                                smooth: false
                                sourceSize: Qt.size(width, height)
                                opacity: enabled ? (row.mouseOver ? 1 : 0.8) : 0.4
                                Behavior on opacity { NumberAnimation { duration: 200 } }

                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    property int myId: 0
                                    onEntered: {
                                        resetMouseOver.stop()
                                        if(myId == 0) myId = handlingGeneral.getUniqueId()
                                        row.mouseOverId = myId
                                        row.mouseOver = true
                                    }
                                    onExited: {
                                        resetMouseOver.oldId = myId
                                        resetMouseOver.restart()
                                    }
                                    onClicked: parent.parent.click()
                                }
                            }
                            PQText {
                                enabled: !leftcol[outerIndex][index][4] || filefoldermodel.current!=-1

                                id: txt
                                visible: leftcol[outerIndex][index][0] == "txt"
                                text: visible ? leftcol[outerIndex][index][1] : " "
                                opacity: enabled ? (row.mouseOver ? 1 : 0.8) : 0.4
                                Behavior on opacity { NumberAnimation { duration: 200 } }

                                PQMouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    property int myId: 0
                                    onEntered: {
                                        resetMouseOver.stop()
                                        if(myId == 0) myId = handlingGeneral.getUniqueId()
                                        row.mouseOverId = myId
                                        row.mouseOver = true
                                    }
                                    onExited: {
                                        resetMouseOver.oldId = myId
                                        resetMouseOver.restart()
                                    }
                                    onClicked: parent.parent.click()
                                }
                            }

                            function click() {

                                if(variables.visibleItem != "" && leftcol[outerIndex][index][1] != "quit")
                                    return

                                if(external)
                                    handlingExternal.executeExternal(leftcol[outerIndex][index][2], leftcol[outerIndex][index][5], filefoldermodel.currentFilePath)
                                else
                                    HandleShortcuts.executeInternalFunction(leftcol[outerIndex][index][2])

                                if(1*leftcol[outerIndex][index][3]) {
                                    if(external)
                                        toplevel.closePhotoQt()
                                    else if(!PQSettings.interfacePopoutMainMenu)
                                        forceHide = true
                                }
                            }

                        }

                    }
                }

            }

        }

        Item {

            width: rightcol.length==0 ? 0 : (flick.width/2)
            height: row2.height

            Row {

                id: row2

                spacing: rightcolNormal ? 10 : 30

                property bool mouseOver: false
                property int mouseOverId: 0

                Timer {
                    id: resetMouseOver2
                    interval: 100
                    property int oldId
                    onTriggered: {
                        if(oldId === row2.mouseOverId)
                            row2.mouseOver = false
                    }
                }

                Repeater {
                    model: rightcol.length

                    Item {

                        y: (nav_col.height-height)/2

                        width: childrenRect.width
                        height: childrenRect.height

                        PQMouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: rightcol[index][4] && filefoldermodel.current==-1
                            tooltip: em.pty+qsTranslate("MainMenu", "You need to load an image first.")
                        }

                        Image {
                            enabled: !rightcol[index][4] || filefoldermodel.current!=-1

                            y: rightcolNormal ? 0.2*height : 0
                            visible: rightcol[index][0] == "img"
                            source: visible ? ("/mainmenu/" + rightcol[index][1]) : ""
                            height: visible ? (rightcolNormal ? (txt2.height*0.8) : (txt2.height*2)) : 0
                            width: height
                            sourceSize: Qt.size(width,height)
                            smooth: false
                            opacity: enabled ? (row2.mouseOver ? 1 : 0.8) : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                property int myId: 0
                                onEntered: {
                                    resetMouseOver2.stop()
                                    if(myId == 0) myId = handlingGeneral.getUniqueId()
                                    row2.mouseOverId = myId
                                    row2.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver2.oldId = myId
                                    resetMouseOver2.restart()
                                }
                                onClicked: parent.parent.click()
                            }
                        }
                        PQText {
                            enabled: !rightcol[index][4] || filefoldermodel.current!=-1
                            id: txt2
                            visible: rightcol[index][0] == "txt"
                            text: visible ? rightcol[index][1] : " "
                            opacity: enabled ? (row2.mouseOver ? 1 : 0.8) : 0.4
                            Behavior on opacity { NumberAnimation { duration: 200 } }

                            PQMouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                property int myId: 0
                                onEntered: {
                                    resetMouseOver2.stop()
                                    if(myId == 0) myId = handlingGeneral.getUniqueId()
                                    row2.mouseOverId = myId
                                    row2.mouseOver = true
                                }
                                onExited: {
                                    resetMouseOver2.oldId = myId
                                    resetMouseOver2.restart()
                                }
                                onClicked: parent.parent.click()
                            }
                        }

                        function click() {

                            if(variables.visibleItem != "" && rightcol[index][1] != "quit")
                                return

                            HandleShortcuts.executeInternalFunction(rightcol[index][2])
                            if(!PQSettings.interfacePopoutMainMenu && rightcol[index][3])
                                forceHide = true
                        }

                    }

                }

            }

        }

    }

}
