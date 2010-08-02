/* Copyright (c) 2007 Scott Lembcke
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
 
#import <UIKit/UIKit.h>
#import "main.h"

#include <stdlib.h>
#include <stdio.h>
#include <math.h>


#include "chipmunk.h"

#define SLEEP_TICKS 16

extern void demo1_init(void);
extern void demo1_update(int);

extern void demo2_init(void);
extern void demo2_update(int);

extern void demo3_init(void);
extern void demo3_update(int);

extern void demo4_init(void);
extern void demo4_update(int);

extern void demo5_init(void);
extern void demo5_update(int);

extern void demo6_init(void);
extern void demo6_update(int);

extern void demo7_init(void);
extern void demo7_update(int);


typedef void (*demo_init_func)(void);
typedef void (*demo_update_func)(int);
typedef void (*demo_destroy_func)(void);

demo_init_func init_funcs[] = {
	demo1_init,
	demo2_init,
	demo3_init,
	demo4_init,
	demo5_init,
	demo6_init,
	demo7_init,
};

demo_update_func update_funcs[] = {
	demo1_update,
	demo2_update,
	demo3_update,
	demo4_update,
	demo5_update,
	demo6_update,
	demo7_update,
};

void demo_destroy(void);

demo_destroy_func destroy_funcs[] = {
	demo_destroy,
	demo_destroy,
	demo_destroy,
	demo_destroy,
	demo_destroy,
	demo_destroy,
	demo_destroy,
};

int demo_index = 0;

int ticks = 0;
cpSpace *space;
cpBody *staticBody;

void demo_destroy(void)
{
	cpSpaceFreeChildren(space);
	cpSpaceFree(space);
	
	cpBodyFree(staticBody);
}

void drawCircleShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpCircleShape *circle = (cpCircleShape *)shape;
	cpVect c = cpvadd(body->p, cpvrotate(circle->c, body->rot));
	drawCircle(c.x, c.y, circle->r, body->a, 15);
}

void drawSegmentShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	cpVect a = cpvadd(body->p, cpvrotate(seg->a, body->rot));
	cpVect b = cpvadd(body->p, cpvrotate(seg->b, body->rot));
	
	drawLine( a.x, a.y, b.x, b.y );
}

void drawPolyShape(cpShape *shape)
{
	cpBody *body = shape->body;
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	int num = poly->numVerts;
	cpVect *verts = poly->verts;
	
	float *vertices = malloc( sizeof(float)*2*poly->numVerts);
	if( ! vertices )
		return;
	
	for(int i=0; i<num; i++){
		cpVect v = cpvadd(body->p, cpvrotate(verts[i], body->rot));
		vertices[i*2] = v.x;
		vertices[i*2+1] = v.y;
	}
	drawPoly( vertices, poly->numVerts );
	
	free(vertices);
}

void drawObject(void *ptr, void *unused)
{
	cpShape *shape = (cpShape *)ptr;
	switch(shape->type){
		case CP_CIRCLE_SHAPE:
			drawCircleShape(shape);
			break;
		case CP_SEGMENT_SHAPE:
			drawSegmentShape(shape);
			break;
		case CP_POLY_SHAPE:
			drawPolyShape(shape);
			break;
		default:
			printf("Bad enumeration in drawObject().\n");
	}
}

void drawCollisions(void *ptr, void *data)
{
	cpArbiter *arb = (cpArbiter *)ptr;
	for(int i=0; i<arb->numContacts; i++){
		cpVect v = arb->contacts[i].p;
		drawPoint(v.x, v.y);
	}
}

@implementation MainLayer
-(id) init
{
	[super init];
	isTouchEnabled = YES;
	cpInitChipmunk();	
	init_funcs[demo_index]();

	[self schedule: @selector(step:)];

	return self;
}

-(void) onEnter
{
	[super onEnter];
		
	float factor = 1.0;
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(-320/factor, 320/factor, -480/factor, 480/factor, -1.0, 1.0);
	if( [[Director sharedDirector] landscape] )
		glTranslatef(0.5, -480.5, 0.0);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glPointSize(3.0);
    glEnable(GL_LINE_SMOOTH);
	glEnable(GL_POINT_SMOOTH);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
    glHint(GL_POINT_SMOOTH_HINT, GL_DONT_CARE);
    glLineWidth(1.5f);
	

	
}

-(void) step: (ccTime) dt
{
	ticks++;	
	update_funcs[demo_index](ticks);
}

-(void) draw
{
	glColor4f(1.0, 1.0, 1.0, 1.0);
	cpSpaceHashEach(space->activeShapes, &drawObject, NULL);
	cpSpaceHashEach(space->staticShapes, &drawObject, NULL);
	
	cpArray *bodies = space->bodies;
	int num = bodies->num;
	
	glColor4f(0.0, 0.0, 1.0, 1.0);
	for(int i=0; i<num; i++){
		cpBody *body = (cpBody *)bodies->arr[i];
		drawPoint(body->p.x, body->p.y);
	}
	
	glColor4f(1.0, 0.0, 0.0, 1.0);
	cpArrayEach(space->arbiters, &drawCollisions, NULL);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//	UITouch *touch = [touches anyObject];	
//	CGPoint location = [touch locationInView: [touch view]];

	destroy_funcs[demo_index]();

	demo_index++;
	demo_index %=7;
	
	ticks = 0;
	init_funcs[demo_index]();
}
@end


@implementation AppController
- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// before creating any layer, set the landscape mode
//	[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setDisplayFPS:YES];
	[[Director sharedDirector] setAnimationInterval:1.0/60];
	
	Scene *scene = [Scene node];
	
	MainLayer * mainLayer =[MainLayer node];
	
	[scene add: mainLayer];

	[[Director sharedDirector] runScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}

@end


int main(int argc, char *argv[]) {
	
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	UIApplicationMain(argc, argv, nil, @"AppController");
	[pool release];
	return 0;
}

