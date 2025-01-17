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

#include "errorimage.h"

PQLoadImageErrorImage::PQLoadImageErrorImage() {}

QImage PQLoadImageErrorImage::load(QString errormessage) {
    QPixmap pix(":/image/plainerrorimg.svg");
    QPainter paint(&pix);
    QTextDocument txt;
    txt.setHtml("<div align='center' style='color: white; font-size: 20pt'><b>Image failed to load</b></div><br><div align='center' style='color: white; font-size: 15pt'>" + errormessage + "</div>");
    txt.setTextWidth(800);
    paint.translate(0,(600-txt.size().height())/2.0);
    QPen pen;
    pen.setColor(Qt::white);
    pen.setWidth(30);
    paint.setPen(pen);
    txt.drawContents(&paint);
    paint.end();
    QImage pix2img = pix.toImage();
    pix2img.setText("error", "error");
    pix2img.setText("", "error");
    return pix2img;
}
