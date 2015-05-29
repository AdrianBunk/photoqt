import QtQuick 2.3
import QtQuick.Controls 1.2

import "../elements"

Rectangle {

	id: rect

	property string text: ""
	property string code: ""

	property bool checked: false
	property bool hovered: false

	property var exclusiveGroup: ExclusiveGroup

	// Size
	width: 90
	height: 90

	// Look
	color: (checked || hovered) ? colour.lang_bg_active : colour.lang_bg_inactive
	radius: 5

	// the text, which item this one is
	Text {

		x: 5
		y: 5
		width: parent.width-5
		height: parent.height-check.height-10

		color: colour.lang_text
		verticalAlignment: Qt.AlignVCenter
		horizontalAlignment: Qt.AlignHCenter
		wrapMode: Text.WordWrap

		text: rect.text

	}

	// And the checkbox indicator
	CustomRadioButton {

		id: check

		exclusiveGroup: parent.exclusiveGroup

		objectName: parent.objectName

		checked: parent.checked

		x: (parent.width-width)/2
		y: parent.height-height-5

		indicatorColourEnabled: colour.lang_indicatorCol
		indicatorBackgroundColourEnabled: colour.lang_indicatorBg

		text: ""

		onCheckedChanged: parent.checked = checked

	}

	// A mouseares governing the hover/checked look
	MouseArea {

		anchors.fill: rect
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true
		onEntered: hovered = true
		onExited: hovered = false
		onClicked: checked = !checked

	}

}
