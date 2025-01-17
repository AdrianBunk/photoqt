/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2023 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
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

#include "imageproviderhistogram.h"

QPixmap PQImageProviderHistogram::requestPixmap(const QString &fpath, QSize *, const QSize &requestedSize) {

    DBG << CURDATE << "PQImageProviderHistogram::requestPixmap() " << NL
        << CURDATE << "** fpath = " << fpath.toStdString() << NL
        << CURDATE << "** requestedSize = " << requestedSize.width() << "x" << requestedSize.height() << NL;

    // Obtain type of histogram
    bool color = false;
    QString tmp = fpath;
    if(tmp.startsWith("color")) {
        color = true;
        tmp = tmp.remove(0,5);
    } else if(tmp.startsWith("grey")) {
        color = false;
        tmp = tmp.remove(0,4);
    }

    // If no path specified, return empty transparent image
    if(tmp.trimmed() == "") {
        QPixmap pix = QPixmap(1,1);
        pix.fill(Qt::transparent);
        return pix;
    }

    bool recalcvalues_filepath = (tmp != filepath);
    filepath = tmp;

    // Retrieve the current image
    if(recalcvalues_filepath) {
        QSize origSize;
        loader->load(filepath, QSize(), origSize, histimg);
        if(histimg.format() != QImage::Format_RGB32)
#if (QT_VERSION >= QT_VERSION_CHECK(5, 13, 0))
            histimg.convertTo(QImage::Format_RGB32);
#else
            histimg = histimg.convertToFormat(QImage::Format_RGB32);
#endif
    }
    bool alsoComputeColor = true;
    if(histimg.isGrayscale()) {
        color = false;
        alsoComputeColor = false;
    }

    // Get width and height
    int w = requestedSize.width();
    int h = requestedSize.height();
    if(w%256 != 0)
        w = (w/256 +1)*256;

    // Get the spacing of the data points
    int interval = w/256;

    if(recalcvalues_filepath) {

        // Read and store image dimensions
        int imgWidth = histimg.width();
        int imgHeight = histimg.height();

        // Prepare the lists for the levels
        levels_grey = new int[256]{};
        levels_red = new int[256]{};
        levels_green = new int[256]{};
        levels_blue = new int[256]{};

        // Loop over all rows of the image
        for(int i = 0; i < imgHeight; ++i) {

            // Get the pixel data of row i of the image
            QRgb *rowData = (QRgb*)histimg.scanLine(i);

            // Loop over all columns
            for(int j = 0; j < imgWidth; ++j) {

                // Get pixel data of pixel at column j in row i
                QRgb pixelData = rowData[j];

                ++levels_grey[qGray(pixelData)];

                if(alsoComputeColor) {
                    ++levels_red[qRed(pixelData)];
                    ++levels_green[qGreen(pixelData)];
                    ++levels_blue[qBlue(pixelData)];
                }

            }

        }

        // Figure out the greatest value for normalisation
        greatestvalue_bw = *std::max_element(levels_grey, levels_grey+256);
        greatestvalue_rgb = 0;
        if(alsoComputeColor) {
            int allgreat[3];
            allgreat[0] = *std::max_element(levels_red, levels_red+256);
            allgreat[1] = *std::max_element(levels_green, levels_green+256);
            allgreat[2] = *std::max_element(levels_blue, levels_blue+256);
            greatestvalue_rgb = *std::max_element(allgreat, allgreat+3);
        }

        // Set up the needed polygons for filling them with color
        // This has to ALWAYS been done even if only the size changed, as then the interval changes, too
        polyGREY.clear();
        polyRED.clear();
        polyGREEN.clear();
        polyBLUE.clear();
        polyGREY << QPointF(0,h);
        for(int i = 0; i < 256; ++i)
            polyGREY << QPointF(i*interval,h*(1-(static_cast<double>(levels_grey[i])/static_cast<double>(greatestvalue_bw))));
        polyGREY << QPointF(w,h);
        if(alsoComputeColor) {
            polyRED << QPointF(0,h);
            for(int i = 0; i < 256; ++i)
                polyRED << QPointF(i*interval,h*(1-(static_cast<double>(levels_red[i])/static_cast<double>(greatestvalue_rgb))));
            polyRED << QPointF(w,h);
            polyGREEN << QPointF(0,h);
            for(int i = 0; i < 256; ++i)
                polyGREEN << QPointF(i*interval,h*(1-(static_cast<double>(levels_green[i])/static_cast<double>(greatestvalue_rgb))));
            polyGREEN << QPointF(w,h);
            polyBLUE << QPointF(0,h);
            for(int i = 0; i < 256; ++i)
                polyBLUE << QPointF(i*interval,h*(1-(static_cast<double>(levels_blue[i])/static_cast<double>(greatestvalue_rgb))));
            polyBLUE << QPointF(w,h);
        }

        if(recalcvalues_filepath) {
            delete[] levels_grey;
            delete[] levels_red;
            delete[] levels_green;
            delete[] levels_blue;
        }

    }

    // Create pixmap...
    QPixmap pix(w,h);
    // ... and fill it with transparent color
    pix.fill(QColor(0,0,0,0));

    // Start painter on return pixmap
    QPainter paint(&pix);

    // set lightly grey colored pen
    paint.setPen(QColor(255,255,255,50));

    // draw outside rectangle
    paint.drawRect(1,1,w-2,h-2);

    // draw mesh lines
    int verticallines = 10;
    int horizontallines = 5;
    for(int i = 0; i < verticallines; ++i)
        paint.drawLine(QPointF((i+1)*(w/(verticallines+1)), 0), QPointF((i+1)*(w/(verticallines+1)), h));
    for(int i = 0; i < horizontallines; ++i)
        paint.drawLine(QPointF(0, (i+1)*(h/(horizontallines+1))), QPointF(w, (i+1)*(h/(horizontallines+1))));

    if(!color) {

        // set pen color
        paint.setPen(QPen(QColor(50,50,50,255),2));
        // draw values
        paint.drawPolygon(polyGREY);
        QPainterPath pathGREY;
        pathGREY.addPolygon(polyGREY);
        paint.fillPath(pathGREY,QColor(150,150,150,180));

    } else {

        // draw red part
        paint.setPen(QPen(QColor(50,50,50,255),2));
        paint.drawPolygon(polyRED);
        QPainterPath pathRED;
        pathRED.addPolygon(polyRED);
        paint.fillPath(pathRED,QColor(255,0,0,120));

        // draw green part
        paint.setPen(QPen(QColor(50,50,50,255),2));
        paint.drawPolygon(polyGREEN);
        QPainterPath pathGREEN;
        pathGREEN.addPolygon(polyGREEN);
        paint.fillPath(pathGREEN,QColor(0,255,0,120));

        // draw blue part
        paint.setPen(QPen(QColor(50,50,50,255),2));
        paint.drawPolygon(polyBLUE);
        QPainterPath pathBLUE;
        pathBLUE.addPolygon(polyBLUE);
        paint.fillPath(pathBLUE,QColor(0,0,255,120));

    }

    paint.end();

    return pix;

}
