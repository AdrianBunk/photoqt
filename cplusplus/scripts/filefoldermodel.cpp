#include "filefoldermodel.h"
#include <chrono>

PQFileFolderModel::PQFileFolderModel(QObject *parent) : QAbstractListModel(parent) {

    loadDelay = new QTimer;
    loadDelay->setInterval(0);
    loadDelay->setSingleShot(true);
    connect(loadDelay, &QTimer::timeout, this, &PQFileFolderModel::loadData);

    if(m_folder.isNull())
        m_folder = QDir::homePath();

    // this is needed so that the delete in loadData() is valid. Checking there for nullptr has led to crashes in the past
    watcher = new QFileSystemWatcher;

    loadDelay->start();

}

void PQFileFolderModel::loadData() {

    beginRemoveRows(QModelIndex(), 0, rowCount());

    for(int i = 0; i < entries.length(); ++i)
        delete entries[i];
    entries.clear();
    allImageFilesInOrder.clear();

    endRemoveRows();

    delete watcher;
    watcher = new QFileSystemWatcher;
    watcher->addPath(m_folder);
    connect(watcher, &QFileSystemWatcher::directoryChanged, this, &PQFileFolderModel::loadData);

    // FIRST ALL DIRS

    QDir dir;
    dir.setPath(m_folder);

    if(!dir.exists()) {
        LOG << CURDATE << "ERROR: Folder location does not exist: " << m_folder.toStdString() << NL;
        return;
    }

    if(m_showHidden)
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot|QDir::Hidden);
    else
        dir.setFilter(QDir::Dirs|QDir::NoDotAndDotDot);

    if(m_sortField != SortBy::NaturalName) {

        QDir::SortFlags flags = QDir::IgnoreCase;
        if(m_sortReversed)
            flags |= QDir::Reversed;
        if(m_sortField == SortBy::Name)
            flags |= QDir::Name;
        else if(m_sortField == SortBy::Time)
            flags |= QDir::Time;
        else if(m_sortField == SortBy::Size)
            flags |= QDir::Size;
        else if(m_sortField == SortBy::Type)
            flags |= QDir::Type;

        dir.setSorting(flags);

    }

    QFileInfoList alldirs = dir.entryInfoList();

    if(m_sortField == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(m_sortReversed)
            std::sort(alldirs.begin(), alldirs.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
        else
            std::sort(alldirs.begin(), alldirs.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
    }

    // THEN ALL FILES

    dir.setNameFilters(m_nameFilters);
    dir.setFilter(QDir::Files|QDir::NoDotAndDotDot);

    if(m_sortField != SortBy::NaturalName) {

        QDir::SortFlags flags = QDir::IgnoreCase;
        if(m_sortReversed)
            flags |= QDir::Reversed;
        if(m_sortField == SortBy::Name)
            flags |= QDir::Name;
        else if(m_sortField == SortBy::Time)
            flags |= QDir::Time;
        else if(m_sortField == SortBy::Size)
            flags |= QDir::Size;
        else if(m_sortField == SortBy::Type)
            flags |= QDir::Type;

        dir.setSorting(flags);

    }

    QFileInfoList allfiles = dir.entryInfoList();

    if(m_sortField == SortBy::NaturalName) {
        QCollator collator;
        collator.setNumericMode(true);
        if(m_sortReversed)
            std::sort(allfiles.begin(), allfiles.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file2.fileName(), file1.fileName()) < 0; });
        else
            std::sort(allfiles.begin(), allfiles.end(), [&collator](const QFileInfo &file1, const QFileInfo &file2) { return collator.compare(file1.fileName(), file2.fileName()) < 0; });
    }

    allImageFilesInOrder = allfiles;

    QFileInfoList entrylist = alldirs+allfiles;

    m_count = entrylist.length();

    if(m_count == 0)
        return;

    entries.reserve(m_count);

    beginInsertRows(QModelIndex(), rowCount(), rowCount()+entrylist.length()-1);

    for(int i = 0; i < m_count; ++i) {

        PQFileFolderEntry *entry = new PQFileFolderEntry;
        entry->fileName = entrylist.at(i).fileName();
        entry->filePath = entrylist.at(i).filePath();
        entry->fileSize = entrylist.at(i).size();
        entry->fileModified = entrylist.at(i).lastModified();
        entry->fileIsDir = entrylist.at(i).isDir();

        entries.push_back(entry);

    }

    endInsertRows();

    emit dataChanged(createIndex(0, 0, entries.first()), createIndex(entries.length()-1, 0, entries.last()));

}
