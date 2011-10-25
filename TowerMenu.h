//
//  TowerMenu.h
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameScene.h"
#import "AngelCodeFont.h"
@class Image;


@interface TowerMenu : NSObject {
    
    float touched;
    Director *_sharedDirector;
    
    Image *backgroundView;
   
    NSMutableArray *miniTowers;

    ///Temporary
    Image *coin;
    Image *turn;
    NSString *moneyCondition;
    NSString *levelCondition;
    ///Temporary
    AngelCodeFont *font1;
    
    Image *miniTowerBack;
    Image *miniTowerBackSelected;
    
    float selected;
}

@property (nonatomic, readonly) float touched;
@property (nonatomic, readonly) float miniTowerTouched;
@property (nonatomic, retain) NSMutableArray *miniTowers;

// Selector that updates the entities logic i.e. location, collision status etc
- (void)update:(GLfloat)delta;

// Selector that renders the entity
- (void)render;

@end
