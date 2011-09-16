//
//  INFSmartFoxRoomVariable.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxRoomVariable.h"

@implementation INFSmartFoxRoomVariable

@synthesize name = _name;
@synthesize value = _value;
@synthesize priv = _priv;
@synthesize persistent = _persistent;

+ (id)roomVariableWithInteger:(NSString *)name value:(NSInteger)value
{
	INFSmartFoxRoomVariable *obj = [INFSmartFoxRoomVariable alloc];
	return [[obj initWithParams:name value:[NSNumber numberWithInt:value]] autorelease];
}

+ (id)roomVariableWithFloat:(NSString *)name value:(float)value;
{
	INFSmartFoxRoomVariable *obj = [INFSmartFoxRoomVariable alloc];
	return [[obj initWithParams:name value:[NSNumber numberWithFloat:value]] autorelease];
}

+ (id)roomVariableWithString:(NSString *)name value:(NSString *)value;
{
	INFSmartFoxRoomVariable *obj = [INFSmartFoxRoomVariable alloc];
	return [[obj initWithParams:name value:value] autorelease];
}

+ (id)roomVariableWithBool:(NSString *)name value:(BOOL)value;
{
	INFSmartFoxRoomVariable *obj = [INFSmartFoxRoomVariable alloc];
	return [[obj initWithParams:name value:[NSNumber numberWithBool:value]] autorelease];
}

- (id)initWithParams:(NSString *)name value:(id)value;
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_value = value;
		
		_priv = false;
		_persistent = false;
	}
	
	return self;
}

- (void)dealloc {
	[_name release];
	
    [super dealloc];
}

@end
