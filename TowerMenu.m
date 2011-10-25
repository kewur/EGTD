//
//  TowerMenu.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TowerMenu.h"
#import "Image.h"

@implementation TowerMenu

@synthesize touched;
@synthesize miniTowers;
- (id)init {
	self = [super init];
	if (self != nil) {
        _sharedDirector = [Director sharedDirector];
        touched = 0;
        backgroundView = [(Image*)[Image alloc] initWithImage:@"towerMenuBackground.png"];
  
        self.miniTowers = [[NSMutableArray alloc] init];
        
        Image *miniTower = [(Image*)[Image alloc] initWithImage:@"china.png"];
        
        [self.miniTowers addObject:miniTower];
        [miniTower release];
        miniTower = nil;
        
        miniTower = [(Image*)[Image alloc] initWithImage:@"france.png"];
        [miniTowers addObject:miniTower];
        [miniTower release];
        miniTower = nil;
        
	}
	return self;
}


- (void)update:(GLfloat)delta {
	
   touched = [(GameScene*)[_sharedDirector currentScene]  touched];
 
}


- (void)render {
	
    
    static  int z = 380;
    
    if (touched && z>230)
    {
        z-=5;
    }
    else if(touched && z<=230)
    {
        z = 230;
    }
    else
    {
        z = 380;
    }
    
    // ------------------------------------------------
    // Draw HUD ---------------------------------------
    // ------------------------------------------------
    glPushMatrix();
    switchToOrtho();

   
    glDisable(GL_DEPTH_TEST);
    [backgroundView setRotation:90];
    [backgroundView renderAtPoint:CGPointMake(z, 240) centerOfImage:YES];  
    //[backgroundView renderSubImageAtPoint:CGPointMake(100, 240) offset:CGPointMake(30, 30) subImageWidth:30 subImageHeight:60 centerOfImage:YES];
 

    int j = 0;
   // int k = 0;
    for (int i = 0 ; i<[miniTowers count]; i++)
    {
        [[miniTowers objectAtIndex:i] setRotation:90];
        [[miniTowers objectAtIndex:i] renderAtPoint:CGPointMake(z+50, 450-j) centerOfImage:YES];
        j+=60;
    }
    
    switchBackToFrustum();
    
    glPopMatrix();
}

@end
