//
//  Collisions.m
//  Hock
//
//  Created by orta on 26/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//
#import "chipmunk.h"
#import "ChuckedAppDelegate.h"

extern void * game;

int playerHitBalls(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){
  cpBody* player = (cpBody *) data;
  if(player->v.y < -1200){
    [(GameLayer *)game playerJustCollidedAtHighSpeed];
  }
  return 1;
}

int returnZero(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data){
  return 0;
}

