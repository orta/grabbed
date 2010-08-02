/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


// cocoa related
#import <UIKit/UIKit.h>

// OpenGL related
#import "Support/EAGLView.h"

// cocos2d related
#import "Scene.h"

// Landscape is right or left ?
#define LANDSCAPE_LEFT 1

// Fast FPS display. FPS are updated 10 times per second without consuming resources
// uncomment this line to use the old method that updated
#define FAST_FPS_DISPLAY 1

enum {
	RGB565,
	RGBA8
};

@class LabelAtlas;

/**Class that creates and handle the main Window and manages how
and when to execute the Scenes
*/
@interface Director : EAGLView
{
	UIWindow*	window;
	CGRect		winSize;

	NSTimer *animationTimer;
	NSTimeInterval animationInterval;
	NSTimeInterval oldAnimationInterval;

	/** landscape mode ? */
	BOOL landscape;
	
	/** display FPS ? */
	BOOL displayFPS;
	int frames;
	ccTime accumDt;
	ccTime frameRate;
#ifdef FAST_FPS_DISPLAY
	LabelAtlas *FPSLabel;
#endif
	
	/** is the running scene paused */
	BOOL paused;
	
	/** running scene */
	Scene *runningScene;
	
	/** will be the next 'runningScene' in the next frame */
	Scene *nextScene;
	
	/** event handler */
	NSMutableArray	*eventHandlers;

	/** scheduled scenes */
	NSMutableArray *scenes;
	
	/** last time the main loop was updated */
	struct timeval lastUpdate;
	/** delta time since last tick to main loop */
	ccTime dt;
	/** whether or not the next delta time will be zero */
	 BOOL nextDeltaTimeZero;
	
	/** are touch events enabled. Default is YES */
	BOOL eventsEnabled;
}

@property (readonly, assign) Scene* runningScene;
@property (readwrite, assign) NSTimeInterval animationInterval;
@property (readwrite,assign) UIWindow* window;
@property (readwrite, assign) BOOL displayFPS;
@property (readwrite, assign) BOOL eventsEnabled;

/** returns a shared instance of the director */
+(Director *)sharedDirector;

// iPhone Specific

/** change default pixel format
 Call this class method before any other call to the Director.
 Default pixel format: RGB565. Supported pixel formats: RGBA8 and RGB565
 */
+(void) setPixelFormat: (int) p;

// Landscape

/** returns the size of the screen 480x320 or 320x480 depeding if landscape mode is activated or not */
- (CGRect) winSize;
/** returns 320x480, always */
-(CGRect) displaySize;

/** returns whether or not the screen is in landscape mode */
- (BOOL) landscape;
/** sets lanscape mode */
- (void) setLandscape: (BOOL) on;
/** converts a UIKit coordinate to an OpenGL coordinate
 Useful to convert (multi) touchs coordinates to the current layout (portrait or landscape)
 */
-(CGPoint) convertCoordinate: (CGPoint) p;

// Scene Management

/**Runs a scene, entering in the Director's main loop. 
 */
- (void) runScene:(Scene*) scene;

/**Suspends the execution of the running scene, pushing it on the stack of suspended scenes.
 The new scene will be executed.
 Try to avoid big stacks of pushed scenes to reduce memory allocation. 
 */
- (void) pushScene:(Scene*) scene;

/**Pops out a scene from the queue.
 This scene will replace the running one.
 The running scene will be deleted. If there are no more scenes in the stack the execution is terminated.
 */
- (void) popScene;

/** Replaces the running scene with a new one. The running scene is terminated.
 */
-(void) replaceScene: (Scene*) scene;

/** Ends the execution */
-(void) end;

/** Pauses the running scene.
 The running scene will be _drawed_ but all scheduled timers will be paused
 While paused, the draw rate will be 4 FPS to reduce CPU consuption
 */
-(void) pause;

/** Resumes the paused scene
 The scheduled timers will be activated again.
 The "delta time" will be 0 (as if the game wasn't paused)
 */
-(void) resume;

// Events

/** adds a cocosnode object to the list of multi-touch event queue */
-(void) addEventHandler: (CocosNode*) node;
/** removes a cocosnode object from the list of multi-touch event queue */
-(void) removeEventHandler: (CocosNode*) node;

// OpenGL Helper

/** enables/disables OpenGL alpha blending */
- (void) setAlphaBlending: (BOOL) on;
/** enables/disables OpenGL depth test */
- (void) setDepthTest: (BOOL) on;
/** enables/disables OpenGL texture 2D */
- (void) setTexture2D: (BOOL) on;
/** sets Cocos OpenGL default projection */
- (void) setDefaultProjection;
/** sets a 2D projection */
-(void) set2Dprojection;
/** sets a 3D projection */
-(void) set3Dprojection;
@end



