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

#include <iomanip>
#include "startup.h"

PQStartup::PQStartup(QObject *parent) : QObject(parent) {

}

// 0: no update
// 1: update
// 2: fresh install
int PQStartup::check(bool onlyCreateDatabase) {

    QSqlDatabase db_settings;
    QSqlDatabase db_shortcuts;
    QSqlDatabase db_context;
    QSqlDatabase db_imageformats;
    QSqlDatabase db_location;

    // check if sqlite is available
    // this is a hard requirement now and we wont launch PhotoQt without it
    if(QSqlDatabase::isDriverAvailable("QSQLITE3")) {
        db_settings = QSqlDatabase::addDatabase("QSQLITE3", "settings");
        db_shortcuts = QSqlDatabase::addDatabase("QSQLITE3", "shortcuts");
        db_context = QSqlDatabase::addDatabase("QSQLITE3", "contextmenu");
        db_imageformats = QSqlDatabase::addDatabase("QSQLITE3", "imageformats");
        db_location = QSqlDatabase::addDatabase("QSQLITE3", "location");
    } else if(QSqlDatabase::isDriverAvailable("QSQLITE")) {
        db_settings = QSqlDatabase::addDatabase("QSQLITE", "settings");
        db_shortcuts = QSqlDatabase::addDatabase("QSQLITE", "shortcuts");
        db_context = QSqlDatabase::addDatabase("QSQLITE", "contextmenu");
        db_imageformats = QSqlDatabase::addDatabase("QSQLITE", "imageformats");
        db_location = QSqlDatabase::addDatabase("QSQLITE", "location");
    } else {
        LOG << CURDATE << "PQStartup::check(): ERROR: SQLite driver not available. Available drivers are: " << QSqlDatabase::drivers().join(",").toStdString() << NL;
        LOG << CURDATE << "PQStartup::check(): PhotoQt cannot function without SQLite available." << NL;
        //: This is the window title of an error message box
        QMessageBox::critical(0, QCoreApplication::translate("PQStartup", "SQLite error"),
                                 QCoreApplication::translate("PQStartup", "You seem to be missing the SQLite driver for Qt. This is needed though for a few different things, like reading and writing the settings. Without it, PhotoQt cannot function!"));
        std::exit(1);
    }

    // if no config files exist, then it is a fresh install
    if((!QFile::exists(ConfigFiles::SETTINGS_FILE()) && !QFile::exists(ConfigFiles::SETTINGS_DB())) ||
        !QFile::exists(ConfigFiles::IMAGEFORMATS_DB()) ||
       (!QFile::exists(ConfigFiles::SHORTCUTS_FILE()) && !QFile::exists(ConfigFiles::SHORTCUTS_DB()))) {

        db_settings.setDatabaseName(ConfigFiles::SETTINGS_DB());
        db_shortcuts.setDatabaseName(ConfigFiles::SHORTCUTS_DB());
        db_context.setDatabaseName(ConfigFiles::CONTEXTMENU_DB());
        db_imageformats.setDatabaseName(ConfigFiles::IMAGEFORMATS_DB());
        db_location.setDatabaseName(ConfigFiles::LOCATION_DB());

        return 2;
    }

    db_settings.setDatabaseName(ConfigFiles::SETTINGS_DB());
    db_shortcuts.setDatabaseName(ConfigFiles::SHORTCUTS_DB());
    db_context.setDatabaseName(ConfigFiles::CONTEXTMENU_DB());
    db_imageformats.setDatabaseName(ConfigFiles::IMAGEFORMATS_DB());
    db_location.setDatabaseName(ConfigFiles::LOCATION_DB());

    /******************************************************************************************************/
    // If we perform an action like export/import/check/... we need access to the db but no more than that
    if(onlyCreateDatabase)
        return 0;

    // 2.4 and older used a settings and shortcuts file
    // 2.5 and later uses a settings and shortcuts database
    if((QFile::exists(ConfigFiles::SETTINGS_FILE()) && !QFile::exists(ConfigFiles::SETTINGS_DB())) ||
       (QFile::exists(ConfigFiles::SHORTCUTS_FILE()) && !QFile::exists(ConfigFiles::SHORTCUTS_DB())))
        return 1;

    // open database
    if(!db_settings.open())
        LOG << CURDATE << "PQStartup::check(): Error opening database: " << db_settings.lastError().text().trimmed().toStdString() << NL;

    // compare version string in database to current version string
    QSqlQuery query(db_settings);
    if(!query.exec("SELECT `value` from `general` where `name`='Version'"))
        LOG << CURDATE << "PQStartup::check(): SQL query error: " << query.lastError().text().trimmed().toStdString() << NL;
    query.next();

    // last time a dev version was run
    QString version = query.record().value(0).toString();
    query.clear();
    if(version == "dev") {
        // update stored version string
        query.prepare("UPDATE general SET value=:val WHERE name='Version'");
        query.bindValue(":val", VERSION);
        if(!query.exec())
            LOG << CURDATE << "PQStartup::check(): Unable to update version string..." << NL;
        return 3;
    }

    // updated
    if(version != QString(VERSION)) {
        // update stored version string
        query.prepare("UPDATE general SET value=:val WHERE name='Version'");
        query.bindValue(":val", VERSION);
        if(!query.exec())
            LOG << CURDATE << "PQStartup::check(): Unable to update version string..." << NL;
        return 1;
    }

    // nothing happened
    return 0;

}

void PQStartup::exportData(QString path) {

    LOG << NL
        << "PhotoQt v" << VERSION << NL
        << " > Exporting configuration to " << path.toStdString() << "... " << NL;

    if(PQHandlingExternal::exportConfigTo(path))
        std::cout << " >> Done!" << NL << NL;
    else
        std::cout << " >> Failed!" << NL << NL;

}

void PQStartup::importData(QString path) {

    LOG << NL
        << "PhotoQt v" << VERSION << NL
        << " > Importing configuration from " << path.toStdString() << "... " << NL;

    if(PQHandlingExternal::importConfigFrom(path))
        std::cout << " >> Done!" << NL << NL;
    else
        std::cout << " >> Failed!" << NL << NL;

}

void PQStartup::setupFresh(int defaultPopout) {

    /**************************************************************/
    // make sure necessary folder exist
    QDir dir;
    dir.mkpath(ConfigFiles::CONFIG_DIR());
    dir.mkpath(ConfigFiles::GENERIC_DATA_DIR());
    dir.mkpath(ConfigFiles::GENERIC_CACHE_DIR());
    dir.mkpath(QString("%1/thumbnails/large/").arg(ConfigFiles::GENERIC_CACHE_DIR()));

    /**************************************************************/
    // create default imageformats database
    if(!QFile::copy(":/imageformats.db", ConfigFiles::IMAGEFORMATS_DB()))
        LOG << CURDATE << "PQStartup::setupFresh(): unable to create default imageformats database" << NL;
    else {
        QFile file(ConfigFiles::IMAGEFORMATS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default settings database
    if(!QFile::copy(":/settings.db", ConfigFiles::SETTINGS_DB()))
        LOG << CURDATE << "PQStartup::setupFresh(): unable to create settings database" << NL;
    else {
        QFile file(ConfigFiles::SETTINGS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default location database
    if(!QFile::copy(":/location.db", ConfigFiles::LOCATION_DB()))
        LOG << CURDATE << "PQStartup::setupFresh(): unable to create location database" << NL;
    else {
        QFile file(ConfigFiles::LOCATION_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    PQSettings::get().update("generalVersion", VERSION);

#ifdef Q_OS_WIN
    // these defaults are different on Windows as on Linux
    PQSettings::get().update("openfileUserPlacesVolumes", true);
#endif

    // record popout selection
    // default is all integrated (defaultPopout == 0)
    if(defaultPopout == 1) { // some integrated, some individual

        PQSettings::get().update("interfacePopoutScale", true);
        PQSettings::get().update("interfacePopoutOpenFile", true);
        PQSettings::get().update("interfacePopoutSlideShowSettings", true);
        PQSettings::get().update("interfacePopoutImgur", true);
        PQSettings::get().update("interfacePopoutWallpaper", true);
        PQSettings::get().update("interfacePopoutSettingsManager", true);
        PQSettings::get().update("interfacePopoutFileSaveAs", true);
        PQSettings::get().update("interfacePopoutChromecast", true);
        PQSettings::get().update("interfacePopoutAdvancedSort", true);
        PQSettings::get().update("interfacePopoutMapExplorer", true);

    } else if(defaultPopout == 2) { // all individual

        PQSettings::get().update("interfacePopoutMainMenu", true);
        PQSettings::get().update("interfacePopoutMetadata", true);
        PQSettings::get().update("interfacePopoutHistogram", true);
        PQSettings::get().update("interfacePopoutScale", true);
        PQSettings::get().update("interfacePopoutOpenFile", true);
        PQSettings::get().update("interfacePopoutOpenFileKeepOpen", true);
        PQSettings::get().update("interfacePopoutSlideShowSettings", true);
        PQSettings::get().update("interfacePopoutSlideShowControls", true);
        PQSettings::get().update("interfacePopoutFileRename", true);
        PQSettings::get().update("interfacePopoutFileDelete", true);
        PQSettings::get().update("interfacePopoutAbout", true);
        PQSettings::get().update("interfacePopoutImgur", true);
        PQSettings::get().update("interfacePopoutWallpaper", true);
        PQSettings::get().update("interfacePopoutFilter", true);
        PQSettings::get().update("interfacePopoutSettingsManager", true);
        PQSettings::get().update("interfacePopoutFileSaveAs", true);
        PQSettings::get().update("interfacePopoutUnavailable", true);
        PQSettings::get().update("interfacePopoutChromecast", true);
        PQSettings::get().update("interfacePopoutAdvancedSort", true);
        PQSettings::get().update("interfacePopoutMapCurrent", true);
        PQSettings::get().update("interfacePopoutMapExplorer", true);
        PQSettings::get().update("interfacePopoutMapExplorerKeepOpen", true);


    }

    /**************************************************************/
    // create default shortcuts database
    if(!QFile::copy(":/shortcuts.db", ConfigFiles::SHORTCUTS_DB()))
        LOG << CURDATE << "PQStartup::Settings: unable to create shortcuts database" << NL;
    else {
        QFile file(ConfigFiles::SHORTCUTS_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/
    // create default contextmenu database
    if(!QFile::copy(":/contextmenu.db", ConfigFiles::CONTEXTMENU_DB()))
        LOG << CURDATE << "PQStartup::setupFresh(): unable to create default contextmenu database" << NL;
    else {
        QFile file(ConfigFiles::CONTEXTMENU_DB());
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    /**************************************************************/


}

void PQStartup::resetToDefaults() {

    LOG << NL
        << "PhotoQt v" << VERSION << NL
        << " > Resetting to default configuration... " << NL;

    PQHandlingGeneral general;
    general.setDefaultSettings();
    PQShortcuts::get().setDefault();

    LOG << " >> Done!" << NL << NL;

}

void PQStartup::performChecksAndMigrations() {

    /**************************************************************/

    // remove version info from imageformats.db
    // the version info is managed through settings.db
    QSqlDatabase db = QSqlDatabase::database("imageformats");
    if(!db.open())
        LOG << CURDATE << "PQStartup::performChecksAndMigrations(): Error opening imageformats database: " << db.lastError().text().trimmed().toStdString() << NL;
    QSqlQuery query(db);
    if(!query.exec("DROP TABLE IF EXISTS info"))
        LOG << CURDATE << "PQStartup::performChecksAndMigrations(): SQL query error: " << query.lastError().text().trimmed().toStdString() << NL;
    query.next();

    /**************************************************************/

    // migrate data
    migrateContextmenuToDb();
    migrateShortcutsToDb();
    migrateSettingsToDb();

    // enter any new settings and shortcuts
    renameSettings();
    renameShortcuts();

    PQValidate validate;
    validate.validate();

}

// These settings changed names
bool PQStartup::renameSettings() {

    QSqlDatabase db = QSqlDatabase::database("settings");

    QMap<QString,QStringList> rename;
    rename ["LabelsWindowButtonsSize"] = QStringList() << "WindowButtonsSize" << "interface";   // 3.1
    rename ["LabelsManageWindow"] = QStringList() << "StatusInfoManageWindow" << "interface";   // 3.1
    rename ["LiftUp"] = QStringList() << "HighlightAnimationLiftUp" << "thumbnails";            // 3.2
    rename ["FilenameOnly"] = QStringList() << "IconsOnly" << "thumbnails";                     // 3.2
    rename ["FilenameOnlyFontSize"] = QStringList() << "" << "thumbnails";                      // 3.2
    QMapIterator<QString, QStringList> i(rename);
    while(i.hasNext()) {
        i.next();

        QString oldname = i.key();
        QString newname = i.value().value(0);
        QString table = i.value().value(1);

        // delete old setting
        if(newname == "") {

            QSqlQuery query(db);
            query.prepare(QString("DELETE FROM '%1' WHERE name=:old").arg(table));
            query.bindValue(":old", oldname);
            if(!query.exec()) {
                LOG << CURDATE << "PQValidate::renameSettings(): Error removing old setting name (" << oldname.toStdString() << "): " << query.lastError().text().trimmed().toStdString() << NL;
                query.clear();
                return false;
            }
            query.clear();

        // rename old setting
        } else {

            QSqlQuery query(db);
            query.prepare(QString("UPDATE '%1' SET name=:new WHERE name=:old").arg(table));
            query.bindValue(":new", newname);
            query.bindValue(":old", oldname);
            if(!query.exec()) {
                LOG << CURDATE << "PQValidate::renameSettings(): Error updating setting name (" << oldname.toStdString() << " -> " << newname.toStdString() << "): " << query.lastError().text().trimmed().toStdString() << NL;
                query.clear();
                return false;
            }
            query.clear();

        }
    }

    return true;

}

bool PQStartup::renameShortcuts() {

    QSqlDatabase db = QSqlDatabase::database("shortcuts");

    // delete old entries
    QSqlQuery query(db);

    // required for transition to v3.3
    if(!query.exec("DELETE FROM builtin WHERE command like '__keepMetaData'")) {
        LOG << CURDATE << "PQValidate::renameShortcuts(): Error removing old shortcut '__keepMetaData': " << query.lastError().text().trimmed().toStdString() << NL;
        query.clear();
        return false;
    }

    query.clear();

    return true;

}

/**************************************************************/
/**************************************************************/
// the following migration functions are below (in this order):
// * migrateContextmenuToDb
// * migrateShortcutsToDb()
// * migrateSettingsToDb()

bool PQStartup::migrateContextmenuToDb() {

    QFile file(ConfigFiles::CONTEXTMENU_FILE());
    QFile dbfile(ConfigFiles::CONTEXTMENU_DB());

    // if the database doesn't exist, we always need to create it
    if(!dbfile.exists()) {
        if(!QFile::copy(":/contextmenu.db", ConfigFiles::CONTEXTMENU_DB()))
            LOG << CURDATE << "PQStartup::migrateContextmenuToDb(): unable to create contextmenu database" << NL;
        else {
            QFile file(ConfigFiles::CONTEXTMENU_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
    }

    // nothing to migrate -> we're done
    if(!file.exists())
        return true;


    // access database
    QSqlDatabase db = QSqlDatabase::database("contextmenu");

    // open database
    if(!db.open()) {
        LOG << CURDATE << "PQStartup::migrateContextmenuToDb(): Error opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    QSqlQuery query(db);
    query.prepare("DELETE FROM entries");
    if(!query.exec()) {
        LOG << CURDATE << "PQStartup::migrateContextmenuToDb(): SQL error, truncate: " << query.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "PQStartup::migrateContextmenuToDb(): Failed to open old contextmenu file" << NL;
        return false;
    }

    QTextStream in(&file);
    QString txt = file.readAll();

    QStringList allEntries = txt.split("\n\n");
    for(const auto &entry : qAsConst(allEntries)) {

        QStringList parts = entry.split("\n");
        if(parts.length() != 2)
            continue;

        QString close = parts[0].at(0);
        QString cmd = parts[0].remove(0,1);
        QString dsc = parts[1];

        QSqlQuery query(db);
        query.prepare("INSERT INTO entries (command,desc,close) VALUES (:cmd,:dsc,:cls)");
        query.bindValue(":cmd", cmd);
        query.bindValue(":dsc", dsc);
        query.bindValue(":cls", close);
        if(!query.exec())
            LOG << CURDATE << "PQStartup::migrateContextmenuToDb(): SQL error, insert: " << query.lastError().text().trimmed().toStdString() << NL;

    }

    QString oldFile = QString("%1.pre-v2.5").arg(ConfigFiles::CONTEXTMENU_FILE());
    if(!QFile::exists(oldFile)) {
        if(!QFile::copy(ConfigFiles::CONTEXTMENU_FILE(), oldFile))
            LOG << CURDATE << "PQStartup::migrateContextmenuToDb(): Failed to copy old contextmenu file to 'contextmenu.pre-v2.5' filename" << NL;
        QFile file(oldFile);
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    if(QFile::exists(QString("%1.pre-v2.5").arg(ConfigFiles::CONTEXTMENU_FILE())))
        if(!QFile::remove(ConfigFiles::CONTEXTMENU_FILE()))
            LOG << CURDATE << "PQStartup::migrateContextmenuToDb(): Failed to remove old contextmenu file" << NL;

    return true;

}

bool PQStartup::migrateShortcutsToDb() {

    QFile dbfile(ConfigFiles::SHORTCUTS_DB());

    // if the database doesn't exist, we always need to create it
    if(!dbfile.exists()) {
        if(!QFile::copy(":/shortcuts.db", ConfigFiles::SHORTCUTS_DB())) {
            LOG << CURDATE << "PQStartup::migrateShortcutsToDb: unable to create shortcuts database" << NL;
            return false;
        } else {
            QFile file(ConfigFiles::SHORTCUTS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
            return true;
        }
    }

    // we already do the potential migration there, do again here
    PQValidate validate;
    return validate.validateShortcutsDatabase();

}

bool PQStartup::migrateSettingsToDb() {

    QFile file(ConfigFiles::SETTINGS_FILE());
    QFile dbfile(ConfigFiles::SETTINGS_DB());

    // if the database doesn't exist, we always need to create it
    if(!dbfile.exists()) {
        if(!QFile::copy(":/settings.db", ConfigFiles::SETTINGS_DB()))
            LOG << CURDATE << "PQStartup::Settings: unable to create settings database" << NL;
        else {
            QFile file(ConfigFiles::SETTINGS_DB());
            file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
        }
    } else {
        if(file.exists())
            file.remove();
        return true;
    }

    // nothing to migrate -> we're done
    if(!file.exists())
        return true;

    QSqlDatabase db = QSqlDatabase::database("settings");

    db.setHostName("migratesettings");
    db.setDatabaseName(ConfigFiles::SETTINGS_DB());
    if(!db.open()) {
        LOG << CURDATE << "PQStartup::migrateSettingsToDb(): Error opening database: " << db.lastError().text().trimmed().toStdString() << NL;
        return false;
    }

    if(!file.open(QIODevice::ReadOnly)) {
        LOG << CURDATE << "PQStartup::migrateSettingsToDb(): Failed to open old settings file" << NL;
        return false;
    }
    QTextStream in(&file);
    QString txt = file.readAll();

    QMap<QString, QStringList> conversions;
    /******************************************************/
    conversions.insert("Version", QStringList() << "general" << "Version");
    conversions.insert("Language",                   QStringList() << "interface" << "Language");
    conversions.insert("WindowMode",                 QStringList() << "interface" << "WindowMode");
    conversions.insert("WindowDecoration",           QStringList() << "interface" << "WindowDecoration");
    conversions.insert("SaveWindowGeometry",         QStringList() << "interface" << "SaveWindowGeometry");
    conversions.insert("KeepOnTop",                  QStringList() << "interface" << "KeepWindowOnTop");
    conversions.insert("StartupLoadLastLoadedImage", QStringList() << "interface" << "RememberLastImage");
    /******************************************************/
    // Category: Look
    /******************************************************/
    conversions.insert("BackgroundColorAlpha",      QStringList() << "interface" << "OverlayColorAlpha");
    conversions.insert("BackgroundColorBlue",       QStringList() << "interface" << "OverlayColorBlue");
    conversions.insert("BackgroundColorGreen",      QStringList() << "interface" << "OverlayColorGreen");
    conversions.insert("BackgroundColorRed",        QStringList() << "interface" << "OverlayColorRed");
    conversions.insert("BackgroundImageCenter",     QStringList() << "interface" << "BackgroundImageCenter");
    conversions.insert("BackgroundImagePath",       QStringList() << "interface" << "BackgroundImagePath");
    conversions.insert("BackgroundImageScale",      QStringList() << "interface" << "BackgroundImageScale");
    conversions.insert("BackgroundImageScaleCrop",  QStringList() << "interface" << "BackgroundImageScaleCrop");
    conversions.insert("BackgroundImageScreenshot", QStringList() << "interface" << "BackgroundImageScreenshot");
    conversions.insert("BackgroundImageStretch",    QStringList() << "interface" << "BackgroundImageStretch");
    conversions.insert("BackgroundImageTile",       QStringList() << "interface" << "BackgroundImageTile");
    conversions.insert("BackgroundImageUse",        QStringList() << "interface" << "BackgroundImageUse");
    /******************************************************/
    // category: Behaviour
    /******************************************************/
    conversions.insert("AnimationDuration",                  QStringList() << "imageview" << "AnimationDuration");
    conversions.insert("AnimationType",                      QStringList() << "imageview" << "AnimationType");
    conversions.insert("ArchiveUseExternalUnrar",            QStringList() << "imageview" << "ExternalUnrar");
    conversions.insert("CloseOnEmptyBackground",             QStringList() << "imageview" << "CloseOnEmptyBackground");
    conversions.insert("NavigateOnEmptyBackground",          QStringList() << "imageview" << "NavigateOnEmptyBackground");
    conversions.insert("FitInWindow",                        QStringList() << "imageview" << "FitInWindow");
    conversions.insert("HotEdgeWidth",                       QStringList() << "imageview" << "HotEdgeSize");
    conversions.insert("InterpolationThreshold",             QStringList() << "imageview" << "InterpolationThreshold");
    conversions.insert("InterpolationDisableForSmallImages", QStringList() << "imageview" << "InterpolationDisableForSmallImages");
    conversions.insert("KeepZoomRotationMirror",             QStringList() << "imageview" << "RememberZoomRotationMirror");
    conversions.insert("LeftButtonMouseClickAndMove",        QStringList() << "imageview" << "LeftButtonMoveImage");
    conversions.insert("LoopThroughFolder",                  QStringList() << "imageview" << "LoopThroughFolder");
    conversions.insert("MarginAroundImage",                  QStringList() << "imageview" << "Margin");
    conversions.insert("MouseWheelSensitivity",              QStringList() << "imageview" << "MouseWheelSensitivity");
    conversions.insert("PdfQuality",                         QStringList() << "imageview" << "PDFQuality");
    conversions.insert("PixmapCache",                        QStringList() << "imageview" << "Cache");
    conversions.insert("QuickNavigation",                    QStringList() << "imageview" << "QuickNavigation");
    conversions.insert("ShowTransparencyMarkerBackground",   QStringList() << "imageview" << "TransparencyMarker");
    conversions.insert("SortImagesBy",                       QStringList() << "imageview" << "SortImagesBy");
    conversions.insert("SortImagesAscending",                QStringList() << "imageview" << "SortImagesAscending");
    conversions.insert("TrayIcon",                           QStringList() << "imageview" << "TrayIcon");
    conversions.insert("ZoomSpeed",                          QStringList() << "imageview" << "ZoomSpeed");
    /******************************************************/
    // category: Labels
    /******************************************************/
    conversions.insert("LabelsWindowButtonsSize", QStringList() << "interface" << "LabelsWindowButtonsSize");
    conversions.insert("LabelsHideCounter",       QStringList() << "interface" << "LabelsHideCounter");
    conversions.insert("LabelsHideFilepath",      QStringList() << "interface" << "LabelsHideFilepath");
    conversions.insert("LabelsHideFilename",      QStringList() << "interface" << "LabelsHideFilename");
    conversions.insert("LabelsWindowButtons",     QStringList() << "interface" << "LabelsWindowButtons");
    conversions.insert("LabelsHideZoomLevel",     QStringList() << "interface" << "LabelsHideZoomLevel");
    conversions.insert("LabelsHideRotationAngle", QStringList() << "interface" << "LabelsHideRotationAngle");
    conversions.insert("LabelsManageWindow",      QStringList() << "interface" << "LabelsManageWindow");
    /******************************************************/
    // category: Exclude
    /******************************************************/
    conversions.insert("ExcludeCacheFolders",   QStringList() << "thumbnails" << "ExcludeFolders");
    conversions.insert("ExcludeCacheDropBox",   QStringList() << "thumbnails" << "ExcludeDropBox");
    conversions.insert("ExcludeCacheNextcloud", QStringList() << "thumbnails" << "ExcludeNextcloud");
    conversions.insert("ExcludeCacheOwnCloud",  QStringList() << "thumbnails" << "ExcludeOwnCloud");
    /******************************************************/
    // category: Thumbnail
    /******************************************************/
    conversions.insert("ThumbnailCache",                      QStringList() << "thumbnails" << "Cache");
    conversions.insert("ThumbnailCenterActive",               QStringList() << "thumbnails" << "CenterOnActive");
    conversions.insert("ThumbnailDisable",                    QStringList() << "thumbnails" << "Disable");
    conversions.insert("ThumbnailFilenameInstead",            QStringList() << "thumbnails" << "FilenameOnly");
    conversions.insert("ThumbnailFilenameInsteadFontSize",    QStringList() << "thumbnails" << "FilenameOnlyFontSize");
    conversions.insert("ThumbnailFontSize",                   QStringList() << "thumbnails" << "FontSize");
    conversions.insert("ThumbnailKeepVisible",                QStringList() << "thumbnails" << "");
    conversions.insert("ThumbnailKeepVisibleWhenNotZoomedIn", QStringList() << "thumbnails" << "");
    conversions.insert("ThumbnailLiftUp",                     QStringList() << "thumbnails" << "LiftUp");
    conversions.insert("ThumbnailMaxNumberThreads",           QStringList() << "thumbnails" << "MaxNumberThreads");
    conversions.insert("ThumbnailPosition",                   QStringList() << "thumbnails" << "Edge");
    conversions.insert("ThumbnailSize",                       QStringList() << "thumbnails" << "Size");
    conversions.insert("ThumbnailSpacingBetween",             QStringList() << "thumbnails" << "Spacing");
    conversions.insert("ThumbnailWriteFilename",              QStringList() << "thumbnails" << "Filename");
    /******************************************************/
    // Slideshow
    /******************************************************/
    conversions.insert("SlideShowHideLabels",        QStringList() << "slideshow" << "HideLabels");
    conversions.insert("SlideShowImageTransition",   QStringList() << "slideshow" << "ImageTransition");
    conversions.insert("SlideShowLoop",              QStringList() << "slideshow" << "Loop");
    conversions.insert("SlideShowMusicFile",         QStringList() << "slideshow" << "MusicFile");
    conversions.insert("SlideShowShuffle",           QStringList() << "slideshow" << "Shuffle");
    conversions.insert("SlideShowTime",              QStringList() << "slideshow" << "Time");
    conversions.insert("SlideShowTypeAnimation",     QStringList() << "slideshow" << "TypeAnimation");
    conversions.insert("SlideShowIncludeSubFolders", QStringList() << "slideshow" << "IncludeSubFolders");
    /******************************************************/
    // category: Metadata
    /******************************************************/
    conversions.insert("MetaApplyRotation",  QStringList() << "metadata" << "AutoRotation");
    conversions.insert("MetaCopyright",      QStringList() << "metadata" << "Copyright");
    conversions.insert("MetaDimensions",     QStringList() << "metadata" << "Dimensions");
    conversions.insert("MetaExposureTime",   QStringList() << "metadata" << "ExposureTime");
    conversions.insert("MetaFilename",       QStringList() << "metadata" << "Filename");
    conversions.insert("MetaFileType",       QStringList() << "metadata" << "FileType");
    conversions.insert("MetaFileSize",       QStringList() << "metadata" << "FileSize");
    conversions.insert("MetaFlash",          QStringList() << "metadata" << "Flash");
    conversions.insert("MetaFLength",        QStringList() << "metadata" << "FLength");
    conversions.insert("MetaFNumber",        QStringList() << "metadata" << "FNumber");
    conversions.insert("MetaGps",            QStringList() << "metadata" << "Gps");
    conversions.insert("MetaGpsMapService",  QStringList() << "metadata" << "GpsMap");
    conversions.insert("MetaImageNumber",    QStringList() << "metadata" << "ImageNumber");
    conversions.insert("MetaIso",            QStringList() << "metadata" << "Iso");
    conversions.insert("MetaKeywords",       QStringList() << "metadata" << "Keywords");
    conversions.insert("MetaLightSource",    QStringList() << "metadata" << "LightSource");
    conversions.insert("MetaLocation",       QStringList() << "metadata" << "Location");
    conversions.insert("MetaMake",           QStringList() << "metadata" << "Make");
    conversions.insert("MetaModel",          QStringList() << "metadata" << "Model");
    conversions.insert("MetaSceneType",      QStringList() << "metadata" << "SceneType");
    conversions.insert("MetaSoftware",       QStringList() << "metadata" << "Software");
    conversions.insert("MetaTimePhotoTaken", QStringList() << "metadata" << "Time");
    /******************************************************/
    // category: Metadata Element
    /******************************************************/
    conversions.insert("MetadataEnableHotEdge", QStringList() << "metadata" << "ElementHotEdge");
    conversions.insert("MetadataWindowWidth",   QStringList() << "metadata" << "ElementWidth");
    /******************************************************/
    // category: People Tags in Metadata
    /******************************************************/
    conversions.insert("PeopleTagInMetaBorderAroundFace",      QStringList() << "metadata" << "FaceTagsBorder");
    conversions.insert("PeopleTagInMetaBorderAroundFaceColor", QStringList() << "metadata" << "FaceTagsBorderColor");
    conversions.insert("PeopleTagInMetaBorderAroundFaceWidth", QStringList() << "metadata" << "FaceTagsBorderWidth");
    conversions.insert("PeopleTagInMetaDisplay",               QStringList() << "metadata" << "FaceTagsEnabled");
    conversions.insert("PeopleTagInMetaFontSize",              QStringList() << "metadata" << "FaceTagsFontSize");
    conversions.insert("PeopleTagInMetaAlwaysVisible",         QStringList() << "metadata" << "");
    conversions.insert("PeopleTagInMetaHybridMode",            QStringList() << "metadata" << "");
    conversions.insert("PeopleTagInMetaIndependentLabels",     QStringList() << "metadata" << "");
    /******************************************************/
    // category: Open File
    /******************************************************/
    conversions.insert("OpenDefaultView",            QStringList() << "openfile" << "DefaultView");
    conversions.insert("OpenKeepLastLocation",       QStringList() << "openfile" << "KeepLastLocation");
    conversions.insert("OpenPreview",                QStringList() << "openfile" << "Preview");
    conversions.insert("OpenShowHiddenFilesFolders", QStringList() << "openfile" << "ShowHiddenFilesFolders");
    conversions.insert("OpenThumbnails",             QStringList() << "openfile" << "Thumbnails");
    conversions.insert("OpenUserPlacesStandard",     QStringList() << "openfile" << "UserPlacesStandard");
    conversions.insert("OpenUserPlacesUser",         QStringList() << "openfile" << "UserPlacesUser");
    conversions.insert("OpenUserPlacesVolumes",      QStringList() << "openfile" << "UserPlacesVolumes");
    conversions.insert("OpenUserPlacesWidth",        QStringList() << "openfile" << "UserPlacesWidth");
    conversions.insert("OpenZoomLevel",              QStringList() << "openfile" << "ZoomLevel");
    /******************************************************/
    // category: Histogram
    /******************************************************/
    conversions.insert("Histogram",         QStringList() << "histogram" << "Visibility");
    conversions.insert("HistogramPosition", QStringList() << "histogram" << "Position");
    conversions.insert("HistogramSize",     QStringList() << "histogram" << "Size");
    conversions.insert("HistogramVersion",  QStringList() << "histogram" << "Version");
    /******************************************************/
    // category: Main Menu Element
    /******************************************************/
    conversions.insert("MainMenuWindowWidth", QStringList() << "mainmenu" << "ElementWidth");
    /******************************************************/
    // category: Video
    /******************************************************/
    conversions.insert("VideoAutoplay",    QStringList() << "filetypes" << "VideoAutoplay");
    conversions.insert("VideoLoop",        QStringList() << "filetypes" << "VideoLoop");
    conversions.insert("VideoVolume",      QStringList() << "filetypes" << "VideoVolume");
    conversions.insert("VideoThumbnailer", QStringList() << "filetypes" << "VideoThumbnailer");
    /******************************************************/
    // category: Popout
    /******************************************************/
    conversions.insert("MainMenuPopoutElement",          QStringList() << "interface" << "PopoutMainMenu");
    conversions.insert("MetadataPopoutElement",          QStringList() << "interface" << "PopoutMetadata");
    conversions.insert("HistogramPopoutElement",         QStringList() << "interface" << "PopoutHistogram");
    conversions.insert("ScalePopoutElement",             QStringList() << "interface" << "PopoutScale");
    conversions.insert("OpenPopoutElement",              QStringList() << "interface" << "PopoutOpenFile");
    conversions.insert("OpenPopoutElementKeepOpen",      QStringList() << "interface" << "PopoutOpenFileKeepOpen");
    conversions.insert("SlideShowSettingsPopoutElement", QStringList() << "interface" << "PopoutSlideShowSettings");
    conversions.insert("SlideShowControlsPopoutElement", QStringList() << "interface" << "PopoutSlideShowControls");
    conversions.insert("FileRenamePopoutElement",        QStringList() << "interface" << "PopoutFileRename");
    conversions.insert("FileDeletePopoutElement",        QStringList() << "interface" << "PopoutFileDelete");
    conversions.insert("AboutPopoutElement",             QStringList() << "interface" << "PopoutAbout");
    conversions.insert("ImgurPopoutElement",             QStringList() << "interface" << "PopoutImgur");
    conversions.insert("WallpaperPopoutElement",         QStringList() << "interface" << "PopoutWallpaper");
    conversions.insert("FilterPopoutElement",            QStringList() << "interface" << "PopoutFilter");
    conversions.insert("SettingsManagerPopoutElement",   QStringList() << "interface" << "PopoutSettingsManager");
    conversions.insert("FileSaveAsPopoutElement",       QStringList() << "interface" << "PopoutFileSaveAs");

    // These are settings combined out of multiple old settings
    QString thumbnailsVisibility = "0";
    QString metadataFaceTagsVisibility = "3";

    const QStringList lines = txt.split("\n");
    for(const auto &line : lines) {

        if(!line.contains("="))
            continue;

        bool dontExecQuery = false;

        QSqlQuery query(db);

        QString key = line.split("=")[0].trimmed();
        QString val = line.split("=")[1].trimmed();

        if(!conversions.contains(key))
            continue;

        QString table = conversions.value(key)[0];
        QString newkey = conversions.value(key)[1];

        query.prepare(QString("UPDATE `%1` SET value=:val WHERE name='%2'").arg(table).arg(newkey));

        /******************************************************/

        if(key == "Version")
            val = QString(VERSION);
        else if(key == "BackgroundImagePath") {
            // workaround to old bug where this value was either 0 or 1 instead of filepath
            if(val == "0" || val == "1")
                val = "";
        } else if(key == "ExcludeCacheFolders") {
            QStringList result;
            QByteArray byteArray = QByteArray::fromBase64(val.toUtf8());
            QDataStream in(&byteArray, QIODevice::ReadOnly);
            in >> result;
            val = result.join(":://::");
        } else if(key == "ThumbnailKeepVisible") {
            dontExecQuery = true;
            if(val == "1")
                thumbnailsVisibility = "1";
        } else if(key == "ThumbnailKeepVisibleWhenNotZoomedIn") {
            dontExecQuery = true;
            if(val == "1")
                thumbnailsVisibility = "2";
        } else if(key == "PeopleTagInMetaAlwaysVisible") {
            dontExecQuery = true;
            if(val == "1")
                metadataFaceTagsVisibility = "1";
        } else if(key == "PeopleTagInMetaHybridMode") {
            dontExecQuery = true;
            if(val == "1")
                metadataFaceTagsVisibility = "0";
        } else if(key == "PeopleTagInMetaIndependentLabels") {
            dontExecQuery = true;
            if(val == "1")
                metadataFaceTagsVisibility = "2";
        }

        if(!dontExecQuery) {

            query.bindValue(":val", val);

            if(!query.exec()) {
                LOG << CURDATE << "PQStartup::migrateSettingsToDb(): Updating setting failed:  " << key.toStdString() << " / " << val.toStdString() << NL;
                LOG << CURDATE << "PQStartup::migrateSettingsToDb(): SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
            }

        }

        query.clear();

    }

    // The following multiple old settings combine, thus they can only be updated here

    QSqlQuery query(db);
    query.prepare("UPDATE `thumbnails` SET value=:val WHERE name='Visibility'");
    query.bindValue(":val", thumbnailsVisibility);
    if(!query.exec()) {
        LOG << CURDATE << "PQStartup::migrateSettingsToDb(): Updating setting failed:  thumbnailsVisibility / " << thumbnailsVisibility.toStdString() << NL;
        LOG << CURDATE << "PQStartup::migrateSettingsToDb(): SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
    }

    query.clear();
    query.prepare("UPDATE `metadata` SET value=:val WHERE name='FaceTagsVisibility'");
    query.bindValue(":val", metadataFaceTagsVisibility);
    if(!query.exec()) {
        LOG << CURDATE << "PQStartup::migrateSettingsToDb(): Updating setting failed:  metadataFaceTagsVisibility / " << metadataFaceTagsVisibility.toStdString() << NL;
        LOG << CURDATE << "PQStartup::migrateSettingsToDb(): SQL error:  " << query.lastError().text().trimmed().toStdString() << NL;
    }

    QString oldfile = QString("%1.pre-v2.5").arg(ConfigFiles::SETTINGS_FILE());
    if(!QFile::exists(oldfile)) {
        if(!QFile::copy(ConfigFiles::SETTINGS_FILE(), oldfile))
            LOG << CURDATE << "PQStartup::migrateSettingsToDb(): Failed to copy old settings file to 'settings.pre-v2.5' filename" << NL;
        QFile file(oldfile);
        file.setPermissions(file.permissions()|QFileDevice::WriteOwner);
    }

    if(QFile::exists(QString("%1.pre-v2.5").arg(ConfigFiles::SETTINGS_FILE())))
        if(!QFile::remove(ConfigFiles::SETTINGS_FILE()))
            LOG << CURDATE << "PQStartup::migrateSettingsToDb(): Failed to rename old settings file to 'settings.pre-v2.5'" << NL;

    query.clear();

    return true;

}

void PQStartup::showInfo() {

    LOG << NL << "PhotoQt configuration:" << NL << NL
        << PQHandlingGeneral::getConfigInfo().toStdString()
        << NL;

}
