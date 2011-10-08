//
//  Director.h
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>
#import "SynthesizeSingleton.h"
#import "CommonOpenGL.h"

@class AbstractScene;

@interface Director : NSObject {
    

	// Current game state
	GLuint currentGameState;
	// Current scene
	AbstractScene *currentScene;
	// Dictionary of scenes
	NSMutableDictionary *_scenes;
	// Global alpha
	GLfloat globalAlpha;
    // Frames Per Second
    float framesPerSecond;
    

}

@property (nonatomic, assign) GLuint currentGameState;
@property (nonatomic, retain) AbstractScene *currentScene;
@property (nonatomic, assign) GLfloat globalAlpha;
@property (nonatomic, assign) float framesPerSecond;

+ (Director*)sharedDirector;
- (void)addSceneWithKey:(NSString*)aSceneKey scene:(AbstractScene*)aScene;
- (BOOL)setCurrentSceneToSceneWithKey:(NSString*)aSceneKey;
- (BOOL)transitionToSceneWithKey:(NSString*)aSceneKey;

@end
