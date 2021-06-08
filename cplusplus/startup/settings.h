/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2021 Lukas Spies                                  **
 ** Contact: http://photoqt.org                                          **
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

#ifndef PQSTARTUP_SETTINGS_H
#define PQSTARTUP_SETTINGS_H

#include <QFile>
#include "../configfiles.h"
#include "../logger.h"
#include "../settings/settings.h"

namespace PQStartup {

    namespace Settings {

        static void updateNameChanges() {

            QFile settingsfile(ConfigFiles::SETTINGS_FILE());
            if(settingsfile.exists() && settingsfile.open(QIODevice::ReadWrite)) {

                QTextStream in(&settingsfile);
                QString txt = in.readAll();

                // Make sure we catch the new name (since 2.2)
                txt = txt.replace("QuickInfo", "Labels");
                QTextStream out(&settingsfile);
                out << txt;

                settingsfile.close();

                // Default value set to 0. Systems with a lot of snaps ave a lot of entries here, so we 'force-hide' it.
                PQSettings::get().setOpenUserPlacesVolumes(0);

                // Make sure the right version is set in the settings file
                PQSettings::get().setVersion(VERSION);

            }

        }

    }

}

#endif // PQSTARTUP_SETTINGS_H
