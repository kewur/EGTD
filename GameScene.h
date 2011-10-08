//
//  GameScene.h
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AbstractScene.h"

@interface GameScene : AbstractScene {
    
    Map3D *gameMap;
    int _mapWidht;
    int _mapHeight;
}

// Provide readonly because we won't change it here
@property (nonatomic, readonly) Map3D *gameMap;
@end
