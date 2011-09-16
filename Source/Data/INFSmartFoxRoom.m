//
//  INFSmartFoxRoom.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxRoom.h"
#import "INFSmartFoxUser.h"


@implementation INFSmartFoxRoom

+ (id)room:(NSInteger)id name:(NSString *)name maxUsers:(NSInteger)maxUsers maxSpectators:(NSInteger)maxSpectators isTemp:(BOOL)isTemp isGame:(BOOL)isGame isPrivate:(BOOL)isPrivate isLimbo:(BOOL)isLimbo userCount:(NSInteger)userCount specCount:(NSInteger)specCount
{
	INFSmartFoxRoom *obj = [INFSmartFoxRoom alloc];
	return [[obj initWithParams:id name:name maxUsers:maxUsers maxSpectators:maxSpectators isTemp:isTemp isGame:isGame isPrivate:isPrivate isLimbo:isLimbo userCount:userCount specCount:specCount] autorelease];
}
	
- (id)initWithParams:(NSInteger)id name:(NSString *)name maxUsers:(NSInteger)maxUsers maxSpectators:(NSInteger)maxSpectators isTemp:(BOOL)isTemp isGame:(BOOL)isGame isPrivate:(BOOL)isPrivate isLimbo:(BOOL)isLimbo userCount:(NSInteger)userCount specCount:(NSInteger)specCount
{
	self = [super init];
	if (self) {
		_id = id;
		_name = [name copy];
		_maxSpectators = maxSpectators;
		_maxUsers = maxUsers;
		_temp = isTemp;
		_game = isGame;
		_priv = isPrivate;
		_limbo = isLimbo;
		
		_userCount = userCount;
		_specCount = specCount;
		_userList = [[NSMutableDictionary dictionary] retain];
		_variables = [[NSMutableDictionary dictionary] retain];		
	}
	
	return self;
}

- (void)addUser:(INFSmartFoxUser *)u id:(NSInteger)id
{
	[_userList setObject:u forKey:[NSNumber numberWithInt:id]];
	
	if (_game && [u isSpectator])
		_specCount++;
	else
		_userCount++;
}

- (void)removeUser:(NSInteger)id
{
	INFSmartFoxUser *u = [_userList objectForKey:[NSNumber numberWithInt:id]];
	
	if (_game && [u isSpectator])
		_specCount--;
	else
		_userCount--;
			
	[_userList removeObjectForKey:[NSNumber numberWithInt:id]];
}

- (NSMutableDictionary *)getUserList
{
	return _userList;
}

- (INFSmartFoxUser *)getUser:(id)userId
{
	INFSmartFoxUser *user = nil;
	
	if ([userId isKindOfClass:[NSNumber class]]) {
		user = [_userList objectForKey:userId];
	}
	else if ([userId isKindOfClass:[NSString class]]) {
		NSEnumerator *enumerator = [_userList objectEnumerator];
		INFSmartFoxUser *value;
		
		while ((value = [enumerator nextObject])) {
			if ([value getName] == userId) {
				user = value;
				break;
			}
		}
	}
	
	return user;
}

- (void)clearUserList
{
	[_userList removeAllObjects];
	_userCount = 0;
	_specCount = 0;	
}

- (id)getVariable:(NSString *)varName
{
	return [_variables objectForKey:varName];
}

- (NSMutableDictionary *)getVariables
{
	return _variables;
}

- (void)setVariables:(NSDictionary *)vars
{
	[_variables setDictionary:vars];
}

- (void)setUserList:(NSDictionary *)uList
{
	[_userList setDictionary:uList];
}

- (void)clearVariables
{
	[_variables removeAllObjects];
}

- (NSString *)getName
{
	return _name;
}

- (NSInteger)getId
{
	return _id;
}

- (BOOL)isTemp
{
	return _temp;
}

- (BOOL)isGame
{
	return _game;
}

- (BOOL)isPrivate
{
	return _priv;
}

- (NSInteger)getUserCount
{
	return _userCount;
}

- (NSInteger)getSpectatorCount
{
	return _specCount;
}

- (NSInteger)getMaxUsers
{
	return _maxUsers;
}

- (NSInteger)getMaxSpectators
{
	return _maxSpectators;
}

- (void)setMyPlayerIndex:(NSInteger)id
{
	_myPlayerIndex = id;
}

- (NSInteger)getMyPlayerIndex
{
	return _myPlayerIndex;
}

- (void)setIsLimbo:(BOOL)b
{
	_limbo = b;
}

- (BOOL)isLimbo
{
	return _limbo;
}

- (void)setUserCount:(NSInteger)n
{
	_userCount = n;
}

- (void)setSpectatorCount:(NSInteger)n
{
	_specCount = n;
}

- (void)dealloc
{
	[_name release];
	[_userList release];
	[_variables release];
	
    [super dealloc];
}

@end
