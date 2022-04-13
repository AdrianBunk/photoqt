/**************************************************************************
 **                                                                      **
 ** Copyright (C) 2011-2022 Lukas Spies                                  **
 ** Contact: https://photoqt.org                                         **
 **                                                                      **
 ** This file is part of PhotoQt.                                        **
 ** Adapted from: https://github.com/mpv-player/mpv-examples/            **
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

#include "mpvobject.h"

#include <stdexcept>
#include <clocale>

#include <QObject>
#include <QtGlobal>
#include <QOpenGLContext>
#include <QGuiApplication>

#include <QtGui/QOpenGLFramebufferObject>

#include <QtQuick/QQuickWindow>
#include <QtQuick/QQuickView>

namespace {

void on_mpv_events(void *ctx) {
    Q_UNUSED(ctx)
}

void on_mpv_redraw(void *ctx) {
    PQMPVObject::on_update(ctx);
}

static void *get_proc_address_mpv(void *ctx, const char *name) {

    Q_UNUSED(ctx)

    QOpenGLContext *glctx = QOpenGLContext::currentContext();
    if (!glctx) return nullptr;

    return reinterpret_cast<void *>(glctx->getProcAddress(QByteArray(name)));
}

}

class PQMPVRenderer : public QQuickFramebufferObject::Renderer {

    PQMPVObject *obj;

public:
    PQMPVRenderer(PQMPVObject *new_obj) : obj{new_obj} {
        mpv_set_wakeup_callback(obj->mpv, on_mpv_events, nullptr);
    }

    virtual ~PQMPVRenderer() {}

    // This function is called when a new FBO is needed.
    // This happens on the initial frame.
    QOpenGLFramebufferObject * createFramebufferObject(const QSize &size) {
        // init mpv_gl:
        if (!obj->mpv_gl) {
            mpv_opengl_init_params gl_init_params{get_proc_address_mpv, nullptr, nullptr};
            mpv_render_param params[]{
                {MPV_RENDER_PARAM_API_TYPE, const_cast<char *>(MPV_RENDER_API_TYPE_OPENGL)},
                {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &gl_init_params},
                {MPV_RENDER_PARAM_INVALID, nullptr}
            };

            if (mpv_render_context_create(&obj->mpv_gl, obj->mpv, params) < 0)
                throw std::runtime_error("failed to initialize mpv GL context");
            mpv_render_context_set_update_callback(obj->mpv_gl, on_mpv_redraw, obj);
        }

        return QQuickFramebufferObject::Renderer::createFramebufferObject(size);
    }

    void render() {

        obj->window()->resetOpenGLState();

        QOpenGLFramebufferObject *fbo = framebufferObject();
        mpv_opengl_fbo mpfbo{.fbo = static_cast<int>(fbo->handle()), .w = fbo->width(), .h = fbo->height(), .internal_format = 0};
        int flip_y{0};

        mpv_render_param params[] = {
            // Specify the default framebuffer (0) as target. This will
            // render onto the entire screen. If you want to show the video
            // in a smaller rectangle or apply fancy transformations, you'll
            // need to render into a separate FBO and draw it manually.
            {MPV_RENDER_PARAM_OPENGL_FBO, &mpfbo},
            // Flip rendering (needed due to flipped GL coordinate system).
            {MPV_RENDER_PARAM_FLIP_Y, &flip_y},
            {MPV_RENDER_PARAM_INVALID, nullptr}
        };
        // See render_gl.h on what OpenGL environment mpv expects, and
        // other API details.
        mpv_render_context_render(obj->mpv_gl, params);

        // when loading a new video while one is playing, the window() object might be invalid and cause a crash if left unchecked
        if(obj->window())
            obj->window()->resetOpenGLState();
    }
};

PQMPVObject::PQMPVObject(QQuickItem * parent) : QQuickFramebufferObject(parent), mpv{mpv_create()}, mpv_gl(nullptr) {

    if (!mpv)
        throw std::runtime_error("could not create mpv context");

    mpv_set_option_string(mpv, "terminal", "yes");
    mpv_set_option_string(mpv, "msg-level", "all=v");

    if (mpv_initialize(mpv) < 0)
        throw std::runtime_error("could not initialize mpv context");

    // Request hw decoding, just for testing.
    mpv::qt::set_option_variant(mpv, "hwdec", "auto");

    connect(this, &PQMPVObject::onUpdate, this, &PQMPVObject::doUpdate,
            Qt::QueuedConnection);
}

PQMPVObject::~PQMPVObject() {

    if (mpv_gl) // only initialized if something got drawn
        mpv_render_context_free(mpv_gl);

    mpv_terminate_destroy(mpv);

}

void PQMPVObject::on_update(void *ctx) {
    PQMPVObject *self = (PQMPVObject *)ctx;
    Q_EMIT self->onUpdate();
}

// connected to onUpdate(); signal makes sure it runs on the GUI thread
void PQMPVObject::doUpdate() {
    update();
}

void PQMPVObject::command(const QVariant& params) {
    mpv::qt::command_variant(mpv, params);
}

void PQMPVObject::setProperty(const QString& name, const QVariant& value) {
    mpv::qt::set_property_variant(mpv, name, value);
}

QVariant PQMPVObject::getProperty(const QString& name) {
    return mpv::qt::get_property(mpv, name);
}

QQuickFramebufferObject::Renderer *PQMPVObject::createRenderer() const {
    window()->setPersistentOpenGLContext(true);
    window()->setPersistentSceneGraph(true);
    return new PQMPVRenderer(const_cast<PQMPVObject *>(this));
}