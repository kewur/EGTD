//
//  Director.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Director.h"
#import "AbstractScene.h"

@implementation Director

@synthesize currentlyBoundTexture;
@synthesize currentGameState;
@synthesize currentScene;
@synthesize globalAlpha;
@synthesize framesPerSecond;

// Make this class a singleton class
SYNTHESIZE_SINGLETON_FOR_CLASS(Director);


- (id)init {
    
	// Initialize the arrays to be used within the state manager
	_scenes = [[NSMutableDictionary alloc] init];
	currentScene = nil;
	globalAlpha = 1.0f;
	return self;
}


- (void)addSceneWithKey:(NSString*)aSceneKey scene:(AbstractScene*)aScene {
	[_scenes setObject:aScene forKey:aSceneKey];
}


- (BOOL)setCurrentSceneToSceneWithKey:(NSString*)aSceneKey {
	if(![_scenes objectForKey:aSceneKey]) {
            
             return NO;
    }
	
    currentScene = [_scenes objectForKey:aSceneKey];
   
	[currentScene setSceneAlpha:1.0f];
    
	[currentScene setSceneState:kGameState_Running];
   

    return YES;
}


- (BOOL)transitionToSceneWithKey:(NSString*)aSceneKey {
    
	// If the scene key exists then tell the current scene to transition to that
    // scene and return YES
    if([_scenes objectForKey:aSceneKey]) {
        [currentScene transitionToSceneWithKey:aSceneKey];
        return YES;
    }
    
    // If the scene does not exist then return NO;
    return NO;
}


- (void)dealloc {
	[_scenes release];
	[super dealloc];
}


@end
