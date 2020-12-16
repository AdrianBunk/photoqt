/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2020 Lukas Spies                                  **
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

#ifndef PQLOCALISATION_H
#define PQLOCALISATION_H

#include <QObject>
#include <QTranslator>
#include <QGuiApplication>
#include <QFile>

class PQLocalisation : public QObject {

    Q_OBJECT

public:
    PQLocalisation(QObject *parent = nullptr) : QObject(parent) {
        trans = new QTranslator;
    }
    ~PQLocalisation() {
        delete trans;
    }

    Q_INVOKABLE void setLanguage(QString code) {

        if(!trans->isEmpty())
            qApp->removeTranslator(trans);

        QStringList allcodes = code.split("/");

        foreach(QString c, allcodes) {

            if(QFile(":/photoqt_" + c + ".qm").exists()) {
                trans->load(":/photoqt_" + c);
                qApp->installTranslator(trans);
                emit languageChanged();
                return;
            }

            if(c.contains("_")) {
                c = c.split("_").at(0);
                if(QFile(":/photoqt_" + c + ".qm").exists()) {
                    trans->load(":/photoqt_" + c);
                    qApp->installTranslator(trans);
                    emit languageChanged();
                    return;
                }
            }

        }

        // Store translation in settings file
        trans->load(":/photoqt_en.qm");
        qApp->installTranslator(trans);
        emit languageChanged();

    }

    Q_PROPERTY(QString pty READ getPty NOTIFY languageChanged)
    QString getPty() {
        return "";
    }

private:
    QTranslator *trans;

signals:
    void languageChanged();

};

#endif // PQLOCALISATION_H
