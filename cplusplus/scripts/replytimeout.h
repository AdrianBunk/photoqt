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

#ifndef PQREPLYTIMEOUT_H
#define PQREPLYTIMEOUT_H

#include <QObject>
#include <QTimerEvent>
#include <QBasicTimer>
#include <QNetworkReply>

class PQReplyTimeout : public QObject {
    Q_OBJECT
    QBasicTimer m_timer;
public:
    PQReplyTimeout(QNetworkReply* reply, const int timeout) : QObject(reply) {
        Q_ASSERT(reply);
        if (reply && reply->isRunning())
            m_timer.start(timeout, this);
    }
    static void set(QNetworkReply* reply, const int timeout) {
        new PQReplyTimeout(reply, timeout);
    }
protected:
    void timerEvent(QTimerEvent * ev) {
        if (!m_timer.isActive() || ev->timerId() != m_timer.timerId())
            return;
        auto reply = static_cast<QNetworkReply*>(parent());
        if (reply->isRunning())
            reply->close();
        m_timer.stop();
    }
};

#endif // PQREPLYTIMEOUT_H
