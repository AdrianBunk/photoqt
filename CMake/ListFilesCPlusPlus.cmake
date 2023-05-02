#####################
#### C++ SOURCES ####
#####################

SET(d "cplusplus")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/main.cpp ${d}/logger.h ${d}/configfiles.h ${d}/keypresschecker.h ${d}/passon.h)

SET(d "cplusplus/settings")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/settings.cpp ${d}/imageformats.cpp ${d}/windowgeometry.cpp ${d}/shortcuts.cpp)

SET(d "cplusplus/scripts")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingfiledialog.cpp ${d}/localisation.h ${d}/imageproperties.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/filewatcher.cpp ${d}/handlinggeneral.cpp ${d}/handlingshortcuts.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingexternal.cpp ${d}/metadata.cpp ${d}/handlingfiledir.cpp ${d}/handlingmanipulation.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingshareimgur.cpp ${d}/replytimeout.h ${d}/simplecrypt.cpp ${d}/handlingwallpaper.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/handlingfacetags.cpp ${d}/handlingchromecast.cpp ${d}/httpserver.cpp)

SET(d "cplusplus/imageprovider")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderfull.cpp ${d}/imageproviderthumb.cpp ${d}/imageprovidericon.cpp ${d}/imageproviderhistogram.cpp ${d}/loadimage.cpp ${d}/resolutionprovider.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/imageproviderfolderthumb.cpp)

SET(d "cplusplus/imageprovider/loader")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/errorimage.cpp ${d}/loadimage_qt.cpp ${d}/loadimage_xcf.cpp ${d}/loadimage_poppler.cpp ${d}/loadimage_raw.cpp ${d}/loadimage_devil.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loadimage_freeimage.cpp ${d}/loadimage_archive.cpp ${d}/loadimage_unrar.cpp ${d}/loadimage_video.cpp ${d}/helper.cpp ${d}/loadimage_magick.cpp)
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/loadimage_libvips.cpp)

SET(d "cplusplus/singleinstance")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/commandlineparser.cpp ${d}/singleinstance.cpp)

SET(d "cplusplus/startup")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/startup.cpp ${d}/validate.cpp)

SET(d "cplusplus/filefoldermodel")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/filefoldermodel.cpp ${d}/filefoldermodelcache.cpp)

SET(d "python")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/pqpy.h)

SET(d "cplusplus/print")
SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/tabimageoptions.cpp ${d}/tabimagepositiontile.cpp ${d}/printsupport.cpp)

if(VIDEO_MPV)
    SET(d "cplusplus/libmpv")
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/mpvqthelper.h ${d}/mpvobject.cpp)
endif()

if(VIDEO_VLC)
    SET(d "cplusplus/qmlvlc")
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/QmlVlc.cpp ${d}/QmlVlcConfig.cpp ${d}/QmlVlcVideoSurface.cpp ${d}/QmlVlcPlayer.cpp ${d}/QmlVlcVideoSource.cpp ${d}/QmlVlcPlayerProxy.cpp)
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/QmlVlcVideoOutput.cpp ${d}/QmlVlcVideoFrame.cpp ${d}/QmlVlcAudio.cpp ${d}/QmlVlcInput.cpp ${d}/QmlVlcMedia.cpp ${d}/QmlVlcPlaylist.cpp)
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/QmlVlcSubtitle.cpp ${d}/QmlVlcVideo.cpp ${d}/QmlVlcMarquee.cpp ${d}/QmlVlcLogo.cpp ${d}/QmlVlcDeinterlace.cpp)
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/QmlVlcMediaListPlayer.cpp ${d}/QmlVlcMediaListPlayerProxy.cpp ${d}/SGVlcVideoNode.cpp ${d}/QmlVlcPositions.cpp)
    SET(d "cplusplus/qmlvlc/libvlc_wrapper")
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/vlc_player.cpp ${d}/vlc_audio.cpp ${d}/vlc_basic_player.cpp ${d}/vlc_playback.cpp ${d}/vlc_subtitles.cpp ${d}/vlc_video.cpp ${d}/vlc_media.cpp)
    SET(photoqt_SOURCES ${photoqt_SOURCES} ${d}/vlc_vmem.cpp ${d}/vlc_media_list_player.cpp ${d}/vlc_helpers.cpp)
endif()
