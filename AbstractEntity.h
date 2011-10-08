//
//  AbstractEntity.h
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

//Temporary
//#import "CommonOpenGL.h"
#import "GameScene.h"
//@class GameScene;

// Entity states
enum entityState {
	kEntity_Idle = 0,
    kEntity_Dead = 1,
	kEntity_Alive = 2
};


@interface AbstractEntity : NSObject {
    

	// Entity position
	EGVertex3D position;
	// Velocity
	EGVertex3D velocity;
	// Entity state
	GLuint entityState;
    // Do we have a reference to the current scene
    BOOL _gotScene;
    
}


@property (nonatomic, assign) EGVertex3D position;
@property (nonatomic, assign) EGVertex3D velocity;
@property (nonatomic, assign) GLuint entityState;


// Selector that updates the entities logic i.e. location, collision status etc
- (void)update:(GLfloat)delta;

// Selector that renders the entity
- (void)render;
@end
