//
//  Camera.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Camera.h"
#import "GameScene.h"

@implementation Camera

@synthesize cameraX;
@synthesize cameraY;
@synthesize cameraZ;
@synthesize xDifference;
@synthesize yDifference;

- (void)dealloc {

    
    [super dealloc];
}


#pragma mark -
#pragma mark Init

- (id)initWithTileLocation:(EGVertex3D)startLocation {
    self = [super init];
	if (self != nil) {
        _sharedDirector = [Director sharedDirector];
        position.x = startLocation.x;
        position.y = startLocation.y;
        position.z = startLocation.z;
        
        // Set up the spritesheets that will give us out player animation
     
        // Speed at which the player moves
        _cameraSpeed = 0.04f;
        
        // Set the players state to alive
        entityState = kEntity_Alive;
        

    }
    return self;
}


#pragma mark -
#pragma mark Update

- (void)update:(GLfloat)aDelta {

    _scene = (GameScene*)[_sharedDirector currentScene];
    xDifference = [(GameScene*)[_sharedDirector currentScene]  xDifference];
    yDifference = [(GameScene*)[_sharedDirector currentScene]  yDifference];
    position.x -= yDifference*kMapAcceloremeter;
    position.z -= xDifference*kMapAcceloremeter;
    
}

#pragma mark -
#pragma mark Render

- (void)render {
  
    glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
    
    glRotatef(90, 0, 0, 1);
    gluLookAt(position.x, position.y, position.z, 0, 0, 0, 0, 1, 0);
  
}


@end
