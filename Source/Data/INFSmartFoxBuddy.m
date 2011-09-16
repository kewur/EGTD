//
//  INFSmartFoxBuddy.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxBuddy.h"

@implementation INFSmartFoxBuddy

@synthesize buddyId = _id;
@synthesize name = _name;
@synthesize isOnline = _isOnline;
@synthesize isBlocked = _isBlocked;
@synthesize variables = _variables;

+ (id)buddy:(NSInteger)id name:(NSString *)name isOnline:(BOOL)isOnline isBlocked:(BOOL)isBlocked;
{
	INFSmartFoxBuddy *obj = [INFSmartFoxBuddy alloc];
	return [[obj initWithParams:id name:name isOnline:isOnline isBlocked:isBlocked] autorelease];
}

- (id)initWithParams:(NSInteger)id name:(NSString *)name isOnline:(BOOL)isOnline isBlocked:(BOOL)isBlocked;
{
	self = [super init];
	if (self) {
		_id = id;
		_name = [name copy];
		_isOnline = isOnline;
		_isBlocked = isBlocked;
		_variables = [[NSMutableDictionary dictionary] retain];
	}
	
	return self;
}

- (void)dealloc
{	
	[_name release];
	[_variables release];
	
    [super dealloc];
}

@end
