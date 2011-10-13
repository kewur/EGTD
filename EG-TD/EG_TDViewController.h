//
//  EG_TDViewController.h
//  EG-TD
//
//  Created by metin okur on 16.09.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "Director.h"
#import "GameScene.h"

@interface EG_TDViewController : UIViewController {
@private
    EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    NSInteger animationFrameInterval;
    CADisplayLink *displayLink;
    
    // Angle of rotation
    GLfloat angle;
    
    // Floor Vertices
    EGVertex3D zFloorVertices[81];
    EGVertex3D xFloorVertices[81];
    
    // Shared game state
	Director *_director;
    
    // Shared resource manager
	ResourceManager *_resourceManager;
    
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;

@end
