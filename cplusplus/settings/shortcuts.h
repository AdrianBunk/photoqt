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

 /* auto-generated using generatesettings.py */

#ifndef PQSHORTCUTS_H
#define PQSHORTCUTS_H

#include <QObject>
#include <QTimer>
#include <QtSql>
#include <QMessageBox>

#include "../logger.h"

class PQShortcuts : public QObject {

    Q_OBJECT

public:
    static PQShortcuts& get() {
        static PQShortcuts instance;
        return instance;
    }
    ~PQShortcuts();

    PQShortcuts(PQShortcuts const&)     = delete;
    void operator=(PQShortcuts const&) = delete;

    Q_INVOKABLE void setDefault();

    Q_INVOKABLE QVariantList getCommandsForShortcut(QString combo);
    Q_INVOKABLE QVariantList getAllCurrentShortcuts();
    Q_INVOKABLE void saveAllCurrentShortcuts(QVariantList list);

    bool backupDatabase();

public Q_SLOTS:
    void readDB();

private:
    PQShortcuts();

    QStringList shortcutsOrder;
    QMap<QString,QVariantList> shortcuts;

    QSqlDatabase db;
    bool readonly;
    bool dbIsTransaction;
    QTimer *dbCommitTimer;

Q_SIGNALS:
    void aboutChanged();

};

#endif // PQSHORTCUTS_H
