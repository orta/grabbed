//
//  DebugRendering.m
//  Thrown
//
//  Created by orta on 23/08/2008.
//  Highly based on Ricardo Quesada's work
//  Copyright 2008 ortatherox.com. All rights reserved.
//
#import "chipmunk.h"
#import "Primitives.h"
#import "cocos2d.h"
#import "OpenGL_Internal.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

void drawCircleShape(cpShape *shape) {
	cpBody *body = shape->body;
	cpCircleShape *circle = (cpCircleShape *)shape;
	cpVect c = cpvadd(body->p, cpvrotate(circle->c, body->rot));
	drawCircle(c.x, c.y, circle->r, body->a, 25);
  // !important this number changes the quality of circles
}

void drawSegmentShape(cpShape *shape) {
	cpBody *body = shape->body;
	cpSegmentShape *seg = (cpSegmentShape *)shape;
	cpVect a = cpvadd(body->p, cpvrotate(seg->a, body->rot));
	cpVect b = cpvadd(body->p, cpvrotate(seg->b, body->rot));
	drawLine( a.x, a.y, b.x, b.y );
}

void drawPolyShape(cpShape *shape) {
	cpBody *body = shape->body;
	cpPolyShape *poly = (cpPolyShape *)shape;
	
	int num = poly->numVerts;
	cpVect *verts = poly->verts;
	
	float *vertices = malloc( sizeof(float)*2*poly->numVerts);
	if(!vertices)
		return;
	
	for(int i=0; i<num; i++){
		cpVect v = cpvadd(body->p, cpvrotate(verts[i], body->rot));
		vertices[i*2] = v.x;
		vertices[i*2+1] = v.y;
	}
	drawPoly( vertices, poly->numVerts );
	free(vertices);
}

void drawObject(void *ptr, void *unused) {
	cpShape *shape = (cpShape *)ptr;  
  glColor4f(1.0, 1.0, 1.0, 0.7);
  
  //if its the player
  if(shape->group == 55){
    glColor4f(1.0, 1.0, 1.0, 1.0);
  }
  
	switch(shape->klass->type){
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
