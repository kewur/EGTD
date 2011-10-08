//
//  GameScene.h
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractScene.h"


@class Camera;
@class OpenGLTexture3D;
@interface GameScene : AbstractScene {
    
    Map3D *gameMap;
    OpenGLTexture3D *texture;
    
    Camera *gameCamera;
    
    int _mapWidht;
    int _mapHeight;
    
    float xDifference;
    float yDifference;
    
    CGPoint _location;
}

// Provide readonly because we won't change it here
@property (nonatomic, readonly) Map3D *gameMap;
@property (nonatomic, readonly) Camera *gameCamera;
@property (nonatomic, assign)float xDifference;
@property (nonatomic, assign)float yDifference;
@property (nonatomic, assign)CGPoint _location;
@property (nonatomic, retain) OpenGLTexture3D *texture;

@end
