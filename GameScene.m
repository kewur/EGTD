//
//  GameScene.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameScene.h"


@implementation GameScene

@synthesize gameMap;


- (id)init {
	
	if(self == [super init]) {
		
        // Grab an instance of our singleton classes
		_sharedDirector = [Director sharedDirector];

    }
	
	return self;
}

#pragma mark -
#pragma mark Update scene logic

- (void)updateWithDelta:(GLfloat)theDelta {
    
 
    
}

#pragma mark -
#pragma mark Touch events

- (void)updateWithTouchLocationBegan:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {
	

}


- (void)updateWithTouchLocationMoved:(NSSet*)touches withEvent:(UIEvent*)event view:(UIView*)aView {


}


#pragma mark -
#pragma mark Render scene

- (void)render {
       
   
    //glPushMatrix();
    
    // Pop the matrix back off the stack which will undo the glTranslate we did above
    //glPopMatrix();
    

    
}


@end
