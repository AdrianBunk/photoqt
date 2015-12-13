import QtQuick 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.2

import "./shortcuts"
import "../../elements"


Rectangle {

	id: tab_top

	property int titlewidth: 100
	property string currentKeyCombo: ""
	onCurrentKeyComboChanged: navigation.currentKeyCombo = currentKeyCombo

	property bool keysReleased: false
	onKeysReleasedChanged: {
		navigation.keysReleased = true
		keysReleased = false
	}

	// This signal ensures that only one shortcut is detected at a time in any category
	signal cancelDetectionEverywhere()

	color: "#00000000"

	anchors {
		fill: parent
		bottomMargin: 5
	}

	Flickable {

		id: flickable

		clip: true

		anchors.fill: parent

		contentHeight: contentItem.childrenRect.height+20
		contentWidth: maincol.width

		Column {

			id: maincol

			Rectangle { color: "transparent"; width: 1; height: 10; }

			Text {
				width: flickable.width
				color: "white"
				font.pointSize: 20
				font.bold: true
				text: "Shortcuts"
				horizontalAlignment: Text.AlignHCenter
			}

			Rectangle { color: "transparent"; width: 1; height: 20; }

			Text {
				color: "white"
				width: flickable.width-20
				x: 10
				wrapMode: Text.WordWrap
				text: qsTr("Here you can adjust the shortcuts, add new or remove existing ones, or change a key combination. The shortcuts are grouped into 4 different categories for internal commands plus a category for external commands. The boxes on the right side contain all the possible commands. To add a shortcut for one of the available function you can either double click on the tile or click the \"+\" button. This automatically opens another widget where you can set a key combination.")
			}

			Rectangle { color: "transparent"; width: 1; height: 30; }

			Rectangle { color: "#88ffffff"; width: parent.width; height: 1; }

			Rectangle { color: "transparent"; width: 1; height: 20; }

			ShortcutsContainer {
				id: navigation
				category: "Navigation"
				allAvailableItems: [["__open",qsTr("Open New File")],
									["__filterImages",qsTr("Filter Images in Folder")],
									["__next",qsTr("Next Image")],
									["__prev",qsTr("Previous Image")],
									["__gotoFirstThb",qsTr("Go to first Image")],
									["__gotoLastThb",qsTr("Go to last Image")],
									["__hide",qsTr("Hide to System Tray")],
									["__close",qsTr("Quit PhotoQt")]]
			}

			ShortcutsContainer {
				id: image
				category: "Image"
				allAvailableItems: [["__zoomIn", qsTr("Zoom In")],
									["__zoomOut", qsTr("Zoom Out")],
									["__zoomActual", qsTr("Zoom to Actual Size")],
									["__zoomReset", qsTr("Reset Zoom")],
									["__rotateR", qsTr("Rotate Right")],
									["__rotateL", qsTr("Rotate Left")],
									["__rotate0", qsTr("Reset Rotation")],
									["__flipH", qsTr("Flip Horizontally")],
									["__flipV", qsTr("Flip Vertically")],
									["__scale", qsTr("Scale Image")]]
			}

			ShortcutsContainer {
				id: file
				category: "File"
				allAvailableItems: [["__rename", qsTr("Rename File")],
									["__delete", qsTr("Delete File")],
									["__copy", qsTr("Copy File to a New Location")],
									["__move", qsTr("Move File to a New Location")]]
			}

			ShortcutsContainer {
				id: other
				category: "Other"
				allAvailableItems: [["__stopThb", qsTr("Interrupt Thumbnail Creation")],
									["__reloadThb", qsTr("Reload Thumbnails")],
									["__hideMeta", qsTr("Hide/Show Exif Info")],
									["__showContext", qsTr("Show Context Menu")],
									["__settings", qsTr("Show Settings")],
									["__slideshow", qsTr("Start Slideshow")],
									["__slideshowQuick", qsTr("Start Slideshow (Quickstart)")],
									["__about", qsTr("About PhotoQt")],
									["__wallpaper", qsTr("Set as Wallpaper")]]
			}

			ShortcutsContainer {
				id: external
				category: "External"
				external: true
				allAvailableItems: [["", qsTr("External")]]
			}

		}

	}

	function setData() {
		var _shortcuts = getanddostuff.getShortcuts()
		navigation.setData(_shortcuts)
		image.setData(_shortcuts)
		file.setData(_shortcuts)
		other.setData(_shortcuts)
		external.setData(_shortcuts)
	}

	function saveData() {

		var dat = navigation.saveData()
		dat = dat.concat(image.saveData())
		dat = dat.concat(file.saveData())
		dat = dat.concat(other.saveData())

		var tosave = []

		for(var i = 0; i < dat.length; ++i) {

			var cur = dat[i];

			tosave = tosave.concat([[cur[0], cur[2], cur[3]]])

		}

		getanddostuff.saveShortcuts(tosave)

//			console.log(dat[i])

	}

}
