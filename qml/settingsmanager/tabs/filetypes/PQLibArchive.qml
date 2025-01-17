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
    id: set
    //: A settings title
    title: "LibArchive"
    helptext: em.pty+qsTranslate("settingsmanager_filetypes", "These are some additional settings for opening archives.")
    expertmodeonly: true
    available: handlingGeneral.isLibArchiveSupportEnabled()
    content: [

        Row {

            spacing: 10

            PQCheckbox {
                id: ext_unrar
                tooltip: "LibArchive supports RAR archives only partially and might fail to read certain archives. If installed, PhotoQt can use the external tool unrar instead of libarchive for proper support of RAR archives."
                //: used as label for checkbox
                text: em.pty+qsTranslate("settingsmanager_filetypes", "use external tool: unrar")
            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            load()
        }

        onSaveAllSettings: {
            PQSettings.filetypesExternalUnrar = ext_unrar.checked
        }

    }

    Component.onCompleted: {
        load()
    }

    function load() {

        ext_unrar.checked = PQSettings.filetypesExternalUnrar

    }


}
