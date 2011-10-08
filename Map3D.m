//
//  Map3D.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Map3D.h"


@implementation Map3D

@synthesize mapWidth;
@synthesize mapHeight;

- (id)initMap3D {
	
	self = [super init];
	if (self != nil) {
		
		// Shared game state
		sharedDirector = [Director sharedDirector];

	}
	return self;
}


@end
