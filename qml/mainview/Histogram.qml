import QtQuick 2.3
import QtCharts 2.1

Rectangle {

	id: rect_top

	color: "transparent"

	property string curversion: "color"

	// half transparent black background
	Rectangle {

		color: "black"
		opacity: 0.5
		anchors.fill: parent

	}

	// slightly transparent chart
	ChartView {

		id: chart

		// same size as parent
		anchors.fill: parent
		anchors.leftMargin: -20
		anchors.bottomMargin: -10

		// enable antialiasing for better look
		antialiasing: true

		// no background color
		backgroundColor: "transparent"

		// slightly transparent child elements
		opacity: 0.8

		// no legends please
		legend.visible: false

		// remove all margins
		margins {
			top: 0
			left: 0
			right: 0
			bottom: 0
		}

		// x axis, from 0 to 255, no labels
		ValueAxis {
			id: xValueAxis
			min: 0
			max: 255
			tickCount: 18
			labelsVisible: false
		}

		// x axis, from 0 to 100 (0.0 to 1.0), no labels
		ValueAxis {
			id: yValueAxis
			min: 0
			max: 100
			tickCount: 6
			labelsVisible: false
		}

		// greyscale histogram series
		AreaSeries {
			color: "grey"
			borderWidth: 2
			borderColor: "black"
			axisX: xValueAxis
			axisY: yValueAxis
			upperSeries: series_grey
		}

		// RED histogram values
		AreaSeries {
			color: "red"
			borderWidth: 2
			borderColor: "black"
			axisX: xValueAxis
			axisY: yValueAxis
			upperSeries: series_r
		}

		// GREEN histogram values
		AreaSeries {
			color: "green"
			borderWidth: 2
			borderColor: "black"
			axisX: xValueAxis
			axisY: yValueAxis
			upperSeries: series_g
		}

		// BLUE histogram values
		AreaSeries {
			color: "blue"
			borderWidth: 2
			borderColor: "black"
			axisX: xValueAxis
			axisY: yValueAxis
			upperSeries: series_b
		}

		// all four LineSeries for the different histograms/colors
		LineSeries { id: series_grey; style: Qt.black; }
		LineSeries { id: series_r; style: Qt.red; }
		LineSeries { id: series_g; style: Qt.green; }
		LineSeries { id: series_b; style: Qt.blue; }

		Connections {
			target: thumbnailBar
			onCurrentFileChanged:
				hist_timer.restart()
		}

		Timer {
			id: hist_timer
			repeat: false
			running: false
			interval: 500
			onTriggered: chart.color_histogram()
		}

		// Load greyscale histogram
		function grey_histogram() {

			if(thumbnailBar.currentFile == "") return

			parent.curversion = "grey"

			// clear previous data
			series_r.clear()
			series_g.clear()
			series_b.clear()
			series_grey.clear()

			// get greyscale values
			var val = getanddostuff.getGreyscaleHistogramValues(thumbnailBar.currentFile)

			// Figure out max value for normalising data set
			var g = 0;
			for(var o = 0; o < 256; ++o)
				if(val[o] > g)
					g = val[o]

			// Add points to plot
			for(var d = 0; d < 256; ++d)
				series_grey.append(d,100*(val[d]/g))

		}

		// Load color histogram
		function color_histogram() {

			if(thumbnailBar.currentFile == "") return

			parent.curversion = "color"

			// clear previous data
			series_r.clear()
			series_g.clear()
			series_b.clear()
			series_grey.clear()

			// get color values
			var val = getanddostuff.getColorHistogramValues(thumbnailBar.currentFile)

			// Figure out max value for normalising data set
			var j = 0;
			for(var e = 0; e < 3*256; ++e)
				if(val[e] > j)
					j = val[e]

			// Add points to plot
			for(var s = 0; s < 256; ++s)
				series_r.append(s,100*(val[s]/j))
			for(var u = 0; u < 256; ++u)
				series_g.append(u,100*(val[256+u]/j))
			for(var s = 0; s < 256; ++s)
				series_b.append(s,100*(val[2*256+s]/j))

		}

	}

	// move histogram around
	MouseArea {

		property bool resizing: false
		property int startMouseX: 0
		property int startMouseY: 0

		property int startX: 0
		property int startY: 0

		acceptedButtons: Qt.LeftButton | Qt.RightButton

		anchors.fill: parent

		onPressed: {
			if(mouse.button == Qt.LeftButton) {
				cursorShape = Qt.SizeAllCursor
				resizing = true
				startX = parent.x
				startY = parent.y
				startMouseX = localcursorpos.x
				startMouseY = localcursorpos.y
			} else {
				if(curversion == "color")
					chart.grey_histogram()
				else
					chart.color_histogram()
			}

		}

		onMouseXChanged: if(resizing) parent.x = startX + (localcursorpos.x-startMouseX)

		onMouseYChanged: if(resizing) parent.y = startY + (localcursorpos.y-startMouseY)

		onReleased: {
			cursorShape = Qt.ArrowCursor
			resizing = false
		}

	}

	// resize histogram
	MouseArea {

		property bool resizing: false
		property int startMouseX: 0
		property int startMouseY: 0

		property int startW: 0
		property int startH: 0
		property int startX: 0
		property int startY: 0

		x: parent.width-30
		y: parent.height-30
		width: 30
		height: 30
		hoverEnabled: true
		cursorShape: Qt.SizeFDiagCursor

		onPressed: {
			resizing = true
			startW = parent.width
			startH = parent.height
			startX = parent.x
			startY = parent.y
			startMouseX = localcursorpos.x
			startMouseY = localcursorpos.y
		}

		onMouseXChanged: {
			if(resizing) {
				var newW = startW + (localcursorpos.x-startMouseX);
				if(newW > 200) parent.width = newW
			}
		}

		onMouseYChanged: {
			if(resizing) {
				var newH = startH + (localcursorpos.y-startMouseY)
				if(newH > 150) parent.height = newH
			}
		}

		onReleased: resizing = false

	}

}