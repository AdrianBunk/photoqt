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

#ifndef VLCRENDERER_H_
#define VLCRENDERER_H_

#include <QtQuick/QQuickFramebufferObject>

#include <vlc/vlc.h>
#include "vlcqthelper.h"

class PQVLCRenderer;

class PQVLCObject : public QQuickFramebufferObject {

    Q_OBJECT

    libvlc_instance_t *vlc;

    friend class PQVLCRenderer;

public:
    static void on_update(void *vlc);

    PQVLCObject(QQuickItem * parent = 0);
    virtual ~PQVLCObject();
    virtual Renderer *createRenderer() const;

public Q_SLOTS:
    void command(const QVariant& params);
    void setProperty(const QString& name, const QVariant& value);
    QVariant getProperty(const QString& name);

Q_SIGNALS:
    void onUpdate();

private Q_SLOTS:
    void doUpdate();
};

#endif //VLCRENDERER_H_
