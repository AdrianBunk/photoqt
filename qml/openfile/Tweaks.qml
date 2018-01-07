import QtQuick 2.6

import "./tweaks"
import "handlestuff.js" as Handle

Rectangle {

    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    height: 50

    color: "#44000000"

    TweaksZoom { id: zoom }

//    TweaksFileType { }

    TweaksPreview { id: prev }

    TweaksThumbnails { id: thumb }

    TweaksViewMode { id: viewmode }

}
