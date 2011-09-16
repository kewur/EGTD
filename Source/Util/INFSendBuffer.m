//
//  INFSendBuffer.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSendBuffer.h"

@implementation INFSendBuffer

@synthesize sendPos;

+ (id)dataWithNSData:(NSData *)newData;
{
	INFSendBuffer *obj = [INFSendBuffer alloc];
	return [[obj initWithData:newData] autorelease];
}

- (id)initWithData:(NSData *)newData
{
	self = [super init];
    if (self) {
		embeddedData = [[NSMutableData dataWithData:newData] retain];
		sendPos = 0;
	}
	
	return self;
}

- (void)consumeData:(NSInteger)length {
	sendPos += length;
}

- (void)dealloc {
	[embeddedData release];
	
    [super dealloc];
}

- (const void *)bytes
{
	return [embeddedData bytes];
}

- (NSUInteger)length
{
	return [embeddedData length];
}

- (void *)mutableBytes
{
	return [embeddedData mutableBytes];
}

- (void)setLength:(NSUInteger)length
{
	[embeddedData setLength:length];
}

@end
