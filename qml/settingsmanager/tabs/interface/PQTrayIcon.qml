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
    //: A settings title.
    title: em.pty+qsTranslate("settingsmanager_interface", "tray icon")
    helptext: em.pty+qsTranslate("settingsmanager_interface", "If a tray icon is to be shown and, if shown, whether to hide it or not.")
    content: [
        Flow {
            width: set.contwidth
            spacing: 10

            PQComboBox {
                id: tray_combo
                model: [
                    em.pty+qsTranslate("settingsmanager_interface", "no tray icon"),
                    em.pty+qsTranslate("settingsmanager_interface", "hide to tray icon"),
                    em.pty+qsTranslate("settingsmanager_interface", "show tray icon but don't hide to it")
                ]
            }
            Item {

                width: childrenRect.width
                height: tray_combo.height

                PQCheckbox {
                    id: tray_reset
                    y: (parent.height-height)/2
                    enabled: tray_combo.currentIndex==1
                    text: em.pty+qsTranslate("settingsmanager_interface", "reset session when hiding")
                }

            }

        }

    ]

    Connections {

        target: settingsmanager_top

        onLoadAllSettings: {
            tray_combo.currentIndex = PQSettings.interfaceTrayIcon
            tray_reset.checked = PQSettings.interfaceTrayIconHideReset
        }

        onSaveAllSettings: {
            PQSettings.interfaceTrayIcon = tray_combo.currentIndex
            PQSettings.interfaceTrayIconHideReset = tray_reset.checked
        }

    }

}
