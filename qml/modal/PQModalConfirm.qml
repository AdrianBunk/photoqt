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

import QtQuick.Dialogs 1.3

MessageDialog {

    id: top

    title: ""
    text: ""
    standardButtons: StandardButton.Yes|StandardButton.No

    modality: Qt.WindowModal

    property bool confirmed: false

    onYes: {
        if(!confirmed)
            confirmed = true
        else
            confirmedChanged()
    }
    onNo: {
        if(confirmed)
            confirmed = false
        else
            confirmedChanged()
    }

    function askForConfirmation(text, informativeText) {
        top.text = text
        top.informativeText = informativeText
        top.open()
    }

}
