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
import Qt.labs.platform 1.0

import "../../../elements"
import "../../../shortcuts/mouseshortcuts.js" as PQAnalyseMouse

Rectangle {

    id: newaction_top

    parent: settingsmanager_top

    anchors.fill: parent

    color: "#ee000000"

    opacity: 0
    visible: opacity > 0
    Behavior on opacity { NumberAnimation { duration: PQSettings.imageviewAnimationDuration*100 } }

    signal addAction(var idx, var act)
    signal updateAction(var idx, var subidx, var act)

    property var categories: [
        "viewingimages",
        "currentimage",
        "currentfolder",
        "interface",
        "other",
        "external"
    ]

    property var categoriesToIndex: {
        "viewingimages" : 0,
        "currentimage" : 1,
        "currentfolder" : 2,
        "interface" : 3,
        "other" : 4,
        "external" : 5
    }

    property var categoryTitles: {
                          //: This is a shortcut category
        "viewingimages" : em.pty+qsTranslate("settingsmanager_shortcuts", "Viewing images"),
                          //: This is a shortcut category
        "currentimage"  : em.pty+qsTranslate("settingsmanager_shortcuts", "Current image"),
                          //: This is a shortcut category
        "currentfolder" : em.pty+qsTranslate("settingsmanager_shortcuts", "Current folder"),
                          //: This is a shortcut category
        "interface"     : em.pty+qsTranslate("settingsmanager_shortcuts", "Interface"),
                          //: This is a shortcut category
        "other"         : em.pty+qsTranslate("settingsmanager_shortcuts", "Other"),
                          //: This is a shortcut category
        "external"      : em.pty+qsTranslate("settingsmanager_shortcuts", "External")
    }

    property var descriptions: [
        em.pty+qsTranslate("settingsmanager_shortcuts", "These actions affect the behavior of PhotoQt when viewing images. They include actions for navigating between images and manipulating the current image (zoom, flip, rotation) amongst others."),
        em.pty+qsTranslate("settingsmanager_shortcuts", "These actions are certain things that can be done with the currently viewed image. They typically do not affect any of the other images."),
        em.pty+qsTranslate("settingsmanager_shortcuts", "These actions affect the currently loaded folder as a whole and not just single images."),
        em.pty+qsTranslate("settingsmanager_shortcuts", "These actions affect the status and behavior of various interface elements regardless of the status of any possibly loaded image."),
        em.pty+qsTranslate("settingsmanager_shortcuts", "These actions do not fit into any other category."),
        em.pty+qsTranslate("settingsmanager_shortcuts", "Here any external executable can be set as shortcut action. The button with the three dots can be used to select an executable with a file dialog.")
    ]

    property var actionsByCategory: [[], [], [], [], [],[]]

    property int selectedCategory: 0

    property int currentShortcutIndex: -1
    property int currentShortcutSubIndex: -1
    property string currentShortcutAction: ""

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked:
            hide()
    }

    PQTextXL {
        id: titletxt
        y: insidecont.y-2*height
        width: parent.width
        font.weight: baselook.boldweight
        horizontalAlignment: Text.AlignHCenter
        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Shortcut actions")
    }

    Rectangle {

        id: insidecont

        x: (parent.width-width)/2
        y: (parent.height-height)/2-10
        width: Math.min(800, parent.width)
        height: Math.min(600, parent.height-2*titletxt.height-2*butcont.height-40)

        color: "#000000"

        MouseArea {
            anchors.fill: parent
            anchors.margins: -10
            hoverEnabled: true
        }

        ListView {

            id: cattabs

            orientation: ListView.Vertical
            interactive: false

            y: (parent.height-height)/2

            width: 200
            height: insidecont.height

            model: 6

            delegate:
                Rectangle {
                    width: parent.width
                    height: insidecont.height/6

                    border {
                        width: 1
                        color: "#555555"
                    }

                    color: selectedCategory==index
                                ? "#555555"
                                : (mouse.containsPress
                                   ? "#444444"
                                   : (mouse.containsMouse
                                      ? "#3a3a3a"
                                      : "#333333"))

                    PQText {
                        anchors.fill: parent
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.weight: baselook.boldweight
                        text: categoryTitles[categories[index]]
                    }
                    PQMouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            newaction_top.selectedCategory = index
                        }
                    }
                }
        }

        Rectangle {
            color: "#181818"

            x: cattabs.width
            width: parent.width-cattabs.width
            height: parent.height

            PQText {
                id: desclabel
                x: 10
                y: 10
                width: parent.width-20
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                text: descriptions[selectedCategory]
            }

            // these are categories 1-5, all except external shortcuts
            ListView {
                id: actionsview
                y: desclabel.height+20
                width: parent.width
                height: parent.height-desclabel.height-25
                visible: selectedCategory<5
                orientation: ListView.Vertical
                model: actionsByCategory[selectedCategory].length
                spacing: 4
                clip: true
                ScrollBar.vertical: PQScrollBar { id: scroll }
                delegate:
                    Rectangle {
                        x: 5
                        width: actionsview.width-10-(scroll.visible ? scroll.width : 0)
                        height: dsclabel.height+10
                        radius: 5
                        color: actionmouse.containsMouse ? "#555555" : (newaction_top.currentShortcutAction==actionsByCategory[selectedCategory][index][0] ? "#444444" : "#333333")
                        Behavior on color { ColorAnimation { duration: 200 } }
                        PQText {
                            id: dsclabel
                            x: 5
                            y: 5
                            width: parent.width-10
                            text: actionsByCategory[selectedCategory][index][1]
                        }
                        PQMouseArea {
                            id: actionmouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if(newaction_top.currentShortcutSubIndex == -1)
                                    addAction(newaction_top.currentShortcutIndex, actionsByCategory[selectedCategory][index][0])
                                else
                                    updateAction(newaction_top.currentShortcutIndex, newaction_top.currentShortcutSubIndex, actionsByCategory[selectedCategory][index][0])
                                hide()
                            }
                        }
                    }
            }

            // This is category 6, external shortcuts
            Flickable {

                id: externalview
                y: desclabel.height+20
                width: parent.width - (extscroll.visible ? extscroll.width : 0)
                height: parent.height-desclabel.height-20
                contentHeight: extcol.height
                clip: true
                visible: selectedCategory==5
                ScrollBar.vertical: PQScrollBar { id: extscroll }

                Column {

                    id: extcol

                    x: 20
                    width: parent.width-40

                    spacing: 10

                    Item {
                        width: 1
                        height: 1
                    }


                    PQText {
                        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Select an executable")
                        font.weight: baselook.boldweight
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }

                    Row {

                        spacing: 5

                        PQLineEdit {
                            id: ext_exe
                            width: 300
                            placeholderText: "executable"
                        }

                        PQButton {
                            id: exebut
                            text: "..."
                            tooltip: em.pty+qsTranslate("settingsmanager_shortcuts", "Click here to select an executable.")
                            onClicked: {
                                selectExec.folder = "file:///"+(ext_exe.text.slice(0,1) == "/"
                                                               ? handlingFileDir.getDirectory(ext_exe.text)
                                                               : (handlingGeneral.amIOnWindows()
                                                                  ? handlingFileDir.getHomeDir()
                                                                  : "/usr/bin/"))
                                selectExec.visible = true
                            }
                        }

                    }

                    Item {
                        width: 1
                        height: 1
                    }

                    PQText {
                        width: parent.width
                        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Additional flags and options to pass on:")
                        font.weight: baselook.boldweight
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    }


                    PQLineEdit {
                        id: ext_flags
                        width: 300
                        placeholderText: "additional flags"
                        tooltipText: text=="" ? placeholderText : (placeholderText + ": " + text)
                    }

                    PQText {
                        width: parent.width
                        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Note that relative file paths are not supported, however, you can use the following placeholders:") + "\n" +
                              "%f = " + em.pty+qsTranslate("settingsmanager_shortcuts", "filename including path") + "\n" +
                              "%u = " + em.pty+qsTranslate("settingsmanager_shortcuts", "filename without path") + "\n" +
                              "%d = " + em.pty+qsTranslate("settingsmanager_shortcuts", "directory containing file") + "\n\n" +
                              em.pty+qsTranslate("settingsmanager_shortcuts", "If you type out a path, make sure to escape spaces accordingly by prepending a backslash:") + " '\\ '"
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    PQCheckbox {
                        id: ext_quit
                        text: em.pty+qsTranslate("settingsmanager_shortcuts", "quit after calling executable")
                    }

                    Item {
                        width: 1
                        height: 10
                    }

                    PQButton {
                        text: em.pty+qsTranslate("settingsmanager_shortcuts", "Save external action")
                        onClicked: {
                            var act = ext_exe.text + ":/:/:" + ext_flags.text + ":/:/:" + (ext_quit.checked ? 1 : 0)
                            if(newaction_top.currentShortcutSubIndex == -1)
                                addAction(newaction_top.currentShortcutIndex, act)
                            else
                                updateAction(newaction_top.currentShortcutIndex, newaction_top.currentShortcutSubIndex, act)
                            hide()
                        }
                    }

                }

            }

        }

    }


    Item {

        id: butcont
        x: (parent.width-width)/2
        y: insidecont.y+insidecont.height+height
        width: row.width
        height: row.height

        Row {
            id: row
            spacing: 10
            PQButton {
                id: savebut
                text: genericStringCancel
                onClicked: {
                    hide()
                }
            }
        }

    }

    FileDialog {
        id: selectExec
        modality: Qt.ApplicationModal
        fileMode: FileDialog.OpenFile
        onAccepted: {

            if(selectExec.file == "")
                return

            var fname = handlingFileDir.getFileNameFromFullPath(selectExec.file)

            if(StandardPaths.findExecutable(fname) == selectExec.file)
                ext_exe.text = fname
            else
                ext_exe.text = handlingFileDir.cleanPath(selectExec.file)

        }
    }

    Component.onCompleted: {
        //: A shortcuts category: actions with current folder

        for(var cmd in tab_shortcuts.actions) {

            var cat = tab_shortcuts.actions[cmd][1]
            var idx = categoriesToIndex[cat]
            var dsc = tab_shortcuts.actions[cmd][0]

            actionsByCategory[idx].push([cmd,dsc])

        }

        actionsByCategoryChanged()

    }

    Connections {
        target: settingsmanager_top
        onCloseModalWindow: {
            hide()
        }
    }

    function change(index, subindex) {

        var cur = tab_shortcuts.entries[index][1][subindex]

        if(cur.startsWith("__")) {

            if(cur in tab_shortcuts.actions) {
                var cat = categoriesToIndex[tab_shortcuts.actions[cur][1]]
                selectedCategory = cat
            }

        } else {

            selectedCategory = 5

            var parts = cur.split(":/:/:")
            ext_exe.text = parts[0]
            ext_flags.text = parts[1]
            ext_quit.checked = (parts[2]*1==1)

        }

        newaction_top.opacity = 1
        settingsmanager_top.modalWindowOpen = true
        newaction_top.currentShortcutIndex = index
        newaction_top.currentShortcutSubIndex = subindex
        newaction_top.currentShortcutAction = cur

    }

    function show(index) {

        newaction_top.opacity = 1
        settingsmanager_top.modalWindowOpen = true
        newaction_top.currentShortcutIndex = index
        newaction_top.currentShortcutSubIndex = -1
        newaction_top.currentShortcutAction = ""
        ext_exe.text = ""
        ext_flags.text = ""
        ext_quit.checked = false
    }

    function hide() {

        newaction_top.opacity = 0
        settingsmanager_top.modalWindowOpen = false

    }

}
