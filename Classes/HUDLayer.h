//
//  HUDLayer.h
//  Thrown
//
//  Created by orta on 27/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"
#import "ChuckedAppDelegate.h"

@class GameLayer;

@interface HUDLayer : Layer {
  
  GameLayer *game;
  Label * topLabel;
  LabelAtlas * maxDistanceLabel;
  Label * currentLabel;
  LabelAtlas * distanceLabel;

  int maxHeight;
  int currentHeight;

}
@property (nonatomic, retain) GameLayer *game;
@property (nonatomic) int maxHeight;
@property (nonatomic) int currentHeight;

@end
