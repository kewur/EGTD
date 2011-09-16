//
//  INFSmartFoxSFSEvent.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxSFSEvent.h"


@implementation INFSmartFoxSFSEvent

@synthesize params = _params;

+ (id)sfsEvent:(NSDictionary *)params;
{
	INFSmartFoxSFSEvent *obj = [INFSmartFoxSFSEvent alloc];
	return [[obj initWithParams:params] autorelease];
}

- (id)initWithParams:(NSDictionary *)params;
{
	self = [super init];
	if (self) {
		_params = params;
	}
	
	return self;
}

@end
