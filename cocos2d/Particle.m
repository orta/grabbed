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

// ideas taken from:
//	 . The ocean spray in your face [Jeff Lander]
//		http://www.double.co.nz/dust/col0798.pdf
//	 . Building an Advanced Particle System [John van der Burg]
//		http://www.gamasutra.com/features/20000623/vanderburg_01.htm
//   . LOVE game engine
//      http://love.sf.net

// opengl
#import <OpenGLES/ES1/gl.h>

// cocos2d
#import "Particle.h"
#import "Primitives.h"
#import "TextureMgr.h"

// support
#import "OpenGL_Internal.h"

#define RANDOM_FLOAT() (((float)random() / (float)0x3fffffff )-1.0f)


@implementation ParticleSystem
@synthesize active, duration;
@synthesize posVar;
@synthesize life, lifeVar;
@synthesize angle, angleVar;
@synthesize speed, speedVar;
@synthesize tangentialAccel, tangentialAccelVar;
@synthesize radialAccel, radialAccelVar;
@synthesize startColor, startColorVar;
@synthesize endColor, endColorVar;
@synthesize emissionRate;
@synthesize totalParticles;

-(id) init {
	NSException* myException = [NSException
								exceptionWithName:@"Particle.init"
								reason:@"Particle.init shall not be called. Used initWithTotalParticles instead."
								userInfo:nil];
	@throw myException;	
}

-(id) initWithTotalParticles:(int) numberOfParticles
{
	if( ! [super init] )
		return nil;
	
	totalParticles = numberOfParticles;
	
	particles = malloc( sizeof(Particle) * totalParticles );
	vertices = malloc( sizeof(ccPointSprite) * totalParticles );
	colors = malloc (sizeof(ccColorF) * totalParticles);

	if( ! ( particles &&vertices && colors ) ) {
		NSLog(@"Particle system: not enough memory");
		if( particles )
			free(particles);
		if( vertices )
			free(vertices);
		if( colors )
			free(colors);
		return nil;
	}
	
	bzero( particles, sizeof(Particle) * totalParticles );
	
	// default, active
	active = YES;
	
	// default: additive
	blendAdditive = NO;
	
	// default: modulate
	// XXX: not used
//	colorModulate = YES;
		
	glGenBuffers(1, &verticesID);
	glGenBuffers(1, &colorsID);	
	
	[self schedule:@selector(step:)];

	return self;
}

-(void) dealloc
{
	free( particles );
	free(vertices);
	free(colors);
	glDeleteBuffers(1, &verticesID);
	glDeleteBuffers(1, &colorsID);

	[texture release];
	
	[super dealloc];
}

-(BOOL) addParticle
{
	if( [self isFull] )
		return NO;
	
	Particle * particle = &particles[ particleCount ];
		
	[self initParticle: particle];		
	particleCount++;
				
	return YES;
}

-(void) initParticle: (Particle*) particle
{
	cpVect v;

	// position
	particle->pos.x = posVar.x * RANDOM_FLOAT();
	particle->pos.y = posVar.y * RANDOM_FLOAT();
	
	// direction
	float a = DEGREES_TO_RADIANS( angle + angleVar * RANDOM_FLOAT() );
	v.y = sinf( a );
	v.x = cosf( a );
	float s = speed + speedVar * RANDOM_FLOAT();
	particle->dir = cpvmult( v, s );
	
	// radial accel
	particle->radialAccel = radialAccel + radialAccelVar * RANDOM_FLOAT();
	
	// tangential accel
	particle->tangentialAccel = tangentialAccel + tangentialAccelVar * RANDOM_FLOAT();
	
	// life
	particle->life = life + lifeVar * RANDOM_FLOAT();
	
	// Color
	ccColorF start;
	start.r = startColor.r + startColorVar.r * RANDOM_FLOAT();
	start.g = startColor.g + startColorVar.g * RANDOM_FLOAT();
	start.b = startColor.b + startColorVar.b * RANDOM_FLOAT();
	start.a = startColor.a + startColorVar.a * RANDOM_FLOAT();

	ccColorF end;
	end.r = endColor.r + endColorVar.r * RANDOM_FLOAT();
	end.g = endColor.g + endColorVar.g * RANDOM_FLOAT();
	end.b = endColor.b + endColorVar.b * RANDOM_FLOAT();
	end.a = endColor.a + endColorVar.a * RANDOM_FLOAT();
	
	particle->color = start;
	particle->deltaColor.r = (end.r - start.r) / particle->life;
	particle->deltaColor.g = (end.g - start.g) / particle->life;
	particle->deltaColor.b = (end.b - start.b) / particle->life;
	particle->deltaColor.a = (end.a - start.a) / particle->life;

	// size
	particle->size = size + sizeVar * RANDOM_FLOAT();	
}

-(void) step: (ccTime) dt
{
	if( active ) {
		float rate = 1.0 / emissionRate;
		emitCounter += dt;
		while( particleCount < totalParticles && emitCounter > rate ) {
			[self addParticle];
			emitCounter -= rate;
		}
		
		elapsed += dt;
		if(duration != -1 && duration < elapsed)
			[self stopSystem];
	}
		
	particleIdx = 0;
	
	while( particleIdx < particleCount )
	{
		Particle *p = &particles[particleIdx];
		
		if( p->life > 0 ) {
		
			cpVect tmp, radial, tangential;
		
			radial = cpvzero;
			// radial acceleration
			if(p->pos.x || p->pos.y)
				radial = cpvnormalize(p->pos);
			tangential = radial;
			radial = cpvmult(radial, p->radialAccel);
			
			// tangential acceleration
			float newy = tangential.x;
			tangential.x = -tangential.y;
			tangential.y = newy;
			tangential = cpvmult(tangential, p->tangentialAccel);
			
			// (gravity + radial + tangential) * dt
			tmp = cpvadd( cpvadd( radial, tangential), gravity);
			tmp = cpvmult( tmp, dt);
			p->dir = cpvadd( p->dir, tmp);
			tmp = cpvmult(p->dir, dt);
			p->pos = cpvadd( p->pos, tmp );
			
			p->color.r += (p->deltaColor.r * dt);
			p->color.g += (p->deltaColor.g * dt);
			p->color.b += (p->deltaColor.b * dt);
			p->color.a += (p->deltaColor.a * dt);
			
			p->life -= dt;

			// place vertices and colos in array
			vertices[particleIdx].x = p->pos.x;
			vertices[particleIdx].y = p->pos.y;
			vertices[particleIdx].size = p->size;
			
			// colors
			colors[particleIdx] = p->color;
		
			// update particle counter
			particleIdx++;
			
		} else {
			// life < 0
			if( particleIdx != particleCount-1 )
				particles[particleIdx] = particles[particleCount-1];
			particleCount--;			
		}
	}
}

-(void) stopSystem
{
	active = NO;
	elapsed = duration;
	emitCounter = 0;
}

-(void) resetSystem
{
	elapsed = duration;
	emitCounter = 0;
}

-(void) draw
{
	int blendSrc, blendDst;
//	int colorMode;
	
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, texture.name);
	
	glEnable(GL_POINT_SPRITE_OES);
	glTexEnvi( GL_POINT_SPRITE_OES, GL_COORD_REPLACE_OES, GL_TRUE );
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(ccPointSprite)*totalParticles, vertices,GL_DYNAMIC_DRAW);
	glVertexPointer(2,GL_FLOAT,sizeof(ccPointSprite),0);
	
	glEnableClientState(GL_POINT_SIZE_ARRAY_OES);
	glPointSizePointerOES(GL_FLOAT,sizeof(ccPointSprite),(GLvoid*) (sizeof(GL_FLOAT)*2));
	
	glEnableClientState(GL_COLOR_ARRAY);
	glBindBuffer(GL_ARRAY_BUFFER, colorsID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(ccColorF)*totalParticles, colors,GL_DYNAMIC_DRAW);
	glColorPointer(4,GL_FLOAT,0,0);

	// save blend state
	glGetIntegerv(GL_BLEND_DST, &blendDst);
	glGetIntegerv(GL_BLEND_SRC, &blendSrc);
	if( blendAdditive )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	else
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// save color mode
#if 0
	glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, &colorMode);
	if( colorModulate )
		glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE );
	else
		glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE );
#endif

	glDrawArrays(GL_POINTS, 0, particleIdx);
	
	// restore blend state
	glBlendFunc( blendSrc, blendDst );

#if 0
	// restore color mode
	glTexEnvi( GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, colorMode);
#endif
	
	// unbind VBO buffer
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	glDisableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_POINT_SIZE_ARRAY_OES);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_POINT_SPRITE_OES);
}

-(BOOL) isFull
{
	return (particleCount == totalParticles);
}
@end
