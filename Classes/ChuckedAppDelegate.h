//
//  grabbed_tooAppDelegate.h
//  grabbed too
//
//  Created by benmaslen on 14/03/2009.
//  Copyright ortatherox.com 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "cpMouse.h"
#import "HUDLayer.h"

@class HUDLayer;

@interface GameLayer : Layer {
  cpMouse* mouse;
  HUDLayer* hud;
  cpBody* player;
  NSUserDefaults *prefs;
}
@property (nonatomic, retain) HUDLayer *hud;

- (void) initChipmunk;

// as cancelled and up do the same thing
- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) rumble;
- (void) playerJustCollidedAtHighSpeed;

@end

@interface grabbed_tooAppDelegate : NSObject <UIAccelerometerDelegate, UIAlertViewDelegate, UITextFieldDelegate, UIApplicationDelegate> {
	UIWindow *window;
}

@end
