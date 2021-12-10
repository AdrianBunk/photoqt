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

#include "imageprovidericon.h"

QImage PQImageProviderIcon::requestImage(const QString &icon, QSize *origSize, const QSize &requestedSize) {

    DBG << CURDATE << "PQImageProviderIcon::requestPixmap() " << NL
        << CURDATE << "** icon = " << icon.toStdString() << NL
        << CURDATE << "** requestedSize = " << requestedSize.width() << "x" << requestedSize.height() << NL;

    QSize use = requestedSize;

    if(use == QSize(-1,-1)) {
        use.setWidth(256);
        use.setHeight(256);
        origSize->setWidth(256);
        origSize->setHeight(256);
    } else {
        origSize->setWidth(requestedSize.width());
        origSize->setHeight(requestedSize.width());
    }


    // get filetype icon
    if(icon.startsWith("IMAGE////")) {

        QString i = const_cast<QString&>(icon);
        QString suf = i.remove(0,9);

        if(QFile::exists(QString(":/filetypes/%1.ico").arg(suf.toLower())))
            return QImage(QString(":/filetypes/%1.ico").arg(suf.toLower()));
        else
            return QImage(":/filetypes/unknown.ico");

    }

    // Attempt to load icon from current theme
    QIcon ico = QIcon::fromTheme(icon);
    QImage ret = QImage(ico.pixmap(use).toImage());

    // If icon is not available or if on Windows, choose from a small selection of custom provided icons
    // These backup icons are taken from the Breese-Dark icon theme, created by KDE/Plasma
    if(ret.isNull()) {
        LOG << CURDATE << "ImageProviderIcon: Icon not found in theme, using fallback icon: " << icon.toStdString() << NL;
        if(QFile(":/filedialog/backupicons/" + icon + ".svg").exists())
            ret = QImage(":/filedialog/backupicons/" + icon + ".svg");
        else if(icon.contains("folder") || icon.contains("directory"))
            ret = QImage(":/filedialog/backupicons/folder.svg");
        else if(icon.contains("image"))
            ret = QImage(":/filedialog/backupicons/image.svg");
        else
            ret = QImage(":/filedialog/backupicons/unknown.svg");
    }

    return ret;

}
