//
//  AbstractEntity.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AbstractEntity.h"


@implementation AbstractEntity


@synthesize position;
@synthesize velocity;
@synthesize entityState;

- (id)init {
	self = [super init];
	if (self != nil) {
		position =  Vector3fMake(0, 0, 0);
		velocity = Vector3fMake(0, 0, 0);
		entityState = kEntity_Idle;
        _gotScene = NO;
	}
	return self;
}


- (void)update:(GLfloat)delta {
	
}


- (void)render {
	
}
@end
