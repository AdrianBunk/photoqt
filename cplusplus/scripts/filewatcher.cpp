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

#include "filewatcher.h"

PQFileWatcher::PQFileWatcher(QObject *parent) : QObject(parent) {

    userPlacesWatcher = new QFileSystemWatcher;
    connect(userPlacesWatcher, &QFileSystemWatcher::fileChanged, this, &PQFileWatcher::userPlacesChangedSLOT);
    userPlacesWatcher->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");

    contextmenuWatcher = new QFileSystemWatcher;
    connect(contextmenuWatcher, &QFileSystemWatcher::fileChanged, this, &PQFileWatcher::contextmenuChangedSLOT);
    contextmenuWatcher->addPath(ConfigFiles::CONTEXTMENU_DB());

    currentFileWatcher = new QFileSystemWatcher;
    connect(currentFileWatcher, &QFileSystemWatcher::fileChanged, this, &PQFileWatcher::currentFileChangedSLOT);

    checkRepeatedly = new QTimer;
    checkRepeatedly->setInterval(2500);
    checkRepeatedly->setSingleShot(false);
    connect(checkRepeatedly, &QTimer::timeout, this, &PQFileWatcher::checkRepeatedlyTimeout);
    checkRepeatedly->start();

}

PQFileWatcher::~PQFileWatcher() {
    delete userPlacesWatcher;
    delete contextmenuWatcher;
    delete currentFileWatcher;
    delete checkRepeatedly;
}

void PQFileWatcher::checkRepeatedlyTimeout() {

    DBG << CURDATE << "PQFileWatcher::checkRepeatedlyTimeout()" << NL;

    if(!userPlacesWatcher->files().contains(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel")) {
        if(QFile(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel").exists())
            userPlacesWatcher->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");
    }

    if(!contextmenuWatcher->files().contains(ConfigFiles::CONTEXTMENU_DB())) {
        if(QFile(ConfigFiles::CONTEXTMENU_DB()).exists())
            contextmenuWatcher->addPath(ConfigFiles::CONTEXTMENU_DB());
    }

}

void PQFileWatcher::userPlacesChangedSLOT() {

    DBG << CURDATE << "PQFileWatcher::userPlacesChangedSLOT()" << NL;

    QFileInfo info(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");
    for(int i = 0; i < 5; ++i) {
        if(info.exists())
            break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    Q_EMIT userPlacesChanged();

    if(info.exists())
        userPlacesWatcher->addPath(ConfigFiles::GENERIC_DATA_DIR() + "/user-places.xbel");

}

void PQFileWatcher::contextmenuChangedSLOT() {

    DBG << CURDATE << "PQFileWatcher::contextmenuChangedSLOT()" << NL;

    QFileInfo info(ConfigFiles::CONTEXTMENU_DB());
    for(int i = 0; i < 5; ++i) {
        if(info.exists())
            break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    Q_EMIT contextmenuChanged();

    if(info.exists())
        contextmenuWatcher->addPath(ConfigFiles::CONTEXTMENU_DB());

}

void PQFileWatcher::currentFileChangedSLOT() {

    DBG << CURDATE << "PQFileWatcher::currentFileChangedSLOT()" << NL;

    QFileInfo info(currentFile);
    for(int i = 0; i < 5; ++i) {
        if(info.exists())
            break;
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    Q_EMIT currentFileChanged();

    if(info.exists())
        contextmenuWatcher->addPath(currentFile);

}

void PQFileWatcher::setCurrentFile(QString file) {

    currentFile = file;
    delete currentFileWatcher;
    currentFileWatcher = new QFileSystemWatcher;

    if(file != "") {
        connect(currentFileWatcher, &QFileSystemWatcher::fileChanged, this, &PQFileWatcher::currentFileChangedSLOT);
        currentFileWatcher->addPath(currentFile);
    }

}
