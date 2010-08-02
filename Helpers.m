//
//  Helpers.m
//  grab
//
//  Created by orta on 19/10/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "chipmunk.h"

extern cpSpace* space;
extern cpBody *staticBody;

cpBody* makeCircle(int radius){
  int num = 4;
  cpVect verts[] = {
    cpv(-radius, -radius),
    cpv(-radius, radius),
    cpv( radius, radius),
    cpv( radius, -radius),
  };
  // all physics stuff needs a body
  cpBody *body = cpBodyNew(1.0, cpMomentForPoly(1.0, num, verts, cpvzero));
  cpSpaceAddBody(space, body);
  // and a shape to represent its collision box
  cpShape* shape = cpCircleShapeNew(body, radius, cpvzero);
  shape->e = 0.1; shape->u = 0.5;
  cpSpaceAddShape(space, shape);
  return body;
}

void makeStaticBox(float x, float y, float width, float height){
  cpShape * shape;
  shape = cpSegmentShapeNew(staticBody, cpv(x,y), cpv(x+width, y), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  shape = cpSegmentShapeNew(staticBody, cpv(x+width, y), cpv(x+width, y+height ), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  shape = cpSegmentShapeNew(staticBody, cpv(x+width, y+height), cpv(x, y+height ), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  shape = cpSegmentShapeNew(staticBody, cpv(x, y+height ), cpv(x, y), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
}

void  createPlayer () {  
  cpShape * shape;
	int num = 4;
  int kColl_Player = 55;
  cpFloat chestMass = 15;
	cpVect verts[] = {
		cpv(-8,-12),
		cpv(-8, 12),
		cpv( 8, 12),
		cpv( 8,-12),
	};
	
	cpBody * playerChest = cpBodyNew(10.0, cpMomentForPoly(chestMass, num, verts, cpv(0,0)));
	cpSpaceAddBody(space, playerChest);
	shape = cpPolyShapeNew(playerChest, num, verts, cpv(0,0));
	shape->e = 0.0; shape->u = 1.0;
  shape->group = kColl_Player;
  playerChest ->p = cpv(160,240);
	cpSpaceAddShape(space, shape);
	
	cpFloat radius = 10;
	cpFloat head_mass = 0.01;
  cpVect offset = cpv(0, 12);
	cpBody *playerHead = cpBodyNew(head_mass, cpMomentForCircle(head_mass, 0.0, radius, cpvzero));
	playerHead->p = cpvadd(playerChest->p, offset);
	playerHead->v = playerChest->v;
	cpSpaceAddBody(space, playerHead);
	shape = cpCircleShapeNew(playerHead, radius, cpvzero);
	shape->e = 0.0; shape->u = 2.5;
  shape->collision_type = kColl_Player;
  shape->group = kColl_Player;
	cpSpaceAddShape(space, shape);
  // apply a small upwards force to keep the head up,
  // this may need adjusting when/if gravity is changed.
  
  // plus this adds an awesome drunkard swagger!
	cpBodyApplyForce(playerHead, cpv(0, 10), cpvzero);
  cpJoint *joint;
	joint = cpPinJointNew(playerChest, playerHead, cpv(0, 10), cpv(0, -5));
	cpSpaceAddJoint(space, joint);
  
  cpVect armverts[] = {
		cpv(-6,-2),
		cpv(-6, 2),
		cpv( 6, 2),
		cpv( 6,-2),
	};
  
  cpBody * playerArm1 = cpBodyNew(0.1, cpMomentForPoly(0.1, num, armverts, cpv(0,0)));
  cpSpaceAddBody(space, playerArm1);
	shape = cpPolyShapeNew(playerArm1, num, armverts, cpv(0,0));
  shape->collision_type = kColl_Player;
	shape->e = 0.0; shape->u = 1.0;
  shape->group = kColl_Player;
  playerArm1 ->p = cpv(160,240);
	cpSpaceAddShape(space, shape);
  joint = cpPinJointNew(playerChest, playerArm1, cpv(5, 0), cpv(5,0));
	cpSpaceAddJoint(space, joint);
  
  cpBody * playerArm2= cpBodyNew(0.1, cpMomentForPoly(0.1, num, armverts, cpv(0,0)));
  cpSpaceAddBody(space, playerArm2);
	shape = cpPolyShapeNew(playerArm2, num, armverts, cpv(0,0));
  shape->collision_type = kColl_Player;
	shape->e = 0.0; shape->u = 1.0;
  shape->group = kColl_Player;

  playerArm2 ->p = cpv(160,240);
	cpSpaceAddShape(space, shape);
  joint = cpPinJointNew(playerChest, playerArm2, cpv(-5, 3), cpv(-5, 3));
	cpSpaceAddJoint(space, joint);
  
}
