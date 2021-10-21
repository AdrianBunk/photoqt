function(composeDesktopFile)

    file(WRITE  "photoqt.desktop" "[Desktop Entry]\n")
    file(APPEND "photoqt.desktop" "Name=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[ca]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[cs]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[de]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[es]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[fr]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[nl]=PhotoQt\n")
    file(APPEND "photoqt.desktop" "Name[sr]=ФотоQт\n")
    file(APPEND "photoqt.desktop" "Name[sr@ijekavian]=ФотоQт\n")
    file(APPEND "photoqt.desktop" "Name[sr@ijekavianlatin]=FotoQt\n")
    file(APPEND "photoqt.desktop" "Name[sr@latin]=FotoQt\n")
    file(APPEND "photoqt.desktop" "GenericName=Image Viewer\n")
    file(APPEND "photoqt.desktop" "GenericName[ca]=Visor d'imatges\n")
    file(APPEND "photoqt.desktop" "GenericName[cs]=Prohlížeč obrázků\n")
    file(APPEND "photoqt.desktop" "GenericName[de]=Bildbetrachter\n")
    file(APPEND "photoqt.desktop" "GenericName[es]=Visor de imagenes\n")
    file(APPEND "photoqt.desktop" "GenericName[fr]=Visualisateur d'images\n")
    file(APPEND "photoqt.desktop" "GenericName[nl]=Afbeeldingen-viewer\n")
    file(APPEND "photoqt.desktop" "GenericName[sr]=Приказивач слика\n")
    file(APPEND "photoqt.desktop" "GenericName[sr@ijekavian]=Приказивач слика\n")
    file(APPEND "photoqt.desktop" "GenericName[sr@ijekavianlatin]=Prikazivač slika\n")
    file(APPEND "photoqt.desktop" "GenericName[sr@latin]=Prikazivač slika\n")
    file(APPEND "photoqt.desktop" "Comment=View and manage images\n")
    file(APPEND "photoqt.desktop" "Comment[ca]=Visualitza i gestiona imatges\n")
    file(APPEND "photoqt.desktop" "Comment[cs]=Prohlížet and spravovat obrázky\n")
    file(APPEND "photoqt.desktop" "Comment[de]=Betrachte und manage Bilder\n")
    file(APPEND "photoqt.desktop" "Comment[es]=Visualizar y gestionar imágenes\n")
    file(APPEND "photoqt.desktop" "Comment[fr]=Voir et gérer des images\n")
    file(APPEND "photoqt.desktop" "Comment[nl]=Bekijk en beheer afbeeldingen\n")
    file(APPEND "photoqt.desktop" "Comment[sr]=Приказује и управља сликама\n")
    file(APPEND "photoqt.desktop" "Comment[sr@ijekavian]=Приказује и управља сликама\n")
    file(APPEND "photoqt.desktop" "Comment[sr@ijekavianlatin]=Prikazuje i upravlja slikama\n")
    file(APPEND "photoqt.desktop" "Comment[sr@latin]=Prikazuje i upravlja slikama\n")
    file(APPEND "photoqt.desktop" "Exec=photoqt %f\n")
    file(APPEND "photoqt.desktop" "Icon=photoqt\n")
    file(APPEND "photoqt.desktop" "Type=Application\n")
    file(APPEND "photoqt.desktop" "Terminal=false\n")
    file(APPEND "photoqt.desktop" "Categories=Graphics;Viewer;\n")


    # add the mimetypes
    set(MIMETYPE "image/avif;image/avif-sequence;application/x-fpt;image/bmp;image/x-ms-bmp")
    set(MIMETYPE "${MIMETYPE};image/bpg;image/x-canon-crw;image/x-canon-cr2;image/x-win-bitmap;image/bmp")
    set(MIMETYPE "${MIMETYPE};image/x-ms-bmp;application/dicom;image/dicom-rle;image/vnd.djvu;image/x-dpx")
    set(MIMETYPE "${MIMETYPE};application/postscript;application/postscript;application/eps;application/x-eps;image/eps")
    set(MIMETYPE "${MIMETYPE};image/x-eps;image/x-eps;image/x-exr;image/fits;application/vnd.ms-office")
    set(MIMETYPE "${MIMETYPE};image/gif;image/heic;image/heif;image/vnd.microsoft.icon;image/x-icon")
    set(MIMETYPE "${MIMETYPE};application/x-pnf;video/x-jng;image/jpeg;image/jp2;image/jpx")
    set(MIMETYPE "${MIMETYPE};image/jpm;image/jxl;application/x-krita;image/x-miff;video/x-mng")
    set(MIMETYPE "${MIMETYPE};image/x-mvg;image/openraster;image/x-olympus-orf;image/x-portable-arbitrarymap;image/x-portable-pixmap")
    set(MIMETYPE "${MIMETYPE};image/x-portable-anymap;image/vnd.zbrush.pcx;image/x-pcx;application/pdf;application/x-pdf")
    set(MIMETYPE "${MIMETYPE};application/x-bzpdf;application/x-gzpdf;image/x-pentax-pef;image/x-portable-greymap;image/x-portable-anymap")
    set(MIMETYPE "${MIMETYPE};image/x-xpmi;image/png;image/x-portable-pixmap;image/x-portable-anymap;application/postscript")
    set(MIMETYPE "${MIMETYPE};image/vnd.adobe.photoshop;image/tiff;image/sgi;image/svg+xml;image/x-targa")
    set(MIMETYPE "${MIMETYPE};image/x-tga;image/tiff;image/tiff-fx;font/sfnt;image/vnd.wap.wbmp")
    set(MIMETYPE "${MIMETYPE};image/webp;image/x-xbitmap;image/x-xbm;image/x-xcf;image/x-xpixmap")
    set(MIMETYPE "${MIMETYPE};image/x-xpmi")

    file(APPEND "photoqt.desktop" "MimeType=${MIMETYPE};")


endfunction()

