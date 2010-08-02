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

#import "types.h"

//
// Timer
//
/** Light weight timer */
@interface Timer : NSObject
{
	NSInvocation* invocation;
	ccTime interval;
	ccTime elapsed; 
}
@property (readwrite,assign) ccTime interval;

/** constructor for timer */
+(id) timerWithTarget:(id) t selector:(SEL)s;

/** constructor for timer with interval */
+(id) timerWithTarget:(id) t selector:(SEL)s interval:(ccTime) i;

/** init for Timer */
-(id) initWithTarget:(id) t selector:(SEL)s;

/** init for Timer with interval */
-(id) initWithTarget:(id) t selector:(SEL)s interval:(ccTime) i;


/** triggers the timer */
-(void) fire: (ccTime) dt;
@end

//
// Scheduler
//
/**Class manages all the schedulers
*/
@interface Scheduler : NSObject
{
	NSMutableArray *scheduledMethods;
	NSMutableArray *methodsToRemove;
	NSMutableArray *methodsToAdd;
}

/** returns a shared instance of the Scheduler */
+(Scheduler *)sharedScheduler;

/** the scheduler is ticked */
-(void) tick: (ccTime) dt;

/** schedule a target/selector */
-(Timer*) scheduleTarget:(id) r selector:(SEL) s;

/** schedule a target/selector with interval */
-(Timer*) scheduleTarget:(id) r selector:(SEL) s interval: (ccTime) i;


/** schedule a Timer */
-(void) scheduleTimer: (Timer*) t;

/** unschedule a timer */
-(void) unscheduleTimer: (Timer*) t;
@end
