//
//  INFSmartFoxZone.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxZone.h"
#import "INFSmartFoxRoom.h"

@implementation INFSmartFoxZone

+ (id)zone:(NSString *)name
{
	INFSmartFoxZone *obj = [INFSmartFoxZone alloc];
	return [[obj initWithParams:name] autorelease];
}

- (id)initWithParams:(NSString *)name
{
	self = [super init];
	if (self) {
		_name = [name copy];
		_roomList = [[NSMutableDictionary dictionary] retain];
	}
	
	return self;
}

- (INFSmartFoxRoom *)getRoom:(NSInteger)id
{
	return [_roomList objectForKey:[NSNumber numberWithInt:id]];
}

- (INFSmartFoxRoom *)getRoomByName:(NSString *)name
{
	INFSmartFoxRoom *room = nil;
	
	NSEnumerator *enumerator = [_roomList objectEnumerator];
	id value;
	
	while ((value = [enumerator nextObject])) {
		if ([value getName] == name) {
			room = value;
			break;
		}
	}	
	
	return room;
}

- (void)dealloc
{	
	[_name release];
	[_roomList release];
	
    [super dealloc];
}

@end
