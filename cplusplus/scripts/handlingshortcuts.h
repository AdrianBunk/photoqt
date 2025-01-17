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

#ifndef PQHANDLINGSHORTCUTS_H
#define PQHANDLINGSHORTCUTS_H

#include <QObject>
#include <QFile>
#include <QKeySequence>
#include <QProcess>
#include "../logger.h"

class PQHandlingShortcuts : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE QString composeDisplayString(QString combo);
    Q_INVOKABLE QString composeString(Qt::KeyboardModifiers mods, Qt::Key keys);
    Q_INVOKABLE int convertCharacterToKeyCode(QString key);
    Q_INVOKABLE QString convertKeyCodeToText(int id);

    Q_INVOKABLE int getNextCommandInCycle(QString combo, int timeout, int maxCmd);
    Q_INVOKABLE void resetCommandCycle(QString combo);

private:
    QMap<QString, QList<qint64>> commandCycle;

};


#endif // PQHANDLINGSHORTCUTS_H
