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
import "../templates"
import "../elements"

PQTemplateFullscreen {

    id: about_top

    popout: PQSettings.interfacePopoutImgur
    shortcut: ""
    showPopinPopout: false
    title: em.pty+qsTranslate("imgur", "Upload to imgur.com")

    button1.text: genericStringCancel

    onPopoutChanged:
        PQSettings.interfacePopoutImgur = popout

    button1.onClicked:
        abortUpload()

    property bool anonymous: false
    property string accountname: ""

    content: [


        PQTextL {
            x: (parent.width-width)/2
            font.weight: baselook.boldweight
            font.italic: true
            visible: !report.visible
            //: Used as in: Upload image as anonymous user
            text: anonymous ? em.pty+qsTranslate("imgur", "anonymous upload") : ("Account: " + accountname)
        },

        Item {
            width: 1
            height: 10
        },

        Item {

            width: childrenRect.width
            height: childrenRect.height
            x: (parent.width-width)/2

            PQProgress {

                id: progress
                anchors.centerIn: report

                visible: !report.visible && !error.visible && !nointernet.visible

                onProgressChanged:
                        opacity = (progress.progress == 100) ? 0 : 1

            }

            PQText {
                anchors.centerIn: report
                opacity: 1-progress.opacity
                visible: !report.visible && !error.visible && !nointernet.visible
                text: em.pty+qsTranslate("imgur", "Obtaining image url...")
            }

            PQText {
                id: longtime
                anchors.top: progress.bottom
                opacity: 1-progress.opacity
                visible: !report.visible && !error.visible && !nointernet.visible
                color: "red"
                horizontalAlignment: Text.AlignHCenter
                text: em.pty+qsTranslate("imgur", "This seems to take a long time...") + "<br>" +
                      em.pty+qsTranslate("imgur", "There might be a problem with your internet connection or the imgur.com servers.")
            }

            PQText {
                id: error
                property int code: 0
                anchors.centerIn: report
                visible: false
                color: "red"
                horizontalAlignment: Text.AlignHCenter
                text: em.pty+qsTranslate("imgur", "An Error occurred while uploading image!") + "<br>" +
                      em.pty+qsTranslate("imgur", "Error code:") + " " + code
            }

            PQText {
                id: nointernet
                property int code: 0
                anchors.centerIn: report
                visible: false
                color: "red"
                horizontalAlignment: Text.AlignHCenter
                text: em.pty+qsTranslate("imgur", "You do not seem to be connected to the internet...") + "<br>" +
                      em.pty+qsTranslate("imgur", "Unable to upload!")
            }

            Item {
                id: report
                x: (longtime.width-width)/2
                property string accessurl: "http://imgur.com/........"
                property string deleteurl: "http://imgur.com/........"
                visible: true

                width: childrenRect.width
                height: childrenRect.height

                Column {

                    spacing: 10

                    width: childrenRect.width
                    height: childrenRect.height

                    PQTextL {
                        text: em.pty+qsTranslate("imgur", "Access Image")
                        font.weight: baselook.boldweight
                    }

                    PQTextL {
                        text: report.accessurl
                        PQMouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            tooltip: em.pty+qsTranslate("imgur", "Click to open in browser")
                            onClicked:
                                Qt.openUrlExternally(parent.text)
                        }
                    }

                    PQButton {
                        text: em.pty+qsTranslate("imgur", "Copy to clipboard")
                        onClicked:
                            handlingExternal.copyTextToClipboard(report.accessurl)
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    PQTextL {
                        text: em.pty+qsTranslate("imgur", "Delete Image")
                        font.weight: baselook.boldweight
                    }

                    PQTextL {
                        text: report.deleteurl
                        PQMouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            tooltip: em.pty+qsTranslate("imgur", "Click to open in browser")
                            onClicked:
                                Qt.openUrlExternally(parent.text)
                        }
                    }

                    PQButton {
                        text: em.pty+qsTranslate("imgur", "Copy to clipboard")
                        onClicked:
                            handlingExternal.copyTextToClipboard(report.deleteurl)
                    }

                }

            }

        }

    ]

    Connections {
        target: loader
        onImgurPassOn: {
            if(what == "show" || what == "show_anonym") {

                if(filefoldermodel.current == -1)
                    return

                anonymous = (what == "show_anonym")
                progress.progress = 0
                longtime.visible = false
                error.visible = false
                nointernet.visible = false
                report.visible = false

                opacity = 1
                variables.visibleItem = "imgur"

                // Some of the actions in there would block the GUI if started in main thread
                // -> timer with timeout=0 moves it to subthread
                startupload.start()

            } else if(what == "hide") {
                abortUpload()
            } else if(what == "keyevent") {
                if(param[0] == Qt.Key_Escape)
                    abortUpload()
            }
        }
    }

    Timer {
        id: startupload
        interval: 0
        repeat: false
        running: false
        onTriggered: {
            if(!handlingShareImgur.checkIfConnectedToInternet())
                nointernet.visible = true

            handlingShareImgur.authorizeHandlePin("68713a8441")

            if(!anonymous) {
                var ret = handlingShareImgur.authAccount()
                if(ret !== 0) {
                    abortUpload()
                    return
                }
                accountname = handlingShareImgur.getAccountUsername()
                handlingShareImgur.upload(filefoldermodel.currentFilePath)
            } else {
                accountname = ""
                handlingShareImgur.anonymousUpload(filefoldermodel.currentFilePath)
            }
        }
    }

    function abortUpload() {
        handlingShareImgur.abort()
        opacity = 0
        variables.visibleItem = ""
    }

}
