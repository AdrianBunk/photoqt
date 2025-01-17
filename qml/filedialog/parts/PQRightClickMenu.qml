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

import QtQuick 2.9
import QtQuick.Controls 1.4
import "../../elements"

PQMenu {

    id: control

    property bool isFolder: false
    property bool isFile: false
    property string path: ""

    signal closed()

    MenuItem {
        visible: isFile || isFolder
        text: (isFolder ? qsTranslate("filedialog", "Load this folder") : qsTranslate("filedialog", "Load this file"))
        onTriggered: {
            if(isFolder)
                filedialog_top.setCurrentDirectory(path)
            else {
                filefoldermodel.setFileNameOnceReloaded = path
                filefoldermodel.fileInFolderMainView = path
                filedialog_top.hideFileDialog()
            }
        }
    }
    MenuItem {
        visible: isFolder && handlingGeneral.isPugixmlSupportEnabled()
        text: (em.pty+qsTranslate("filedialog", "Add to Favorites"))
        onTriggered:
            handlingFileDialog.addNewUserPlacesEntry(path, upl.model.count)
    }
    MenuSeparator { visible: isFile || isFolder }
    MenuItem {
        visible: isFile || isFolder
        text: fileview.isCurrentFileSelected() ? qsTranslate("filedialog", "Remove file selection") : qsTranslate("filedialog", "Select file")
        onTriggered: {
            fileview.toggleCurrentFileSelection()
        }
    }
    MenuItem {
        text: fileview.isCurrentFileSelected() ? qsTranslate("filedialog", "Remove all file selection") : qsTranslate("filedialog", "Select all files")
        onTriggered: {
            fileview.setFilesSelection(!fileview.isCurrentFileSelected())
        }
    }
    MenuSeparator { }
    MenuItem {
        visible: !handlingGeneral.amIOnWindows() || handlingGeneral.isAtLeastQt515()
        enabled: (isFile || isFolder || fileview.anyFilesSelected())
        text: (fileview.isCurrentFileSelected() || (!isFile && !isFolder && fileview.anyFilesSelected()))
                    ? qsTranslate("filedialog", "Delete selection")
                    : (isFile ? qsTranslate("filedialog", "Delete file") : (isFolder ? qsTranslate("filedialog", "Delete folder") : qsTranslate("filedialog", "Delete file/folder")))
        onTriggered:
            fileview.doDeleteFiles()
    }
    MenuItem {
        enabled: (isFile || isFolder || fileview.anyFilesSelected())
        text: (fileview.isCurrentFileSelected() || (!isFile && !isFolder && fileview.anyFilesSelected()))
                    ? qsTranslate("filedialog", "Cut selection")
                    : (isFile ? qsTranslate("filedialog", "Cut file") : (isFolder ? qsTranslate("filedialog", "Cut folder") : qsTranslate("filedialog", "Cut file/folder")))
        onTriggered:
            fileview.doCutFiles()
    }
    MenuItem {
        enabled: (isFile || isFolder || fileview.anyFilesSelected())
        text: (fileview.isCurrentFileSelected() || (!isFile && !isFolder && fileview.anyFilesSelected()))
                    ? qsTranslate("filedialog", "Copy selection")
                    : (isFile ? qsTranslate("filedialog", "Copy file") : (isFolder ? qsTranslate("filedialog", "Copy folder") : qsTranslate("filedialog", "Copy file/folder")))
        onTriggered:
            fileview.doCopyFiles()
    }
    MenuItem {
        id: item_paste
        text: qsTranslate("filedialog", "Paste files from clipboard")
        onTriggered:
            fileview.doPasteFiles()

        Component.onCompleted: {
            item_paste.enabled = handlingExternal.areFilesInClipboard()
        }
    }

    MenuSeparator { }

    MenuItem {
        checkable: true
        checked: PQSettings.openfileShowHiddenFilesFolders
        text: qsTranslate("filedialog", "Show hidden files")
        onTriggered:
            PQSettings.openfileShowHiddenFilesFolders = !PQSettings.openfileShowHiddenFilesFolders
    }
    MenuItem {
        checkable: true
        checked: PQSettings.openfileDetailsTooltip
        text: qsTranslate("filedialog", "Show tooltip with image details")
        onTriggered:
            PQSettings.openfileDetailsTooltip = !PQSettings.openfileDetailsTooltip
    }

    Connections {
        target: handlingExternal
        onChangedClipboardData: {
            item_paste.enabled = handlingExternal.areFilesInClipboard()
        }
    }

}
