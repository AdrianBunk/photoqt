import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

    id: tab

    color: "#00000000"

    anchors {
        fill: parent
        leftMargin: 20
        rightMargin: 20
        topMargin: 15
        bottomMargin: 5
    }

    Flickable {

        id: flickable

        clip: true

        anchors.fill: parent

        contentHeight: contentItem.childrenRect.height+50
        contentWidth: tab.width

        boundsBehavior: Flickable.StopAtBounds

        Column {

            id: maincol

            spacing: 15

            /**********
             * HEADER *
             **********/

            Rectangle {
                id: header
                width: flickable.width
                height: childrenRect.height
                color: "#00000000"
                Text {
                    color: "white"
                    font.pointSize: 18
                    font.bold: true
                    text: "Advanced Settings"
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            /******************
             * THUMBNAIL EDGE *
             ******************/

            SettingsText {

                width: flickable.width

                text: "<h2>Change Thumbnail Position</h2><br>Per default the bar with the thumbnails is shown at the lower edge. However, some might find it nice and handy to have the thumbnail bar at the upper edge, so that's what can be changed here."

            }

            Rectangle {

                color: "#00000000"

                width: childrenRect.width
                height: childrenRect.height

                x: (flickable.width-width)/2

                Row {

                    spacing: 10

                    ExclusiveGroup { id: edgegroup; }

                    CustomRadioButton {
                        id: loweredge
                        text: "Show at lower edge"
                        checked: true
                        exclusiveGroup: edgegroup
                    }

                    CustomRadioButton {
                        id: upperedge
                        text: "Show at upper edge"
                        exclusiveGroup: edgegroup
                    }

                }

            }


            /**********************
             * FILENAME/DIMENSION *
             **********************/

            SettingsText {

                width: flickable.width

                text: "<h2>Filename? Dimension? Or both?</h2><br>When thumbnails are displayed at the top/bottom, PhotoQt usually writes the filename on them. But also the dimension of the image can be written on it. Or also both or none. You can use the slider below to adjust the font size."

            }

            /* WHICH ONE? */

            Rectangle {

                color: "#00000000"

                // center rectangle
                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Row {

                    spacing: 10

                    CustomCheckBox {
                        id: writefilename
                        text: "Write Filename"
                    }

                    CustomCheckBox {
                        id: writedimension
                        text: "Write Dimension"
                    }

                }

            }

            /* FONT SIZE? */

            Rectangle {

                color: "#00000000"

                // center rectangle
                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Row {

                    spacing: 10

                    CustomSlider {

                        id: fontsize_slider

                        width: 400

                        minimumValue: 5
                        maximumValue: 20

                        value: fontsize_spinbox.value
                        stepSize: 1

                        enabled: writefilename.checkedButton || writedimension.checkedButton

                    }

                    CustomSpinBox {

                        id: fontsize_spinbox

                        width: 75

                        minimumValue: 5
                        maximumValue: 20

                        value: fontsize_slider.value

                        enabled: writefilename.checkedButton || writedimension.checkedButton

                    }

                }

            }



            /******************
             * FILENAME ONLY? *
             ******************/

            SettingsText {

                width: flickable.width

                text: "<h2>Use file-name-only Thumbnails</h2><br>If you don't want PhotoQt to always load the actual image thumbnail in the background, but you still want to have something for better navigating, then you can set a file-name-only thumbnail, i.e. PhotoQt wont load any thumbnail images but simply puts the file name into the box. You can also adjust the font size of this text."

            }

            CustomCheckBox {
                id: filenameonly
                text: "Use filename-only thumbnail"
                x: (flickable.width-width)/2
            }


            /* FONT SIZE? */

            Rectangle {

                color: "#00000000"

                // center rectangle
                width: childrenRect.width
                height: childrenRect.height
                x: (flickable.width-width)/2

                Row {

                    spacing: 10

                    CustomSlider {

                        id: filenameonly_fontsize_slider

                        width: 400

                        minimumValue: 5
                        maximumValue: 20

                        enabled: filenameonly.checkedButton

                        value: filenameonly_fontsize_spinbox.value
                        stepSize: 1

                    }

                    CustomSpinBox {

                        id: filenameonly_fontsize_spinbox

                        width: 75

                        minimumValue: 5
                        maximumValue: 20

                        enabled: filenameonly.checkedButton

                        value: filenameonly_fontsize_slider.value

                    }

                }

            }



            /**************
             * PRELOADING *
             **************/

            SettingsText {

                width: flickable.width

                text: "<h2>Preloading</h2><br>Here you can adjust, how many images AT MOST will be preloaded. For example, if the directory contains 800 images, a limit of 400 (default value) means, that starting from the opened image, 200 images to the left and 200 to the right are preloaded.<br><br>If you don't want to limit PhotoQt to any number, you can simply enable the option to always preload the full directory. WARNING: This is perfectly fine for directories with a small number of images (usually anything less than 1000, depending on your computer), but can lead to performance and memory issues for larger directories. Make sure you know what you're doing before enabling this!"

            }

            Rectangle {

                color: "#00000000"

                width: childrenRect.width
                height: childrenRect.height

                x: (flickable.width-width)/2

                Column {

                    spacing: 10

                    Row {

                        spacing: 5

                        CustomSlider {

                            id: preload_slider

                            width: 400

                            minimumValue: 50
                            maximumValue: 2500

                            enabled: !preload_button.checkedButton

                            value: preload_spinbox.value
                            stepSize: 1

                        }

                        CustomSpinBox {

                            id: preload_spinbox

                            width: 125

                            minimumValue: 50
                            maximumValue: 2500

                            suffix: " images"

                            enabled: !preload_button.checkedButton

                            value: preload_slider.value

                        }

                    }

                    CustomCheckBox {
                        id: preload_button
                        x: (parent.width-width)/2
                        text: "Preload Full Directory"
                    }


                }

            }

            /**********************
             * DISABLE THUMBNAILS *
             **********************/

            SettingsText {

                width: flickable.width

                text: "<h2>Disable Thumbnails</h2><br>If you just don't need or don't want any thumbnails whatsoever, then you can disable them here completely. This option can also be toggled remotely via command line (run 'photoqt --help' for more information on that). This might increase the speed of PhotoQt a good bit, however, navigating through a folder might be a little harder without thumbnails."

            }

            CustomCheckBox {

                id: disable

                text: "Disable Thumbnails altogether"

                x: (flickable.width-width)/2

            }


            /*******************
             * THUMBNAIL CACHE *
             *******************/

            SettingsText {

                width: flickable.width

                text: "<h2>Thumbnail Cache</h2><br>Thumbnails can be cached in two different ways:<br>1) File Caching (following the freedesktop.org standard) or<br>2) Database Caching (better performance and management, default option).<br><br>Both ways have their advantages and disadvantages:<br>File Caching is done according to the freedesktop.org standard and thus different applications can share the same thumbnail for the same image file. However, it's not possible to check for obsolete thumbnails (thus this may lead to many unneeded thumbnail files).<br>Database Caching doesn't have the advantage of sharing thumbnails with other applications (and thus every thumbnails has to be newly created for PhotoQt), but it brings a slightly better performance, and it allows a better handling of existing thumbnails (e.g. deleting obsolete thumbnails).<br><br>PhotoQt works with either option, though the second way is set as default.<br><br>Although everybody is encouraged to use at least one of the two options, caching can be completely disabled altogether. However, that does affect the performance and usability of PhotoQt, since thumbnails have to be newly re-created every time they are needed."

            }

            Rectangle {

                id: cacherect

                width: childrenRect.width
                height: childrenRect.height

                x: (flickable.width-width)/2

                color: "#00000000"

                Column {

                    spacing: 15

                    CustomCheckBox {

                        id: cache

                        x: (parent.width-width)/2

                        text: "Enable Thumbnail Cache"

                    }

                    Rectangle {

                        width: childrenRect.width
                        height: childrenRect.height

                        x: (parent.width-width)/2

                        color: "#00000000"

                        Row {

                            spacing: 10

                            ExclusiveGroup { id: cachegroup; }

                            CustomRadioButton {
                                id: cache_file
                                text: "File Caching"
                                enabled: cache.checkedButton
                                exclusiveGroup: cachegroup
                            }
                            CustomRadioButton {
                                id: cache_db
                                text: "Database Caching"
                                enabled: cache.checkedButton
                                exclusiveGroup: cachegroup
                            }

                        }

                    }

                    Column {

                        Rectangle {

                            width: childrenRect.width
                            height: childrenRect.height

                            color: "#00000000"

                            x: (cacherect.width-width)/2

                            Row {
                                spacing: 5
                                Text {
                                    color: cache.checkedButton ? "white" : "#555555"
                                    text: "Current database filesize:"
                                }
                                Text {
                                    id: db_filesize
                                    color: cache.checkedButton ? "white" : "#555555"
                                    text: "0 KB"
                                }
                            }
                        }


                        Rectangle {

                            width: childrenRect.width
                            height: childrenRect.height

                            color: "#00000000"

                            x: (cacherect.width-width)/2

                            Row {
                                spacing: 5
                                Text {
                                    color: cache.checkedButton ? "white" : "#555555"
                                    text: "Entries in database:"
                                }
                                Text {
                                    id: db_entries
                                    color: cache.checkedButton ? "white" : "#555555"
                                    text: "0"
                                }
                            }
                        }

                    }

                    Row {

                        spacing: 10

                        CustomButton {

                            id: cleanup
                            height: 35
                            text: "CLEAN UP database"

                            enabled: cache.checkedButton

                            onClickedButton: confirmclean.show()

                        }

                        CustomButton {

                            id: erase
                            height: 35
                            text: "ERASE database"

                            enabled: cache.checkedButton

                            onClickedButton: confirmerase.show()

                        }

                    }

                }

            }

        }

    }

    function setData() {

        loweredge.checked = (settings.thumbnailposition === "Bottom")
        upperedge.checked = (settings.thumbnailposition === "Top")

        writefilename.checkedButton = settings.thumbnailWriteFilename
        writedimension.checkedButton = settings.thumbnailWriteResolution
        fontsize_slider.value = settings.thumbnailFontSize

        filenameonly.checkedButton = settings.thumbnailFilenameInstead
        filenameonly_fontsize_slider.value = settings.thumbnailFilenameInsteadFontSize

        preload_slider.value = settings.thumbnailPreloadNumber
        preload_button.checkedButton = settings.thumbnailPreloadFullDirectory

        disable.checkedButton = settings.thumbnailDisable

        cache.checkedButton = settings.thumbnailcache
        cache_file.checked = settings.thbcachefile
        cache_db.checked = !settings.thbcachefile

        // Update db info
        updateDatabaseInfo()

    }

    function saveData() {

        if(loweredge.checked) settings.thumbnailposition = "Bottom"
        else settings.thumbnailposition = "Top"

        settings.thumbnailWriteFilename = writefilename.checkedButton
        settings.thumbnailWriteResolution = writedimension.checkedButton
        settings.thumbnailFontSize = fontsize_slider.value

        settings.thumbnailFilenameInstead = filenameonly.checkedButton
        settings.thumbnailFilenameInsteadFontSize = filenameonly_fontsize_slider.value

        settings.thumbnailPreloadNumber = preload_slider.value
        settings.thumbnailPreloadFullDirectory = preload_button.checkedButton

        settings.thumbnailDisable = disable.checkedButton

        settings.thumbnailcache = cache.checkedButton
        settings.thbcachefile = cache_file.checked

    }

    function updateDatabaseInfo() {

        var filesize = thumbnailmanagement.getDatabaseFilesize()
        db_filesize.text = filesize + " KB  (" + Math.round(filesize*100/1024)/100 + " MB)"
        db_entries.text = thumbnailmanagement.getNumberDatabaseEntries()

    }

    function eraseDatabase() {
        thumbnailmanagement.eraseDatabase()
        updateDatabaseInfo()
    }

    function cleanDatabase() {
        thumbnailmanagement.cleanDatabase()
        updateDatabaseInfo()
    }

}