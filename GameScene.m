//
//  GameScene.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"
#import "Camera.h"
#import "OpenGLTexture3D.h"
#import "Sand.h"

@implementation GameScene

@synthesize gameMap;
@synthesize xDifference;
@synthesize yDifference;
@synthesize texture;
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
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Sand" ofType:@"jpg"];
        OpenGLTexture3D *newTexture = [[OpenGLTexture3D alloc] initWithFilename:path width:512 height:512];
        self.texture = newTexture;
        [newTexture release];
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
           NSLog(@"touch began pressed");
    
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
    
    [texture bind];
  /*  glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_NORMAL_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
    glEnable(GL_BLEND);
    
    [texture bind];
    glLoadIdentity();
 //   glTranslatef(0.0, 0.0, -5.0);
   // glRotatef(rot, 1.0, 1.0, 1.0);
    glVertexPointer(3, GL_FLOAT, 0, SandVerts);
    glNormalPointer(GL_FLOAT, 0, SandNormals);
    glTexCoordPointer(2, GL_FLOAT, 0, SandTexCoords);
    glDrawArrays(GL_TRIANGLES, 0, SandNumVerts);
    //glDrawElements(GL_TRIANGLES, kCubeNumberOfVertices, GL_FLOAT, CubeFaces);
    
    glDisableClientState(GL_VERTEX_ARRAY);
    glDisableClientState(GL_NORMAL_ARRAY);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
    */
    [gameMap render];
    [gameCamera render];

   
    //glPushMatrix();
    
    // Pop the matrix back off the stack which will undo the glTranslate we did above
    //glPopMatrix();
    

    
}


@end
