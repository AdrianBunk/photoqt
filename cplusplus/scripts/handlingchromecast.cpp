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

#include "handlingchromecast.h"
#include "../logger.h"
#include <QtDebug>
#include <QFutureWatcher>

PQHandlingChromecast::PQHandlingChromecast(QObject *parent) : QObject(parent) {

#ifdef CHROMECAST
    server = new PQHttpServer;
    currentFriendlyName = "";

    chromecastModuleName = QString("%1/photoqt_chromecast.py").arg(QDir::tempPath());

    if(QFile::exists(chromecastModuleName))
        QFile::remove(chromecastModuleName);

    if(!QFile::copy(":/chromecast.py", chromecastModuleName))
        LOG << CURDATE << "PQHandlingStreaming::PQHandlingStreaming(): Unable to make chromecast module accessible" << NL;

    QFile f(chromecastModuleName);
    f.setPermissions(f.permissions() | QFileDevice::WriteOwner);

    watcher = nullptr;
    imageprovider = nullptr;

    scanRunning = false;

    Py_Initialize();

    chromecastCast = new PQPyObject;
    chromecastServices = new PQPyObject;
    chromecastBrowser = new PQPyObject;
    chromecastMediaController = new PQPyObject;

    triedReconnectingAfterDisconnect = 0;
#endif

}

PQHandlingChromecast::~PQHandlingChromecast() {

#ifdef CHROMECAST

    delete server;

    if(watcher != nullptr) {
        if(watcher->isRunning()) {
            watcher->cancel();
            LOG << "Waiting for Chromecast connection to terminate..." << NL;
            watcher->waitForFinished();
        }
        delete watcher;
    }

    delete chromecastCast;
    delete chromecastServices;
    delete chromecastBrowser;
    delete chromecastMediaController;

#if PY_MINOR_VERSION < 10
    Py_FinalizeEx();
#endif

    if(!QFile::remove(chromecastModuleName))
        LOG << CURDATE << "PQHandlingStreaming::~PQHandlingStreaming: Unable to remove chromecast module file" << NL;

#endif

}

void PQHandlingChromecast::getListOfChromecastDevices() {

    DBG << CURDATE << "PQHandlingChromecast::getListOfChromecastDevices()" << NL;

#ifdef CHROMECAST

    if(!QFile::exists(QString("%1/photoqt_chromecast.py").arg(QDir::tempPath())))
        return;

    if(scanRunning) {
        Q_EMIT updatedListChromecast(QVariantList());
        return;
    }

    scanRunning = true;

    if(watcher != nullptr)
        delete watcher;
    watcher = new QFutureWatcher<QVariantList>(this);
    QObject::connect(watcher, &QFutureWatcher<QVariantList>::finished, this, [=]() {
        if(watcher->isCanceled()) {
            scanRunning = false;
            Q_EMIT updatedListChromecast(QVariantList());
            return;
        }
        QVariantList devices = watcher->result();
        if(devices.length() > 0) {
            *chromecastServices = devices[0].value<PQPyObject>();
            Q_EMIT updatedListChromecast(devices.mid(1));
        } else
            Q_EMIT updatedListChromecast(QVariantList());
        scanRunning = false;
    });
    watcher->setFuture(QtConcurrent::run(&PQHandlingChromecast::_getListOfChromecastDevices));
    connect(this, &PQHandlingChromecast::cancelScan, watcher, &QFutureWatcher<QVariantList>::cancel);

#endif

}

QVariantList PQHandlingChromecast::_getListOfChromecastDevices() {

    DBG << CURDATE << "PQHandlingChromecast::_getListOfChromecastDevices()" << NL;

    QVariantList ret;

#ifdef CHROMECAST

    PyObject *sys_path = PySys_GetObject("path");
    if(PyList_Append(sys_path, PyUnicode_FromString(QDir::tempPath().toStdString().c_str())) == -1) {
        LOG << CURDATE << "PQHandlingChromecast::_getListOfChromecastDevices(): Python error: Unable to append temp path to sys path" << NL;
        return ret;
    }

    PQPyObject pModule = PyImport_ImportModule("photoqt_chromecast");
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 1")) return ret;

    PQPyObject funcGetAvailable = PyObject_GetAttrString(pModule, "getAvailable");
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 2")) return ret;

    PQPyObject services_count = PyObject_CallFunction(funcGetAvailable, NULL);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 3")) return ret;

    PQPyObject count = PyList_GetItem(services_count, 0);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 4")) return ret;

    PQPyObject services = PyList_GetItem(services_count, 1);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 5")) return ret;

    int c = PyLong_AsSize_t(count);
    if(c == 0)
        return ret;

    // the first one is a pychromecast variable
    // since this is static we need to wrap it into the return type
    // as we do not have access to global class variables as easily
    ret.push_back(QVariant::fromValue(services));

    PQPyObject funcGetNames = PyObject_GetAttrString(pModule, "getNamesIps");
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 6")) return ret;


    PQPyObject args = PyTuple_Pack(1, services.get());
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 7")) return ret;

    PQPyObject keywords = PyDict_New();
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 8")) return ret;

    PQPyObject namesips = PyObject_Call(funcGetNames, args, keywords);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 9")) return ret;

    PQPyObject names = PyList_GetItem(namesips, 0);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 10")) return ret;

    PQPyObject ips = PyList_GetItem(namesips, 1);
    if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 11")) return ret;

    auto len = PyList_Size(names);
    for(int i = 0; i < len; ++i) {
        ret.push_back(PyUnicode_AsUTF8(PyList_GetItem(names, i)));
        ret.push_back(PyUnicode_AsUTF8(PyList_GetItem(ips, i)));
        if(PQPyObject::catchEx("PQHandlingChromecast::_getListOfChromecastDevices() 12")) return ret;
    }

#endif

    return ret;

}

void PQHandlingChromecast::cancelScanForChromecast() {
    Q_EMIT cancelScan();
}

bool PQHandlingChromecast::connectToDevice(QString friendlyname) {

    DBG << CURDATE << "PQHandlingChromecast::connectToDevice()" << NL
        << CURDATE << "** friendlyname = " << friendlyname.toStdString() << NL;

#ifdef CHROMECAST

    PyObject *sys_path = PySys_GetObject("path");
    if(PyList_Append(sys_path, PyUnicode_FromString(QDir::tempPath().toStdString().c_str())) == -1) {
        LOG << CURDATE << "PQHandlingChromecast::connectToDevice(): Python error: Unable to append temp path to sys path" << NL;
        return false;
    }

    PQPyObject pModule = PyImport_ImportModule("photoqt_chromecast");
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice() 1")) return false;

    PQPyObject funcConnectTo = PyObject_GetAttrString(pModule, "connectTo");
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice() 2")) return false;


    PQPyObject args = PyTuple_Pack(1, PyUnicode_FromString(friendlyname.toStdString().c_str()));
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice() 3")) return false;

    PQPyObject keywords = PyDict_New();
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice() 4")) return false;

    PQPyObject cast_browser_mc = PyObject_Call(funcConnectTo, args, keywords);
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice() 5")) return false;

    int c = PyList_Size(cast_browser_mc);
    if(c != 3) {
        LOG << CURDATE << "PQHandlingChromecast::connectToDevice(): Error: device unreachable..." << NL;
        return false;
    }

    *chromecastCast = PyList_GetItem(cast_browser_mc, 0);
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice() 6")) return false;

    *chromecastBrowser = PyList_GetItem(cast_browser_mc, 1);
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice() 7")) return false;

    *chromecastMediaController = PyList_GetItem(cast_browser_mc, 2);
    if(PQPyObject::catchEx("PQHandlingChromecast::connectToDevice() 8")) return false;

    currentFriendlyName = friendlyname;

    if(server->isRunning())
        return true;

    serverPort = server->start();

    // find local ip address
    localIP = "";
    const auto addresses = QNetworkInterface::allAddresses();
    for(const auto &entry : addresses) {
        if(!entry.isLoopback() &&  entry.protocol() == QAbstractSocket::IPv4Protocol) {
            const QString ip = entry.toString();
            if(ip != "127.0.0.1" && ip != "localhost") {
                localIP = ip;
                break;
            }
        }
    }

    if(localIP == "")
        return false;

    return true;

#else
    return false;
#endif

}

bool PQHandlingChromecast::disconnectFromDevice() {

    DBG << CURDATE << "PQHandlingChromecast::disconnectFromDevice()" << NL;

#ifdef CHROMECAST

    PyObject *sys_path = PySys_GetObject("path");
    if(PyList_Append(sys_path, PyUnicode_FromString(QDir::tempPath().toStdString().c_str())) == -1) {
        LOG << CURDATE << "PQHandlingChromecast::disconnectFromDevice(): Python error: Unable to append temp path to sys path" << NL;
        return false;
    }

    PQPyObject pModule = PyImport_ImportModule("photoqt_chromecast");
    if(PQPyObject::catchEx("PQHandlingChromecast::disconnectFromDevice() 1")) return false;

    PQPyObject funcDisconnectFrom = PyObject_GetAttrString(pModule, "disconnectFrom");
    if(PQPyObject::catchEx("PQHandlingChromecast::disconnectFromDevice() 2")) return false;

    PQPyObject args = PyTuple_Pack(2, chromecastCast->get(), chromecastBrowser->get());
    if(PQPyObject::catchEx("PQHandlingChromecast::disconnectFromDevice() 3")) return false;

    PQPyObject keywords = PyDict_New();
    if(PQPyObject::catchEx("PQHandlingChromecast::disconnectFromDevice() 4")) return false;

    PQPyObject disc = PyObject_Call(funcDisconnectFrom, args, keywords);
    if(PQPyObject::catchEx("PQHandlingChromecast::disconnectFromDevice() 5")) {
        if(triedReconnectingAfterDisconnect < 4) {
            ++triedReconnectingAfterDisconnect;
            connectToDevice(currentFriendlyName);
            disconnectFromDevice();
        } else
            triedReconnectingAfterDisconnect = 0;
        return false;
    }

    triedReconnectingAfterDisconnect = 0;
    currentFriendlyName = "";
    return true;

#else
    return false;
#endif

}

void PQHandlingChromecast::streamOnDevice(QString src) {

    DBG << CURDATE << "PQHandlingChromecast::streamOnDevice()" << NL
        << CURDATE << "** src = " << src.toStdString() << NL;

#ifdef CHROMECAST

    // Make sure image provider exists
    if(imageprovider == nullptr)
        imageprovider = new PQImageProviderFull;

    // request image
    if(src.isNull() || src == "") {
        QImage img(":/other/logo_smallinsidelarge.jpg");
        if(!img.save(QString("%1/photoqtchromecast.jpg").arg(QDir::tempPath()), nullptr, 100))
            LOG << CURDATE << "PQHandlingChromecast::streamOnDevice(): Failed to save default image." << NL;
    } else {

        QImage img = imageprovider->requestImage(src, new QSize, QSize(1920,1080));

        // if image is smaller than display and is not to be fit to window size
        if(!PQSettings::get()["imageviewFitInWindow"].toBool() && (img.width() < 1920 || img.height() < 1080)) {
            QImage ret(1920, 1080, QImage::Format_ARGB32);
            ret.fill(Qt::black);
            QPainter painter(&ret);
            painter.drawImage((1920-img.width())/2, (1080-img.height())/2, img);
            painter.end();
            if(!ret.save(QString("%1/photoqtchromecast.jpg").arg(QDir::tempPath()), nullptr, 100))
                LOG << CURDATE << "PQHandlingChromecast::streamOnDevice(): Failed to save image: " << src.toStdString() << NL;
        } else
            if(!img.save(QString("%1/photoqtchromecast.jpg").arg(QDir::tempPath()), nullptr, 100))
                LOG << CURDATE << "PQHandlingChromecast::streamOnDevice(): Failed to save image: " << src.toStdString() << NL;
    }

    PyObject *sys_path = PySys_GetObject("path");
    if(PyList_Append(sys_path, PyUnicode_FromString(QDir::tempPath().toStdString().c_str())) == -1) {
        LOG << CURDATE << "PQHandlingChromecast::streamOnDevice(): Python error: Unable to append temp path to sys path" << NL;
        return;
    }

    PQPyObject pModule = PyImport_ImportModule("photoqt_chromecast");
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice() 1")) return;

    PQPyObject funcStreamOn = PyObject_GetAttrString(pModule, "streamOnDevice");
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice() 2")) return;

    PQPyObject args = PyTuple_Pack(3, PyUnicode_FromString(localIP.toStdString().c_str()), PyLong_FromLong(serverPort), chromecastMediaController->get());
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice() 3")) return;

    PQPyObject keywords = PyDict_New();
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice() 4")) return;

    PQPyObject browser_mc = PyObject_Call(funcStreamOn, args, keywords);
    if(PQPyObject::catchEx("PQHandlingChromecast::streamOnDevice() 5")) {
        if(triedReconnectingAfterDisconnect < 4) {
            ++triedReconnectingAfterDisconnect;
            connectToDevice(currentFriendlyName);
            streamOnDevice(src);
        } else
            triedReconnectingAfterDisconnect = 0;
        return;
    }

    triedReconnectingAfterDisconnect = 0;

#endif

}
