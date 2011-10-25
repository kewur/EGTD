//
//  GameScene.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "Camera.h"
#import "TowerMenu.h"

@implementation GameScene

@synthesize gameMap;
@synthesize xDifference;
@synthesize yDifference;
@synthesize _location;
@synthesize towerMenu;
@synthesize touched;
@synthesize miniTowerTouched;
- (id)init {
	
	if(self == [super init]) {
		
        // Grab an instance of our singleton classes
		_sharedDirector = [Director sharedDirector];
        _sharedResourceManager = [ResourceManager sharedResourceManager];
        gameMap = [[Map3D alloc] initMap3D];
        towerMenu = [[TowerMenu alloc] init];
      
        //Cameras first position x = 0 y = -20 z = 40
        //Y is decreasing to up dont switch y
        //X is increasing with LEFT not right
        //Z is decreasing with forward
        gameCamera = [[Camera alloc] initWithTileLocation:Vector3fMake(0,-20,40)];
        xDifference = 0;
        yDifference = 0;
        touched = 0;
        miniTowerTouched = 0;
        miniTower = CGRectMake(240, 0, 80, 80);
        

        

    }
	
	return self;
}

#pragma mark -
#pragma mark Update scene logic

- (void)updateWithDelta:(GLfloat)theDelta {
    
    [gameCamera update:theDelta];
    [towerMenu update:theDelta];
    
}

#pragma mark -
#pragma mark Touch events

- (void)updateWithTouchLocationBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
          
    
    UITouch *touch = [[event touchesForView:aView] anyObject];

	_location = [touch locationInView:aView];

    
    if (CGRectContainsPoint(miniTower, _location) && touched == 1)
    {
        NSLog(@"mini tower touched");
        
        miniTowerHash = [touch hash];
        miniTowerTouched = 1;
    }
    
   // NSLog(@"location X : %f  location Y : %f ", _location.x, _location.y);
    
    if (_location.x > 300)
    {
        touched = 1;
    }
    else if(miniTowerTouched !=1)
    {
        touched = 0;
    }

    
}


- (void)updateWithTouchLocationMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

    UITouch *touch = [[event touchesForView:aView] anyObject];

    if ([touch hash] == miniTowerHash)
    {
        
    
    
    
    }
    
    if (!touched && miniTowerTouched != 1)
    {
      //  UITouch *touch = [[event touchesForView:aView] anyObject];
        CGPoint _nextLocation;
        _nextLocation = [touch locationInView:aView];
        
        xDifference = _nextLocation.x-_location.x;
        yDifference = _nextLocation.y-_location.y;
        
        //NSLog(@"X DIFFERENCE %f",xDifference);
        //NSLog(@"Y DIFFERENCE %f",yDifference);
    } 


}
- (void)updateWithTouchLocationEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
 
    xDifference *= 0.5;
    yDifference *= 0.5;

    
    if(miniTowerTouched == 1 )
    {
        touched = 0;
        miniTowerTouched = 0;
    }
    
}


#pragma mark -
#pragma mark Render scene

- (void)render {
  
    
    [gameMap render];
    [gameCamera render];
    [towerMenu render];

}


@end
