import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: meta

	// Set up model on first load, afetrwards just change data
	property bool imageLoaded: false

	property int orientation: 0

	// Background/Border color
	color: colour_slidein_bg
	border.width: 1
	border.color: colour_slidein_border

	// Set position (we pretend that rounded corners are along the right edge only, that's why visible x is off screen)
	x: -width-safetyDistanceForSlidein
	y: (background.height-meta.height)/3

	// Adjust size
	width: ((view.width+2*radius < 350) ? 350 : view.width+2*radius)
	height: ((imageLoaded) ? (view.contentHeight > width/2 ? view.contentHeight : width/2) : width)+2*check.height+2*spacing.height

	// Corner radius
	radius: 10

	// Label at first start-up
	Text {

		anchors.fill: parent

		color: "grey"

		visible: !imageLoaded
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter

		font.bold: true
		font.pointSize: 18
		text: "No File Loaded"

	}

	Text {

		id: unsupportedLabel

		anchors.fill: parent

		color: "grey"

		visible: false
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter

		font.bold: true
		font.pointSize: 18
		text: "File Format Not Supported"

	}

	Text {

		id: invalidLabel

		anchors.fill: parent

		color: "grey"

		visible: false
		horizontalAlignment: Qt.AlignHCenter
		verticalAlignment: Qt.AlignVCenter

		font.bold: true
		font.pointSize: 18
		text: "Invalid File"

	}

	ListView {

		id: view

		x: meta.radius+10
		y: radius

		width: childrenRect.width
		height: meta.height-2*check.height-2*spacing.height

		visible: imageLoaded
		model: ListModel { id: mod; }
		delegate: deleg

	}

	Rectangle {
		id: spacing
		width: meta.width
		height: 1
		x: 0
		y: view.height+view.y
		color: colour_linecolour
	}

	Rectangle {
		id: keepopen
		color: "#00000000"
		x: 0
		y: view.height+view.y+spacing.height+3
		width: meta.width
		CustomCheckBox {
			id: check
			textOnRight: false
			anchors.right: parent.right
			anchors.rightMargin: 5
			textColour: "#66ffffff"
			text: "Keep Open"
			onButtonCheckedChanged: {
				settingssession.setValue("metadatakeepopen",check.checkedButton)
			}
		}
	}
	function uncheckCheckbox() { check.checkedButton = false; }
	function checkCheckbox() { check.checkedButton = true; }

	Component {

		id: deleg

		Rectangle {

			id: rect

			color: "#00000000";
			height: val.height;

			Text {

				id: val;

				visible: imageLoaded
				color: "white";
				font.pointSize: settings.exiffontsize
				lineHeight: (name == "" ? 0.8 : 1.3);
				textFormat: Text.RichText
				text: name !== "" ? "<b>" + name + "</b>: " + value : ""

				MouseArea {
					anchors.fill: parent
					cursorShape: prop == "Exif.GPSInfo.GPSLongitudeRef" ? Qt.PointingHandCursor : Qt.ArrowCursor
					onClicked: {
						if(prop == "Exif.GPSInfo.GPSLongitudeRef")
							gpsClick(value)
					}
				}

			}

		}

	}

	function setData(d) {

		invalidLabel.visible = false
		unsupportedLabel.visible = false
		view.visible = false

		if(d["validfile"] == "0")
			invalidLabel.visible = true
		else {

			if(d["supported"] == "0")
				unsupportedLabel.visible = true
			else {

				orientation = d["Exif.Image.Orientation"]

				view.visible = true

				mod.clear()

				mod.append({"name" : "Filesize", "prop" : "", "value" : d["filesize"], "tooltip" : d["filesize"]})
				if("dimensions" in d)
					mod.append({"name" : "Dimensions", "prop" : "", "value" : d["dimensions"], "tooltip" : d["dimensions"]})
				else if("Exif.Photo.PixelXDimension" in d && "Exif.Photo.PixelYDimension" in d) {
					var dim = d["Exif.Photo.PixelXDimension"] + "x" + d["Exif.Photo.PixelYDimension"]
					mod.append({"name" : "Dimensions", "prop" : "", "value" : dim, "tooltip" : dim})
				}

				mod.append({"name" : "", "prop" : "", "value" : ""})

				var labels = ["Exif.Image.Make", "Make", "",
						"Exif.Image.Model", "Model", "",
						"Exif.Image.Software", "Software", "",
						"","", "",
						"Exif.Photo.DateTimeOriginal", "Time Photo was Taken", "",
						"Exif.Photo.ExposureTime", "Exposure Time", "",
						"Exif.Photo.Flash", "Flash", "",
						"Exif.Photo.ISOSpeedRatings", "ISO", "",
						"Exif.Photo.SceneCaptureType", "Scene Type", "",
						"Exif.Photo.FocalLength", "Focal Length", "",
						"Exif.Photo.FNumber", "F Number", "",
						"Exif.Photo.LightSource", "Light Source", "",
						"","", "",
						"Iptc.Application2.Keywords", "Keywords", "",
						"Iptc.Application2.City", "Location", "",
						"Iptc.Application2.Copyright", "Copyright", "",
						"","", "",
						"Exif.GPSInfo.GPSLongitudeRef", "GPS Position", "Exif.GPSInfo.GPSLatitudeRef",
						"","",""]


				/*

				Exif.Image.Orientation


				*/

				var oneEmpty = false;

				for(var i = 0; i < labels.length; i+=3) {
					if(labels[i] == "" && labels[i+1] == "") {
						if(!oneEmpty) {
							oneEmpty = true
							mod.append({"name" : "", "prop" : "", "value" : "", "tooltip" : ""})
						}
					} else if(d[labels[i]] != "" && d[labels[i+1]] != "") {
						oneEmpty = false;
						mod.append({"name" : labels[i+1],
								"prop" : labels[i],
								"value" : d[labels[i]],
								"tooltip" : d[labels[i+2] == "" ? d[labels[i]] : d[labels[i+2]]]})
					}
				}

				view.model = mod
				imageLoaded = true

			}

		}

	}

	function gpsClick(value) {

		if(settings.exifgpsmapservice == "bing.com/maps")
			Qt.openUrlExternally("http://www.bing.com/maps/?sty=r&q=" + value + "&obox=1")
		else if(settings.exifgpsmapservice == "maps.google.com")
			Qt.openUrlExternally("http://maps.google.com/maps?t=h&q=" + value)
		else {

			// For openstreetmap.org, we need to convert the GPS location into decimal format

			var one = value.split(", ")[0]
			var one_dec = 1*one.split("°")[0] + (1*(one.split("°")[1].split("'")[0]))/60 + (1*(one.split("'")[1].split("''")[0]))/3600
			if(one.indexOf("S") !== -1)
				one_dec *= -1;

			var two = value.split(", ")[1]
			var two_dec = 1*two.split("°")[0] + (1*(two.split("°")[1].split("'")[0]))/60 + (1*(two.split("'")[1].split("''")[0]))/3600
			if(two.indexOf("W") !== -1)
				two_dec *= -1;

			Qt.openUrlExternally("http://www.openstreetmap.org/#map=15/" + "" + one_dec + "/" + two_dec)
		}

	}

	function clear() {
		imageLoaded = false
	}

}
