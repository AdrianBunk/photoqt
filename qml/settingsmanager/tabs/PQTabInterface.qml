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

import "./interface"
import "../../elements"

Item {

    Flickable {

        id: cont

        contentHeight: col.height
        onContentHeightChanged: {
            if(visible)
                settingsmanager_top.scrollBarVisible = scroll.visible
        }

        width: stack.width
        height: stack.height

        ScrollBar.vertical: PQScrollBar { id: scroll }

        maximumFlickVelocity: 1500
        boundsBehavior: Flickable.StopAtBounds

        Rectangle {

            x: 278
            y: desc.y+desc.height+col.spacing
            width: 2
            height: cont.contentHeight-y
            color: "#88444444"

        }

        Column {

            id: col

            x: 10
            y: 0

            spacing: 15

            Item {
                width: 1
                height: 1
            }

            PQTextXL {
                id: title
                width: cont.width-20
                horizontalAlignment: Text.AlignHCenter
                font.weight: baselook.boldweight
                text: em.pty+qsTranslate("settingsmanager", "Interface settings")
            }

            Item {
                width: 1
                height: 1
            }

            PQText {
                id: desc
                width: cont.width-20
                wrapMode: Text.WordWrap
                text: em.pty+qsTranslate("settingsmanager", "These settings affect the interface in general, how the application looks like and behaves. This includes the background, some of the labels in the main view, which elements are to be shown in their own window, and others.") + "\n" + em.pty+qsTranslate("settingsmanager", "Some settings are only shown in expert mode.")
            }

            PQLanguage { id: lng }
                PQHorizontalLine { expertModeOnly: lng.expertmodeonly }
            PQStatusInfo { id: sti }
                PQHorizontalLine { expertModeOnly: sti.expertmodeonly }
            PQWindowMode { id: wmo }
                PQHorizontalLine { expertModeOnly: wmo.expertmodeonly }
            PQWindowButtons { id: wbt }
                PQHorizontalLine { expertModeOnly: wbt.expertmodeonly }
            PQNavigation { id: nav }
                PQHorizontalLine { expertModeOnly: nav.expertmodeonly }
            PQTrayIcon { id: tic }
                PQHorizontalLine { expertModeOnly: tic.expertmodeonly }
            PQOpenGL { id: ogl }
                PQHorizontalLine { expertModeOnly: ogl.expertmodeonly }
            PQBackground { id: bck }
                PQHorizontalLine { expertModeOnly: bck.expertmodeonly }
            PQOverlayColor { id: ovc }
                PQHorizontalLine { expertModeOnly: ovc.expertmodeonly }
            PQBlurElementsInBackground { id: blu }
                PQHorizontalLine { expertModeOnly: blu.expertmodeonly }
            PQPopout { id: pop }
                PQHorizontalLine { expertModeOnly: pop.expertmodeonly }
            PQPopoutWhenSmall { id: psm }
                PQHorizontalLine { expertModeOnly: psm.expertmodeonly }
            PQStartupLoadLast { id: sll }
                PQHorizontalLine { expertModeOnly: sll.expertmodeonly }
            PQClickOnEmpty { id: coe }
                PQHorizontalLine { expertModeOnly: coe.expertmodeonly }
            PQHotEdgeWidth { id: hew }
                PQHorizontalLine { expertModeOnly: hew.expertmodeonly }
            PQWindowManagement { id: wma }
                PQHorizontalLine { expertModeOnly: wma.expertmodeonly }
            PQMouseWheel { id: mwh }
                PQHorizontalLine { expertModeOnly: mwh.expertmodeonly }
            PQContextMenu { id: ctx }

            // add some spacing at the bottom
            Item { width: 1; height: 25 }


        }

        Connections {
            target: settingsmanager_top
            onIsScrollBarVisible: {
                if(visible)
                    settingsmanager_top.scrollBarVisible = scroll.visible
            }
        }

    }

}
