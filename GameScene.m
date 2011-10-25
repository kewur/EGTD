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
    
   // NSLog(@"location X : %f  location Y : %f ", _location.x, _location.y);
    
    if (_location.x > 300)
    {
        touched = 1;
    }
    else
    {
        touched = 0;
    }

    
}


- (void)updateWithTouchLocationMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

    if (!touched)
    {
        UITouch *touch = [[event touchesForView:aView] anyObject];
        CGPoint _nextLocation;
        _nextLocation = [touch locationInView:aView];
        
        xDifference = _nextLocation.x-_location.x;
        yDifference = _nextLocation.y-_location.y;
        
        NSLog(@"XDIFFERENCE %f",xDifference);
        NSLog(@"YDIFFERENCE %f",yDifference);
    } 


}
- (void)updateWithTouchLocationEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
 
    xDifference *= 0.5;
    yDifference *= 0.5;
    
}


#pragma mark -
#pragma mark Render scene

- (void)render {
  
    
    [gameMap render];
    [gameCamera render];
    [towerMenu render];
    
}


@end
