//
//  Camera.h
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractEntity.h"

@class GameScene;

@interface Camera : AbstractEntity {
    
    Director *_sharedDirector;
    float cameraX;
    float cameraY;
    float cameraZ;
    
    float _cameraSpeed;
    GameScene *_scene;

    
}

@property (nonatomic, assign) float cameraX;
@property (nonatomic, assign) float cameraY;
@property (nonatomic, assign) float cameraZ;


- (id)initWithTileLocation:(EGVertex3D)startLocation;


@end
