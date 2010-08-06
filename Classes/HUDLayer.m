//
//  HUDLayer.m
//  Thrown
//
//  Created by orta on 27/08/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"

@implementation HUDLayer

@synthesize game, maxHeight, currentHeight;

-(id) init {
	[super init];
	isTouchEnabled = YES;
  topLabel = [Label labelWithString:@"Top :" dimensions:CGSizeMake(180,40) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:24];
  currentLabel = [Label labelWithString:@"Current :" dimensions:CGSizeMake(180,40) alignment:UITextAlignmentCenter fontName:@"Helvetica" fontSize:24];
  maxDistanceLabel = [LabelAtlas labelAtlasWithString:@"0" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];
  distanceLabel = [LabelAtlas labelAtlasWithString:@"0" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'];

  maxHeight = 0;
  [currentLabel setPosition:cpv(60, 460)];
  [topLabel setPosition:cpv(60, 420)];

  [distanceLabel setPosition:cpv(120, 452)];
  [maxDistanceLabel setPosition:cpv(120, 412)];

  [self add:currentLabel];
  [self add:distanceLabel];
  [self add:topLabel];
  [self add:maxDistanceLabel];
  return self;
}

- (void) draw {
	[maxDistanceLabel setString:[NSString stringWithFormat:@"%i", maxHeight]];
  [distanceLabel setString: [NSString stringWithFormat:@"%i", currentHeight]];
}

@end
