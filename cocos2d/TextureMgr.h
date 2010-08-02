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

#import <UIKit/UIKit.h>

#import "Support/Texture2D.h"

/** Singleton that handles the loading of textures
 * Once the texture is loaded, the next time it will return
 * a reference of the previously loaded texture reducing GPU & CPU memory
 */
@interface TextureMgr : NSObject
{
	NSMutableDictionary *textures;
}

/** Retruns ths shared instance of the Texture Manager */
+ (TextureMgr *) sharedTextureMgr;

/** Returns a Texture2D object given an file image
 * If the file image was not previously loaded, it will create a new Texture2D
 *  object and it will return it.
 * Otherwise it will return a reference of a previosly loaded image
 */
-(Texture2D*) addImage: (NSString*) fileimage;

/** Purges the dictionary of loaded textures.
 * Call this method if you receive the "Memory Warning"
 * In the short term: it will free some resources preventing your app from being killed
 * In the medium term: it will allocate more resources
 * In the long term: it will be the same
 */
-(void) removeAllTextures;

/** Deletes a texture from the Texture Manager
 */
-(void) removeTexture: (Texture2D*) tex;

@end
