//
//  Grab.m
//  grab
//
//  Created by orta on 19/10/2008.
//  Copyright 2008 ortatherox.com. All rights reserved.
//

#import "Grab.h"


extern cpBody* makeCircle(int radius);
extern void drawObject(void *ptr, void *unused);
extern void createPlayer();
extern void makeStaticBox(float x, float y, float width, float height);
cpSpace *space;
cpBody *staticBody;


@implementation GameLayer

-(id) init {
	[super init];
  [self initChipmunk];
  isTouchEnabled = YES;
	isAccelerometerEnabled = YES;
  [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
  
  //seed the random generator
  srand([[NSDate date] timeIntervalSince1970]);
  
  // make a bunch of circles
  for (int i = 0; i < (rand() % 10) + 20; i++) {
    cpBody* circle = makeCircle((rand() % 40) + 5);
    circle->p = cpv( (rand() % 240) + 30,  (rand() % 360) + 30);
  }
  
  glEnable(GL_LINE_SMOOTH);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
  
  
  return self;
}  

- (void) initChipmunk{
  // start chipumnk
  // create the space for the bodies
  // and set the hash to a rough estimate of how many shapes there could be
  // set gravity, make the physics run loop
  // make a bounding box the size of the screen
  
  cpInitChipmunk();
  space = cpSpaceNew();
	cpSpaceResizeStaticHash(space, 4, 20);
  cpSpaceResizeActiveHash(space, 50.0, 500);

	space->gravity = cpv(0, -200);
  staticBody = cpBodyNew(INFINITY, INFINITY);  
  [self schedule: @selector(step:)];
  
  CGRect window = [[Director sharedDirector] winSize];
  int margin = 4;
  int dmargin = margin*2;
  makeStaticBox(margin, margin, window.size.width - dmargin, window.size.height - dmargin);
  createPlayer();
}

- (void) draw{  
  glColor4f(1.0, 1.0, 1.0, 1.0);
  cpSpaceHashEach(space->activeShapes, &drawObject, NULL);
  glColor4f(1.0, 1.0, 1.0, 0.7);
  cpSpaceHashEach(space->staticShapes, &drawObject, NULL);  
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{  
  UITouch *myTouch =  [touches anyObject];
  CGPoint location = [myTouch locationInView: [myTouch view]];
  location = [[Director sharedDirector] convertCoordinate: location];
  cpMouseMove(mouse, cpv(location.x, location.y));
  if(mouse->grabbedBody == nil){
    cpMouseGrab(mouse, 0);
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *myTouch =  [touches anyObject];
  CGPoint location = [myTouch locationInView: [myTouch view]];
  location = [[Director sharedDirector] convertCoordinate: location];
  mouse = cpMouseNew(space);
  cpMouseMove(mouse, cpv(location.x, location.y));
  cpMouseGrab(mouse, 0);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self touchesCancelled:touches withEvent:event];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  cpMouseDestroy(mouse);
}


-(void) step: (ccTime) delta {
	int steps = 2;
	cpFloat dt = delta/(cpFloat)steps;
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
} 

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration{	
  static float prevX=0, prevY=0;	
  #define kFilterFactor 0.05
  
  float accelX = acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
  float accelY = acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
  
  prevX = accelX;
  prevY = accelY;
  
  cpVect v = cpv( accelX, accelY);
  space->gravity = cpvmult(v, 200);
}
@end


@implementation AppController
- (void) applicationDidFinishLaunching:(UIApplication*)application {
	[[Director sharedDirector] setAnimationInterval:1.0/60];
 // [[Director sharedDirector] setMultipleTouchEnabled:YES];
  
	Scene *scene = [Scene node];
  GameLayer *game = [GameLayer node];
  [scene add: game];
	
  glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	[[Director sharedDirector] runScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application {
	[[Director sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application {
	[[Director sharedDirector] resume];
}

@end