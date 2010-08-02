//
//  Grab.h
//  grab
//
//  Created by orta on 19/10/2008.
//  Copyright 2008 ortatherox.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "cocos2d.h"
#import "chipmunk.h"
#import "cpMouse.h"

@interface GameLayer : Layer {
  cpMouse* mouse;
}
- (void) initChipmunk;

// as cancelled and up do the same thing
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;


@end


@interface AppController : NSObject <UIAlertViewDelegate, UITextFieldDelegate> {
}


@end
