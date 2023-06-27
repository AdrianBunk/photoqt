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

#include <pqc_filefoldermodelcache.h>
#include <QTextStream>
#include <QFileInfo>
#include <QSize>
#include <QCryptographicHash>

PQCFileFolderModelCache::PQCFileFolderModelCache() {
    cacheFiles.clear();
    cacheFolders.clear();
}

bool PQCFileFolderModelCache::loadFilesFromCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed, QStringList &entriesFiles) {
    const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, ignoreFiltersExceptDefault, sortField, sortReversed);
    if(cacheFiles.contains(key)) {
        entriesFiles = cacheFiles.value(key);
        return true;
    }
    return false;
}

bool PQCFileFolderModelCache::loadFoldersFromCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed, QStringList &entriesFolders) {
    const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, ignoreFiltersExceptDefault, sortField, sortReversed);
    if(cacheFolders.contains(key)) {
        entriesFolders = cacheFolders.value(key);
        return true;
    }
    return false;
}

void PQCFileFolderModelCache::saveFilesToCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed, QStringList &entriesFiles) {
    const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, ignoreFiltersExceptDefault, sortField, sortReversed);
    cacheFiles.insert(key, entriesFiles);
}

void PQCFileFolderModelCache::saveFoldersToCache(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFileters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed, QStringList &entriesFolders) {
    const QString key = getUniqueCacheKey(foldername, showHidden, sortFlags, defaultNameFilters, nameFilters, filenameFileters, mimeTypeFilters, imageResolutionFilter, fileSizeFilter, ignoreFiltersExceptDefault, sortField, sortReversed);
    cacheFolders.insert(key, entriesFolders);
}

QString PQCFileFolderModelCache::getUniqueCacheKey(QString foldername, bool showHidden, int sortFlags, QStringList defaultNameFilters, QStringList nameFilters, QStringList filenameFilters, QStringList mimeTypeFilters, QSize imageResolutionFilter, int fileSizeFilter, bool ignoreFiltersExceptDefault, int sortField, bool sortReversed) {
    QString key;
    QTextStream(&key) << foldername
                      << showHidden
                      << QFileInfo(foldername).lastModified().toMSecsSinceEpoch()
                      << sortFlags
                      << nameFilters.join("")
                      << defaultNameFilters.join("")
                      << filenameFilters.join("")
                      << mimeTypeFilters.join("")
                      << imageResolutionFilter.width() << imageResolutionFilter.height()
                      << fileSizeFilter
                      << ignoreFiltersExceptDefault
                      << sortField
                      << sortReversed;
    return QCryptographicHash::hash(key.toUtf8(),QCryptographicHash::Md5).toHex();
}

void PQCFileFolderModelCache::resetData() {
    cacheFiles.clear();
    cacheFolders.clear();
}
