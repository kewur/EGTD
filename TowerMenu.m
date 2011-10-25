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
@synthesize miniTowerTouched;
@synthesize miniTowers;
- (id)init {
	self = [super init];
	if (self != nil) {
        _sharedDirector = [Director sharedDirector];
        touched = 0;
        backgroundView = [(Image*)[Image alloc] initWithImage:@"towerMenuBackground.png"];
        
        coin = [(Image*)[Image alloc] initWithImage:@"coin.png"];
        turn = [(Image*)[Image alloc] initWithImage:@"turn.png"];
        
        miniTowerBack = [(Image*)[Image alloc] initWithImage:@"miniTowerBack.png"];
        miniTowerBackSelected = [(Image*)[Image alloc] initWithImage:@"miniTowerBackSelected.png"];
      
        font1 = [[AngelCodeFont alloc] initWithFontImageNamed:@"font1.png" controlFile:@"font1" scale:0.8 filter:GL_LINEAR];
        
        moneyCondition = @"100";
        levelCondition = @"16";

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
   miniTowerTouched = [(GameScene*)[_sharedDirector currentScene]  miniTowerTouched];
    
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
 
    [font1 drawStringAt:CGPointMake(z-136.5, 415) text:moneyCondition];
    [font1 drawStringAt:CGPointMake(z-124, 355) text:levelCondition];
 
    [coin setRotation:90];
    [coin renderAtPoint:CGPointMake(z-73, 470) centerOfImage:YES];
  
    if(miniTowerTouched == 0)
    {
        [miniTowerBack setRotation:90];
        [miniTowerBack renderAtPoint:CGPointMake(z+45, 440) centerOfImage:YES];
    }
    else
    {
        [miniTowerBackSelected setRotation:90];
        [miniTowerBackSelected renderAtPoint:CGPointMake(z+45, 440) centerOfImage:YES];
    }
    [turn  setRotation:90];
    [turn renderAtPoint:CGPointMake(z-73, 400) centerOfImage:YES];
    // ------------------------------------------------
    // Rendering Towers ---------------------------------------
    // ------------------------------------------------
    int j = 0;
    for (int i = 0 ; i<[miniTowers count]; i++)
    {
        [[miniTowers objectAtIndex:i] setRotation:90];
        [[miniTowers objectAtIndex:i] renderAtPoint:CGPointMake(z+50, 440-j) centerOfImage:YES];
        j+=60;
    }

    switchBackToFrustum();
    
    glPopMatrix();
    

}
-(void)dealloc
{
    [miniTowers release];
    [super dealloc];
}

@end
