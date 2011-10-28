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
      
        //NORMAL CAMERA GAME COORDINATE SYSTEM
        
        gameCamera = [[Camera alloc] initWithTileLocation:Vector3fMake(0,30,-40)];
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
   
     CGPoint tt = [self unProject:_location];
   //  NSLog(@"location X : %f  location Y : %f ", tt.x, tt.y);
  //  NSLog(@"location X : %f  location Y : %f ", _location.x, _location.y);
    
    if (_location.y < 30)
    {
        touched = 1;
    }
    else if(miniTowerTouched !=1)
    {
        touched = 0;
    }
    
    xDifference = 0;
    yDifference = 0;

    
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

    } 


}
- (void)updateWithTouchLocationEnded:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
 
//    xDifference *= 0.5;
 //   yDifference *= 0.5;

    
    if(miniTowerTouched == 1 )
    {
        touched = 0;
        miniTowerTouched = 0;
    }
    
}

#define RAY_ITERATIONS  100
- (CGPoint) unProject: (CGPoint) point
{
    
    GLfloat x=0, y=0, z=0;
    GLfloat modelMatrix[16]; 
    GLfloat projMatrix[16];
    GLint viewport[4];
    glGetFloatv(GL_MODELVIEW_MATRIX, modelMatrix);
    glGetFloatv(GL_PROJECTION_MATRIX, projMatrix);
    glGetIntegerv(GL_VIEWPORT, viewport);


   
    point.y = viewport[3] - point.y;
 
 //  NSLog(@"location X : %f  location Y : %f ", point.x, point.y);
    EGVertex3D far3d;
    EGVertex3D near3d;
    EGVertex3D rayVector3d;

    //Retreiving position projected on near plan
   	gluUnProject( point.x, point.y , 0, modelMatrix, projMatrix, viewport, &near3d.x, &near3d.y, &near3d.z);
    
	//Retreiving position projected on far plan
	gluUnProject( point.x, point.y,  1, modelMatrix, projMatrix, viewport, &far3d.x, &far3d.y, &far3d.z);
    
    rayVector3d.x = (far3d.x - near3d.x);
	rayVector3d.y = (far3d.y - near3d.y);
	rayVector3d.z = (far3d.z - near3d.z);

  //  NSLog(@"RAY X : %f  location Y : %f  location Z : %f", rayVector3d.x, rayVector3d.y,rayVector3d.z);
   // rayVector3d.x =  near3d.x;
	//rayVector3d.y =  near3d.y;
	//rayVector3d.z =  near3d.z;
    
    float rayLength = sqrtf(rayVector3d.x*rayVector3d.x + rayVector3d.y*rayVector3d.y + rayVector3d.z*rayVector3d.z);
    NSLog(@"NEAR X : %f  location Y : %f  location Z : %f", near3d.x, near3d.y,near3d.z);
   // NSLog(@"RAY X : %f  location Y : %f  location Z : %f", far3d.x, far3d.y,far3d.z);
    
    rayVector3d.x /= rayLength;
	rayVector3d.y /= rayLength;
	rayVector3d.z /= rayLength;


      

  // NSLog(@"RAY X : %f  location Y : %f  location Z : %f", rayVector3d.x, rayVector3d.y,rayVector3d.z);
    CGPoint result = { 0.0f/0.0f, 0.0f/0.0f };

    EGVertex3D collisionPoint;
    //Iterating over ray vector to check collisions
	for(int i = 0; i < RAY_ITERATIONS; i++)
	{
//		collisionPoint.x = rayVector3d.x * rayLength/RAY_ITERATIONS*i;
//		collisionPoint.y = rayVector3d.y * rayLength/RAY_ITERATIONS*i;
//		collisionPoint.z = rayVector3d.z * rayLength/RAY_ITERATIONS*i;
        
        collisionPoint.x = near3d.x + rayVector3d.x*i;
        collisionPoint.y = near3d.y + rayVector3d.y*i;
		collisionPoint.z = near3d.z + rayVector3d.z*i;
        
        
        //Checking collision 
         NSLog(@"RAY X : %f  location Y : %f  location Z : %f", collisionPoint.x, collisionPoint.y,collisionPoint.z);
	}
  //  return result;
}

#pragma mark -
#pragma mark Render scene

- (void)render {
  
    
    [gameMap render];
    [gameCamera render];
    [towerMenu render];

}


@end
