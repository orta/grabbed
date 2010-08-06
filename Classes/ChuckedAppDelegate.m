//
//  grabbed_tooAppDelegate.m
//  grabbed too
//
//  Created by benmaslen on 14/03/2009.
//  Copyright ortatherox.com 2009. All rights reserved.
//

#import "ChuckedAppDelegate.h"
#import "Globals.h"

extern int playerHitBalls(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data);
extern int returnZero(cpShape *a, cpShape *b, cpContact *contacts, int numContacts, cpFloat normal_coef, void *data);
extern cpBody* makeCircle(int radius);
extern void drawObject(void *ptr, void *unused);
void pushAwayFromPlayer(void *ptr, void *player_body);
extern cpBody* createPlayer();
extern void makeStaticBox(float x, float y, float width, float height);
cpSpace *space;
cpBody *staticBody;
int slowdown;
void * game;

@implementation GameLayer
@synthesize hud;


-(id) init {
	[super init];
  game = self;
  [self initChipmunk];
  isTouchEnabled = YES;
//	isAccelerometerEnabled = YES;
  [[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 60)];
  
  //seed the random generator
  srand([[NSDate date] timeIntervalSince1970]);
  
  // make a bunch of circles
  for (int i = 0; i < (rand() % 10) + 10; i++) {
    cpBody* circle = makeCircle((rand() % 20) + 10);
    circle->p = cpv( (rand() % 240) + 30,  (rand() % 360) + 30);
    circle->rot = circle->p;
  }
  
  int width = 4000;
  // my current best is 50000, doene it twice
  int height = 60000;
  
  cpShape * shape;
  shape = cpSegmentShapeNew(staticBody, cpv(8, 8), cpv(304, 8), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  shape->collision_type = kColl_Floor_balls;
  cpSpaceAddStaticShape(space, shape);
  
  shape = cpSegmentShapeNew(staticBody, cpv(304, 555), cpv(304, 8), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  shape = cpSegmentShapeNew(staticBody, cpv(8, 555), cpv(8, 8), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  shape = cpSegmentShapeNew(staticBody, cpv(304, 555), cpv(width/2, height ), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);
  
  shape = cpSegmentShapeNew(staticBody, cpv(8, 555), cpv(width/2 * -1, height ), 0.0f);
  shape->e = 1.0; shape->u = 1.0;
  cpSpaceAddStaticShape(space, shape);

  glEnable(GL_LINE_SMOOTH);
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glHint(GL_LINE_SMOOTH_HINT, GL_DONT_CARE);
  
  NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
  return self;
}

-(void) dealloc {
	[super dealloc];
}

- (void) initChipmunk{
  // start chipumnk
  // create the space for the bodies
  // and set the hash to a rough estimate of how many shapes there could be
  // set gravity, make the physics run loop
  // make a bounding box the size of the screen
  
  cpInitChipmunk();
  space = cpSpaceNew();
  cpSpaceResizeStaticHash(space, 120.0, 2000);
  cpSpaceResizeActiveHash(space, 120.0, 2000);
  
	space->gravity = cpv(0, -200);
  staticBody = cpBodyNew(INFINITY, INFINITY);  
  [self schedule: @selector(step:)];
  
  player = createPlayer();
  cpSpaceAddCollisionPairFunc(space, kColl_Floor_balls, kColl_Player, &playerHitBalls, player);

}

- (void) draw{  
  // rendering loop
  glColor4f(1.0, 1.0, 1.0, 1.0);
  cpSpaceHashEach(space->activeShapes, &drawObject, NULL);
  //by switching colour here we can make static stuff darker
  glColor4f(1.0, 1.0, 1.0, 0.7);
  cpSpaceHashEach(space->staticShapes, &drawObject, NULL);  
  
  for (int i = 1; i < 50; i++) {
    //    drawLine(-3000, 3000, i*1000, i*1000); // this is really pretty, but wrong
    drawLine(-3000, i*1000, 3000, i*1000);
  }
  
}


- (void) centerOnPlayer{
  float py = player->p.y;
  if(py < 550){
    [self setPosition:cpv(0,0)];
  }else{
    [self setPosition:cpv((player->p.x - 160) * -1 , (py - 240) * -1)];
  }
}



- (void)ccTouchesMoved:(NSSet*)touches withEvent:(UIEvent*)event{  
  UITouch *myTouch =  [touches anyObject];
  CGPoint location = [myTouch locationInView: [myTouch view]];
  location = [[Director sharedDirector] convertCoordinate: location];
  //move the nouse to the click
  cpMouseMove(mouse, cpv(location.x, location.y));
  if(mouse->grabbedBody == nil){
    //if there's no associated grabbed object
    // try get one
    cpMouseGrab(mouse, 0);
    //TODO: look for any member of player and set boy

  }
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *myTouch =  [touches anyObject];
  CGPoint location = [myTouch locationInView: [myTouch view]];
  location = [[Director sharedDirector] convertCoordinate: location];
  mouse = cpMouseNew(space);
  cpMouseMove(mouse, cpv(location.x, location.y));
  cpMouseGrab(mouse, 0);
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [self ccTouchesCancelled:touches withEvent:event];
}
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  cpMouseDestroy(mouse);
}


-(void) step: (ccTime) delta {
  cpFloat slowEffect = 1;
  if(slowdown > 0){
    slowdown--;
    slowEffect = 0.1;
    
  }
	int steps = 2;
	cpFloat dt = delta/(cpFloat)steps;
  dt *= slowEffect;
	for(int i=0; i<steps; i++){
		cpSpaceStep(space, dt);
	}
  int py = player->p.y;
  [self centerOnPlayer];
  [hud setCurrentHeight:player->p.y];
  if(py > [hud maxHeight]){
    [hud setMaxHeight:py];
  }
  
  if(py < -100){
    //TODO improve
    player->p = cpv(200,200);
    player->v = cpvzero;
  }
} 

-(void) checkForHighScore: (ccTime) delta {

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



- (void) playerJustCollidedAtHighSpeed{
  [self rumble];
  cpSpaceHashEach(space->activeShapes, &pushAwayFromPlayer, player);
  
  player->v.y *= 0.1;
  
}

- (void) rumble{
  id scaleAction = [ScaleTo actionWithDuration:0.1 scale:1.1];
  id scaleBackAction = [ScaleTo actionWithDuration:0.1 scale:1.0];
  id jump1 = [JumpTo actionWithDuration:0.1 position:cpv(4,4) height:2 jumps:1];
  id jump2 = [JumpTo actionWithDuration:0.1 position:cpv(-8,-2) height:2 jumps:1];
  id jump3 = [JumpTo actionWithDuration:0.1 position:cpv(0,0) height:-6 jumps:1];
  
  id scoreAction = [Sequence actions: scaleAction, jump2, scaleBackAction, jump1, jump3, nil];
  [self do:scoreAction];
  
}

@end

// this is free from any class probably should be in Helpers
void pushAwayFromPlayer(void *ptr, void *player_body){
  cpShape *shape = (cpShape *)ptr;  
  if(shape -> collision_type != kColl_Floor_balls){
    return;
  }
  cpBody *body = shape->body;
  cpBody * player = (cpBody *)player_body;
  cpVect impulse = cpvsub(body->p, player->p);
  cpBodyApplyImpulse(body, cpvmult(impulse, 50), cpvzero);
  slowdown = 100;
}


@implementation grabbed_tooAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// NEW: Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setUserInteractionEnabled:YES];
	//[window setMultipleTouchEnabled:YES];

  
	//[[Director sharedDirector] setLandscape: YES];
	[[Director sharedDirector] setDisplayFPS:YES];

	[[Director sharedDirector] attachInWindow:window];

	Scene *scene = [Scene node];
  GameLayer *game = [GameLayer node];
  HUDLayer *hud = [HUDLayer node];  
  [game setHud:hud];
  [scene add: hud z:1];
  [scene add: game z:0];
  
	[window makeKeyAndVisible];
	
	[[Director sharedDirector] runWithScene: scene];

}
-(void)dealloc
{
	[super dealloc];
}
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[Director sharedDirector] pause];
}
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[Director sharedDirector] resume];
}
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[TextureMgr sharedTextureMgr] removeAllTextures];
}

@end
