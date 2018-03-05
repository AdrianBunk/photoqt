/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2018 Lukas Spies                                       **
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

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.2

import "../../../elements"
import "../../"

EntryContainer {

    id: item_top

    Row {

        spacing: 20

        EntryTitle {

            id: title
            title: em.pty+qsTr("File Formats") + ":<br>&gt; GraphicsMagick/Ghostscript"
                      //: Used as in 'disabled category'
                   + (helptext_warning ? "<br><br><font color=\"red\"><i>&gt; " + em.pty+qsTr("disabled") + "!</i></font>" : "")
            helptext: entry.enabled
                      ? em.pty+qsTr("The following file types are supported by GraphicsMagick, and they have been tested and should work. However, they require Ghostscript to be installed on the system.")
                      : "<div color='red'>" + em.pty+qsTr("PhotoQt was built without GraphicsMagick support!") + "</div>"

            helptext_warning: !entry.enabled

        }

        EntrySetting {

            id: entry

            enabled: getanddostuff.isGraphicsMagickSupportEnabled()

            // the model array
            property var types_gm: [["", "", true]]
            // which item is checked
            property var modeldata: {"" : ""}

            GridView {

                id: grid
                width: item_top.width-title.x-title.width
                height: childrenRect.height
                cellWidth: 300
                cellHeight: 30+spacing*2
                property int spacing: 3

                interactive: false

                model: entry.types_gm.length
                delegate: FileTypesTile {
                    id: tile
                    fileType: entry.types_gm[index][0]
                    fileEnding: entry.types_gm[index][1]
                    checked: entry.types_gm[index][2]
                    width: grid.cellWidth-grid.spacing*2
                    x: grid.spacing
                    height: grid.cellHeight-grid.spacing*2
                    y: grid.spacing

                    // Store updates
                    Component.onCompleted:
                        entry.modeldata[entry.types_gm[index][1]] = tile.checked
                    onCheckedChanged:
                        entry.modeldata[entry.types_gm[index][1]] = tile.checked
                }

            }

        }

    }

    function setData() {

        // storing intermediate results
        var tmp_types_gm = []

        // Get current settings
        var setformats = fileformats.formats_gm_ghostscript

        // Valid fileformats
        var gm = [["Encapsulated PostScript","*.eps", "*.epsf"],
            ["Encapsulated PostScript Interchange","*.epi", "*.epsi", "*.ept"],
            ["Level II Encapsulated PostScript","*.eps2"],
            ["Level III Encapsulated PostScript","*.eps3"],
            ["Portable Document Format","*.pdf"],
            ["Adobe PostScript","*.ps"],
            ["Adobe Level II PostScript","*.ps2"],
            ["Adobe Level III PostScript","*.ps3"]]

        for(var i = 0; i < gm.length; ++i) {

            // the current file ending
            var cur = gm[i]
            // if it has been found
            var found = true
            // And the file endings composed in string
            var composed = ""

            for(var j = 1; j < cur.length; ++j) {

                // If found, then the current file format is ENabled, if not then it is DISabled
                if(setformats.indexOf(cur[j]) === -1)
                    found = false

                // The space aftet eh comma is very important! It is needed when saving data
                if(composed != "") composed += ", "
                composed += cur[j]
            }

            // Add to temporary array
            tmp_types_gm = tmp_types_gm.concat([[cur[0],composed,found]])

        }

        // Set new data
        entry.types_gm = tmp_types_gm

    }

    function saveData() {

        // Storing valid elements
        var tobesaved = []

        // Loop over all data and store checked elements
        for(var ele in entry.modeldata) {
            if(entry.modeldata[ele])
                tobesaved = tobesaved.concat(ele.split(", "))
        }

        // Update data
        fileformats.formats_gm_ghostscript = tobesaved.filter(function(n){ return n !== ""; })

    }

}