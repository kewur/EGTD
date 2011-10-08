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
    
    // If we do not have access to the currentscene then grab it
    if(!_gotScene) {
        _scene = (GameScene*)[_sharedDirector currentScene];

        _gotScene = YES;
    }
    


    
    switch (entityState) {
        case kEntity_Alive:
 
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark Render

- (void)render {
    
}


@end
