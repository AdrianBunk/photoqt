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

#ifndef PQFILEWATCHER_H
#define PQFILEWATCHER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QFileInfo>
#include <thread>
#include <QTimer>
#include "../configfiles.h"
#include "../logger.h"

class PQFileWatcher : public QObject {

    Q_OBJECT

public:
    explicit PQFileWatcher(QObject *parent = nullptr);
    ~PQFileWatcher();

    Q_INVOKABLE void setCurrentFile(QString file);

private:
    QFileSystemWatcher *userPlacesWatcher;
    QFileSystemWatcher *contextmenuWatcher;
    QFileSystemWatcher *currentFileWatcher;

    QTimer *checkRepeatedly;
    QString currentFile;

private Q_SLOTS:
    void userPlacesChangedSLOT();
    void contextmenuChangedSLOT();
    void currentFileChangedSLOT();

    void checkRepeatedlyTimeout();

Q_SIGNALS:
    void userPlacesChanged();
    void contextmenuChanged();
    void currentFileChanged();

};


#endif // PQFILEWATCHER_H
