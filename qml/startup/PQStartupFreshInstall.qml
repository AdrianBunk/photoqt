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
import QtQuick.Controls 2.2
import PQStartup 1.0

Window {

    id: top_first

    //: Window title
    title: "Welcome to PhotoQt"

    minimumWidth: 800
    minimumHeight: 600

    color: "#ffffff"

    x: (Screen.width - width)/2
    y: (Screen.height - height)/2

    PQStartup {
        id: startup
    }

    Item {

        anchors.fill: parent

        Column {

            spacing: 10
            x: 5
            width: top_first.width-10

            Item {
                width: 1
                height: 10
            }

            Text {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "Welcome to PhotoQt"
                font.pointSize: 25
                font.bold: true
            }

            Item {
                width: 1
                height: 10
            }

            Text {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: "PhotoQt is an image viewer that aims to be very flexible in order to adapt to your needs and workflow instead of the other way around. Thus, most things and behaviours can be adjusted in the settings manager. Below you can choose one of three sets of default settings to start out with."
            }

            Text {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                font.bold: true
                text: "If you do not know what to do here, that is nothing to worry about: Simply click on continue."
            }

            Item {
                width: 1
                height: 1
            }

            Row {

                id: optrow

                x: (parent.width-width)/2

                spacing: 20

                property int maxRadioheight: 0

                Column {

                    Image {
                        width: 150
                        height: 100
                        fillMode: Image.PreserveAspectFit
                        source: "/startup/single.svg"
                        sourceSize: Qt.size(width, height)
                        opacity: radio_single.checked ? 1 : 0.5
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                                radio_single.checked = true
                        }
                    }

                    RadioButton {
                        id: radio_single
                        x: (150-width)/2
                        text: ""
                        ButtonGroup.group: radiogroup
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    Text {
                        width: 150
                        horizontalAlignment: Text.AlignHCenter
                        //: one of three sets of default settings in the welcome screen
                        text: "show everything integrated into main window"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: radio_single.checked ? "#000000" : "#888888"
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: radio_single.checked = true
                        }
                    }

                }

                Column {

                    Image {
                        width: 150
                        height: 100
                        fillMode: Image.PreserveAspectFit
                        source: "/startup/mixed.svg"
                        sourceSize: Qt.size(width, height)
                        opacity: radio_mixed.checked ? 1 : 0.5
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                                radio_mixed.checked = true
                        }
                    }

                    RadioButton {
                        id: radio_mixed
                        x: (150-width)/2
                        text: ""
                        ButtonGroup.group: radiogroup
                        checked: true
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    Text {
                        width: 150
                        horizontalAlignment: Text.AlignHCenter
                        //: one of three sets of default settings in the welcome screen
                        text: "show some things integrated into the main window and some on their own"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: radio_mixed.checked ? "#000000" : "#888888"
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: radio_mixed.checked = true
                        }
                    }

                }

                Column {


                    Image {
                        width: 150
                        height: 100
                        fillMode: Image.PreserveAspectFit
                        source: "/startup/individual.svg"
                        sourceSize: Qt.size(width, height)
                        opacity: radio_individual.checked ? 1 : 0.5
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked:
                                radio_individual.checked = true
                        }
                    }

                    RadioButton {
                        id: radio_individual
                        x: (150-width)/2
                        text: ""
                        ButtonGroup.group: radiogroup
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    Text {
                        width: 150
                        horizontalAlignment: Text.AlignHCenter
                        //: one of three sets of default settings in the welcome screen
                        text: "show everything in its own window"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        color: radio_individual.checked ? "#000000" : "#888888"
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: radio_individual.checked = true
                        }
                    }

                }

                ButtonGroup { id: radiogroup }

            }

            Item {
                width: 1
                height: 1
            }

            Text {
                width: parent.width
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                horizontalAlignment: Text.AlignHCenter
                text: "Note that you can change any and all of these settings (and many more) at any time from the settings manager."
            }

            Item {
                width: 1
                height: 20
            }

            Button {
                x: (parent.width-width)/2
                //: written on a clickable button
                text: "Continue"
                font.bold: true
                focus: true
                onClicked:
                    top_first.close()
            }

        }

    }

    Component.onCompleted: {
        top_first.showNormal()
    }

    onClosing: {

        // everything in one single window
        if(radio_single.checked)

            startup.setupFresh(0)

        // some integrated, some individual
        else if(radio_mixed.checked)

            startup.setupFresh(1)

        // everything in its own window
        else

            startup.setupFresh(2)

    }

    Shortcut {
        sequences: ["Escape", "Enter", "Return"]
        onActivated:
            top_first.close()
    }

}
