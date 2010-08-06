/* Copyright (c) 2008 Tommy Thorsen
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "cpMouse.h"
#include <stdlib.h>


static void
mouseUpdateVelocity(cpBody *body,
                    cpVect gravity,
                    cpFloat damping,
                    cpFloat dt)
{
    cpMouse *mouse = (cpMouse *)body->data;

    /*
     *  Calculate the velocity based on the distance moved since the
     *  last time we calculated velocity. We use a weighted average
     *  of the new velocity and the old velocity to make everything
     *  a bit smoother.
     */
    cpVect newVelocity = cpvmult(mouse->moved, 1.0f / dt);

    body->v = cpvadd(cpvmult(body->v, 0.7f),
                     cpvmult(newVelocity, 0.3f));

    mouse->moved = cpvzero;
}

static void
mouseUpdatePosition(cpBody *body,
                    cpFloat dt)
{
}

static int
mouseOver(void *p1, void *p2, void *data)
{
    cpShape *a = (cpShape *)p1;
    cpShape *b = (cpShape *)p2;
    cpMouse *mouse = (cpMouse *)data;
    if (!cpBBintersects(a->bb, b->bb) || a->body == b->body)
    {
        return 0;
    }

    if (a->klass->type > b->klass->type) {
        cpShape *temp = a;
        a = b;
        b = temp;
    }

    mouse->grabbedBody = mouse->shape != a ? a->body : b->body;

    return 0;
}

cpMouse *
cpMouseAlloc()
{
    return (cpMouse *)malloc(sizeof(cpMouse));
}

cpMouse *
cpMouseInit(cpMouse *mouse, cpSpace *space)
{
    mouse->space = space;
    mouse->grabbedBody = NULL;
    mouse->moved = cpvzero;

    mouse->body = cpBodyNew(INFINITY, INFINITY);
    mouse->body->velocity_func = mouseUpdateVelocity;
    mouse->body->position_func = mouseUpdatePosition;
    mouse->body->data = (void *)mouse;

    mouse->shape = cpCircleShapeNew(mouse->body, 3.0f, cpvzero);
    mouse->shape->layers = (unsigned int)(1 << 31);

    mouse->joint1 = NULL;
    mouse->joint2 = NULL;

    cpSpaceAddBody(mouse->space, mouse->body);
    cpSpaceAddShape(mouse->space, mouse->shape);

    return mouse;
}

cpMouse *
cpMouseNew(cpSpace *space)
{
    return cpMouseInit(cpMouseAlloc(), space);
}

void
cpMouseDestroy(cpMouse *mouse)
{
    cpMouseRelease(mouse);

    cpSpaceRemoveShape(mouse->space, mouse->shape);
    cpSpaceRemoveBody(mouse->space, mouse->body);

    cpShapeFree(mouse->shape);
    cpBodyFree(mouse->body);
}

void
cpMouseFree(cpMouse *mouse)
{
    if (mouse) {
        cpMouseDestroy(mouse);
        free(mouse);
    }
}

void
cpMouseMove(cpMouse *mouse, cpVect position)
{
    mouse->moved = cpvadd(mouse->moved,
                          cpvsub(position, mouse->body->p));
    mouse->body->p = position;
}

void
cpMouseGrab(cpMouse *mouse, int lockAngle)
{
    cpMouseRelease(mouse);

    mouse->grabbedBody = NULL;

    cpSpaceHashQuery(mouse->space->activeShapes,
                     mouse->shape,
                     mouse->shape->bb,
                     mouseOver,
                     (void *)mouse);

    if (mouse->grabbedBody) {
        if (lockAngle) {
            /*
             *  I'd like to just use one joint that would lock the angle
             *  for me, but that doesn't exist yet, so we'll set up two
             *  pivot joints between our bodies
             */
            mouse->joint1 = cpPivotJointNew(mouse->body,
                                           mouse->grabbedBody,
                                           cpv(mouse->body->p.x - 1.0f,
                                               mouse->body->p.y));
            cpSpaceAddJoint(mouse->space, mouse->joint1);

            mouse->joint2 = cpPivotJointNew(mouse->body,
                                           mouse->grabbedBody,
                                           cpv(mouse->body->p.x + 1.0f,
                                               mouse->body->p.y));
            cpSpaceAddJoint(mouse->space, mouse->joint2);
        } else {
            mouse->joint1 = cpPivotJointNew(mouse->body,
                                           mouse->grabbedBody,
                                           mouse->body->p);
            cpSpaceAddJoint(mouse->space, mouse->joint1);
        }
    }
}

void
cpMouseRelease(cpMouse *mouse)
{
    if (!mouse->joint1) {
        return;
    }

    cpSpaceRemoveJoint(mouse->space, mouse->joint1);
    cpJointFree(mouse->joint1);
    mouse->joint1 = NULL;

    cpSpaceRemoveJoint(mouse->space, mouse->joint2);
    cpJointFree(mouse->joint2);
    mouse->joint2 = NULL;

    mouse->grabbedBody = NULL;
}
