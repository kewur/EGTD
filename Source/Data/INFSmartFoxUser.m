//
//  INFSmartFoxUser.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxUser.h"

@implementation INFSmartFoxUser

+ (id)user:(NSInteger)id name:(NSString *)name
{
	INFSmartFoxUser *obj = [INFSmartFoxUser alloc];
	return [[obj initWithParams:id name:name] autorelease];
}

- (id)initWithParams:(NSInteger)id name:(NSString *)name
{
	self = [super init];
	if (self) {
		_id = id;		
		_name = [name copy];
		_variables = [[NSMutableDictionary dictionary] retain];
		_isSpec = false;
		_isMod = false;
		_pId = 0;
	}
	
	return self;
}

- (int)getId
{
	return _id;
}

- (NSString *)getName
{
	return _name;
}

- (id)getVariable:(NSString *)varName
{
	return [_variables objectForKey:varName];
}

- (NSMutableDictionary *)getVariables
{
	return _variables;
}

- (void)setVariables:(NSDictionary *)o
{
	NSEnumerator *enumerator = [o keyEnumerator];
	id key;
	
	while ((key = [enumerator nextObject])) {
		if ([[o objectForKey:key] isKindOfClass:[NSNull class]] == NO) {
			[_variables setObject:[o objectForKey:key] forKey:key];
		}
		else {
			[_variables removeObjectForKey:key];
		}		
	}
}

- (void)clearVariables
{
	[_variables removeAllObjects];
}

- (void)setIsSpectator:(BOOL)b
{
	_isSpec = b;
}

- (BOOL)isSpectator
{
	return _isSpec;
}

- (void)setModerator:(BOOL)b
{
	_isMod = b;
}

- (BOOL)isModerator
{
	return _isMod;
}

- (NSInteger)getPlayerId
{
	return _pId;
}

- (void)setPlayerId:(NSInteger)pid
{
	_pId = pid;
}

- (void)dealloc
{
	[_name release];
	[_variables release];
	
    [super dealloc];
}

@end
