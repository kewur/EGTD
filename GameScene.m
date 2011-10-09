//
//  GameScene.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "Camera.h"


@implementation GameScene

@synthesize gameMap;
@synthesize xDifference;
@synthesize yDifference;
@synthesize _location;
- (id)init {
	
	if(self == [super init]) {
		
        // Grab an instance of our singleton classes
		_sharedDirector = [Director sharedDirector];
        gameMap = [[Map3D alloc] initMap3D];
        
      
        //Cameras first position x = 0 y = -20 z = 40
        //Y is decreasing to up dont switch y
        //X is increasing with LEFT not right
        //Z is decreasing with forward
        gameCamera = [[Camera alloc] initWithTileLocation:Vector3fMake(0,-20,40)];
        xDifference = 0;
        yDifference = 0;

    }
	
	return self;
}

#pragma mark -
#pragma mark Update scene logic

- (void)updateWithDelta:(GLfloat)theDelta {
    
    [gameCamera update:theDelta];
    
}

#pragma mark -
#pragma mark Touch events

- (void)updateWithTouchLocationBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
          
    
    UITouch *touch = [[event touchesForView:aView] anyObject];
    
	_location = [touch locationInView:aView];
    
}


- (void)updateWithTouchLocationMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {

    UITouch *touch = [[event touchesForView:aView] anyObject];
	CGPoint _nextLocation;
	_nextLocation = [touch locationInView:aView];
    
    xDifference = _nextLocation.x-_location.x;
    yDifference = _nextLocation.y-_location.y;

}


#pragma mark -
#pragma mark Render scene

- (void)render {
    
    [gameMap render];
    [gameCamera render];
    
    // ------------------------------------------------
    // Draw HUD ---------------------------------------
    // ------------------------------------------------
    
    glPushMatrix();
    switchToOrtho();
    
    static const GLfloat squareVertices[] = {
        5.0f, 150.0f,
        5.0f, 250.0f,
        100.0f, 250.0f,
        100.0f, 150.0f
    };
    
    glLineWidth(3.0);
    glColor4f(0.0, 0.0, 1.0, 1.0); // blue
    glTranslatef(5.0, 0.0, 0.0);
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
    glDrawArrays(GL_LINE_LOOP, 0, 4);
    glTranslatef(100.0, 0.0, 0.0);
    glColor4f(1.0, 0.0, 0.0, 1.0);  // Red
    glDrawArrays(GL_LINE_LOOP, 0, 4);
    glTranslatef(100.0, 0.0, 0.0);
    glColor4f(1.0, 1.0, 0.0, 1.0);  // Yellow
    glDrawArrays(GL_LINE_LOOP, 0, 4);
    
    

    
    switchBackToFrustum();

    glPopMatrix();
    

    
}


@end
