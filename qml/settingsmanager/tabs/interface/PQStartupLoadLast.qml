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

import "../../../elements"

PQSetting {
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "remember last image")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "At startup the image loaded at the end of the last session can be automatically reloaded.")
    content: [
        PQCheckbox {
            id: start_load_last
            text: em.pty+qsTranslate("settingsmanager_interface", "re-open last loaded image at startup")
        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            start_load_last.checked = PQSettings.interfaceRememberLastImage
        }

        onSaveAllSettings: {
            PQSettings.interfaceRememberLastImage = start_load_last.checked
        }

    }

}
