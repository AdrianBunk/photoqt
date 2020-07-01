#ifndef PQHANDLINGEXTERNAL_H
#define PQHANDLINGEXTERNAL_H

#include <QObject>
#include <QFileDialog>
#include <QTextStream>
#ifdef LIBARCHIVE
#include <archive.h>
#include <archive_entry.h>
#endif
#include "../logger.h"

class PQHandlingExternal : public QObject {

    Q_OBJECT

public:
    Q_INVOKABLE bool exportConfigTo(QString path);
    Q_INVOKABLE bool importConfigFrom(QString path);

};

#endif // PQHANDLINGEXTERNAL_H
