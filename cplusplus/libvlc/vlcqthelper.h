/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

#ifndef LIBVLC_QTHELPER_H_
#define LIBVLC_QTHELPER_H_

#include <vlc/libvlc.h>

#include <cstring>

#include <QVariant>
#include <QString>
#include <QList>
#include <QHash>
#include <QSharedPointer>
#include <QMetaType>

namespace vlc {
namespace qt {

// Wrapper around mpv_handle. Does refcounting under the hood.
class Handle {

    struct container {
        container(libvlc_instance_t *h) : vlc(h) {}
        ~container() { libvlc_free(vlc); }
        libvlc_instance_t *vlc;
    };
    QSharedPointer<container> sptr;

public:
    // Construct a new Handle from a raw libvlc_instance_t with refcount 1. If the
    // last Handle goes out of scope, the libvlc_instance_t will be destroyed with
    // libvlc_free().
    // Never destroy the libvlc_instance_t manually when using this wrapper. You
    // will create dangling pointers. Just let the wrapper take care of
    // destroying the libvlc_instance_t.
    // Never create multiple wrappers from the same raw libvlc_instance_t; copy the
    // wrapper instead (that's what it's for).
    static Handle FromRawHandle(libvlc_instance_t *handle) {
        Handle h;
        h.sptr = QSharedPointer<container>(new container(handle));
        return h;
    }

    // Return the raw handle; for use with the libvlc C API.
    operator libvlc_instance_t*() const { return sptr ? (*sptr).vlc : 0; }
};

#endif // LIBVLC_QTHELPER_H_
