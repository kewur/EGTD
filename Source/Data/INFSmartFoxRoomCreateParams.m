//
//  INFSmartFoxRoomCreateParams.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxRoomCreateParams.h"

@implementation INFSmartFoxRoomCreateParams

@synthesize name = _name;
@synthesize password = _password;
@synthesize maxUsers = _maxUsers;
@synthesize maxSpectators = _maxSpectators;
@synthesize isGame = _isGame;
@synthesize exitCurrentRoom = _exitCurrentRoom;
@synthesize uCount = _uCount;
@synthesize extensionName = _extensionName;
@synthesize extensionScript = _extensionScript;

@dynamic vars;

- (NSArray *)vars {
    return _vars;	
}

+ (id)roomCreateParams
{
	INFSmartFoxRoomCreateParams *obj = [INFSmartFoxRoomCreateParams alloc];
	return [[obj initWithParams:nil] autorelease];
}

+ (id)roomCreateParamsWithName:(NSString *)name
{
	INFSmartFoxRoomCreateParams *obj = [INFSmartFoxRoomCreateParams alloc];
	return [[obj initWithParams:name] autorelease];
}

- (id)initWithParams:(NSString *)name
{
	self = [super init];
	if (self) {
		_name = [name copy];
		
		_maxUsers = 0;		
		_password = nil;
		_maxSpectators = 0;
		_isGame = false;
		_exitCurrentRoom = true;
		_uCount = false;
		_vars = nil;
		_extensionName = nil;
		_extensionScript = nil;
	}
	
	return self;
}

- (void)addVar:(INFSmartFoxRoomVariable *)var
{
	if (_vars == nil) {
		_vars = [[NSMutableArray array] retain];
	}
	
	[_vars addObject:var];
}

- (void)dealloc {
	[_name release];
	[_vars release];
	
    [super dealloc];
}

@end
