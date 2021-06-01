import QtQuick 2.9
import PQFileFolderModel 1.0

PQFileFolderModel {

    id: model

    // MainView:
    // the current index and filename
    // a change in the current filename triggers a (re-)load of the image even if the index remained unchanged
    property int current: -1
    property string currentFilePath: ""

    // shortcut to detect whether filter is currently set
    property bool filterCurrentlyActive: nameFilters.length!=0||filenameFilters.length!=0

    // this allows to set a specific filename as current
    // once the model has finished reloading
    property string setFileNameOnceReloaded: ""

    // is this a document or archive? if so, save some extra details
    property bool isPQT: currentFilePath.indexOf("::PQT::")>-1
    property bool isARC: currentFilePath.indexOf("::ARC::")>-1
    property string pqtName: isPQT ? currentFilePath.split("::PQT::")[1] : ""
    property int pqtNum: isPQT ? currentFilePath.split("::PQT::")[0]*1 : ""
    property string arcName: isPQT ? currentFilePath.split("::ARC::")[1] : ""
    property string arcFile: isPQT ? currentFilePath.split("::ARC::")[0] : ""

    defaultNameFilters: PQImageFormats.getEnabledFormats()
    mimeTypeFilters: PQImageFormats.getEnabledMimeTypes()

    onCurrentChanged:
        currentFilePath = model.entriesMainView[current]

    onFolderFileDialogChanged:
        handlingFileDialog.setLastLocation(folderFileDialog)

    onNewDataLoadedMainView: {

        var curset = false

        // if a specific filename is to be loaded
        if(setFileNameOnceReloaded == "---") {
            current = 0
            currentFilePath = model.entriesMainview[0]
        } else if(setFileNameOnceReloaded != "") {
            if(setAsCurrent(setFileNameOnceReloaded)) {
                curset = true
                currentFilePath = setFileNameOnceReloaded
            }
            setFileNameOnceReloaded = ""
        } else if(currentFilePath != "") {
            if(setAsCurrent(currentFilePath))
                curset = true
        }

        if(!curset) {

            // make sure the index is valid
            if(model.current >= model.countMainView)
                model.current = model.countMainView-1
            else if(model.current == -1 && model.countMainView > 0)
                model.current = 0
            else if(model.countMainView == 0)
                model.current = -1

            // update the current file path
            model.currentFilePath = (model.current!=-1 ? model.entriesMainview[model.current] : "")

        }

    }

    // set a specific file as current file
    function setAsCurrent(filepath) {
        var ind = model.getIndexOfMainView(filepath)
        if(ind != -1) {
            current = ind
            return true
        }
        return false
    }

}
