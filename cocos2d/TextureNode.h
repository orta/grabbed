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

#import "CocosNode.h"


/** A CocosNode that knows how to render a texture */
@interface TextureNode : CocosNode <CocosNodeOpacity, CocosNodeSize> {

	/// texture
	Texture2D *texture;
	
	/// texture opacity
	GLubyte opacity;
	
	/// texture color
	GLubyte	r,g,b;
}

@property (readwrite,assign) Texture2D *texture;
@property (readwrite,assign) GLubyte r, g, b, opacity;

/** set the color of the texture.
 * example:  [node setRGB: 255:128:25];
 */
-(void) setRGB: (GLubyte)r :(GLubyte)g :(GLubyte)b;


/** returns the size in pixels of the texture
 * Conforms to the CocosNodeSize protocol
 */
-(CGSize) contentSize;
@end
