//
//  ResourceManager.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResourceManager.h"
#import "CommonOpenGL.h"
#import "SynthesizeSingleton.h"
#import "Texture2D.h"

@implementation ResourceManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ResourceManager);

- (void)dealloc {
    
    // Release the cachedTextures dictionary.
	[_cachedTextures release];
	[super dealloc];
}


- (id)init {
	// Initialize a dictionary with an initial size to allocate some memory, but it will 
    // increase in size as necessary as it is mutable.
	_cachedTextures = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
	return self;
}


- (Texture2D*)getTextureWithName:(NSString*)aTextureName {
    
    // Try to get a texture from cachedTextures with the supplied key.
    Texture2D *_cachedTexture;
    
    // If we can find a texture with the supplied key then return it.
    if(_cachedTexture = [_cachedTextures objectForKey:aTextureName]) {
        if(DEBUG) NSLog(@"INFO - Resource Manager: A cached texture was found with the key '%@'.", aTextureName);
        return _cachedTexture;
    }
    
    // As no texture was found we create a new one, cache it and return it.
    if(DEBUG) NSLog(@"INFO - Resource Manager: A texture with the key '%@' could not be found so creating it.", aTextureName);
    _cachedTexture = [[Texture2D alloc] initWithImage:[UIImage imageNamed:aTextureName] filter:GL_NEAREST];
    [_cachedTextures setObject:_cachedTexture forKey:aTextureName];
    
    // Return the texture which is autoreleased as the caller is responsible for it
    return [_cachedTexture autorelease];
}

- (BOOL)releaseTextureWithName:(NSString*)aTextureName {
    
    // Try to get a texture from cachedTextures with the supplied key.
    Texture2D *cachedTexture = [_cachedTextures objectForKey:aTextureName];
    
    // If a texture was found we can remove it from the cachedTextures and return YES.
    if(cachedTexture) {
        if(DEBUG) NSLog(@"INFO - Resource Manager: A cached texture with the key '%@' was released.", aTextureName);
        [_cachedTextures removeObjectForKey:aTextureName];
        return YES;
    }
    
    // No texture was found with the supplied key so log that and return NO;
    if(DEBUG) NSLog(@"INFO - Resource Manager: A texture with the key '%@' could not be found to release.", aTextureName);
    return NO;
}

- (void)releaseAllTextures {
    if(DEBUG) NSLog(@"INFO - Resource Manager: Releasing all cached textures.");
    [_cachedTextures removeAllObjects];
}


@end

